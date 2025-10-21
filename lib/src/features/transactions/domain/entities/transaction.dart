import 'package:equatable/equatable.dart';

enum TransactionType { income, expense }

extension TransactionTypeMapper on TransactionType {
  String get value => this == TransactionType.income ? 'income' : 'expense';

  static TransactionType fromString(String raw) {
    return raw.toLowerCase() == 'income' ? TransactionType.income : TransactionType.expense;
  }
}

class Transaction extends Equatable {
  const Transaction({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.amount,
    this.category,
    required this.occurredAt,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String userId;
  final TransactionType type;
  final String title;
  final double amount;
  final String? category;
  final DateTime occurredAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  List<Object?> get props => [id, userId, type, title, amount, category, occurredAt, createdAt, updatedAt];
}
