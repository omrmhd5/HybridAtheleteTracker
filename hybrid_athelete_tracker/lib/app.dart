import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/services/onboarding_service.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/chat/chat_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';

class HybridAthleteTrackerApp extends StatelessWidget {
  const HybridAthleteTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final router = GoRouter(
      initialLocation: '/',
      redirect: (context, state) {
        final isLoggedIn = authProvider.isAuthenticated;
        final loc = state.matchedLocation;
        final isAuthRoute = loc == '/login' || loc == '/register';
        final isOnboarding = loc == '/onboarding';

        // First-run onboarding for new, signed-out users.
        if (!isLoggedIn && !OnboardingService.isComplete && !isOnboarding) {
          return '/onboarding';
        }
        if (!isLoggedIn && !isAuthRoute && !isOnboarding) {
          return '/login';
        }
        if (isLoggedIn && (isAuthRoute || isOnboarding)) {
          return '/';
        }
        return null;
      },
      routes: [
        GoRoute(
          path: '/onboarding',
          builder: (context, state) => const OnboardingScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;
            return RegisterScreen(prefill: extra);
          },
        ),
        GoRoute(
          path: '/',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
        GoRoute(
          path: '/chat',
          builder: (context, state) => const ChatScreen(),
        ),
      ],
    );

    return MaterialApp.router(
      title: 'Hybrid Athlete Tracker',
      theme: AppTheme.lightTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
