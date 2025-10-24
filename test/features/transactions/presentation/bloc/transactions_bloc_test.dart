import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:prueba_itau/src/core/network/network_info.dart';
import 'package:prueba_itau/src/features/transactions/domain/entities/transaction.dart';
import 'package:prueba_itau/src/features/transactions/domain/entities/transaction_payload.dart';
import 'package:prueba_itau/src/features/transactions/domain/entities/transaction_realtime_event.dart';
import 'package:prueba_itau/src/features/transactions/domain/usecases/create_transaction.dart';
import 'package:prueba_itau/src/features/transactions/domain/usecases/delete_transaction.dart';
import 'package:prueba_itau/src/features/transactions/domain/usecases/get_pending_operations_count.dart';
import 'package:prueba_itau/src/features/transactions/domain/usecases/get_transactions.dart';
import 'package:prueba_itau/src/features/transactions/domain/usecases/sync_pending_transactions.dart';
import 'package:prueba_itau/src/features/transactions/domain/usecases/update_transaction.dart';
import 'package:prueba_itau/src/features/transactions/domain/usecases/watch_transactions_realtime.dart';
import 'package:prueba_itau/src/features/transactions/presentation/bloc/transactions_bloc.dart';

class MockGetTransactions extends Mock implements GetTransactions {}

class MockCreateTransaction extends Mock implements CreateTransaction {}

class MockUpdateTransaction extends Mock implements UpdateTransaction {}

class MockDeleteTransaction extends Mock implements DeleteTransaction {}

class MockSyncPendingTransactions extends Mock implements SyncPendingTransactions {}

class MockGetPendingOperationsCount extends Mock implements GetPendingOperationsCount {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

class MockWatchTransactionsRealtime extends Mock implements WatchTransactionsRealtime {}

void main() {
	late MockGetTransactions getTransactions;
	late MockCreateTransaction createTransaction;
	late MockUpdateTransaction updateTransaction;
	late MockDeleteTransaction deleteTransaction;
	late MockSyncPendingTransactions syncPendingTransactions;
	late MockGetPendingOperationsCount getPendingOperationsCount;
	late MockNetworkInfo networkInfo;
		late MockWatchTransactionsRealtime watchTransactionsRealtime;
	late StreamController<bool> connectionController;

	TransactionsBloc buildBloc() {
		return TransactionsBloc(
			getTransactions: getTransactions,
			createTransaction: createTransaction,
			updateTransaction: updateTransaction,
			deleteTransaction: deleteTransaction,
			syncPendingTransactions: syncPendingTransactions,
			getPendingOperationsCount: getPendingOperationsCount,
			networkInfo: networkInfo,
			watchTransactionsRealtime: watchTransactionsRealtime,
		);
	}

	Transaction transaction({
		required String id,
		required DateTime createdAt,
	}) {
		return Transaction(
			id: id,
			userId: 'user-1',
			type: TransactionType.expense,
			title: 'Tx $id',
			amount: 50,
			category: 'general',
			occurredAt: createdAt.subtract(const Duration(days: 1)),
			createdAt: createdAt,
			updatedAt: createdAt,
		);
	}

	setUpAll(() {
		registerFallbackValue(
			TransactionCreatePayload(
				type: TransactionType.expense,
				title: 'fallback',
				amount: 1,
				occurredAt: DateTime(2024, 1, 1),
			),
		);
			registerFallbackValue(TransactionUpdatePayload());
	});

	setUp(() {
		getTransactions = MockGetTransactions();
		createTransaction = MockCreateTransaction();
		updateTransaction = MockUpdateTransaction();
		deleteTransaction = MockDeleteTransaction();
		syncPendingTransactions = MockSyncPendingTransactions();
		getPendingOperationsCount = MockGetPendingOperationsCount();
		networkInfo = MockNetworkInfo();
			watchTransactionsRealtime = MockWatchTransactionsRealtime();
		connectionController = StreamController<bool>.broadcast();

		when(() => networkInfo.onStatusChange).thenAnswer((_) => connectionController.stream);
		when(() => networkInfo.isConnected).thenAnswer((_) async => true);
				when(() => watchTransactionsRealtime()).thenAnswer(
					(_) => Stream<TransactionRealtimeEvent>.empty(),
				);
		when(() => createTransaction(any())).thenAnswer((_) async => transaction(id: 'new', createdAt: DateTime.now()));
		when(() => updateTransaction(any(), any())).thenAnswer((_) async => transaction(id: 'updated', createdAt: DateTime.now()));
		when(() => deleteTransaction(any())).thenAnswer((_) async {});
	});

	tearDown(() {
		connectionController.close();
	});

	group('TransactionsLoaded', () {
			late Transaction newer;
			late Transaction older;

		blocTest<TransactionsBloc, TransactionsState>(
			'emits sorted transactions by createdAt',
			build: () {
					newer = transaction(id: '2', createdAt: DateTime(2024, 5, 10));
					older = transaction(id: '1', createdAt: DateTime(2024, 5, 1));
				when(() => getTransactions()).thenAnswer((_) async => [older, newer]);
				when(() => getPendingOperationsCount()).thenAnswer((_) async => 0);
				return buildBloc();
			},
			act: (bloc) => bloc.add(const TransactionsLoaded()),
			expect: () => [
				const TransactionsState(status: TransactionsStatus.loading),
				TransactionsState(
					status: TransactionsStatus.success,
						transactions: [newer, older],
					pendingOperations: 0,
					isSyncing: false,
				),
			],
		);
	});

	group('TransactionsConnectionChanged', () {
			late Transaction newer;
			late Transaction older;

		blocTest<TransactionsBloc, TransactionsState>(
			'triggers sync when pending operations exist and connection returns',
			build: () {
					newer = transaction(id: '4', createdAt: DateTime(2024, 7, 8));
					older = transaction(id: '3', createdAt: DateTime(2024, 6, 30));
				var count = 0;
				when(() => getPendingOperationsCount()).thenAnswer((_) async {
					if (count == 0) {
						count++;
						return 2;
					}
					return 0;
				});
				when(() => syncPendingTransactions()).thenAnswer((_) async => [older, newer]);
				return buildBloc();
			},
			act: (bloc) => bloc.add(const TransactionsConnectionChanged(true)),
			expect: () => [
				const TransactionsState(pendingOperations: 2),
				const TransactionsState(pendingOperations: 2, isSyncing: true),
				TransactionsState(
					status: TransactionsStatus.success,
						transactions: [newer, older],
					pendingOperations: 0,
					isSyncing: false,
				),
			],
		);
	});
}
