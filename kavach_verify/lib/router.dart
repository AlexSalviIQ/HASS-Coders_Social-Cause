import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'screens/home_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/library_screen.dart';
import 'screens/library_detail_screen.dart';
import 'screens/profile_screen.dart';
import 'widgets/shell_scaffold.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/home',
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return ShellScaffold(currentPath: state.uri.path, child: child);
      },
      routes: [
        GoRoute(
          path: '/home',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const HomeScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
          ),
        ),
        GoRoute(
          path: '/chat',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const ChatScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
          ),
        ),
        GoRoute(
          path: '/library',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const LibraryScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
          ),
          routes: [
            GoRoute(
              path: 'detail/:id',
              pageBuilder: (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: LibraryDetailScreen(
                  detectionId: state.pathParameters['id'] ?? '',
                ),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                      const begin = Offset(1.0, 0.0);
                      const end = Offset.zero;
                      final tween = Tween(
                        begin: begin,
                        end: end,
                      ).chain(CurveTween(curve: Curves.easeInOutCubic));
                      return SlideTransition(
                        position: animation.drive(tween),
                        child: child,
                      );
                    },
              ),
            ),
          ],
        ),
        GoRoute(
          path: '/profile',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const ProfileScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
          ),
        ),
      ],
    ),
  ],
);
