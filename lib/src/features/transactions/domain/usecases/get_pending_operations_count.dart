import '../repositories/transactions_repository.dart';

class GetPendingOperationsCount {
  GetPendingOperationsCount(this.repository);

  final TransactionsRepository repository;

  Future<int> call() {
    return repository.pendingOperationsCount();
  }
}
