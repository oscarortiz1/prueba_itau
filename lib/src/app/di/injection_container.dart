import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;

import '../../core/config/app_config.dart';
import '../../core/session/session_manager.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_user.dart';
import '../../features/auth/domain/usecases/register_user.dart';
import '../../features/auth/presentation/bloc/login/login_bloc.dart';
import '../../features/auth/presentation/bloc/registration/registration_bloc.dart';
import '../router/app_router.dart';

final sl = GetIt.instance;

Future<void> configureDependencies() async {
  sl
    ..registerLazySingleton<AppConfig>(
      () => const AppConfig(
        apiBaseUrl: 'http://localhost:3000/api/v1',
        socketBaseUrl: 'http://localhost:3000',
      ),
    )
    ..registerLazySingleton(SessionManager.new)
    ..registerLazySingleton<http.Client>(http.Client.new)
    ..registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(
        client: sl(),
        baseUrl: sl<AppConfig>().apiBaseUrl,
      ),
    )
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(remoteDataSource: sl()),
    )
    ..registerLazySingleton(() => LoginUser(sl()))
    ..registerLazySingleton(() => RegisterUser(sl()))
  ..registerFactory(() => LoginBloc(loginUser: sl(), sessionManager: sl()))
    ..registerFactory(() => RegistrationBloc(registerUser: sl()))
    ..registerLazySingleton(() => AppRouter(sl));
}
