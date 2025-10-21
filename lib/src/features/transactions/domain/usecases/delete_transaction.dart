import '../repositories/transactions_repository.dart';

class DeleteTransaction {
  DeleteTransaction(this.repository);

  final TransactionsRepository repository;

  Future<void> call(String id) {
    return repository.deleteTransaction(id);
  }
}
