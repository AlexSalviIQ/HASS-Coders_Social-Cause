import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'screens/home_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/library_screen.dart';
import 'screens/library_detail_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/community_screen.dart';
import 'screens/heatmap_screen.dart';
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
            transitionsBuilder: (context, anim, _, child) =>
                FadeTransition(opacity: anim, child: child),
          ),
        ),
        GoRoute(
          path: '/chat',
          pageBuilder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;
            return CustomTransitionPage(
              key: state.pageKey,
              child: ChatScreen(
                initialAttachmentPath: extra?['attachmentPath'] as String?,
                initialAttachmentType: extra?['attachmentType'] as String?,
                initialAttachmentName: extra?['attachmentName'] as String?,
              ),
              transitionsBuilder: (context, anim, _, child) =>
                  FadeTransition(opacity: anim, child: child),
            );
          },
        ),
        GoRoute(
          path: '/library',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const LibraryScreen(),
            transitionsBuilder: (context, anim, _, child) =>
                FadeTransition(opacity: anim, child: child),
          ),
          routes: [
            GoRoute(
              path: 'detail/:id',
              pageBuilder: (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: LibraryDetailScreen(
                  detectionId: state.pathParameters['id'] ?? '',
                ),
                transitionsBuilder: (context, anim, _, child) {
                  final tween = Tween(
                    begin: const Offset(1.0, 0.0),
                    end: Offset.zero,
                  ).chain(CurveTween(curve: Curves.easeInOutCubic));
                  return SlideTransition(
                    position: anim.drive(tween),
                    child: child,
                  );
                },
              ),
            ),
          ],
        ),
        GoRoute(
          path: '/community',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const CommunityScreen(),
            transitionsBuilder: (context, anim, _, child) =>
                FadeTransition(opacity: anim, child: child),
          ),
        ),
        GoRoute(
          path: '/heatmap',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const HeatmapScreen(),
            transitionsBuilder: (context, anim, _, child) =>
                FadeTransition(opacity: anim, child: child),
          ),
        ),
        GoRoute(
          path: '/profile',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const ProfileScreen(),
            transitionsBuilder: (context, anim, _, child) =>
                FadeTransition(opacity: anim, child: child),
          ),
        ),
      ],
    ),
  ],
);
