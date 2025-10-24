import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/transaction.dart';
import '../../domain/entities/transaction_payload.dart';
import '../bloc/transactions_bloc.dart';


class TransactionsUiState {
  const TransactionsUiState({
    this.listPage = 0,
    this.totalsPage = 0,
    this.viewportFraction = 0.9,
    this.filtersTick = 0,
    this.formType,
    this.formOccurredAt,
  });

  final int listPage;
  final int totalsPage;
  final double viewportFraction;
  final int filtersTick; 
  final TransactionType? formType;
  final DateTime? formOccurredAt;

  TransactionsUiState copyWith({
    int? listPage,
    int? totalsPage,
    double? viewportFraction,
    int? filtersTick,
    TransactionType? formType,
    DateTime? formOccurredAt,
  }) {
    return TransactionsUiState(
      listPage: listPage ?? this.listPage,
      totalsPage: totalsPage ?? this.totalsPage,
      viewportFraction: viewportFraction ?? this.viewportFraction,
      filtersTick: filtersTick ?? this.filtersTick,
      formType: formType ?? this.formType,
      formOccurredAt: formOccurredAt ?? this.formOccurredAt,
    );
  }
}

class TransactionsUiCubit extends Cubit<TransactionsUiState> {
  TransactionsUiCubit() : super(const TransactionsUiState()) {

    _pageController = PageController(viewportFraction: state.viewportFraction);
    _pageController.addListener(_onPageControllerScroll);
  }

  late PageController _pageController;

  PageController get pageController => _pageController;

  void _onPageControllerScroll() {

    final page = _pageController.hasClients
        ? (_pageController.page ?? _pageController.initialPage).round()
        : 0;
    if (page != state.totalsPage) {
      emit(state.copyWith(totalsPage: page));
    }
  }

  @override
  Future<void> close() {
    _pageController.removeListener(_onPageControllerScroll);
    _pageController.dispose();
    return super.close();
  }

  void notifyFiltersChanged() => emit(state.copyWith(filtersTick: state.filtersTick + 1));

  void setListPage(int page) => emit(state.copyWith(listPage: page));

  void nextListPage(int maxPage) {
    final candidate = state.listPage + 1;
    final next = candidate > maxPage ? maxPage : candidate;
    emit(state.copyWith(listPage: next));
  }

  void prevListPage() {
    final prev = state.listPage > 0 ? state.listPage - 1 : 0;
    emit(state.copyWith(listPage: prev));
  }

