import 'transaction.dart';

class TransactionCreatePayload {
  TransactionCreatePayload({
    required this.type,
    required this.title,
    required this.amount,
    this.category,
    required this.occurredAt,
  });

  final TransactionType type;
  final String title;
  final double amount;
  final String? category;
  final DateTime occurredAt;
}

class TransactionUpdatePayload {
  TransactionUpdatePayload({
    this.type,
    this.title,
    this.amount,
    this.category,
    this.occurredAt,
  });

  final TransactionType? type;
  final String? title;
  final double? amount;
  final String? category;
  final DateTime? occurredAt;

  bool get hasChanges =>
      type != null || title != null || amount != null || category != null || occurredAt != null;
}
