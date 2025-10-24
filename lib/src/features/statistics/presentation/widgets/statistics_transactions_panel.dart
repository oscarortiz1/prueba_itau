import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/statistics_bloc.dart';
import '../bloc/statistics_event.dart';
import '../bloc/statistics_state.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../../transactions/presentation/bloc/transactions_bloc.dart';

class StatisticsTransactionsPanel extends StatelessWidget {
  const StatisticsTransactionsPanel({super.key, required this.pageSize});

  final int pageSize;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StatisticsBloc, StatisticsState>(
      builder: (context, statisticsState) {
        final transactionsState = context.read<TransactionsBloc>().state;
        final allTransactions = transactionsState.transactions;
        final startDate = statisticsState.startDate;
        final endDate = statisticsState.endDate;

        final filteredTransactions = allTransactions.where((transaction) {
          if (startDate != null && transaction.occurredAt.isBefore(DateTime(startDate.year, startDate.month, startDate.day))) {
            return false;
          }
          if (endDate != null && transaction.occurredAt.isAfter(DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59))) {
            return false;
          }
          return true;
        }).toList();

        final total = filteredTransactions.length;
        final totalPages = total == 0 ? 1 : ((total - 1) ~/ pageSize) + 1;
        final currentPage = statisticsState.txPage;
        final maxPageIndex = totalPages - 1;
        final currentPageSafe = total == 0 ? 0 : currentPage.clamp(0, maxPageIndex);

        final start = currentPageSafe * pageSize;
        final end = math.min(start + pageSize, filteredTransactions.length);
        final pageItems = filteredTransactions.sublist(start, end);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView.separated(
                itemCount: pageItems.length,
                separatorBuilder: (context, _) => const SizedBox(height: 6),
                itemBuilder: (context, index) {
                  final transaction = pageItems[index];
                  final isIncome = transaction.type == TransactionType.income;
                  final amountColor = isIncome ? Colors.green.shade700 : Colors.red.shade700;

                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: (isIncome ? Colors.green : Colors.red).withValues(alpha: 0.12),
                          child: Icon(
                            isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                            color: amountColor,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                transaction.title,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${transaction.category ?? ''} • ${_formatDate(transaction.occurredAt)}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${isIncome ? '+' : '-'}\$ ${transaction.amount.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: amountColor, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text('Página ${currentPageSafe + 1} de $totalPages'),
                const Spacer(),
                IconButton(
                  onPressed: currentPageSafe == 0
                      ? null
                      : () => context.read<StatisticsBloc>().add(PageChanged(currentPageSafe - 1)),
                  icon: const Icon(Icons.chevron_left),
                ),
                IconButton(
                  onPressed: currentPageSafe >= maxPageIndex
                      ? null
                      : () => context.read<StatisticsBloc>().add(PageChanged(currentPageSafe + 1)),
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }
}
