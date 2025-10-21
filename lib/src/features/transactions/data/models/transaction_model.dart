import '../../domain/entities/transaction.dart';

class TransactionModel extends Transaction {
  const TransactionModel({
    required super.id,
    required super.userId,
    required super.type,
    required super.title,
    required super.amount,
    super.category,
    required super.occurredAt,
    required super.createdAt,
    required super.updatedAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    final id = (json['_id'] ?? json['id']) as String?;

    if (id == null || id.isEmpty) {
      throw const FormatException('Transaccion sin identificador.');
    }

    return TransactionModel(
      id: id,
      userId: json['userId'] as String,
      type: TransactionTypeMapper.fromString(json['type'] as String),
      title: json['title'] as String,
      amount: (json['amount'] as num).toDouble(),
      category: json['category'] as String?,
      occurredAt: DateTime.parse(json['occurredAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'id': id,
      'userId': userId,
      'type': type.value,
      'title': title,
      'amount': amount,
      'category': category,
      'occurredAt': occurredAt.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