  void setTotalsPage(int page) {
    emit(state.copyWith(totalsPage: page));
    if (_pageController.hasClients) {
      _pageController.animateToPage(page, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
    }
  }

  void goToPage(int page) {
    if (_pageController.hasClients) {
      _pageController.animateToPage(page, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
    } else {
      setTotalsPage(page);
    }
  }

  void setViewportFraction(double fraction) {
    if ((fraction - state.viewportFraction).abs() < 0.01) return;
    final old = _pageController;
    final newController = PageController(initialPage: state.totalsPage, viewportFraction: fraction);
    old.removeListener(_onPageControllerScroll);
    old.dispose();
    _pageController = newController;
    _pageController.addListener(_onPageControllerScroll);
    emit(state.copyWith(viewportFraction: fraction));
  }

  void initForm({TransactionType? type, DateTime? occurredAt}) => emit(state.copyWith(formType: type, formOccurredAt: occurredAt));

  void setFormType(TransactionType type) => emit(state.copyWith(formType: type));

  void setFormOccurredAt(DateTime date) => emit(state.copyWith(formOccurredAt: date));

  void resetForm() => emit(state.copyWith(formType: null, formOccurredAt: null));
}

class TransactionsSection extends StatelessWidget {
  const TransactionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final _ = context.watch<TransactionsUiCubit>().state.filtersTick;
    final theme = Theme.of(context);

  return BlocConsumer<TransactionsBloc, TransactionsState>(
      listenWhen: (previous, current) =>
          previous.errorMessage != current.errorMessage,
      listener: (context, state) {
        if (state.hasError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.errorMessage ?? 'Ocurrio un error inesperado.',
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          elevation: 6,
          margin: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
          color: theme.colorScheme.surface,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.surface,
                  theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.18),
                  theme.colorScheme.primary.withValues(alpha: 0.08),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(26),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      const compactWidth = 520.0;
                      final isCompact = constraints.maxWidth <= compactWidth;

                      const headerSpacing = SizedBox(height: 16);
                      final headerSubtitle = Text(
                        'Visualiza el estado de tus finanzas y gestiona cada movimiento en segundos.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      );

                      final button = FilledButton.icon(
                        onPressed: state.isProcessing
                            ? null
                            : () => _openCreateSheet(context),
                        icon: const Icon(Icons.add),
                        label: const Text('Registrar movimiento'),
                      );

                      final title = Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ingresos y gastos',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 6),
                          headerSubtitle,
                        ],
                      );

                      if (isCompact) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            title,
                            headerSpacing,
                            SizedBox(width: double.infinity, child: button),
                          ],
                        );
                      }

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: title),
                          const SizedBox(width: 24),
                          button,
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  Divider(
                    height: 1,
                    color: theme.dividerColor.withValues(alpha: 0.2),
                  ),
                  const SizedBox(height: 24),
                  if (state.isLoading)
                    const _LoadingPlaceholder()
                  else if (state.transactions.isEmpty)
                    _EmptyState(onRetry: () => _reload(context))
                  else
                    _TransactionsContent(
                      transactions: state.transactions,
                      onEdit: (transaction) =>
                          _openEditSheet(context, transaction),
                      onDelete: (transaction) =>
                          _confirmDelete(context, transaction),
                      isBusy: state.isProcessing,
                    ),
                ],
              ),
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
    final uiCubit = context.read<TransactionsUiCubit>();
    uiCubit.initForm(type: TransactionType.expense, occurredAt: DateTime.now());

    if (kIsWeb) {
      showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (dialogContext) {
          return BlocProvider.value(
            value: uiCubit,
            child: Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(dialogContext).viewInsets.bottom,
                  ),
                  child: SingleChildScrollView(
                    child: _TransactionFormSheet(
                      onSubmit: (payload) {
                        Navigator.of(dialogContext).pop();
                        context.read<TransactionsBloc>().add(
                          TransactionCreateRequested(payload),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
        ),
        child: BlocProvider.value(
          value: uiCubit,
          child: _TransactionFormSheet(
            onSubmit: (payload) {
              Navigator.of(sheetContext).pop();
              context.read<TransactionsBloc>().add(
                TransactionCreateRequested(payload),
              );
            },
          ),
        ),
      ),
    );
  }

  void _openEditSheet(BuildContext context, Transaction transaction) {
    final uiCubit = context.read<TransactionsUiCubit>();
    uiCubit.initForm(type: transaction.type, occurredAt: transaction.occurredAt);

    if (kIsWeb) {
      showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (dialogContext) {
          return BlocProvider.value(
            value: uiCubit,
            child: Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(dialogContext).viewInsets.bottom,
                  ),
                  child: SingleChildScrollView(
                    child: _TransactionFormSheet.edit(
                      transaction: transaction,
                      onSubmit: (payload) {
                        Navigator.of(dialogContext).pop();
                        context.read<TransactionsBloc>().add(
                          TransactionUpdateRequested(transaction.id, payload),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
        ),
        child: BlocProvider.value(
          value: uiCubit,
          child: _TransactionFormSheet.edit(
            transaction: transaction,
            onSubmit: (payload) {
              Navigator.of(sheetContext).pop();
              context.read<TransactionsBloc>().add(
                TransactionUpdateRequested(transaction.id, payload),
              );
            },
          ),
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
              context.read<TransactionsBloc>().add(
                TransactionDeleteRequested(transaction.id),
              );
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

class _LoadingPlaceholder extends StatelessWidget {
  const _LoadingPlaceholder();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
            ),
            child: SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary),
                strokeWidth: 3,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Cargando movimientos...',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Por favor espera un momento mientras sincronizamos tus ingresos y gastos.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
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

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.32),
            theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.12),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.primary.withValues(alpha: 0.12),
            ),
            child: Icon(
              Icons.auto_graph_outlined,
              size: 36,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No hay movimientos registrados aún',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            'Empieza registrando tus ingresos o gastos para visualizar tendencias y balances al instante.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          FilledButton.tonalIcon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Actualizar lista'),
          ),
        ],
      ),
    );
  }
}

