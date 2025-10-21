import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/bloc/login/login_bloc.dart';
import '../../features/auth/presentation/bloc/registration/registration_bloc.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/registration_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import 'routes.dart';

class AppRouter {
  AppRouter(GetIt sl)
      : _sl = sl,
        _rootNavigatorKey = GlobalKey<NavigatorState>();

  final GetIt _sl;
  final GlobalKey<NavigatorState> _rootNavigatorKey;

  late final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutePath.login,
    routes: [
      GoRoute(
        name: AppRouteName.login,
        path: AppRoutePath.login,
        builder: (context, state) => BlocProvider(
          create: (_) => _sl<LoginBloc>(),
          child: const LoginPage(),
        ),
      ),
      GoRoute(
        name: AppRouteName.register,
        path: AppRoutePath.register,
        builder: (context, state) => BlocProvider(
          create: (_) => _sl<RegistrationBloc>(),
          child: const RegistrationPage(),
        ),
      ),
      GoRoute(
        name: AppRouteName.home,
        path: AppRoutePath.home,
        builder: (context, state) => const HomePage(),
      ),
    ],
  );
}
