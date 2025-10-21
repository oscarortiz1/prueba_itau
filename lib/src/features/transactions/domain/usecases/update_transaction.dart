import '../entities/transaction.dart';
import '../entities/transaction_payload.dart';
import '../repositories/transactions_repository.dart';

class UpdateTransaction {
  UpdateTransaction(this.repository);

  final TransactionsRepository repository;

  Future<Transaction> call(String id, TransactionUpdatePayload payload) {
    return repository.updateTransaction(id, payload);
  }
}
