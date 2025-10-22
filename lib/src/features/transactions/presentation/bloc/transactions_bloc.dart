import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/transaction_payload.dart';
import '../../domain/usecases/create_transaction.dart';
import '../../domain/usecases/delete_transaction.dart';
import '../../domain/usecases/get_pending_operations_count.dart';
import '../../domain/usecases/get_transactions.dart';
import '../../domain/usecases/sync_pending_transactions.dart';
import '../../domain/usecases/update_transaction.dart';

part 'transactions_event.dart';
part 'transactions_state.dart';

class TransactionsBloc extends Bloc<TransactionsEvent, TransactionsState> {
  TransactionsBloc({
    required GetTransactions getTransactions,
    required CreateTransaction createTransaction,
    required UpdateTransaction updateTransaction,
    required DeleteTransaction deleteTransaction,
    required SyncPendingTransactions syncPendingTransactions,
    required GetPendingOperationsCount getPendingOperationsCount,
    required NetworkInfo networkInfo,
  })  : _getTransactions = getTransactions,
        _createTransaction = createTransaction,
        _updateTransaction = updateTransaction,
        _deleteTransaction = deleteTransaction,
        _syncPendingTransactions = syncPendingTransactions,
        _getPendingOperationsCount = getPendingOperationsCount,
        _networkInfo = networkInfo,
        super(const TransactionsState()) {
    on<TransactionsLoaded>(_onLoaded);
    on<TransactionCreateRequested>(_onCreateRequested);
    on<TransactionUpdateRequested>(_onUpdateRequested);
    on<TransactionDeleteRequested>(_onDeleteRequested);
    on<TransactionsConnectionChanged>(_onConnectionChanged);
    on<TransactionsSyncRequested>(_onSyncRequested);

    _connectionSubscription = _networkInfo.onStatusChange.listen(
      (isConnected) => add(TransactionsConnectionChanged(isConnected)),
    );
  }

  final GetTransactions _getTransactions;
  final CreateTransaction _createTransaction;
  final UpdateTransaction _updateTransaction;
  final DeleteTransaction _deleteTransaction;
  final SyncPendingTransactions _syncPendingTransactions;
  final GetPendingOperationsCount _getPendingOperationsCount;
  final NetworkInfo _networkInfo;
  late final StreamSubscription<bool> _connectionSubscription;

  @override
  Future<void> close() {
    _connectionSubscription.cancel();
    return super.close();
  }

  Future<void> _onLoaded(TransactionsLoaded event, Emitter<TransactionsState> emit) async {
    emit(state.copyWith(status: TransactionsStatus.loading, clearError: true));

    final isConnected = await _networkInfo.isConnected;
    try {
      final transactions = await _getTransactions();
      final pendingCount = await _getPendingOperationsCount();
      emit(
        state.copyWith(
          status: TransactionsStatus.success,
          transactions: _sorted(transactions),
          clearError: true,
          isOffline: !isConnected,
          pendingOperations: pendingCount,
          isSyncing: false,
        ),
      );
    } on AppException catch (error) {
      final pendingCount = await _getPendingOperationsCount();
      emit(state.copyWith(
        status: TransactionsStatus.failure,
        errorMessage: error.message,
        isOffline: !isConnected,
        pendingOperations: pendingCount,
        isSyncing: false,
      ));
    } catch (_) {
      final pendingCount = await _getPendingOperationsCount();
      emit(state.copyWith(
        status: TransactionsStatus.failure,
        errorMessage: 'No se pudieron cargar las transacciones.',
        isOffline: !isConnected,
        pendingOperations: pendingCount,
        isSyncing: false,
      ));
    }
  }

  Future<void> _onCreateRequested(
    TransactionCreateRequested event,
    Emitter<TransactionsState> emit,
  ) async {
    emit(state.copyWith(isProcessing: true, clearError: true));

    try {
      final transaction = await _createTransaction(event.payload);
      final updatedList = List<Transaction>.from(state.transactions)
        ..removeWhere((item) => item.id == transaction.id)
        ..add(transaction);
      final pendingCount = await _getPendingOperationsCount();
      emit(
        state.copyWith(
          isProcessing: false,
          transactions: _sorted(updatedList),
          status: TransactionsStatus.success,
          pendingOperations: pendingCount,
        ),
      );
    } on AppException catch (error) {
      final pendingCount = await _getPendingOperationsCount();
      emit(state.copyWith(
        isProcessing: false,
        errorMessage: error.message,
        pendingOperations: pendingCount,
      ));
    } catch (_) {
      final pendingCount = await _getPendingOperationsCount();
      emit(state.copyWith(
        isProcessing: false,
        errorMessage: 'No se pudo crear la transaccion.',
        pendingOperations: pendingCount,
      ));
    }
  }

