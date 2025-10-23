import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:prueba_itau/src/features/transactions/domain/entities/transaction.dart';
import 'package:prueba_itau/src/features/transactions/presentation/bloc/transactions_bloc.dart';
import 'package:prueba_itau/src/features/transactions/presentation/widgets/transactions_section.dart';

class MockTransactionsBloc extends MockBloc<TransactionsEvent, TransactionsState>
    implements TransactionsBloc {}

Transaction buildTransaction({required String id, required DateTime createdAt}) {
  return Transaction(
    id: id,
    userId: 'user-1',
    type: TransactionType.expense,
    title: 'Movimiento $id',
    amount: 50,
    category: 'general',
    occurredAt: createdAt.subtract(const Duration(days: 1)),
    createdAt: createdAt,
    updatedAt: createdAt,
  );
}

Widget _buildApp(TransactionsBloc bloc) {
  return MaterialApp(
    home: MultiBlocProvider(
      providers: [
        BlocProvider<TransactionsBloc>.value(value: bloc),
        BlocProvider(create: (_) => TransactionsUiCubit()),
      ],
      child: const Scaffold(body: TransactionsSection()),
    ),
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue(const TransactionsLoaded());
    registerFallbackValue(const TransactionsState());
  });

  group('TransactionsSection', () {
    late MockTransactionsBloc bloc;

    setUp(() {
      bloc = MockTransactionsBloc();
      when(() => bloc.close()).thenAnswer((_) async {});
    });

    tearDown(() => bloc.close());

    testWidgets('shows loading placeholder while fetching data', (tester) async {
      final view = tester.view;
      view.physicalSize = const Size(1200, 2000);
      view.devicePixelRatio = 1.0;
      addTearDown(() {
        view.resetPhysicalSize();
        view.resetDevicePixelRatio();
      });

      const state = TransactionsState(status: TransactionsStatus.loading);
      when(() => bloc.state).thenReturn(state);
      whenListen(bloc, Stream<TransactionsState>.value(state), initialState: state);

      await tester.pumpWidget(_buildApp(bloc));

      expect(find.text('Cargando movimientos...'), findsOneWidget);
    });

    testWidgets('shows empty state when there are no transactions', (tester) async {
      final view = tester.view;
      view.physicalSize = const Size(1200, 2000);
      view.devicePixelRatio = 1.0;
      addTearDown(() {
        view.resetPhysicalSize();
        view.resetDevicePixelRatio();
      });

      const state = TransactionsState(status: TransactionsStatus.success, transactions: []);
      when(() => bloc.state).thenReturn(state);
      whenListen(bloc, Stream<TransactionsState>.value(state), initialState: state);

      await tester.pumpWidget(_buildApp(bloc));

      expect(find.text('No hay movimientos registrados aún'), findsOneWidget);
      expect(find.text('Actualizar lista'), findsOneWidget);
    });

    testWidgets('renders the transaction list when data is available', (tester) async {
      final view = tester.view;
      view.physicalSize = const Size(1200, 2000);
      view.devicePixelRatio = 1.0;
      addTearDown(() {
        view.resetPhysicalSize();
        view.resetDevicePixelRatio();
      });

      final newer = buildTransaction(id: '2', createdAt: DateTime(2024, 5, 12));
      final older = buildTransaction(id: '1', createdAt: DateTime(2024, 5, 5));
      final state = TransactionsState(
        status: TransactionsStatus.success,
        transactions: [newer, older],
      );

      when(() => bloc.state).thenReturn(state);
      whenListen(bloc, Stream<TransactionsState>.value(state), initialState: state);

      await tester.pumpWidget(_buildApp(bloc));
      await tester.pumpAndSettle();

      expect(find.text(newer.title), findsOneWidget);
      expect(find.text(older.title), findsOneWidget);
      expect(find.byType(Card), findsWidgets);
    });
  });
}
