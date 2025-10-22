import 'package:equatable/equatable.dart';
class StatisticsState extends Equatable {
  static const Object _unset = Object();

  final bool isLoading;
  final double totalIncomes;
  final double totalExpenses;
  final double balance;
  final String? category;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<CategoryBreakdown> breakdown;
  final int txPage;

  const StatisticsState({
    this.isLoading = false,
    this.totalIncomes = 0.0,
    this.totalExpenses = 0.0,
    this.balance = 0.0,
    this.category,
    this.startDate,
    this.endDate,
    this.breakdown = const [],
    this.txPage = 0,
  });

  StatisticsState copyWith({
    bool? isLoading,
    double? totalIncomes,
    double? totalExpenses,
    double? balance,
    Object? category = _unset,
    Object? startDate = _unset,
    Object? endDate = _unset,
    List<CategoryBreakdown>? breakdown,
    int? txPage,
  }) {
    return StatisticsState(
      isLoading: isLoading ?? this.isLoading,
      totalIncomes: totalIncomes ?? this.totalIncomes,
      totalExpenses: totalExpenses ?? this.totalExpenses,
      balance: balance ?? this.balance,
      category: identical(category, _unset) ? this.category : category as String?,
      startDate: identical(startDate, _unset) ? this.startDate : startDate as DateTime?,
      endDate: identical(endDate, _unset) ? this.endDate : endDate as DateTime?,
      breakdown: breakdown ?? this.breakdown,
      txPage: txPage ?? this.txPage,
    );
  }

  @override
  List<Object?> get props => [isLoading, totalIncomes, totalExpenses, balance, category, startDate, endDate, breakdown, txPage];
}

class CategoryBreakdown {
  final String category;
  final double incomes;
  final double expenses;

  const CategoryBreakdown({required this.category, required this.incomes, required this.expenses});
}
