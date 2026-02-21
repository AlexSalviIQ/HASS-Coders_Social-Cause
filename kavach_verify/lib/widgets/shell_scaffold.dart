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
      case '/report':
        return 'Report';
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
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      try {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return PopScope(
      canPop: _isHome,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) context.go('/home');
          });
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
        resizeToAvoidBottomInset: false,
        drawer: _buildDrawer(context, isDark),
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [AppColors.darkSurface, AppColors.darkSurface]
                    : [AppColors.deepBlueDark, AppColors.deepBlue],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    // Hamburger LEFT
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () => _scaffoldKey.currentState?.openDrawer(),
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
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
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.emeraldGreen.withValues(
                                    alpha: 0.3,
                                  ),
                                  blurRadius: 6,
                                ),
                              ],
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
                                  color: Colors.white.withValues(alpha: 0.65),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // WhatsApp / Chat icon
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: _openWhatsApp,
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: const Color(0xFF25D366),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFF25D366,
                                ).withValues(alpha: 0.3),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.chat,
                            color: Colors.white,
                            size: 18,
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
        child: SafeArea(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.deepBlueDark, AppColors.deepBlue],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.emeraldGreen,
                            AppColors.emeraldGreenLight,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.emeraldGreen.withValues(
                              alpha: 0.3,
                            ),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text('🛡️', style: TextStyle(fontSize: 22)),
                      ),
                    ).animate().fadeIn(duration: 300.ms),
                    const SizedBox(height: 10),
                    const Text(
                      'KavachVerify',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ).animate().fadeIn(delay: 80.ms, duration: 300.ms),
                    const SizedBox(height: 2),
                    Text(
                      'Truth Shield for the Digital Age',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 11,
                      ),
                    ).animate().fadeIn(delay: 150.ms, duration: 300.ms),
                  ],
                ),
              ),
              // Scrollable nav items for landscape safety
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      const SizedBox(height: 6),
                      _navItem(context, Icons.home_rounded, 'Home', '/home', 0),
                      _navItem(
                        context,
                        Icons.chat_bubble_rounded,
                        'Chat',
                        '/chat',
                        40,
                      ),
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
                        Icons.flag_rounded,
                        'Report',
                        '/report',
                        160,
                      ),
                      _navItem(
                        context,
                        Icons.person_rounded,
                        'Profile',
                        '/profile',
                        200,
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  'v1.0.0',
                  style: TextStyle(color: AppColors.mediumGrey, fontSize: 11),
                ),
              ),
            ],
          ),
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
    final isActive =
        isSelected; // Renamed for clarity in the new widget structure
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        context.go(path);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: isActive
              ? (isDark
                    ? AppColors.deepBlue.withValues(alpha: 0.2)
                    : AppColors.deepBlue.withValues(alpha: 0.1))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: ListTile(
          dense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 0,
          ),
          leading: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.deepBlue.withValues(alpha: 0.15)
                  : (isDark
                        ? AppColors.darkBorder.withValues(alpha: 0.5)
                        : AppColors.lightGrey),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(
              icon,
              size: 18,
              color: isActive
                  ? AppColors.deepBlue
                  : (isDark ? AppColors.mediumGrey : AppColors.darkGrey),
            ),
          ),
          title: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              color: isActive
                  ? (isDark ? AppColors.deepBlueLight : AppColors.deepBlue)
                  : (isDark ? AppColors.white : AppColors.charcoal),
            ),
          ),
        ),
      ),
    ).animate().fadeIn(
      delay: Duration(milliseconds: delay),
      duration: 250.ms,
    );
  }
}
