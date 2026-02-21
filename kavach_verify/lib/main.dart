import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:device_preview/device_preview.dart';
import 'package:provider/provider.dart';

import 'theme/app_theme.dart';
import 'providers/theme_provider.dart';
import 'providers/auth_provider.dart';
import 'router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    DevicePreview(
      enabled: true,
      builder: (context) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (ctx) => ThemeProvider()),
          ChangeNotifierProvider(create: (ctx) => AuthProvider()),
        ],
        child: const KavachVerifyApp(),
      ),
    ),
  );
}

class KavachVerifyApp extends StatefulWidget {
  const KavachVerifyApp({super.key});

  @override
  State<KavachVerifyApp> createState() => _KavachVerifyAppState();
}

class _KavachVerifyAppState extends State<KavachVerifyApp> {
  late GoRouter _router;
  AuthProvider? _lastAuth;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authProvider = Provider.of<AuthProvider>(context);
    // Only recreate router when auth instance changes
    if (_lastAuth != authProvider) {
      _lastAuth = authProvider;
      _router = createRouter(authProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp.router(
      title: 'KavachVerify',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      routerConfig: _router,
      locale: DevicePreview.locale(context),
      builder: (context, child) {
        final deviceChild = DevicePreview.appBuilder(context, child);
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          color: isDark ? const Color(0xFF0D1117) : const Color(0xFFE8EDF3),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: _SplashGate(child: deviceChild),
            ),
          ),
        );
      },
    );
  }
}

class _SplashGate extends StatefulWidget {
  final Widget child;
  const _SplashGate({required this.child});
  @override
  State<_SplashGate> createState() => _SplashGateState();
}

class _SplashGateState extends State<_SplashGate> {
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 4000), () {
      if (mounted) setState(() => _showSplash = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      transitionBuilder: (child, anim) =>
          FadeTransition(opacity: anim, child: child),
      child: _showSplash
          ? const _KavachSplash(key: ValueKey('splash'))
          : KeyedSubtree(key: const ValueKey('app'), child: widget.child),
    );
  }
}

class _KavachSplash extends StatefulWidget {
  const _KavachSplash({super.key});
  @override
  State<_KavachSplash> createState() => _KavachSplashState();
}

class _KavachSplashState extends State<_KavachSplash>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<double> _textFade;

  int _verifyIndex = 0;
  final List<String> _verifyWords = ['Verify', 'सत्यापन', 'पडताळणी'];
  bool _showText = false;

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _textFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _slideController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );

    // After 800ms, slide logo left and show text
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() => _showText = true);
        _slideController.forward();
      }
    });

    // Start cycling after text has appeared
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) _startCycling();
    });
  }

  void _startCycling() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 1200));
      if (!mounted) return false;
      setState(() => _verifyIndex = (_verifyIndex + 1) % _verifyWords.length);
      return mounted;
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedBuilder(
          animation: _slideController,
          builder: (context, child) {
            // Logo moves from center to left as text appears
            final slideProgress = _slideController.value;
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.asset(
                    'assets/images/kavach_logo.png',
                    width: 96,
                    height: 96,
                    fit: BoxFit.cover,
                    alignment: const Alignment(0, -0.15),
                  ),
                ),
                // Text slides in from right
                if (_showText) ...[
                  SizedBox(width: 14 * slideProgress),
                  Opacity(
                    opacity: _textFade.value,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            const Text(
                              'Kavach',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1A237E),
                                letterSpacing: -0.5,
                                height: 1.0,
                              ),
                            ),
                            SizedBox(
                              width: 120,
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 400),
                                transitionBuilder: (child, anim) {
                                  return FadeTransition(
                                    opacity: anim,
                                    child: child,
                                  );
                                },
                                child: Align(
                                  key: ValueKey(_verifyIndex),
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    _verifyWords[_verifyIndex],
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF388E3C),
                                      letterSpacing: -0.3,
                                      height: 1.0,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Truth Shield for the Digital Age',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}
