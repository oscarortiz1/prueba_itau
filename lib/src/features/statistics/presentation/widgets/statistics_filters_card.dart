import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/statistics_bloc.dart';
import '../bloc/statistics_event.dart';
import '../bloc/statistics_state.dart';

class StatisticsFiltersCard extends StatelessWidget {
  const StatisticsFiltersCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Filtros por fecha', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.start,
              children: [
                BlocBuilder<StatisticsBloc, StatisticsState>(
                  builder: (context, state) {
                    return FilledButton(
                      onPressed: () async {
                        final bloc = context.read<StatisticsBloc>();
                        var firstDate = DateTime(2000);
                        var lastDate = state.endDate ?? DateTime(2100);
                        if (lastDate.isBefore(firstDate)) {
                          firstDate = lastDate;
                        }
                        final initialCandidate = state.startDate ?? (state.endDate ?? DateTime.now());
                        final initialDate = _clampDate(initialCandidate, firstDate, lastDate);

                        final picked = await showDatePicker(
                          context: context,
                          initialDate: initialDate,
                          firstDate: firstDate,
                          lastDate: lastDate,
                        );

                        if (!context.mounted || picked == null) {
                          return;
                        }

                        if (state.endDate != null && picked.isAfter(state.endDate!)) {
                          _showValidationError(context, 'La fecha desde no puede ser posterior a la fecha hasta.');
                          return;
                        }

                        bloc.add(UpdateFilters(startDate: picked, endDate: state.endDate));
                      },
                      child: Text(state.startDate == null ? 'Desde' : _formatDate(state.startDate!)),
                    );
                  },
                ),
                BlocBuilder<StatisticsBloc, StatisticsState>(
                  builder: (context, state) {
                    return FilledButton(
                      onPressed: () async {
                        final bloc = context.read<StatisticsBloc>();
                        var firstDate = state.startDate ?? DateTime(2000);
                        var lastDate = DateTime(2100);
                        if (lastDate.isBefore(firstDate)) {
                          lastDate = firstDate;
                        }
                        final initialCandidate = state.endDate ?? (state.startDate ?? DateTime.now());
                        final initialDate = _clampDate(initialCandidate, firstDate, lastDate);

                        final picked = await showDatePicker(
                          context: context,
                          initialDate: initialDate,
                          firstDate: firstDate,
                          lastDate: lastDate,
                        );

                        if (!context.mounted || picked == null) {
                          return;
                        }

                        if (state.startDate != null && picked.isBefore(state.startDate!)) {
                          _showValidationError(context, 'La fecha hasta no puede ser anterior a la fecha desde.');
                          return;
                        }

                        bloc.add(UpdateFilters(startDate: state.startDate, endDate: picked));
                      },
                      child: Text(state.endDate == null ? 'Hasta' : _formatDate(state.endDate!)),
                    );
                  },
                ),
                TextButton(
                  onPressed: () {
                    context.read<StatisticsBloc>().add(const UpdateFilters(startDate: null, endDate: null));
                  },
                  child: const Text('Limpiar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static DateTime _clampDate(DateTime value, DateTime min, DateTime max) {
    if (value.isBefore(min)) return min;
    if (value.isAfter(max)) return max;
    return value;
  }

  static void _showValidationError(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  static String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }
}