class _TransactionsContent extends StatefulWidget {
  const _TransactionsContent({
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
  State<_TransactionsContent> createState() => _TransactionsContentState();
}

class _TransactionsContentState extends State<_TransactionsContent> {
  late final TextEditingController _descriptionController;
  late final TextEditingController _categoryController;
  late final TextEditingController _minAmountController;
  late final TextEditingController _maxAmountController;
  late final List<TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController();
    _categoryController = TextEditingController();
    _minAmountController = TextEditingController();
    _maxAmountController = TextEditingController();
    _controllers = [
      _descriptionController,
      _categoryController,
      _minAmountController,
      _maxAmountController,
    ];
    for (final controller in _controllers) {
      controller.addListener(_onFiltersChanged);
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.removeListener(_onFiltersChanged);
      controller.dispose();
    }
    super.dispose();
  }

  void _onFiltersChanged() {

    final cubit = context.read<TransactionsUiCubit>();
    cubit.notifyFiltersChanged();
  }

  bool get _hasFilters {
    return _descriptionController.text.trim().isNotEmpty ||
        _categoryController.text.trim().isNotEmpty ||
        _minAmountController.text.trim().isNotEmpty ||
        _maxAmountController.text.trim().isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final minAmount = _tryParseAmount(_minAmountController.text);
    final maxAmount = _tryParseAmount(_maxAmountController.text);
    final rangeError = _rangeError(minAmount, maxAmount);

    final filteredTransactions = rangeError != null
        ? <Transaction>[]
        : _applyFilters(
            widget.transactions,
            minAmount: minAmount,
            maxAmount: maxAmount,
          );

  final totalsAll = _calculateTotals(widget.transactions);
  final totalCount = widget.transactions.length;
  final filteredCount = filteredTransactions.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildFilters(
          theme: theme,
          totalCount: totalCount,
          filteredCount: filteredCount,
          rangeError: rangeError,
        ),
        const SizedBox(height: 24),
        _TotalsCarousel(totals: totalsAll),
        const SizedBox(height: 24),
        if (filteredTransactions.isEmpty)
          _NoResultsPlaceholder(
            onClear: _hasFilters ? _clearFilters : null,
          )
        else
          _TransactionsList(
            transactions: filteredTransactions,
            onEdit: widget.onEdit,
            onDelete: widget.onDelete,
            isBusy: widget.isBusy,
          ),
      ],
    );
  }

  Widget _buildFilters({
    required ThemeData theme,
    required int totalCount,
    required int filteredCount,
    required String? rangeError,
  }) {
    final minFormatError = _amountFormatError(_minAmountController);
    final maxFormatError = _amountFormatError(_maxAmountController);
    final activeFilters = _controllers
        .where((controller) => controller.text.trim().isNotEmpty)
        .length;
    final panelColor = theme.colorScheme.surfaceContainerHighest.withValues(
      alpha: theme.brightness == Brightness.dark ? 0.28 : 0.14,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
          decoration: BoxDecoration(
            color: panelColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.18),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.tune_rounded,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Filtros',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (activeFilters > 0) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '$activeFilters activos',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                  const Spacer(),
                  if (_hasFilters)
                    TextButton.icon(
                      onPressed: _clearFilters,
                      icon: const Icon(Icons.filter_alt_off_outlined),
                      label: const Text('Limpiar'),
                    ),
                ],
              ),
              const SizedBox(height: 18),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isCompact = constraints.maxWidth < 640;
                  final fieldSpacing = isCompact ? 12.0 : 16.0;
                  final descriptionField = _buildFilterField(
                    theme: theme,
                    controller: _descriptionController,
                    label: 'Descripcion',
                    icon: Icons.search,
                    textInputAction: TextInputAction.search,
                  );
                  final categoryField = _buildFilterField(
                    theme: theme,
                    controller: _categoryController,
                    label: 'Categoria',
                    icon: Icons.label_outline,
                    textInputAction: TextInputAction.search,
                  );
                  final minAmountField = _buildFilterField(
                    theme: theme,
                    controller: _minAmountController,
                    label: 'Monto minimo',
                    icon: Icons.trending_down,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    textInputAction: TextInputAction.next,
                    errorText: minFormatError,
                  );
                  final maxAmountField = _buildFilterField(
                    theme: theme,
                    controller: _maxAmountController,
                    label: 'Monto maximo',
                    icon: Icons.trending_up,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    textInputAction: TextInputAction.done,
                    errorText: maxFormatError,
                  );

                  if (isCompact) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        descriptionField,
                        SizedBox(height: fieldSpacing),
                        categoryField,
                        SizedBox(height: fieldSpacing),
                        minAmountField,
                        SizedBox(height: fieldSpacing),
                        maxAmountField,
                      ],
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: descriptionField),
                      SizedBox(width: fieldSpacing),
                      Expanded(flex: 2, child: categoryField),
                      SizedBox(width: fieldSpacing),
                      Expanded(flex: 2, child: minAmountField),
                      SizedBox(width: fieldSpacing),
                      Expanded(flex: 2, child: maxAmountField),
                    ],
                  );
                },
              ),
              if (rangeError != null) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.error.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: theme.colorScheme.error,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          rangeError,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Icon(
              Icons.list_alt_outlined,
              size: 18,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Text(
              'Mostrando $filteredCount de $totalCount movimientos',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (activeFilters > 0)
              Text(
                ' • $activeFilters filtros activos',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterField({
    required ThemeData theme,
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    TextInputAction textInputAction = TextInputAction.next,
    String? errorText,
  }) {
    final radius = BorderRadius.circular(16);
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: _buildClearIcon(controller),
        errorText: errorText,
        filled: true,
        fillColor: theme.colorScheme.surface.withValues(
          alpha: theme.brightness == Brightness.dark ? 0.28 : 0.08,
        ),
        border: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(
            color: theme.colorScheme.primary.withValues(alpha: 0.6),
          ),
        ),
      ),
    );
  }

  Widget? _buildClearIcon(TextEditingController controller) {
    if (controller.text.isEmpty) {
      return null;
    }
    return IconButton(
      onPressed: () => controller.clear(),
      icon: const Icon(Icons.close),
      tooltip: 'Limpiar',
      visualDensity: VisualDensity.compact,
      splashRadius: 18,
    );
  }

  void _clearFilters() {
    for (final controller in _controllers) {
      if (controller.text.isNotEmpty) {
        controller.clear();
      }
    }
  }

  List<Transaction> _applyFilters(
    List<Transaction> transactions, {
    double? minAmount,
    double? maxAmount,
  }) {
    final description = _descriptionController.text.trim().toLowerCase();
    final category = _categoryController.text.trim().toLowerCase();

    return transactions.where((transaction) {
      final matchesDescription = description.isEmpty ||
          transaction.title.toLowerCase().contains(description);
      if (!matchesDescription) {
        return false;
      }

      final categoryValue = (transaction.category ?? '').toLowerCase();
      final matchesCategory =
          category.isEmpty || categoryValue.contains(category);
      if (!matchesCategory) {
        return false;
      }

      final amount = transaction.amount;
      if (minAmount != null && amount < minAmount) {
        return false;
      }
      if (maxAmount != null && amount > maxAmount) {
        return false;
      }

      return true;
    }).toList();
  }

  double? _tryParseAmount(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    final normalized = trimmed.replaceAll(' ', '').replaceAll(',', '.');
    return double.tryParse(normalized);
  }

  String? _amountFormatError(TextEditingController controller) {
    final text = controller.text.trim();
    if (text.isEmpty) {
      return null;
    }
    return _tryParseAmount(text) == null ? 'Formato invalido' : null;
  }

  String? _rangeError(double? minAmount, double? maxAmount) {
    if (minAmount != null && maxAmount != null && minAmount > maxAmount) {
      return 'El monto minimo no puede ser mayor que el maximo';
    }
    return null;
  }
}

