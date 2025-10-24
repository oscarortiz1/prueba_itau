import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/statistics_bloc.dart';
import '../bloc/statistics_state.dart';
import 'statistics_balance_card.dart';
import 'statistics_filters_card.dart';
import 'statistics_income_expense_pie_chart.dart';
import 'statistics_transactions_panel.dart';

class StatisticsLayout extends StatelessWidget {
  const StatisticsLayout({super.key});

  static const int _mobilePageSize = 4;
  static const int _webPageSize = 10;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Estadísticas')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 900;
          final pageSize = isWide ? _webPageSize : _mobilePageSize;
          final content = isWide
              ? _WideStatisticsContent(pageSize: pageSize)
              : _MobileStatisticsContent(pageSize: pageSize);

          return Padding(
            padding: const EdgeInsets.all(16),
            child: content,
          );
        },
      ),
    );
  }
}

class _WideStatisticsContent extends StatelessWidget {
  const _WideStatisticsContent({required this.pageSize});

  final int pageSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: _StatisticsLeftColumn(
            includeTransactionsList: false,
            chartSize: 220,
            pageSize: pageSize,
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          flex: 3,
          child: _StatisticsRightColumn(pageSize: pageSize),
        ),
      ],
    );
  }
}

class _MobileStatisticsContent extends StatelessWidget {
  const _MobileStatisticsContent({required this.pageSize});

  final int pageSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const StatisticsFiltersCard(),
        const SizedBox(height: 12),
        const StatisticsBalanceCard(),
        const SizedBox(height: 12),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 300,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: StatisticsTransactionsPanel(pageSize: pageSize),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 200,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: _StatisticsPieChartSection(maxChartSize: 160),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StatisticsLeftColumn extends StatelessWidget {
  const _StatisticsLeftColumn({
    required this.includeTransactionsList,
    required this.chartSize,
    required this.pageSize,
  });

  final bool includeTransactionsList;
  final double chartSize;
  final int pageSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const StatisticsFiltersCard(),
        const SizedBox(height: 12),
        const StatisticsBalanceCard(),
        if (includeTransactionsList) ...[
          const SizedBox(height: 12),
          SizedBox(
            height: 300,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: StatisticsTransactionsPanel(pageSize: pageSize),
              ),
            ),
          ),
        ],
        const SizedBox(height: 12),
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: _StatisticsPieChartSection(maxChartSize: chartSize),
            ),
          ),
        ),
      ],
    );
  }
}

class _StatisticsRightColumn extends StatelessWidget {
  const _StatisticsRightColumn({required this.pageSize});

  final int pageSize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Movimientos', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Expanded(child: StatisticsTransactionsPanel(pageSize: pageSize)),
          ],
        ),
      ),
    );
  }
}

class _StatisticsPieChartSection extends StatelessWidget {
  const _StatisticsPieChartSection({required this.maxChartSize});

  final double maxChartSize;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final usableHeight = constraints.maxHeight.isFinite ? constraints.maxHeight : maxChartSize;
        final usableWidth = constraints.maxWidth.isFinite ? constraints.maxWidth : maxChartSize;
        const legendAndSpacingAllowance = 40.0;
        final adjustedHeight = math.max(0.0, usableHeight - legendAndSpacingAllowance);
        final chartSide = math.max(0.0, math.min(maxChartSize, math.min(adjustedHeight, usableWidth)));

        return BlocBuilder<StatisticsBloc, StatisticsState>(
          builder: (context, state) {
            if (state.totalIncomes == 0 && state.totalExpenses == 0) {
              return Center(
                child: Text(
                  'No hay datos para mostrar',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              );
            }

            return Center(
              child: StatisticsIncomeExpensePieChart(
                incomes: state.totalIncomes,
                expenses: state.totalExpenses,
                size: chartSide,
              ),
            );
          },
        );
      },
    );
  }
}
