import '../entities/transaction.dart';
import '../entities/transaction_payload.dart';

abstract class TransactionsRepository {
  Future<List<Transaction>> fetchTransactions();

  Future<Transaction> createTransaction(TransactionCreatePayload payload);

  Future<Transaction> updateTransaction(String id, TransactionUpdatePayload payload);

  Future<void> deleteTransaction(String id);

  Future<List<Transaction>> syncPendingTransactions();

  Future<int> pendingOperationsCount();
}
