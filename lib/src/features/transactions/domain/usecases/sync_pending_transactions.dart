import '../entities/transaction.dart';
import '../repositories/transactions_repository.dart';

class SyncPendingTransactions {
  SyncPendingTransactions(this.repository);

  final TransactionsRepository repository;

  Future<List<Transaction>> call() {
    return repository.syncPendingTransactions();
  }
}
