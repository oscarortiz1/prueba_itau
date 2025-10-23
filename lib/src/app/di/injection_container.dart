import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/config/app_config.dart';
import '../../core/network/network_info.dart';
import '../../core/session/session_manager.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_user.dart';
import '../../features/auth/domain/usecases/register_user.dart';
import '../../features/auth/presentation/bloc/login/login_bloc.dart';
import '../../features/auth/presentation/bloc/registration/registration_bloc.dart';
import '../../features/transactions/data/datasources/transactions_local_data_source.dart';
import '../../features/transactions/data/datasources/transactions_remote_data_source.dart';
import '../../features/transactions/data/repositories/transactions_repository_impl.dart';
import '../../features/transactions/domain/repositories/transactions_repository.dart';
import '../../features/transactions/domain/usecases/create_transaction.dart';
import '../../features/transactions/domain/usecases/delete_transaction.dart';
import '../../features/transactions/domain/usecases/get_pending_operations_count.dart';
import '../../features/transactions/domain/usecases/get_transactions.dart';
import '../../features/transactions/domain/usecases/sync_pending_transactions.dart';
import '../../features/transactions/domain/usecases/update_transaction.dart';
import '../../features/transactions/presentation/bloc/transactions_bloc.dart';
import '../router/app_router.dart';

final sl = GetIt.instance;

Future<void> configureDependencies() async {
  final prefs = await SharedPreferences.getInstance();
  final apiHost = _resolveApiHost();

  sl
    ..registerLazySingleton<AppConfig>(
      () => AppConfig(
        apiBaseUrl: '$apiHost/api/v1',
        socketBaseUrl: apiHost,
      ),
    )
    ..registerLazySingleton<SharedPreferences>(() => prefs)
    ..registerLazySingleton(Connectivity.new)
    ..registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()))
    ..registerLazySingleton<SessionManager>(
      () => SessionManager(prefs: sl()),
    )
    ..registerLazySingleton<Dio>(
      () => Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 12),
          receiveTimeout: const Duration(seconds: 12),
          sendTimeout: const Duration(seconds: 12),
        ),
      ),
    )
    ..registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(
        dio: sl(),
        baseUrl: sl<AppConfig>().apiBaseUrl,
      ),
    )
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(remoteDataSource: sl()),
    )
    ..registerLazySingleton(() => LoginUser(sl()))
    ..registerLazySingleton(() => RegisterUser(sl()))
    ..registerLazySingleton<TransactionsRemoteDataSource>(
      () => TransactionsRemoteDataSourceImpl(
        dio: sl(),
        baseUrl: sl<AppConfig>().apiBaseUrl,
      ),
    )
    ..registerLazySingleton<TransactionsLocalDataSource>(
      () => TransactionsLocalDataSourceImpl(prefs: sl()),
    )
    ..registerLazySingleton<TransactionsRepository>(
      () => TransactionsRepositoryImpl(
        remoteDataSource: sl(),
        localDataSource: sl(),
        sessionManager: sl(),
        networkInfo: sl(),
      ),
    )
    ..registerLazySingleton(() => GetTransactions(sl()))
    ..registerLazySingleton(() => CreateTransaction(sl()))
    ..registerLazySingleton(() => UpdateTransaction(sl()))
    ..registerLazySingleton(() => DeleteTransaction(sl()))
    ..registerLazySingleton(() => SyncPendingTransactions(sl()))
    ..registerLazySingleton(() => GetPendingOperationsCount(sl()))
    ..registerFactory(() => LoginBloc(loginUser: sl(), sessionManager: sl()))
    ..registerFactory(() => RegistrationBloc(registerUser: sl()))
    ..registerFactory(
      () => TransactionsBloc(
        getTransactions: sl(),
        createTransaction: sl(),
        updateTransaction: sl(),
        deleteTransaction: sl(),
        syncPendingTransactions: sl(),
        getPendingOperationsCount: sl(),
        networkInfo: sl(),
      ),
    )
    ..registerLazySingleton(() => AppRouter(sl));

  await sl<SessionManager>().restore();
}

String _resolveApiHost() {
  if (kIsWeb) {
    return 'http://localhost:3000';
  }

  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
      return 'http://10.0.2.2:3000';
    case TargetPlatform.iOS:
    case TargetPlatform.macOS:
    case TargetPlatform.windows:
    case TargetPlatform.linux:
      return 'http://localhost:3000';
    case TargetPlatform.fuchsia:
      return 'http://localhost:3000';
  }
}
