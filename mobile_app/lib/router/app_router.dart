import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mongez/core/theme/app_theme.dart';
import 'package:mongez/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:mongez/features/auth/presentation/bloc/auth_state.dart';
import 'package:mongez/features/nurse/presentation/screens/nurse_dashboard_screen.dart';
import 'package:mongez/features/patient/presentation/screens/patient_dashboard_screen.dart';
import 'package:mongez/features/home/presentation/screens/home_screen.dart';
import 'package:mongez/features/auth/presentation/screens/login_screen.dart';
import 'package:mongez/features/auth/presentation/screens/patient_register_screen.dart';
import 'package:mongez/features/auth/presentation/screens/nurse_register_screen.dart';

class AppRouter {
  late final GoRouter router;
  late final StreamSubscription<AuthState> _authSubscription;

  AppRouter({required AuthBloc authBloc}) {
    final notifier = ValueNotifier<int>(0);
    _authSubscription = authBloc.stream.listen((_) {
      notifier.value++;
    });

    router = GoRouter(
      navigatorKey: GlobalKey<NavigatorState>(),
      initialLocation: '/',
      refreshListenable: _ValueListenableAdapter(notifier),
      redirect: (context, state) {
        final authState = authBloc.state;
        final isAuthenticated = authState is AuthAuthenticated;
        final currentPath = state.matchedLocation;

        if (isAuthenticated) {
          if (currentPath == '/' || currentPath == '/login') {
            final role = authState.user.role;
            if (role == 'nurse') return '/nurse';
            if (role == 'patient') return '/patient';
            return '/login';
          }
          return null;
        }

        final publicPaths = ['/', '/login', '/patient-register', '/nurse-register'];
        if (!publicPaths.contains(currentPath)) {
          return '/login';
        }

        return null;
      },
      routes: [
        GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
        GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
        GoRoute(path: '/patient-register', builder: (_, __) => const PatientRegisterScreen()),
        GoRoute(path: '/nurse-register', builder: (_, __) => const NurseRegisterScreen()),
        GoRoute(path: '/patient', builder: (_, __) => const PatientDashboardScreen()),
        GoRoute(path: '/nurse', builder: (_, __) => const NurseDashboardScreen()),
      ],
      errorBuilder: (context, state) => Scaffold(
        backgroundColor: AppTheme.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: AppTheme.error),
              const SizedBox(height: 16),
              Text(
                'الصفحة غير موجودة',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go('/'),
                child: const Text('العودة للرئيسية'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void dispose() {
    _authSubscription.cancel();
  }
}

class _ValueListenableAdapter extends ChangeNotifier {
  final ValueNotifier<int> _source;

  _ValueListenableAdapter(this._source) {
    _source.addListener(notifyListeners);
  }

  @override
  void dispose() {
    _source.removeListener(notifyListeners);
    super.dispose();
  }
}