class _NoResultsPlaceholder extends StatelessWidget {
  const _NoResultsPlaceholder({this.onClear});

  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.filter_alt_off_outlined,
            size: 32,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 12),
          Text(
            'No encontramos movimientos con los filtros seleccionados.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          if (onClear != null) ...[
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: onClear,
              icon: const Icon(Icons.refresh),
              label: const Text('Limpiar filtros'),
            ),
          ],
        ],
      ),
    );
  }
}

class _TotalsCarousel extends StatefulWidget {
  const _TotalsCarousel({required this.totals});

  final _TransactionsTotals totals;

  @override
  State<_TotalsCarousel> createState() => _TotalsCarouselState();
}

class _TotalsCarouselState extends State<_TotalsCarousel> {

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final slides = <_TotalSlide>[
      _TotalSlide(
        title: 'Balance',
        value: widget.totals.balance,
        color: theme.colorScheme.primary,
        icon: Icons.account_balance_wallet_outlined,
        showSign: true,
      ),
      _TotalSlide(
        title: 'Ingresos',
        value: widget.totals.incomes,
        color: Colors.green.shade600,
        icon: Icons.arrow_downward_rounded,
      ),
      _TotalSlide(
        title: 'Gastos',
        value: widget.totals.expenses,
        color: Colors.red.shade600,
        icon: Icons.arrow_upward_rounded,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final desiredFraction = width >= 1024
            ? 0.4
            : width >= 768
            ? 0.5
            : width >= 560
            ? 0.68
            : 0.9;

  final allowNav = slides.length > 1 && (kIsWeb || width >= 680);
  final showOverlayNav = allowNav && width >= 720;
  final showInlineNav = allowNav && !showOverlayNav && kIsWeb;
  final maxPage = slides.length - 1;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          final uiCubit = context.read<TransactionsUiCubit>();
          uiCubit.setViewportFraction(desiredFraction);
        });

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 180,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PageView.builder(
                    controller: context.read<TransactionsUiCubit>().pageController,
                    itemCount: slides.length,
                    onPageChanged: (index) {
                      context.read<TransactionsUiCubit>().setTotalsPage(index);
                    },
                    itemBuilder: (context, index) {
                      final slide = slides[index];
                      final isActive = index == context.watch<TransactionsUiCubit>().state.totalsPage;
                      return AnimatedPadding(
                        duration: const Duration(milliseconds: 280),
                        curve: Curves.easeOut,
                        padding: EdgeInsets.symmetric(
                          horizontal: isActive ? 6 : 14,
                          vertical: isActive ? 0 : 6,
                        ),
                        child: _TotalTile(slide: slide, isActive: isActive),
                      );
                    },
                  ),
                  if (showOverlayNav) ...[
                    Positioned(
                      left: 4,
                        child: _CarouselArrow(
                          icon: Icons.chevron_left,
                          enabled: context.watch<TransactionsUiCubit>().state.totalsPage > 0,
                          onTap: () => context.read<TransactionsUiCubit>().goToPage(context.read<TransactionsUiCubit>().state.totalsPage - 1),
                        ),
                    ),
                      Positioned(
                        right: 4,
                        child: _CarouselArrow(
                          icon: Icons.chevron_right,
                          enabled: context.watch<TransactionsUiCubit>().state.totalsPage < maxPage,
                          onTap: () => context.read<TransactionsUiCubit>().goToPage(context.read<TransactionsUiCubit>().state.totalsPage + 1),
                        ),
                      ),
                  ],
                ],
              ),
            ),
            if (slides.length > 1) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (showInlineNav) ...[
                    _CarouselArrow(
                      icon: Icons.chevron_left,
                      enabled: context.watch<TransactionsUiCubit>().state.totalsPage > 0,
                      onTap: () => context.read<TransactionsUiCubit>().goToPage(context.read<TransactionsUiCubit>().state.totalsPage - 1),
                      dense: true,
                    ),
                    const SizedBox(width: 12),
                  ],
                  ...List.generate(slides.length, (index) {
                    final isActive = index == context.watch<TransactionsUiCubit>().state.totalsPage;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 8,
                      width: isActive ? 22 : 8,
                      decoration: BoxDecoration(
            color: isActive
              ? theme.colorScheme.primary
              : theme.colorScheme.primary.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    );
                  }),
                  if (showInlineNav) ...[
                    const SizedBox(width: 12),
                    _CarouselArrow(
                      icon: Icons.chevron_right,
                      enabled: context.watch<TransactionsUiCubit>().state.totalsPage < maxPage,
                      onTap: () => context.read<TransactionsUiCubit>().goToPage(context.read<TransactionsUiCubit>().state.totalsPage + 1),
                      dense: true,
                    ),
                  ],
                ],
              ),
            ],
          ],
        );
      },
    );
  }
}

