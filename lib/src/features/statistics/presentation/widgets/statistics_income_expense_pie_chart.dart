import 'dart:math' as math;

import 'package:flutter/material.dart';

class StatisticsIncomeExpensePieChart extends StatelessWidget {
  const StatisticsIncomeExpensePieChart({
    super.key,
    required this.incomes,
    required this.expenses,
    this.size = 180,
  });

  final double incomes;
  final double expenses;
  final double size;

  @override
  Widget build(BuildContext context) {
    final total = incomes + expenses;
    if (total == 0) {
      return const SizedBox.shrink();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _StatisticsPiePainter(incomes: incomes, expenses: expenses),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _StatisticsLegendDot(
              color: Colors.green.shade600,
              label: 'Ingresos: \$ ${incomes.toStringAsFixed(2)}',
            ),
            const SizedBox(width: 12),
            _StatisticsLegendDot(
              color: Colors.red.shade600,
              label: 'Gastos: \$ ${expenses.toStringAsFixed(2)}',
            ),
          ],
        ),
      ],
    );
  }
}

class _StatisticsPiePainter extends CustomPainter {
  const _StatisticsPiePainter({required this.incomes, required this.expenses});

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
    final expensesAngle = total > 0 ? (expenses / total) * math.pi * 2 : 0.0;
    canvas.drawArc(rect, start + incomesAngle, expensesAngle, true, paint);

    final inner = Paint()..color = Colors.white;
    canvas.drawCircle(rect.center, size.width * 0.32, inner);

    final delta = incomes - expenses;
    final painter = TextPainter(
      text: TextSpan(
        text: '\$${delta.toStringAsFixed(2)}',
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
      ),
      textDirection: TextDirection.ltr,
    );
    painter.layout();
    painter.paint(canvas, rect.center - Offset(painter.width / 2, painter.height / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _StatisticsLegendDot extends StatelessWidget {
  const _StatisticsLegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
        ),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
