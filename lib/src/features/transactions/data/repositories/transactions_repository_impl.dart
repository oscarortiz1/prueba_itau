import '../../../../core/errors/app_exception.dart';
import '../../../../core/session/session_manager.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/transaction_payload.dart';
import '../../domain/repositories/transactions_repository.dart';
import '../datasources/transactions_remote_data_source.dart';

class TransactionsRepositoryImpl implements TransactionsRepository {
  TransactionsRepositoryImpl({
    required TransactionsRemoteDataSource remoteDataSource,
    required SessionManager sessionManager,
  })  : _remoteDataSource = remoteDataSource,
        _sessionManager = sessionManager;

  final TransactionsRemoteDataSource _remoteDataSource;
  final SessionManager _sessionManager;

  String get _token {
    final token = _sessionManager.token;
    if (token == null || token.isEmpty) {
      throw AppException('Tu sesion ha expirado. Inicia sesion nuevamente.');
    }
    return token;
  }

  @override
  Future<List<Transaction>> fetchTransactions() {
    return _remoteDataSource.fetchTransactions(token: _token);
  }

  @override
  Future<Transaction> createTransaction(TransactionCreatePayload payload) {
    return _remoteDataSource.createTransaction(token: _token, payload: payload);
  }

  @override
  Future<Transaction> updateTransaction(String id, TransactionUpdatePayload payload) {
    if (!payload.hasChanges) {
      throw AppException('No hay cambios para actualizar.');
    }
    return _remoteDataSource.updateTransaction(token: _token, id: id, payload: payload);
  }

  @override
  Future<void> deleteTransaction(String id) {
    return _remoteDataSource.deleteTransaction(token: _token, id: id);
  }
}
