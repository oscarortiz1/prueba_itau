import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/statistics_bloc.dart';
import '../bloc/statistics_event.dart';
import '../bloc/statistics_state.dart';
import 'package:prueba_itau/src/features/transactions/presentation/bloc/transactions_bloc.dart';
import 'package:prueba_itau/src/features/transactions/domain/entities/transaction.dart';
import 'package:prueba_itau/src/features/transactions/domain/usecases/get_transactions.dart';
import 'package:prueba_itau/src/app/di/injection_container.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final txBloc = context.read<TransactionsBloc>();
    final getTransactions = sl<GetTransactions>();
    return BlocProvider(
      create: (_) => StatisticsBloc(transactionsBloc: txBloc, getTransactions: getTransactions)..add(const LoadStatistics()),
      child: const _StatisticsView(),
    );
  }

  
}

class _StatisticsView extends StatefulWidget {
  const _StatisticsView();

  @override
  State<_StatisticsView> createState() => _StatisticsViewState();
}

class _StatisticsViewState extends State<_StatisticsView> {
  static const int _txPageSize = 4;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Estadísticas')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 900;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: isWide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 2, child: _leftColumn(theme)),
                      const SizedBox(width: 20),
                      Expanded(flex: 3, child: _rightColumn(theme)),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _filtersCard(theme),
                      const SizedBox(height: 12),
                      _balanceCard(),
                      const SizedBox(height: 12),
                      Expanded(child: SingleChildScrollView(child: _chartAndTransactionsMobile(theme))),
                    ],
                  ),
          );
        },
      ),
    );
  }

  Widget _balanceCard() {
    return BlocBuilder<StatisticsBloc, StatisticsState>(builder: (context, state) {
      final theme = Theme.of(context);
      final balance = state.balance;
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10),
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
                  Row(children: [
                    Icon(Icons.arrow_downward, color: Colors.green.shade600, size: 18),
                    const SizedBox(width: 6),
                    Text('\$ ${state.totalIncomes.toStringAsFixed(2)}', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.green.shade700, fontWeight: FontWeight.w600)),
                  ]),
                  const SizedBox(height: 8),
                  Row(children: [
                    Icon(Icons.arrow_upward, color: Colors.red.shade600, size: 18),
                    const SizedBox(width: 6),
                    Text('\$ ${state.totalExpenses.toStringAsFixed(2)}', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.red.shade700, fontWeight: FontWeight.w600)),
                  ]),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _chartAndTransactionsMobile(ThemeData theme) {
    return Column(
      children: [
        SizedBox(height: 300, child: Card(child: Padding(padding: const EdgeInsets.all(8.0), child: _transactionsListPanel()))),
        const SizedBox(height: 12),
        SizedBox(
          height: 180,
          child: BlocBuilder<StatisticsBloc, StatisticsState>(builder: (context, state) {
            if (state.totalIncomes == 0 && state.totalExpenses == 0) return Center(child: Text('No hay datos para mostrar', style: theme.textTheme.bodyLarge));
            return Center(child: _IncomeExpensePieChart(incomes: state.totalIncomes, expenses: state.totalExpenses, size: 140));
          }),
        ),
      ],
    );
  }

  

  Widget _leftColumn(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _filtersCard(theme),
        const SizedBox(height: 12),
        _balanceCard(),
        const SizedBox(height: 12),
        SizedBox(height: 300, child: Card(child: Padding(padding: const EdgeInsets.all(8.0), child: _transactionsListPanel()))),
        const SizedBox(height: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: BlocBuilder<StatisticsBloc, StatisticsState>(
              builder: (context, state) {
                if (state.totalIncomes == 0 && state.totalExpenses == 0) {
                  return Center(child: Text('No hay datos para mostrar', style: theme.textTheme.bodyLarge));
                }
                return Center(child: _IncomeExpensePieChart(incomes: state.totalIncomes, expenses: state.totalExpenses, size: 140));
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _rightColumn(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Movimientos', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Expanded(child: _transactionsListPanel()),
          ],
        ),
      ),
    );
  }

  Widget _filtersCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
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
                BlocBuilder<StatisticsBloc, StatisticsState>(builder: (context, state) {
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
                      if (picked == null) return;
                      if (state.endDate != null && picked.isAfter(state.endDate!)) {
                        _showValidationError(context, 'La fecha desde no puede ser posterior a la fecha hasta.');
                        return;
                      }
                      bloc.add(UpdateFilters(startDate: picked, endDate: state.endDate));
                    },
                    child: Text(state.startDate == null ? 'Desde' : _formatDate(state.startDate!)),
                  );
                }),
                BlocBuilder<StatisticsBloc, StatisticsState>(builder: (context, state) {
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
                      if (picked == null) return;
                      if (state.startDate != null && picked.isBefore(state.startDate!)) {
                        _showValidationError(context, 'La fecha hasta no puede ser anterior a la fecha desde.');
                        return;
                      }
                      bloc.add(UpdateFilters(startDate: state.startDate, endDate: picked));
                    },
                    child: Text(state.endDate == null ? 'Hasta' : _formatDate(state.endDate!)),
                  );
                }),
                FilledButton(
                  onPressed: () {
                    final bloc = context.read<StatisticsBloc>();
                    final current = bloc.state;
                    final st = current.startDate;
                    final en = current.endDate;
                    if (st != null && en != null && st.isAfter(en)) {
                      _showValidationError(context, 'Rango de fechas inválido. Ajusta las fechas antes de aplicar.');
                      return;
                    }
                    bloc.add(UpdateFilters(startDate: st, endDate: en));
                  },
                  child: const Text('Aplicar'),
                ),
                TextButton(
                  onPressed: () {
                    context.read<StatisticsBloc>().add(UpdateFilters(startDate: null, endDate: null));
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

  Widget _transactionsListPanel() {
    return BlocBuilder<StatisticsBloc, StatisticsState>(builder: (context, sstate) {
      final txState = context.read<TransactionsBloc>().state;
      final all = txState.transactions;
      final st = sstate.startDate;
      final en = sstate.endDate;
      final filtered = all.where((t) {
        if (st != null && t.occurredAt.isBefore(DateTime(st.year, st.month, st.day))) return false;
        if (en != null && t.occurredAt.isAfter(DateTime(en.year, en.month, en.day, 23, 59, 59))) return false;
        return true;
      }).toList();

  final total = filtered.length;
  final totalPages = total == 0 ? 1 : ((total - 1) ~/ _txPageSize) + 1;
  final currentPage = sstate.txPage;
  final maxPageIndex = totalPages - 1;
  final currentPageSafe = total == 0 ? 0 : currentPage.clamp(0, maxPageIndex);

  final start = currentPageSafe * _txPageSize;
  final end = math.min(start + _txPageSize, filtered.length);
      final pageItems = filtered.sublist(start, end);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListView.separated(
              itemCount: pageItems.length,
              separatorBuilder: (_, __) => const SizedBox(height: 6),
              itemBuilder: (context, index) {
                final tx = pageItems[index];
                final isIncome = tx.type == TransactionType.income;
                final amountColor = isIncome ? Colors.green.shade700 : Colors.red.shade700;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: (isIncome ? Colors.green : Colors.red).withOpacity(0.12),
                        child: Icon(isIncome ? Icons.arrow_downward : Icons.arrow_upward, color: amountColor, size: 18),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(tx.title, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            Text('${tx.category ?? ''} • ${_formatDate(tx.occurredAt)}', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text((isIncome ? '+' : '-') + '\$ ${tx.amount.toStringAsFixed(2)}', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: amountColor, fontWeight: FontWeight.w700)),
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
    });
  }

  DateTime _clampDate(DateTime value, DateTime min, DateTime max) {
    if (value.isBefore(min)) return min;
    if (value.isAfter(max)) return max;
    return value;
  }

  void _showValidationError(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  String _formatDate(DateTime d) => '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}


class _IncomeExpensePieChart extends StatelessWidget {
  const _IncomeExpensePieChart({required this.incomes, required this.expenses, this.size = 180});

  final double incomes;
  final double expenses;
  final double size;

  @override
  Widget build(BuildContext context) {
    final total = incomes + expenses;
    if (total == 0) return const SizedBox.shrink();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _PiePainter(incomes: incomes, expenses: expenses),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _LegendDot(color: Colors.green.shade600, label: 'Ingresos: \$ ${incomes.toStringAsFixed(2)}'),
            const SizedBox(width: 12),
            _LegendDot(color: Colors.red.shade600, label: 'Gastos: \$ ${expenses.toStringAsFixed(2)}'),
          ],
        ),
      ],
    );
  }
}

class _PiePainter extends CustomPainter {
  _PiePainter({required this.incomes, required this.expenses});

  final double incomes;
  final double expenses;

  @override
  void paint(Canvas canvas, Size size) {
    final total = incomes + expenses;
    final rect = Offset.zero & size;
    final paint = Paint()..style = PaintingStyle.fill;
    final start = -math.pi / 2;
    final incomesAngle = total > 0 ? (incomes / total) * math.pi * 2 : 0.0;
    paint.color = Colors.green.shade400;
    canvas.drawArc(rect, start, incomesAngle, true, paint);
    paint.color = Colors.red.shade400;
    canvas.drawArc(rect, start + incomesAngle, total > 0 ? (expenses / total) * math.pi * 2 : 0.0, true, paint);
    final inner = Paint()..color = Colors.white;
    canvas.drawCircle(rect.center, size.width * 0.32, inner);
    final tp = TextPainter(text: TextSpan(text: '\$${(incomes - expenses).toStringAsFixed(2)}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black)), textDirection: TextDirection.ltr);
    tp.layout();
    tp.paint(canvas, rect.center - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(children: [Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))), const SizedBox(width: 6), Text(label, style: Theme.of(context).textTheme.bodySmall)]);
  }
}
