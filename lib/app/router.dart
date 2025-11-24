import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dikkhaai/features/auth/presentation/splash_screen.dart';
import 'package:dikkhaai/features/auth/presentation/get_started_screen.dart';
import 'package:dikkhaai/features/auth/presentation/phone_screen.dart';
import 'package:dikkhaai/features/auth/presentation/otp_screen.dart';
import 'package:dikkhaai/features/profile/presentation/create_profile_screen.dart';
import 'package:dikkhaai/features/profile/presentation/profile_screen.dart';
import 'package:dikkhaai/features/main/presentation/main_shell.dart';
import 'package:dikkhaai/features/reader/presentation/reader_screen.dart';
import 'package:dikkhaai/features/chat/presentation/chat_screen.dart';
import 'package:dikkhaai/features/chat/presentation/chat_history_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String getStarted = '/get-started';
  static const String phone = '/phone';
  static const String otp = '/otp';
  static const String createProfile = '/create-profile';
  static const String main = '/main';
  static const String profile = '/profile';
  static const String chatHistory = '/chat-history';
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.getStarted,
        builder: (context, state) => const GetStartedScreen(),
      ),
      GoRoute(
        path: AppRoutes.phone,
        builder: (context, state) => const PhoneScreen(),
      ),
      GoRoute(
        path: AppRoutes.otp,
        builder: (context, state) {
          final phone = state.extra as String? ?? '';
          return OtpScreen(phoneNumber: phone);
        },
      ),
      GoRoute(
        path: AppRoutes.createProfile,
        builder: (context, state) {
          final phone = state.extra as String? ?? '';
          return CreateProfileScreen(phoneNumber: phone);
        },
      ),
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.main,
            redirect: (context, state) {
              if (state.fullPath == AppRoutes.main) {
                return '${AppRoutes.main}/read';
              }
              return null;
            },
            routes: [
              GoRoute(
                path: 'read',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: ReaderScreen(),
                ),
              ),
              GoRoute(
                path: 'chat',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: ChatScreen(),
                ),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.chatHistory,
        builder: (context, state) => const ChatHistoryScreen(),
      ),
    ],
  );
});

