part of 'transactions_bloc.dart';

enum TransactionsStatus { initial, loading, success, failure }

class TransactionsState extends Equatable {
  const TransactionsState({
    this.status = TransactionsStatus.initial,
    this.transactions = const [],
    this.errorMessage,
    this.isProcessing = false,
  });

  final TransactionsStatus status;
  final List<Transaction> transactions;
  final String? errorMessage;
  final bool isProcessing;

  bool get isLoading => status == TransactionsStatus.loading;
  bool get hasError => errorMessage != null && errorMessage!.isNotEmpty;

  TransactionsState copyWith({
    TransactionsStatus? status,
    List<Transaction>? transactions,
    String? errorMessage,
    bool? isProcessing,
    bool clearError = false,
  }) {
    return TransactionsState(
      status: status ?? this.status,
      transactions: transactions ?? this.transactions,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isProcessing: isProcessing ?? this.isProcessing,
    );
  }

  @override
  List<Object?> get props => [status, transactions, errorMessage, isProcessing];
}
