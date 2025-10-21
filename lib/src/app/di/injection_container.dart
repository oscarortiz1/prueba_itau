import 'package:get_it/get_it.dart';

import '../../features/auth/data/datasources/auth_local_data_source.dart';
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
    ..registerLazySingleton<AuthLocalDataSource>(
      AuthLocalDataSourceImpl.new,
    )
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(localDataSource: sl()),
    )
    ..registerLazySingleton(() => LoginUser(sl()))
    ..registerLazySingleton(() => RegisterUser(sl()))
    ..registerFactory(() => LoginBloc(loginUser: sl()))
    ..registerFactory(() => RegistrationBloc(registerUser: sl()))
    ..registerLazySingleton(() => AppRouter(sl));
}
