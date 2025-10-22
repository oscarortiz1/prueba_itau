import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:prueba_itau/src/core/errors/app_exception.dart';
import 'package:prueba_itau/src/core/network/network_info.dart';
import 'package:prueba_itau/src/core/session/session_manager.dart';
import 'package:prueba_itau/src/features/auth/domain/entities/auth_user.dart';
import 'package:prueba_itau/src/features/transactions/data/datasources/transactions_local_data_source.dart';
import 'package:prueba_itau/src/features/transactions/data/datasources/transactions_remote_data_source.dart';
import 'package:prueba_itau/src/features/transactions/data/models/pending_transaction_operation_model.dart';
import 'package:prueba_itau/src/features/transactions/data/models/transaction_model.dart';
import 'package:prueba_itau/src/features/transactions/data/repositories/transactions_repository_impl.dart';
import 'package:prueba_itau/src/features/transactions/domain/entities/transaction.dart';
import 'package:prueba_itau/src/features/transactions/domain/entities/transaction_payload.dart';

class MockTransactionsRemoteDataSource extends Mock
		implements TransactionsRemoteDataSource {}

class MockTransactionsLocalDataSource extends Mock
		implements TransactionsLocalDataSource {}

class MockSessionManager extends Mock implements SessionManager {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
	late TransactionsRepositoryImpl repository;
	late MockTransactionsRemoteDataSource remoteDataSource;
	late MockTransactionsLocalDataSource localDataSource;
	late MockSessionManager sessionManager;
	late MockNetworkInfo networkInfo;

	const authUser = AuthUser(id: 'user-1', email: 'test@example.com', token: 'token');

	setUpAll(() {
		registerFallbackValue(<TransactionModel>[]);
		registerFallbackValue(<PendingTransactionOperationModel>[]);
		registerFallbackValue(
			TransactionCreatePayload(
				type: TransactionType.expense,
				title: 'fallback',
				amount: 1,
				occurredAt: DateTime(2024, 1, 1),
			),
		);
	});

	setUp(() {
		remoteDataSource = MockTransactionsRemoteDataSource();
		localDataSource = MockTransactionsLocalDataSource();
		sessionManager = MockSessionManager();
		networkInfo = MockNetworkInfo();

		repository = TransactionsRepositoryImpl(
			remoteDataSource: remoteDataSource,
			localDataSource: localDataSource,
			sessionManager: sessionManager,
			networkInfo: networkInfo,
		);

		when(() => sessionManager.token).thenReturn(authUser.token);
		when(() => sessionManager.currentUser).thenReturn(authUser);
		when(() => networkInfo.isConnected).thenAnswer((_) async => true);
		when(() => localDataSource.loadPendingOperations()).thenAnswer((_) async => []);
		when(() => localDataSource.loadTransactions()).thenAnswer((_) async => []);
		when(() => localDataSource.saveTransactions(any())).thenAnswer((_) async {});
		when(() => localDataSource.savePendingOperations(any())).thenAnswer((_) async {});
	});

	TransactionModel _transactionModel({
		required String id,
		required DateTime createdAt,
	}) {
		return TransactionModel(
			id: id,
			userId: authUser.id!,
			type: TransactionType.expense,
			title: 'Tx $id',
			amount: 10,
			category: 'food',
			occurredAt: createdAt.subtract(const Duration(days: 1)),
			createdAt: createdAt,
			updatedAt: createdAt,
		);
	}

	group('fetchTransactions', () {
		test('returns remote transactions sorted by createdAt when online', () async {
			final newer = _transactionModel(id: 'b', createdAt: DateTime(2024, 5, 10));
			final older = _transactionModel(id: 'a', createdAt: DateTime(2024, 5, 1));

			when(() => remoteDataSource.fetchTransactions(token: any(named: 'token')))
					.thenAnswer((_) async => [older, newer]);

			final result = await repository.fetchTransactions();

			expect(result, equals([newer, older]));

			final saved = verify(
				() => localDataSource.saveTransactions(captureAny()),
			).captured.single as List<TransactionModel>;
			expect(saved, equals([newer, older]));
		});

		test('falls back to cached transactions when remote fails', () async {
			final cachedNewer = _transactionModel(id: 'c', createdAt: DateTime(2024, 6, 3));
			final cachedOlder = _transactionModel(id: 'd', createdAt: DateTime(2024, 4, 20));

			when(() => remoteDataSource.fetchTransactions(token: any(named: 'token')))
					.thenThrow(AppException('error'));
			when(() => localDataSource.loadTransactions())
					.thenAnswer((_) async => [cachedOlder, cachedNewer]);

			final result = await repository.fetchTransactions();

			expect(result, equals([cachedNewer, cachedOlder]));
			verifyNever(() => localDataSource.saveTransactions(any()));
		});
	});

	group('createTransaction', () {
		test('queues operation locally when offline', () async {
			when(() => networkInfo.isConnected).thenAnswer((_) async => false);
			when(() => localDataSource.loadTransactions()).thenAnswer((_) async => []);
			when(() => localDataSource.loadPendingOperations()).thenAnswer((_) async => []);

			final payload = TransactionCreatePayload(
				type: TransactionType.income,
				title: 'New income',
				amount: 120.5,
				category: 'bonus',
				occurredAt: DateTime(2024, 7, 10),
			);

			final transaction = await repository.createTransaction(payload);

			expect(transaction.title, equals(payload.title));
			expect(transaction.userId, equals(authUser.id));
			expect(transaction.type, equals(TransactionType.income));
			expect(transaction.id.startsWith('local-'), isTrue);

			final savedTransactions = verify(
				() => localDataSource.saveTransactions(captureAny()),
			).captured.single as List<TransactionModel>;
			expect(savedTransactions.length, 1);
			expect(savedTransactions.first.id, equals(transaction.id));

			final pending = verify(
				() => localDataSource.savePendingOperations(captureAny()),
			).captured.single as List<PendingTransactionOperationModel>;
			expect(pending.length, 1);
			final operation = pending.first;
			expect(operation.type, PendingTransactionOperationType.create);
			expect(operation.localId, equals(transaction.id));
		});
	});
}
