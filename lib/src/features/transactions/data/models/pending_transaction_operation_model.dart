import '../../domain/entities/transaction.dart';
import '../../domain/entities/transaction_payload.dart';

enum PendingTransactionOperationType { create, update, delete }

extension PendingTransactionOperationTypeX on PendingTransactionOperationType {
  String get value => switch (this) {
        PendingTransactionOperationType.create => 'create',
        PendingTransactionOperationType.update => 'update',
        PendingTransactionOperationType.delete => 'delete',
      };

  static PendingTransactionOperationType fromValue(String raw) {
    switch (raw.toLowerCase()) {
      case 'create':
        return PendingTransactionOperationType.create;
      case 'update':
        return PendingTransactionOperationType.update;
      case 'delete':
        return PendingTransactionOperationType.delete;
      default:
        throw ArgumentError('Tipo de operacion desconocido: $raw');
    }
  }
}

class PendingTransactionOperationModel {
  const PendingTransactionOperationModel({
    required this.type,
    this.id,
    this.localId,
    this.createPayload,
    this.updatePayload,
  });

  factory PendingTransactionOperationModel.create({
    required String localId,
    required TransactionCreatePayload payload,
  }) {
    return PendingTransactionOperationModel(
      type: PendingTransactionOperationType.create,
      localId: localId,
      createPayload: _serializeCreatePayload(payload),
    );
  }

  factory PendingTransactionOperationModel.update({
    required String id,
    required TransactionUpdatePayload payload,
  }) {
    return PendingTransactionOperationModel(
      type: PendingTransactionOperationType.update,
      id: id,
      updatePayload: _serializeUpdatePayload(payload),
    );
  }

  factory PendingTransactionOperationModel.delete({
    required String id,
  }) {
    return PendingTransactionOperationModel(
      type: PendingTransactionOperationType.delete,
      id: id,
    );
  }

  factory PendingTransactionOperationModel.fromJson(Map<String, dynamic> json) {
    final type = PendingTransactionOperationTypeX.fromValue(json['type'] as String);
    return PendingTransactionOperationModel(
      type: type,
      id: json['id'] as String?,
      localId: json['localId'] as String?,
      createPayload: json['createPayload'] == null
          ? null
          : Map<String, dynamic>.from(json['createPayload'] as Map),
      updatePayload: json['updatePayload'] == null
          ? null
          : Map<String, dynamic>.from(json['updatePayload'] as Map),
    );
  }

  final PendingTransactionOperationType type;
  final String? id;
  final String? localId;
  final Map<String, dynamic>? createPayload;
  final Map<String, dynamic>? updatePayload;

  Map<String, dynamic> toJson() {
    return {
      'type': type.value,
      'id': id,
      'localId': localId,
      if (createPayload != null) 'createPayload': createPayload,
      if (updatePayload != null) 'updatePayload': updatePayload,
    };
  }

  TransactionCreatePayload toCreatePayload() {
    final payload = createPayload;
    if (payload == null) {
      throw StateError('No hay payload de creacion.');
    }
    return TransactionCreatePayload(
      type: TransactionTypeMapper.fromString(payload['type'] as String),
      title: payload['title'] as String,
      amount: (payload['amount'] as num).toDouble(),
      category: payload['category'] as String?,
      occurredAt: DateTime.parse(payload['occurredAt'] as String),
    );
  }

  TransactionUpdatePayload toUpdatePayload() {
    final payload = updatePayload;
    if (payload == null) {
      throw StateError('No hay payload de actualizacion.');
    }
    return TransactionUpdatePayload(
      type: payload.containsKey('type')
          ? TransactionTypeMapper.fromString(payload['type'] as String)
          : null,
      title: payload['title'] as String?,
      amount: payload['amount'] == null ? null : (payload['amount'] as num).toDouble(),
      category: payload['category'] as String?,
      occurredAt: payload['occurredAt'] == null
          ? null
          : DateTime.parse(payload['occurredAt'] as String),
    );
  }

  PendingTransactionOperationModel mergeWithUpdate(TransactionUpdatePayload payload) {
    final base = Map<String, dynamic>.from(updatePayload ?? const {});
    if (payload.type != null) {
      base['type'] = payload.type!.value;
    }
    if (payload.title != null) {
      base['title'] = payload.title;
    }
    if (payload.amount != null) {
      base['amount'] = payload.amount;
    }
    if (payload.category != null) {
      base['category'] = payload.category;
    }
    if (payload.occurredAt != null) {
      base['occurredAt'] = payload.occurredAt!.toIso8601String();
    }

    return PendingTransactionOperationModel(
      type: type,
      id: id,
      localId: localId,
      createPayload: createPayload,
      updatePayload: base.isEmpty ? null : base,
    );
  }

  PendingTransactionOperationModel applyUpdateToCreate(TransactionUpdatePayload payload) {
    final base = Map<String, dynamic>.from(createPayload ?? const {});
    if (payload.type != null) {
      base['type'] = payload.type!.value;
    }
    if (payload.title != null) {
      base['title'] = payload.title;
    }
    if (payload.amount != null) {
      base['amount'] = payload.amount;
    }
    if (payload.category != null) {
      base['category'] = payload.category;
    }
    if (payload.occurredAt != null) {
      base['occurredAt'] = payload.occurredAt!.toIso8601String();
    }

    return PendingTransactionOperationModel(
      type: type,
      id: id,
      localId: localId,
      createPayload: base,
      updatePayload: updatePayload,
    );
  }

  PendingTransactionOperationModel copyWith({
    PendingTransactionOperationType? type,
    String? id,
    String? localId,
    Map<String, dynamic>? createPayload,
    Map<String, dynamic>? updatePayload,
  }) {
    return PendingTransactionOperationModel(
      type: type ?? this.type,
      id: id ?? this.id,
      localId: localId ?? this.localId,
      createPayload: createPayload ?? this.createPayload,
      updatePayload: updatePayload ?? this.updatePayload,
    );
  }
}

Map<String, dynamic> _serializeCreatePayload(TransactionCreatePayload payload) {
  return {
    'type': payload.type.value,
    'title': payload.title,
    'amount': payload.amount,
    'category': payload.category,
    'occurredAt': payload.occurredAt.toIso8601String(),
  };
}

Map<String, dynamic> _serializeUpdatePayload(TransactionUpdatePayload payload) {
  final map = <String, dynamic>{};
  if (payload.type != null) {
    map['type'] = payload.type!.value;
  }
  if (payload.title != null) {
    map['title'] = payload.title;
  }
  if (payload.amount != null) {
    map['amount'] = payload.amount;
  }
  if (payload.category != null) {
    map['category'] = payload.category;
  }
  if (payload.occurredAt != null) {
    map['occurredAt'] = payload.occurredAt!.toIso8601String();
  }
  return map;
}
