import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/transaction.dart';
import '../../domain/entities/transaction_payload.dart';
import '../bloc/transactions_bloc.dart';

class TransactionsSection extends StatelessWidget {
  const TransactionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<TransactionsBloc, TransactionsState>(
      listenWhen: (previous, current) => previous.errorMessage != current.errorMessage,
      listener: (context, state) {
        if (state.hasError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage ?? 'Ocurrio un error inesperado.')),
          );
        }
      },
      builder: (context, state) {
        final totals = _calculateTotals(state.transactions);

        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          elevation: 5,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Ingresos y gastos',
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    FilledButton.icon(
                      onPressed: state.isProcessing
                          ? null
                          : () => _openCreateSheet(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Registrar movimiento'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (state.isLoading)
                  const _LoadingPlaceholder()
                else if (state.transactions.isEmpty)
                  _EmptyState(onRetry: () => _reload(context))
                else
                  Column(
                    children: [
                      _TotalsRow(totals: totals),
                      const SizedBox(height: 20),
                      _TransactionsList(
                        transactions: state.transactions,
                        onEdit: (transaction) => _openEditSheet(context, transaction),
                        onDelete: (transaction) => _confirmDelete(context, transaction),
                        isBusy: state.isProcessing,
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

  void _reload(BuildContext context) {
    context.read<TransactionsBloc>().add(const TransactionsLoaded());
  }

  void _openCreateSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
        ),
        child: _TransactionFormSheet(
          onSubmit: (payload) {
            Navigator.of(sheetContext).pop();
            context.read<TransactionsBloc>().add(TransactionCreateRequested(payload));
          },
        ),
      ),
    );
  }

  void _openEditSheet(BuildContext context, Transaction transaction) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
        ),
        child: _TransactionFormSheet.edit(
          transaction: transaction,
          onSubmit: (payload) {
            Navigator.of(sheetContext).pop();
            context
                .read<TransactionsBloc>()
                .add(TransactionUpdateRequested(transaction.id, payload));
          },
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Transaction transaction) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar movimiento'),
        content: Text('¿Seguro que deseas eliminar "${transaction.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context
                  .read<TransactionsBloc>()
                  .add(TransactionDeleteRequested(transaction.id));
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  _TransactionsTotals _calculateTotals(List<Transaction> transactions) {
    double incomes = 0;
    double expenses = 0;
    for (final transaction in transactions) {
      if (transaction.type == TransactionType.income) {
        incomes += transaction.amount;
      } else {
        expenses += transaction.amount;
      }
    }
    return _TransactionsTotals(
      incomes: incomes,
      expenses: expenses,
      balance: incomes - expenses,
    );
  }
}

class _LoadingPlaceholder extends StatelessWidget {
  const _LoadingPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: const [
          SizedBox(height: 12),
          CircularProgressIndicator(),
          SizedBox(height: 12),
          Text('Cargando movimientos...'),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(Icons.inbox_outlined, size: 48, color: theme.colorScheme.primary),
        const SizedBox(height: 16),
        Text(
          'No hay movimientos registrados aún',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'Empieza registrando tus ingresos o gastos para verlos aqui.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        OutlinedButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh),
          label: const Text('Actualizar'),
        ),
      ],
    );
  }
}

class _TotalsRow extends StatelessWidget {
  const _TotalsRow({required this.totals});

  final _TransactionsTotals totals;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget tile(String title, double value, Color color, IconData icon, {bool showSign = false}) {
      final formatted = showSign
          ? (value >= 0 ? '+${_formatCurrency(value)}' : '-${_formatCurrency(value)}')
          : _formatCurrency(value);

      return Card(
        color: color.withValues(alpha: 0.08),
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color),
              const SizedBox(height: 12),
              Text(title, style: theme.textTheme.bodyMedium),
              const SizedBox(height: 6),
              Text(
                formatted,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width >= 960
            ? 3
            : width >= 640
                ? 2
                : 1;
        final spacing = 12.0;
        final itemWidth = (width - spacing * (columns - 1)) / columns;

        final tiles = <Widget>[
          SizedBox(
            width: itemWidth,
            child: tile('Ingresos', totals.incomes, Colors.green.shade600, Icons.arrow_downward_rounded),
          ),
          SizedBox(
            width: itemWidth,
            child: tile('Gastos', totals.expenses, Colors.red.shade600, Icons.arrow_upward_rounded),
          ),
          SizedBox(
            width: itemWidth,
            child: tile(
              'Balance',
              totals.balance,
              theme.colorScheme.primary,
              Icons.account_balance_wallet_outlined,
              showSign: true,
            ),
          ),
        ];

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: tiles,
        );
      },
    );
  }
}

class _TransactionsList extends StatelessWidget {
  const _TransactionsList({
    required this.transactions,
    required this.onEdit,
    required this.onDelete,
    required this.isBusy,
  });

