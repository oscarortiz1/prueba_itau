part of 'transactions_bloc.dart';

enum TransactionsStatus { initial, loading, success, failure }

class TransactionsState extends Equatable {
  const TransactionsState({
    this.status = TransactionsStatus.initial,
    this.transactions = const [],
    this.errorMessage,
    this.isProcessing = false,
    this.isOffline = false,
    this.pendingOperations = 0,
    this.isSyncing = false,
  });

  final TransactionsStatus status;
  final List<Transaction> transactions;
  final String? errorMessage;
  final bool isProcessing;
  final bool isOffline;
  final int pendingOperations;
  final bool isSyncing;

  bool get isLoading => status == TransactionsStatus.loading;
  bool get hasError => errorMessage != null && errorMessage!.isNotEmpty;
  bool get hasPendingOperations => pendingOperations > 0;

  TransactionsState copyWith({
    TransactionsStatus? status,
    List<Transaction>? transactions,
    String? errorMessage,
    bool? isProcessing,
    bool? isOffline,
    int? pendingOperations,
    bool? isSyncing,
    bool clearError = false,
  }) {
    return TransactionsState(
      status: status ?? this.status,
      transactions: transactions ?? this.transactions,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isProcessing: isProcessing ?? this.isProcessing,
      isOffline: isOffline ?? this.isOffline,
      pendingOperations: pendingOperations ?? this.pendingOperations,
      isSyncing: isSyncing ?? this.isSyncing,
    );
  }

  @override
  List<Object?> get props => [status, transactions, errorMessage, isProcessing, isOffline, pendingOperations, isSyncing];
}
