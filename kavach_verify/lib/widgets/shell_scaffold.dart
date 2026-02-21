import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';

class ShellScaffold extends StatefulWidget {
  final Widget child;
  final String currentPath;

  const ShellScaffold({
    super.key,
    required this.child,
    required this.currentPath,
  });

  @override
  State<ShellScaffold> createState() => _ShellScaffoldState();
}

class _ShellScaffoldState extends State<ShellScaffold> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String get _currentPageName {
    switch (widget.currentPath) {
      case '/home':
        return 'Home';
      case '/chat':
        return 'Chat';
      case '/library':
        return 'Library';
      case '/profile':
        return 'Profile';
      default:
        if (widget.currentPath.startsWith('/library/detail')) {
          return 'Detection Details';
        }
        return 'Home';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      key: _scaffoldKey,
      endDrawer: _buildDrawer(context, isDark),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.deepBlue,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  // AI Mascot Icon
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.emeraldGreen,
                          AppColors.emeraldGreenLight,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.emeraldGreen.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text('🛡️', style: TextStyle(fontSize: 18)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Title & Page Name
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'KavachVerify',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                          ),
                        ),
                        Text(
                          _currentPageName,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Hamburger Menu
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        _scaffoldKey.currentState?.openEndDrawer();
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.menu_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  ).animate().scale(duration: 200.ms, curve: Curves.easeOut),
                ],
              ),
            ),
          ),
        ),
      ),
      body: widget.child,
    );
  }

  Widget _buildDrawer(BuildContext context, bool isDark) {
    return Drawer(
      width: 280,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.white,
        ),
        child: Column(
          children: [
            // Drawer Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.deepBlue, AppColors.deepBlueLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.emeraldGreen,
                              AppColors.emeraldGreenLight,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.emeraldGreen.withValues(
                                alpha: 0.3,
                              ),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text('🛡️', style: TextStyle(fontSize: 28)),
                        ),
                      )
                      .animate()
                      .fadeIn(duration: 300.ms)
                      .slideX(
                        begin: -0.2,
                        duration: 400.ms,
                        curve: Curves.easeOutCubic,
                      ),
                  const SizedBox(height: 16),
                  const Text(
                    'KavachVerify',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ).animate().fadeIn(delay: 100.ms, duration: 300.ms),
                  const SizedBox(height: 4),
                  Text(
                    'Truth Shield for the Digital Age',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 13,
                    ),
                  ).animate().fadeIn(delay: 200.ms, duration: 300.ms),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Nav Items
            _buildNavItem(
              context,
              icon: Icons.home_rounded,
              label: 'Home',
              path: '/home',
              delay: 0,
            ),
            _buildNavItem(
              context,
              icon: Icons.chat_bubble_rounded,
              label: 'Chat',
              path: '/chat',
              delay: 50,
            ),
            _buildNavItem(
              context,
              icon: Icons.library_books_rounded,
              label: 'Library',
              path: '/library',
              delay: 100,
            ),
            _buildNavItem(
              context,
              icon: Icons.person_rounded,
              label: 'Profile',
              path: '/profile',
              delay: 150,
            ),
            const Spacer(),
            // Footer
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'v1.0.0 • Made with ❤️',
                style: TextStyle(
                  color: isDark ? AppColors.mediumGrey : AppColors.mediumGrey,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().slideX(
      begin: 1,
      end: 0,
      duration: 300.ms,
      curve: Curves.easeOutCubic,
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String path,
    required int delay,
  }) {
    final isSelected = widget.currentPath == path;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            child: ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              selected: isSelected,
              selectedTileColor: AppColors.deepBlue.withValues(
                alpha: isDark ? 0.3 : 0.08,
              ),
              leading: Icon(
                icon,
                color: isSelected
                    ? AppColors.deepBlue
                    : (isDark ? AppColors.mediumGrey : AppColors.darkGrey),
                size: 22,
              ),
              title: Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? AppColors.deepBlue
                      : (isDark ? AppColors.lightGrey : AppColors.darkGrey),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  fontSize: 15,
                ),
              ),
              onTap: () {
                Navigator.of(context).pop(); // Close drawer
                context.go(path);
              },
            ),
          ),
        )
        .animate()
        .fadeIn(
          delay: Duration(milliseconds: delay),
          duration: 300.ms,
        )
        .slideX(
          begin: 0.15,
          delay: Duration(milliseconds: delay),
          duration: 300.ms,
          curve: Curves.easeOutCubic,
        );
  }
}
