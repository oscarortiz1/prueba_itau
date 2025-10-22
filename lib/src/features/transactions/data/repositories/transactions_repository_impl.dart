import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/session/session_manager.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/transaction_payload.dart';
import '../../domain/repositories/transactions_repository.dart';
import '../datasources/transactions_local_data_source.dart';
import '../datasources/transactions_remote_data_source.dart';
import '../models/pending_transaction_operation_model.dart';
import '../models/transaction_model.dart';

class TransactionsRepositoryImpl implements TransactionsRepository {
  TransactionsRepositoryImpl({
    required TransactionsRemoteDataSource remoteDataSource,
    required TransactionsLocalDataSource localDataSource,
    required SessionManager sessionManager,
    required NetworkInfo networkInfo,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource,
        _sessionManager = sessionManager,
        _networkInfo = networkInfo;

  final TransactionsRemoteDataSource _remoteDataSource;
  final TransactionsLocalDataSource _localDataSource;
  final SessionManager _sessionManager;
  final NetworkInfo _networkInfo;

  String get _token {
    final token = _sessionManager.token;
    if (token == null || token.isEmpty) {
      throw AppException('Tu sesion ha expirado. Inicia sesion nuevamente.');
    }
    return token;
  }

  @override
  Future<List<Transaction>> fetchTransactions() async {
    final isConnected = await _networkInfo.isConnected;

    if (isConnected) {
      try {
        await _syncPendingTransactionsInternal();
      } catch (_) {
      }

      try {
        final remote = await _remoteDataSource.fetchTransactions(token: _token);
        await _localDataSource.saveTransactions(_sortModels(remote));
        return _sortTransactions(remote);
      } on AppException {
        final cached = await _localDataSource.loadTransactions();
        if (cached.isNotEmpty) {
          return _sortTransactions(cached);
        }
        rethrow;
      } catch (_) {
        final cached = await _localDataSource.loadTransactions();
        if (cached.isNotEmpty) {
          return _sortTransactions(cached);
        }
        rethrow;
      }
    }

    final cached = await _localDataSource.loadTransactions();
    if (cached.isNotEmpty) {
      return _sortTransactions(cached);
    }

    throw AppException('Sin conexion. No hay datos almacenados.');
  }

  @override
  Future<Transaction> createTransaction(TransactionCreatePayload payload) async {
    if (await _networkInfo.isConnected) {
      try {
        final transaction = await _remoteDataSource.createTransaction(token: _token, payload: payload);
        await _upsertLocal(transaction);
        await _removePendingForId(transaction.id);
        return transaction;
      } on NetworkException {
      }
    }

    return _createOffline(payload);
  }

  @override
  Future<Transaction> updateTransaction(String id, TransactionUpdatePayload payload) async {
    if (!payload.hasChanges) {
      throw AppException('No hay cambios para actualizar.');
    }

    if (await _networkInfo.isConnected) {
      try {
        final transaction = await _remoteDataSource.updateTransaction(token: _token, id: id, payload: payload);
        await _upsertLocal(transaction);
        await _removePendingForId(id);
        return transaction;
      } on NetworkException {
      }
    }

    return _updateOffline(id, payload);
  }

  @override
  Future<void> deleteTransaction(String id) async {
    if (await _networkInfo.isConnected) {
      try {
        await _remoteDataSource.deleteTransaction(token: _token, id: id);
        await _removeLocal(id);
        await _removePendingForId(id);
        return;
      } on NetworkException {
      }
    }

    await _deleteOffline(id);
  }

  @override
  Future<List<Transaction>> syncPendingTransactions() async {
    final models = await _syncPendingTransactionsInternal();
    return _sortTransactions(models);
  }

  @override
  Future<int> pendingOperationsCount() async {
    final pending = await _localDataSource.loadPendingOperations();
    return pending.length;
  }

  Future<void> _upsertLocal(TransactionModel model) async {
    await _updateLocalTransactions((transactions) {
      final index = transactions.indexWhere((item) => item.id == model.id);
      if (index != -1) {
        transactions[index] = model;
      } else {
        transactions.add(model);
      }
    });
  }

  Future<void> _removeLocal(String id) async {
    await _updateLocalTransactions((transactions) {
      transactions.removeWhere((item) => item.id == id);
    });
  }

  Future<void> _removePendingForId(String id) async {
    final pending = await _localDataSource.loadPendingOperations();
    final filtered = pending
        .where((op) =>
            !(op.id == id || (op.localId == id && op.type == PendingTransactionOperationType.create)))
        .toList();
    if (filtered.length != pending.length) {
      await _localDataSource.savePendingOperations(filtered);
    }
  }

  Future<List<TransactionModel>> _syncPendingTransactionsInternal() async {
    if (!await _networkInfo.isConnected) {
      return _localDataSource.loadTransactions();
    }

    final pending = await _localDataSource.loadPendingOperations();
    if (pending.isEmpty) {
      return _localDataSource.loadTransactions();
    }

    final transactions = await _localDataSource.loadTransactions();
    final remaining = <PendingTransactionOperationModel>[];

    for (final operation in pending) {
      try {
        switch (operation.type) {
          case PendingTransactionOperationType.create:
            final payload = operation.toCreatePayload();
            final created = await _remoteDataSource.createTransaction(
              token: _token,
              payload: payload,
            );
            transactions.removeWhere((item) => item.id == (operation.localId ?? created.id));
            transactions.add(created);
            break;
          case PendingTransactionOperationType.update:
            final updatePayload = operation.toUpdatePayload();
            final updated = await _remoteDataSource.updateTransaction(
              token: _token,
              id: operation.id!,
              payload: updatePayload,
            );
            final index = transactions.indexWhere((item) => item.id == updated.id);
            if (index != -1) {
              transactions[index] = updated;
            } else {
              transactions.add(updated);
            }
            break;
          case PendingTransactionOperationType.delete:
            await _remoteDataSource.deleteTransaction(
              token: _token,
              id: operation.id!,
            );
            transactions.removeWhere((item) => item.id == operation.id);
            break;
        }
      } on AppException {
        remaining.add(operation);
      } catch (_) {
        remaining.add(operation);
      }
    }

    await _localDataSource.saveTransactions(_sortModels(transactions));
    await _localDataSource.savePendingOperations(remaining);
    return _localDataSource.loadTransactions();
  }

  Future<void> _updateLocalTransactions(
    void Function(List<TransactionModel>) update,
  ) async {
    final current = await _localDataSource.loadTransactions();
    update(current);
    await _localDataSource.saveTransactions(_sortModels(current));
  }

  Future<Transaction> _createOffline(TransactionCreatePayload payload) async {
    final localId = _generateLocalId();
    final model = _buildLocalTransaction(localId, payload);
    final transactions = await _localDataSource.loadTransactions();
    transactions.add(model);
    await _localDataSource.saveTransactions(_sortModels(transactions));

    final pending = await _localDataSource.loadPendingOperations();
    pending.add(PendingTransactionOperationModel.create(localId: localId, payload: payload));
    await _localDataSource.savePendingOperations(pending);

    return model;
  }

  Future<Transaction> _updateOffline(String id, TransactionUpdatePayload payload) async {
    final transactions = await _localDataSource.loadTransactions();
    final index = transactions.indexWhere((item) => item.id == id);
    if (index == -1) {
      throw AppException('La transaccion no existe en cache.');
    }

    final current = transactions[index];
    final updated = TransactionModel(
      id: current.id,
      userId: current.userId,
      type: payload.type ?? current.type,
      title: payload.title ?? current.title,
      amount: payload.amount ?? current.amount,
      category: payload.category ?? current.category,
      occurredAt: payload.occurredAt ?? current.occurredAt,
      createdAt: current.createdAt,
      updatedAt: DateTime.now(),
    );
    transactions[index] = updated;
    await _localDataSource.saveTransactions(_sortModels(transactions));

    final pending = await _localDataSource.loadPendingOperations();
    final createIndex = pending.indexWhere(
      (op) => op.type == PendingTransactionOperationType.create && op.localId == id,
    );

    if (createIndex != -1) {
      pending[createIndex] = pending[createIndex].applyUpdateToCreate(payload);
    } else {
      final updateIndex = pending.indexWhere(
        (op) => op.type == PendingTransactionOperationType.update && op.id == id,
      );
      if (updateIndex != -1) {
        pending[updateIndex] = pending[updateIndex].mergeWithUpdate(payload);
      } else {
        pending.add(PendingTransactionOperationModel.update(id: id, payload: payload));
      }
    }

    await _localDataSource.savePendingOperations(pending);
    return updated;
  }

  Future<void> _deleteOffline(String id) async {
    final transactions = await _localDataSource.loadTransactions();
    transactions.removeWhere((item) => item.id == id);
    await _localDataSource.saveTransactions(_sortModels(transactions));

    final pending = await _localDataSource.loadPendingOperations();
    final createIndex = pending.indexWhere(
      (op) => op.type == PendingTransactionOperationType.create && op.localId == id,
    );
    if (createIndex != -1) {
      pending.removeAt(createIndex);
    } else {
      pending.removeWhere((op) =>
          op.type == PendingTransactionOperationType.update && op.id == id);
      final already = pending.any(
        (op) => op.type == PendingTransactionOperationType.delete && op.id == id,
      );
      if (!already) {
        pending.add(PendingTransactionOperationModel.delete(id: id));
      }
    }

    await _localDataSource.savePendingOperations(pending);
  }

  TransactionModel _buildLocalTransaction(String id, TransactionCreatePayload payload) {
    final now = DateTime.now();
    return TransactionModel(
      id: id,
      userId: _sessionManager.currentUser?.id ?? 'local-user',
      type: payload.type,
      title: payload.title,
      amount: payload.amount,
      category: payload.category,
      occurredAt: payload.occurredAt,
      createdAt: now,
      updatedAt: now,
    );
  }

  String _generateLocalId() => 'local-${DateTime.now().microsecondsSinceEpoch}';

  List<Transaction> _sortTransactions(List<Transaction> source) {
    final copy = List<Transaction>.from(source);
    copy.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return copy;
  }

  List<TransactionModel> _sortModels(List<TransactionModel> source) {
    final copy = List<TransactionModel>.from(source);
    copy.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return copy;
  }
}
