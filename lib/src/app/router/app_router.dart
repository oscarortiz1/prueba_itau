import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../core/session/session_manager.dart';
import '../../features/auth/presentation/bloc/login/login_bloc.dart';
import '../../features/auth/presentation/bloc/registration/registration_bloc.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/registration_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/transactions/presentation/bloc/transactions_bloc.dart';
import 'routes.dart';

class AppRouter {
  AppRouter(GetIt sl)
      : _sl = sl,
        _sessionManager = sl<SessionManager>(),
        _rootNavigatorKey = GlobalKey<NavigatorState>();

  final GetIt _sl;
  final SessionManager _sessionManager;
  final GlobalKey<NavigatorState> _rootNavigatorKey;

  late final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    refreshListenable: _sessionManager,
    initialLocation: AppRoutePath.login,
    redirect: (context, state) {
      if (!_sessionManager.isInitialized) {
        return null;
      }

      final isAuthenticated = _sessionManager.isAuthenticated;
  final location = state.matchedLocation;
  final loggingIn = location == AppRoutePath.login;
  final registering = location == AppRoutePath.register;

      if (!isAuthenticated && !loggingIn && !registering) {
        return AppRoutePath.login;
      }

      if (isAuthenticated && (loggingIn || registering)) {
        return AppRoutePath.home;
      }

      return null;
    },
    routes: [
      GoRoute(
        name: AppRouteName.login,
        path: AppRoutePath.login,
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: BlocProvider(
            create: (_) => _sl<LoginBloc>(),
            child: const LoginPage(),
          ),
        ),
      ),
      GoRoute(
        name: AppRouteName.register,
        path: AppRoutePath.register,
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: BlocProvider(
            create: (_) => _sl<RegistrationBloc>(),
            child: const RegistrationPage(),
          ),
        ),
      ),
      GoRoute(
        name: AppRouteName.home,
        path: AppRoutePath.home,
        builder: (context, state) => BlocProvider(
          create: (_) => _sl<TransactionsBloc>()..add(const TransactionsLoaded()),
          child: const HomePage(),
        ),
      ),
    ],
  );
}
