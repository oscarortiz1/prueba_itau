import 'dart:async';

import 'package:bloc/bloc.dart';
import 'statistics_event.dart';
import 'statistics_state.dart';
import 'package:prueba_itau/src/features/transactions/presentation/bloc/transactions_bloc.dart';
import 'package:prueba_itau/src/features/transactions/domain/entities/transaction.dart';
import 'package:prueba_itau/src/features/transactions/domain/usecases/get_transactions.dart';

class StatisticsBloc extends Bloc<StatisticsEvent, StatisticsState> {
  final GetTransactions _getTransactions;
  late List<Transaction> _latestTransactions = const [];

  StatisticsBloc({required TransactionsBloc transactionsBloc, required GetTransactions getTransactions}) : _getTransactions = getTransactions, super(const StatisticsState()) {
    on<LoadStatistics>((event, emit) async {
      try {
        final list = await _getTransactions();
        _recompute(list);
      } catch (_) {
      }
    });

    on<UpdateFilters>((event, emit) async {
      emit(state.copyWith(category: event.category, startDate: event.startDate, endDate: event.endDate, isLoading: true, txPage: 0));
      if (_latestTransactions.isNotEmpty) {
        _recompute(_latestTransactions);
        return;
      }

      try {
        final list = await _getTransactions();
        _latestTransactions = List.unmodifiable(list);
        _recompute(_latestTransactions);
      } catch (_) {
        emit(state.copyWith(isLoading: false));
      }
    });

    on<StatisticsTotalsUpdated>((event, emit) {
      final balance = event.incomes - event.expenses;
      final breakdownList = (event.breakdown ?? []).map<CategoryBreakdown>((raw) {
        final map = raw as Map<String, dynamic>;
        return CategoryBreakdown(
          category: map['category'] as String,
          incomes: (map['incomes'] as num).toDouble(),
          expenses: (map['expenses'] as num).toDouble(),
        );
      }).toList();
      emit(state.copyWith(isLoading: false, totalIncomes: event.incomes, totalExpenses: event.expenses, balance: balance, breakdown: breakdownList));
    });

    on<PageChanged>((event, emit) {
      emit(state.copyWith(txPage: event.page));
    });

    if (transactionsBloc.state.status == TransactionsStatus.success) {
      _latestTransactions = List.unmodifiable(transactionsBloc.state.transactions);
      _recompute(_latestTransactions);
    }

    _txSub = transactionsBloc.stream.listen((txState) {
      if (txState.status == TransactionsStatus.success) {
        _latestTransactions = List.unmodifiable(txState.transactions);
        _recompute(_latestTransactions);
      }
    });
  }

  late final StreamSubscription _txSub;

  void _recompute(List<Transaction> all) {
    final catMap = <String, Map<String, double>>{};
    double incomes = 0;
    double expenses = 0;

    DateTime? startDay;
    DateTime? endDay;
    if (state.startDate != null) {
      final s = state.startDate!;
      startDay = DateTime(s.year, s.month, s.day);
    }
    if (state.endDate != null) {
      final e = state.endDate!;
      endDay = DateTime(e.year, e.month, e.day, 23, 59, 59, 999);
    }

    for (final t in all) {
      if (state.category != null && state.category!.isNotEmpty) {
        if ((t.category ?? '').toLowerCase() != state.category!.toLowerCase()) continue;
      }
      if (startDay != null && t.occurredAt.isBefore(startDay)) continue;
      if (endDay != null && t.occurredAt.isAfter(endDay)) continue;

      if (t.type == TransactionType.income) {
        incomes += t.amount;
        catMap.putIfAbsent(t.category ?? 'Sin categoria', () => {'incomes': 0.0, 'expenses': 0.0});
        catMap[t.category ?? 'Sin categoria']!['incomes'] = catMap[t.category ?? 'Sin categoria']!['incomes']! + t.amount;
      } else {
        expenses += t.amount;
        catMap.putIfAbsent(t.category ?? 'Sin categoria', () => {'incomes': 0.0, 'expenses': 0.0});
        catMap[t.category ?? 'Sin categoria']!['expenses'] = catMap[t.category ?? 'Sin categoria']!['expenses']! + t.amount;
      }
    }

    final breakdown = catMap.entries.map((e) => {'category': e.key, 'incomes': e.value['incomes'] ?? 0.0, 'expenses': e.value['expenses'] ?? 0.0}).toList();
    add(StatisticsTotalsUpdated(incomes: incomes, expenses: expenses, breakdown: breakdown));
  }

  @override
  Future<void> close() {
    _txSub.cancel();
    return super.close();
  }
}
