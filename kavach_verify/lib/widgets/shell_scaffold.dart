import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
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
      case '/community':
        return 'Community';
      case '/heatmap':
        return 'Threat Heatmap';
      default:
        if (widget.currentPath.startsWith('/library/detail')) return 'Details';
        return 'Home';
    }
  }

  bool get _isHome => widget.currentPath == '/home';

  Future<void> _openWhatsApp() async {
    final uri = Uri.parse(
      'https://wa.me/14155238886?text=join%20chemical-farther',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return PopScope(
      canPop: _isHome,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) context.go('/home');
      },
      child: Scaffold(
        key: _scaffoldKey,
        drawer: _buildDrawer(context, isDark),
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.deepBlue,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    // Hamburger on LEFT
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () => _scaffoldKey.currentState?.openDrawer(),
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.menu_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                    // CENTERED logo + title
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.emeraldGreen,
                                  AppColors.emeraldGreenLight,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(
                              child: Text(
                                '🛡️',
                                style: TextStyle(fontSize: 15),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'KavachVerify',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              Text(
                                _currentPageName,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.6),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // WhatsApp icon on RIGHT
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: _openWhatsApp,
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF25D366,
                            ).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.chat_rounded,
                            color: Color(0xFF25D366),
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: widget.child,
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, bool isDark) {
    return Drawer(
      width: 275,
      child: Container(
        color: isDark ? AppColors.darkSurface : AppColors.white,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 56, 20, 20),
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
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.emeraldGreen,
                              AppColors.emeraldGreenLight,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Center(
                          child: Text('🛡️', style: TextStyle(fontSize: 24)),
                        ),
                      )
                      .animate()
                      .fadeIn(duration: 300.ms)
                      .slideX(
                        begin: -0.15,
                        duration: 350.ms,
                        curve: Curves.easeOutCubic,
                      ),
                  const SizedBox(height: 14),
                  const Text(
                    'KavachVerify',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ).animate().fadeIn(delay: 80.ms, duration: 300.ms),
                  const SizedBox(height: 2),
                  Text(
                    'Truth Shield for the Digital Age',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 12,
                    ),
                  ).animate().fadeIn(delay: 150.ms, duration: 300.ms),
                ],
              ),
            ),
            const SizedBox(height: 6),
            _navItem(context, Icons.home_rounded, 'Home', '/home', 0),
            _navItem(context, Icons.chat_bubble_rounded, 'Chat', '/chat', 40),
            _navItem(
              context,
              Icons.library_books_rounded,
              'Library',
              '/library',
              80,
            ),
            _navItem(
              context,
              Icons.people_rounded,
              'Community',
              '/community',
              120,
            ),
            _navItem(
              context,
              Icons.map_rounded,
              'Threat Heatmap',
              '/heatmap',
              160,
            ),
            _navItem(context, Icons.person_rounded, 'Profile', '/profile', 200),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'v1.0.0',
                style: TextStyle(color: AppColors.mediumGrey, fontSize: 11),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _navItem(
    BuildContext context,
    IconData icon,
    String label,
    String path,
    int delay,
  ) {
    final isSelected = widget.currentPath == path;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            child: ListTile(
              dense: true,
              visualDensity: const VisualDensity(vertical: -1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              selected: isSelected,
              selectedTileColor: AppColors.deepBlue.withValues(
                alpha: isDark ? 0.25 : 0.07,
              ),
              leading: Icon(
                icon,
                color: isSelected
                    ? AppColors.deepBlue
                    : (isDark ? AppColors.mediumGrey : AppColors.darkGrey),
                size: 20,
              ),
              title: Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? AppColors.deepBlue
                      : (isDark ? AppColors.lightGrey : AppColors.darkGrey),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  fontSize: 14,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                context.go(path);
              },
            ),
          ),
        )
        .animate()
        .fadeIn(
          delay: Duration(milliseconds: delay),
          duration: 250.ms,
        )
        .slideX(
          begin: -0.1,
          delay: Duration(milliseconds: delay),
          duration: 250.ms,
          curve: Curves.easeOutCubic,
        );
  }
}
