import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/statistics_bloc.dart';
import '../bloc/statistics_state.dart';

class StatisticsBalanceCard extends StatelessWidget {
  const StatisticsBalanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StatisticsBloc, StatisticsState>(
      builder: (context, state) {
        final theme = Theme.of(context);
        final balance = state.balance;

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Balance', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[700])),
                      const SizedBox(height: 6),
                      Text('\$ ${balance.toStringAsFixed(2)}', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 6),
                      Text('Últimos movimientos', style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.arrow_downward, color: Colors.green.shade600, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          '\$ ${state.totalIncomes.toStringAsFixed(2)}',
                          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.green.shade700, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.arrow_upward, color: Colors.red.shade600, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          '\$ ${state.totalExpenses.toStringAsFixed(2)}',
                          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.red.shade700, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