class _TotalSlide {
  const _TotalSlide({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
    this.showSign = false,
  });

  final String title;
  final double value;
  final Color color;
  final IconData icon;
  final bool showSign;

  String formatValue() {
    final currency = _formatCurrency(value);
    if (!showSign) {
      return currency;
    }
    return value >= 0 ? '+$currency' : '-$currency';
  }
}

class _TotalTile extends StatelessWidget {
  const _TotalTile({required this.slide, required this.isActive});

  final _TotalSlide slide;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedScale(
      scale: isActive ? 1.0 : 0.94,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: [
              slide.color.withValues(alpha: 0.16),
              slide.color.withValues(alpha: 0.04),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: slide.color.withValues(alpha: 0.14)),
          boxShadow: [
            BoxShadow(
              color: slide.color.withValues(alpha: 0.1),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: slide.color.withValues(alpha: 0.2),
                ),
                child: Icon(slide.icon, color: slide.color, size: 22),
              ),
              const SizedBox(height: 18),
              Text(
                slide.title,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.85),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: FittedBox(
                  alignment: AlignmentDirectional.centerStart,
                  fit: BoxFit.scaleDown,
                  child: Text(
                    slide.formatValue(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: slide.color,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CarouselArrow extends StatelessWidget {
  const _CarouselArrow({
    required this.icon,
    required this.enabled,
    required this.onTap,
    this.dense = false,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final minSize = dense ? const Size(36, 36) : const Size(44, 44);
    final iconSize = dense ? 20.0 : 24.0;
    return Material(
      color: Colors.transparent,
      child: IconButton.filledTonal(
        onPressed: enabled ? onTap : null,
        icon: Icon(icon, size: iconSize),
        style: IconButton.styleFrom(
          minimumSize: minSize,
          padding: EdgeInsets.zero,
          foregroundColor: theme.colorScheme.primary,
          backgroundColor: theme.colorScheme.surface.withValues(
            alpha: dense ? 0.9 : 0.95,
          ),
        ),
        tooltip: icon == Icons.chevron_left ? 'Anterior' : 'Siguiente',
      ),
    );
  }
}

class _TransactionsList extends StatefulWidget {
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
  State<_TransactionsList> createState() => _TransactionsListState();
}

class _TransactionsListState extends State<_TransactionsList> {
  static const int _pageSize = 5;

  int get _totalPages {
    if (widget.transactions.isEmpty) {
      return 1;
    }
    return ((widget.transactions.length - 1) / _pageSize).floor() + 1;
  }

  @override
  void didUpdateWidget(covariant _TransactionsList oldWidget) {
    super.didUpdateWidget(oldWidget);
    final cubit = context.read<TransactionsUiCubit>();
    if (widget.transactions.length != oldWidget.transactions.length) {
      cubit.setListPage(0);
    }
    final current = cubit.state.listPage;
    if (current >= _totalPages) {
      cubit.setListPage(_totalPages - 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
  final currentPage = context.watch<TransactionsUiCubit>().state.listPage;
  final start = currentPage * _pageSize;
    final end = start + _pageSize;
    final visibleTransactions = widget.transactions.sublist(
      start,
      end > widget.transactions.length ? widget.transactions.length : end,
    );
    final showPagination = widget.transactions.length > _pageSize;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: visibleTransactions.length,
          separatorBuilder: (context, _) => const SizedBox(height: 12),
          itemBuilder: (_, index) {
            final transaction = visibleTransactions[index];
            final isIncome = transaction.type == TransactionType.income;
            final amountColor =
                isIncome ? Colors.green.shade700 : Colors.red.shade700;

            return LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxWidth < 400;

                Widget buildActions({required bool dense}) {
                  final amountText = Text(
                    '${isIncome ? '+' : '-'}${_formatCurrency(transaction.amount)}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: amountColor,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                  );

                  final buttons = Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        tooltip: 'Editar',
                        onPressed:
                            widget.isBusy ? null : () => widget.onEdit(transaction),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        tooltip: 'Eliminar',
                        onPressed: widget.isBusy
                            ? null
                            : () => widget.onDelete(transaction),
                      ),
                    ],
                  );

                  if (dense) {
                    return Wrap(
                      alignment: WrapAlignment.end,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 4,
                      children: [amountText, buttons],
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [amountText, const SizedBox(height: 8), buttons],
                  );
                }

                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              backgroundColor:
                                  (isIncome ? Colors.green : Colors.red)
                                      .withValues(alpha: 0.1),
                              child: Icon(
                                isIncome
                                    ? Icons.arrow_downward
                                    : Icons.arrow_upward,
                                color: amountColor,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    transaction.title,
                                    style: theme.textTheme.titleMedium,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _buildSubtitle(transaction),
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color:
                                          theme.colorScheme.onSurfaceVariant,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            if (!isCompact) ...[
                              const SizedBox(width: 12),
                              ConstrainedBox(
                                constraints:
                                    const BoxConstraints(maxWidth: 160),
                                child: buildActions(dense: false),
                              ),
                            ],
                          ],
                        ),
                        if (isCompact) ...[
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ConstrainedBox(
                              constraints:
                                  const BoxConstraints(maxWidth: 220),
                              child: buildActions(dense: true),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
        if (showPagination) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                'Página ${currentPage + 1} de $_totalPages',
                style: theme.textTheme.bodyMedium,
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.chevron_left),
                tooltip: 'Página anterior',
                onPressed: currentPage == 0
                    ? null
                    : () => context.read<TransactionsUiCubit>().prevListPage(),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                tooltip: 'Página siguiente',
                onPressed: currentPage >= _totalPages - 1
                    ? null
                    : () => context.read<TransactionsUiCubit>().nextListPage(_totalPages - 1),
              ),
            ],
          ),
        ],
      ],
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
  const _TransactionFormSheet({
    this.transaction,
    required this.onSubmit,
  });

  factory _TransactionFormSheet.edit({
    required Transaction transaction,
    required void Function(dynamic payload) onSubmit,
  }) {
    return _TransactionFormSheet(transaction: transaction, onSubmit: onSubmit);
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

  static const double _maxAmount = 999999999999.99;

  bool get _isEditing => widget.transaction != null;

  @override
  void initState() {
    super.initState();
    final transaction = widget.transaction;
    _titleController = TextEditingController(text: transaction?.title ?? '');
    _amountController = TextEditingController(
      text: transaction != null ? transaction.amount.toStringAsFixed(2) : '',
    );
    _categoryController = TextEditingController(
      text: transaction?.category ?? '',
    );
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
          Text(
            titleLabel,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Form(
            key: _formKey,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<TransactionType>(
                          initialValue: context.watch<TransactionsUiCubit>().state.formType ?? TransactionType.expense,
                        decoration: const InputDecoration(labelText: 'Tipo'),
                        items: const [
                          DropdownMenuItem(
                            value: TransactionType.income,
                            child: Text('Ingreso'),
                          ),
                          DropdownMenuItem(
                            value: TransactionType.expense,
                            child: Text('Gasto'),
                          ),
                        ],
                          onChanged: (value) {
                            if (value != null) {
                              context.read<TransactionsUiCubit>().setFormType(value);
                            }
                          },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _amountController,
                        decoration: const InputDecoration(labelText: 'Monto'),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: _validateAmount,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Descripcion'),
                  validator: _validateTitle,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _categoryController,
                  decoration: const InputDecoration(
                    labelText: 'Categoria (opcional)',
                  ),
                  validator: _validateCategory,
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final cubit = context.read<TransactionsUiCubit>();
                      final initial = cubit.state.formOccurredAt ?? DateTime.now();
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: initial,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                        locale: const Locale('es'),
                      );
                      if (picked != null) {
                        final prev = cubit.state.formOccurredAt ?? DateTime.now();
                        cubit.setFormOccurredAt(DateTime(picked.year, picked.month, picked.day, prev.hour, prev.minute));
                      }
                    },
                    icon: const Icon(Icons.calendar_today_outlined),
                    label: Text('Fecha: ${_formatDate(context.watch<TransactionsUiCubit>().state.formOccurredAt ?? DateTime.now())}'),
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

              final cubit = context.read<TransactionsUiCubit>();
              final occurredAt = cubit.state.formOccurredAt ?? DateTime.now();

              final amount = _parseAmount(_amountController.text);
              final category = _categoryController.text.trim().isEmpty
                  ? null
                  : _categoryController.text.trim();

              if (_isEditing) {
                final transaction = widget.transaction!;
                final selectedType = cubit.state.formType ?? transaction.type;
                final payload = TransactionUpdatePayload(
                  type: selectedType == transaction.type ? null : selectedType,
                  title: _titleController.text.trim() == transaction.title
                      ? null
                      : _titleController.text.trim(),
                  amount: amount == transaction.amount ? null : amount,
                  category: category == transaction.category ? null : category,
                  occurredAt: _sameDate(occurredAt, transaction.occurredAt)
                      ? null
                      : occurredAt,
                );

                if (!payload.hasChanges) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Realiza al menos un cambio para actualizar.',
                      ),
                    ),
                  );
                  return;
                }

                widget.onSubmit(payload);
              } else {
                final payload = TransactionCreatePayload(
                  type: cubit.state.formType ?? TransactionType.expense,
                  title: _titleController.text.trim(),
                  amount: amount,
                  category: category,
                  occurredAt: occurredAt,
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

  String? _validateAmount(String? value) {
    final raw = value?.trim() ?? '';
    if (raw.isEmpty) {
      return 'Ingresa un monto valido';
    }
    final normalized = raw.replaceAll(' ', '').replaceAll(',', '.');
    final decimalRegex = RegExp(r'^\d+(\.\d{1,2})?$');
    if (!decimalRegex.hasMatch(normalized)) {
      return 'Usa solo numeros con hasta 2 decimales';
    }

    final parsed = double.tryParse(normalized);
    if (parsed == null) {
      return 'Monto invalido';
    }
    if (parsed <= 0) {
      return 'Ingresa un monto mayor a cero';
    }
    if (parsed > _maxAmount) {
      return 'Monto excede el limite permitido';
    }
    return null;
  }

  double _parseAmount(String raw) {
    final normalized = raw.trim().replaceAll(' ', '').replaceAll(',', '.');
    return double.parse(normalized);
  }

  String? _validateTitle(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return 'Ingresa una descripcion';
    }
    if (trimmed.length < 3) {
      return 'La descripcion debe tener al menos 3 caracteres';
    }
    if (trimmed.length > 60) {
      return 'La descripcion es demasiado larga (max 60)';
    }
    return null;
  }

  String? _validateCategory(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return null;
    }
    if (trimmed.length > 40) {
      return 'La categoria es demasiado larga (max 40)';
    }
    return null;
  }
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
