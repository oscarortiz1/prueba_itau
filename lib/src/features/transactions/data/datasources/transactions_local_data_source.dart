import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/pending_transaction_operation_model.dart';
import '../models/transaction_model.dart';

abstract class TransactionsLocalDataSource {
  Future<List<TransactionModel>> loadTransactions();

  Future<void> saveTransactions(List<TransactionModel> transactions);

  Future<List<PendingTransactionOperationModel>> loadPendingOperations();

  Future<void> savePendingOperations(List<PendingTransactionOperationModel> operations);
}

class TransactionsLocalDataSourceImpl implements TransactionsLocalDataSource {
  TransactionsLocalDataSourceImpl({required SharedPreferences prefs}) : _prefs = prefs;

  final SharedPreferences _prefs;

  static const _transactionsKey = 'transactions.cached.list';
  static const _pendingOpsKey = 'transactions.pending.operations';

  @override
  Future<List<TransactionModel>> loadTransactions() async {
    final raw = _prefs.getString(_transactionsKey);
    if (raw == null || raw.isEmpty) {
      return [];
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
    return decoded
      .whereType<Map<String, dynamic>>()
      .map(TransactionModel.fromJson)
      .toList(growable: true);
      }
    } catch (_) {
    }

    await _prefs.remove(_transactionsKey);
    return [];
  }

  @override
  Future<void> saveTransactions(List<TransactionModel> transactions) async {
    final encoded = jsonEncode(transactions.map((model) => model.toJson()).toList());
    await _prefs.setString(_transactionsKey, encoded);
  }

  @override
  Future<List<PendingTransactionOperationModel>> loadPendingOperations() async {
    final raw = _prefs.getString(_pendingOpsKey);
    if (raw == null || raw.isEmpty) {
      return [];
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded
            .whereType<Map<String, dynamic>>()
            .map(PendingTransactionOperationModel.fromJson)
            .toList(growable: true);
      }
    } catch (_) {
    }

    await _prefs.remove(_pendingOpsKey);
    return [];
  }

  @override
  Future<void> savePendingOperations(List<PendingTransactionOperationModel> operations) async {
    if (operations.isEmpty) {
      await _prefs.remove(_pendingOpsKey);
      return;
    }

    final encoded = jsonEncode(operations.map((op) => op.toJson()).toList());
    await _prefs.setString(_pendingOpsKey, encoded);
  }
}
