part of 'transactions_bloc.dart';

abstract class TransactionsEvent extends Equatable {
  const TransactionsEvent();

  @override
  List<Object?> get props => [];
}

class TransactionsLoaded extends TransactionsEvent {
  const TransactionsLoaded();
}

class TransactionCreateRequested extends TransactionsEvent {
  const TransactionCreateRequested(this.payload);

  final TransactionCreatePayload payload;

  @override
  List<Object?> get props => [payload];
}

class TransactionUpdateRequested extends TransactionsEvent {
  const TransactionUpdateRequested(this.id, this.payload);

  final String id;
  final TransactionUpdatePayload payload;

  @override
  List<Object?> get props => [id, payload];
}

class TransactionDeleteRequested extends TransactionsEvent {
  const TransactionDeleteRequested(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}
