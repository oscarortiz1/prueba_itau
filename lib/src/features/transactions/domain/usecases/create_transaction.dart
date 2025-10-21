import '../entities/transaction.dart';
import '../entities/transaction_payload.dart';
import '../repositories/transactions_repository.dart';

class CreateTransaction {
  CreateTransaction(this.repository);

  final TransactionsRepository repository;

  Future<Transaction> call(TransactionCreatePayload payload) {
    return repository.createTransaction(payload);
  }
}
