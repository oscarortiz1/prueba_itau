import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/statistics_bloc.dart';
import '../bloc/statistics_event.dart';
import '../widgets/statistics_layout.dart';
import 'package:prueba_itau/src/app/di/injection_container.dart';
import 'package:prueba_itau/src/features/transactions/domain/usecases/get_transactions.dart';
import 'package:prueba_itau/src/features/transactions/presentation/bloc/transactions_bloc.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final transactionsBloc = context.read<TransactionsBloc>();
    final getTransactions = sl<GetTransactions>();

    return BlocProvider(
      create: (_) => StatisticsBloc(
        transactionsBloc: transactionsBloc,
        getTransactions: getTransactions,
      )..add(const LoadStatistics()),
      child: const StatisticsLayout(),
    );
  }
}
