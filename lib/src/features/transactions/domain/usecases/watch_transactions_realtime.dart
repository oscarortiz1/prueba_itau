import '../entities/transaction_realtime_event.dart';
import '../repositories/transactions_repository.dart';

class WatchTransactionsRealtime {
  WatchTransactionsRealtime(this._repository);

  final TransactionsRepository _repository;

  Stream<TransactionRealtimeEvent> call() {
    return _repository.watchTransactionsRealtime();
  }
}
