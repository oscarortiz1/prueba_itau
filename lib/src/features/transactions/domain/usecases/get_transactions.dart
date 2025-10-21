import '../entities/transaction.dart';
import '../repositories/transactions_repository.dart';

class GetTransactions {
  GetTransactions(this.repository);

  final TransactionsRepository repository;

  Future<List<Transaction>> call() {
    return repository.fetchTransactions();
  }
}
