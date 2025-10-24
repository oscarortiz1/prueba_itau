import 'package:equatable/equatable.dart';

import 'transaction.dart';

enum TransactionRealtimeEventType { created, updated, deleted }

class TransactionRealtimeEvent extends Equatable {
  const TransactionRealtimeEvent._({
    required this.type,
    this.transaction,
    this.transactionId,
  });

  factory TransactionRealtimeEvent.created(Transaction transaction) {
    return TransactionRealtimeEvent._(
      type: TransactionRealtimeEventType.created,
      transaction: transaction,
      transactionId: transaction.id,
    );
  }

  factory TransactionRealtimeEvent.updated(Transaction transaction) {
    return TransactionRealtimeEvent._(
      type: TransactionRealtimeEventType.updated,
      transaction: transaction,
      transactionId: transaction.id,
    );
  }

  factory TransactionRealtimeEvent.deleted(String id) {
    return TransactionRealtimeEvent._(
      type: TransactionRealtimeEventType.deleted,
      transactionId: id,
    );
  }

  final TransactionRealtimeEventType type;
  final Transaction? transaction;
  final String? transactionId;

  bool get hasTransaction => transaction != null;

  @override
  List<Object?> get props => [type, transaction, transactionId];
}
