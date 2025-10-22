import 'package:equatable/equatable.dart';

abstract class StatisticsEvent extends Equatable {
  const StatisticsEvent();

  @override
  List<Object?> get props => [];
}

class LoadStatistics extends StatisticsEvent {
  const LoadStatistics();
}

class UpdateFilters extends StatisticsEvent {
  final String? category;
  final DateTime? startDate;
  final DateTime? endDate;

  const UpdateFilters({this.category, this.startDate, this.endDate});

  @override
  List<Object?> get props => [category, startDate, endDate];
}

class PageChanged extends StatisticsEvent {
  final int page;

  const PageChanged(this.page);

  @override
  List<Object?> get props => [page];
}

class StatisticsTotalsUpdated extends StatisticsEvent {
  final double incomes;
  final double expenses;
  final List<dynamic>? breakdown;

  const StatisticsTotalsUpdated({required this.incomes, required this.expenses, this.breakdown});

  @override
  List<Object?> get props => [incomes, expenses, breakdown];
}