  Future<void> _onUpdateRequested(
    TransactionUpdateRequested event,
    Emitter<TransactionsState> emit,
  ) async {
    emit(state.copyWith(isProcessing: true, clearError: true));

    try {
      final transaction = await _updateTransaction(event.id, event.payload);
      final updatedList = state.transactions
          .map((item) => item.id == transaction.id ? transaction : item)
          .toList();
      final pendingCount = await _getPendingOperationsCount();
      emit(
        state.copyWith(
          isProcessing: false,
          transactions: _sorted(updatedList),
          status: TransactionsStatus.success,
          pendingOperations: pendingCount,
        ),
      );
    } on AppException catch (error) {
      final pendingCount = await _getPendingOperationsCount();
      emit(state.copyWith(
        isProcessing: false,
        errorMessage: error.message,
        pendingOperations: pendingCount,
      ));
    } catch (_) {
      final pendingCount = await _getPendingOperationsCount();
      emit(state.copyWith(
        isProcessing: false,
        errorMessage: 'No se pudo actualizar la transaccion.',
        pendingOperations: pendingCount,
      ));
    }
  }

  Future<void> _onDeleteRequested(
    TransactionDeleteRequested event,
    Emitter<TransactionsState> emit,
  ) async {
    emit(state.copyWith(isProcessing: true, clearError: true));

    try {
      await _deleteTransaction(event.id);
      final updatedList = state.transactions.where((item) => item.id != event.id).toList();
      final pendingCount = await _getPendingOperationsCount();
      emit(
        state.copyWith(
          isProcessing: false,
          transactions: _sorted(updatedList),
          status: TransactionsStatus.success,
          pendingOperations: pendingCount,
        ),
      );
    } on AppException catch (error) {
      final pendingCount = await _getPendingOperationsCount();
      emit(state.copyWith(
        isProcessing: false,
        errorMessage: error.message,
        pendingOperations: pendingCount,
      ));
    } catch (_) {
      final pendingCount = await _getPendingOperationsCount();
      emit(state.copyWith(
        isProcessing: false,
        errorMessage: 'No se pudo eliminar la transaccion.',
        pendingOperations: pendingCount,
      ));
    }
  }

  Future<void> _onConnectionChanged(
    TransactionsConnectionChanged event,
    Emitter<TransactionsState> emit,
  ) async {
    final pendingCount = await _getPendingOperationsCount();
    emit(state.copyWith(
      isOffline: !event.isConnected,
      pendingOperations: pendingCount,
    ));

    if (event.isConnected && pendingCount > 0) {
      add(const TransactionsSyncRequested());
    }
  }

  Future<void> _onSyncRequested(
    TransactionsSyncRequested event,
    Emitter<TransactionsState> emit,
  ) async {
    if (state.isSyncing) return;
    emit(state.copyWith(isSyncing: true));

    try {
      final synced = await _syncPendingTransactions();
      final pendingCount = await _getPendingOperationsCount();
      emit(state.copyWith(
        isSyncing: false,
        status: TransactionsStatus.success,
        transactions: _sorted(synced),
        pendingOperations: pendingCount,
        clearError: true,
      ));
    } on AppException catch (error) {
      final pendingCount = await _getPendingOperationsCount();
      emit(state.copyWith(
        isSyncing: false,
        errorMessage: error.message,
        pendingOperations: pendingCount,
      ));
    } catch (_) {
      final pendingCount = await _getPendingOperationsCount();
      emit(state.copyWith(
        isSyncing: false,
        errorMessage: 'No se pudo sincronizar las transacciones pendientes.',
        pendingOperations: pendingCount,
      ));
    }
  }

  List<Transaction> _sorted(List<Transaction> transactions) {
    final list = List<Transaction>.from(transactions);
    list.sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
    return list;
  }
}