  final List<Transaction> transactions;
  final ValueChanged<Transaction> onEdit;
  final ValueChanged<Transaction> onDelete;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: transactions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, index) {
        final transaction = transactions[index];
        final isIncome = transaction.type == TransactionType.income;
        final amountColor = isIncome ? Colors.green.shade700 : Colors.red.shade700;

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            leading: CircleAvatar(
              backgroundColor: (isIncome ? Colors.green : Colors.red).withValues(alpha: 0.1),
              child: Icon(isIncome ? Icons.arrow_downward : Icons.arrow_upward, color: amountColor),
            ),
            title: Text(transaction.title),
            subtitle: Text(_buildSubtitle(transaction)),
            trailing: Wrap(
              spacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  (isIncome ? '+' : '-') + _formatCurrency(transaction.amount),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: amountColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Editar',
                  onPressed: isBusy ? null : () => onEdit(transaction),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Eliminar',
                  onPressed: isBusy ? null : () => onDelete(transaction),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _buildSubtitle(Transaction transaction) {
    final date = transaction.occurredAt;
    final dateLabel = '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
    if (transaction.category == null || transaction.category!.isEmpty) {
      return dateLabel;
    }
    return '${transaction.category} • $dateLabel';
  }
}

class _TransactionFormSheet extends StatefulWidget {
  // ignore: use_super_parameters
  const _TransactionFormSheet({
    Key? key,
    this.transaction,
    required this.onSubmit,
  }) : super(key: key);

  factory _TransactionFormSheet.edit({
    required Transaction transaction,
    required void Function(dynamic payload) onSubmit,
  }) {
    return _TransactionFormSheet(
      transaction: transaction,
      onSubmit: onSubmit,
    );
  }

  final Transaction? transaction;
  final void Function(dynamic payload) onSubmit;

  @override
  State<_TransactionFormSheet> createState() => _TransactionFormSheetState();
}

class _TransactionFormSheetState extends State<_TransactionFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _amountController;
  late final TextEditingController _categoryController;
  late TransactionType _type;
  late DateTime _occurredAt;

  bool get _isEditing => widget.transaction != null;

  @override
  void initState() {
    super.initState();
    final transaction = widget.transaction;
    _type = transaction?.type ?? TransactionType.expense;
    _occurredAt = transaction?.occurredAt ?? DateTime.now();
    _titleController = TextEditingController(text: transaction?.title ?? '');
    _amountController = TextEditingController(
      text: transaction != null ? transaction.amount.toStringAsFixed(2) : '',
    );
    _categoryController = TextEditingController(text: transaction?.category ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final submitLabel = _isEditing ? 'Actualizar' : 'Guardar';
    final titleLabel = _isEditing ? 'Editar movimiento' : 'Nuevo movimiento';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(titleLabel, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          Form(
            key: _formKey,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<TransactionType>(
                        initialValue: _type,
                        decoration: const InputDecoration(labelText: 'Tipo'),
                        items: const [
                          DropdownMenuItem(value: TransactionType.income, child: Text('Ingreso')),
                          DropdownMenuItem(value: TransactionType.expense, child: Text('Gasto')),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _type = value);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _amountController,
                        decoration: const InputDecoration(labelText: 'Monto'),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Ingresa un monto valido';
                          }
                          final parsed = double.tryParse(value.replaceAll(',', '.'));
                          if (parsed == null || parsed <= 0) {
                            return 'Ingresa un monto mayor a cero';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Descripcion'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ingresa una descripcion';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _categoryController,
                  decoration: const InputDecoration(labelText: 'Categoria (opcional)'),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _occurredAt,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() => _occurredAt = DateTime(
                              picked.year,
                              picked.month,
                              picked.day,
                              _occurredAt.hour,
                              _occurredAt.minute,
                            ));
                      }
                    },
                    icon: const Icon(Icons.calendar_today_outlined),
                    label: Text('Fecha: ${_formatDate(_occurredAt)}'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () {
              if (_formKey.currentState?.validate() != true) {
                return;
              }

              final amount = double.parse(_amountController.text.replaceAll(',', '.'));
              final category = _categoryController.text.trim().isEmpty
                  ? null
                  : _categoryController.text.trim();

              if (_isEditing) {
                final transaction = widget.transaction!;
                final payload = TransactionUpdatePayload(
                  type: _type == transaction.type ? null : _type,
                  title: _titleController.text.trim() == transaction.title
                      ? null
                      : _titleController.text.trim(),
                  amount: amount == transaction.amount ? null : amount,
                  category: category == transaction.category ? null : category,
                  occurredAt: _sameDate(_occurredAt, transaction.occurredAt) ? null : _occurredAt,
                );

                if (!payload.hasChanges) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Realiza al menos un cambio para actualizar.')),
                  );
                  return;
                }

                widget.onSubmit(payload);
              } else {
                final payload = TransactionCreatePayload(
                  type: _type,
                  title: _titleController.text.trim(),
                  amount: amount,
                  category: category,
                  occurredAt: _occurredAt,
                );
                widget.onSubmit(payload);
              }
            },
            child: Text(submitLabel),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  bool _sameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class _TransactionsTotals {
  const _TransactionsTotals({
    required this.incomes,
    required this.expenses,
    required this.balance,
  });

  final double incomes;
  final double expenses;
  final double balance;
}

String _formatCurrency(double value) {
  return '\$ ${value.abs().toStringAsFixed(2)}';
}