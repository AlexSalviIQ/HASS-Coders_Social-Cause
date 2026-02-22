import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'providers/auth_provider.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/library_screen.dart';
import 'screens/library_detail_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/community_screen.dart';
import 'screens/report_screen.dart';
import 'screens/whatsapp_bot_screen.dart';
import 'widgets/shell_scaffold.dart';

GoRouter createRouter(AuthProvider auth) {
  return GoRouter(
    initialLocation: '/login',
    refreshListenable: auth,
    redirect: (context, state) {
      final isAuth = auth.isAuthenticated;
      final isAuthRoute =
          state.uri.path == '/login' || state.uri.path == '/register';

      if (!isAuth && !isAuthRoute) return '/login';
      if (isAuth && isAuthRoute) return '/home';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const LoginScreen(),
          transitionsBuilder: (context, anim, _, child) =>
              FadeTransition(opacity: anim, child: child),
        ),
      ),
      GoRoute(
        path: '/register',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const RegisterScreen(),
          transitionsBuilder: (context, anim, _, child) =>
              FadeTransition(opacity: anim, child: child),
        ),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return ShellScaffold(currentPath: state.uri.path, child: child);
        },
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (context, state) =>
                NoTransitionPage(key: state.pageKey, child: const HomeScreen()),
          ),
          GoRoute(
            path: '/chat',
            pageBuilder: (context, state) {
              final extra = state.extra as Map<String, dynamic>?;
              return NoTransitionPage(
                key: state.pageKey,
                child: ChatScreen(
                  initialAttachmentPath: extra?['attachmentPath'] as String?,
                  initialAttachmentType: extra?['attachmentType'] as String?,
                  initialAttachmentName: extra?['attachmentName'] as String?,
                ),
              );
            },
          ),
          GoRoute(
            path: '/library',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const LibraryScreen(),
            ),
            routes: [
              GoRoute(
                path: 'detail/:id',
                pageBuilder: (context, state) => NoTransitionPage(
                  key: state.pageKey,
                  child: LibraryDetailScreen(
                    detectionId: state.pathParameters['id'] ?? '',
                  ),
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/whatsapp',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const WhatsAppBotScreen(),
            ),
          ),
          GoRoute(
            path: '/community',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const CommunityScreen(),
            ),
          ),
          GoRoute(
            path: '/report',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const ReportScreen(),
            ),
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const ProfileScreen(),
            ),
          ),
        ],
      ),
    ],
  );
}
