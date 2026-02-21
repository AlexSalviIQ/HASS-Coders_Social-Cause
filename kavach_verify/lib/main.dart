import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'theme/app_theme.dart';
import 'providers/theme_provider.dart';
import 'router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    DevicePreview(
      enabled: true,
      builder: (context) => ChangeNotifierProvider(
        create: (_) => ThemeProvider(),
        child: const KavachVerifyApp(),
      ),
    ),
  );
}

class KavachVerifyApp extends StatelessWidget {
  const KavachVerifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp.router(
      title: 'KavachVerify',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      routerConfig: appRouter,
      locale: DevicePreview.locale(context),
      builder: (context, child) {
        final deviceChild = DevicePreview.appBuilder(context, child);
        return _SplashGate(child: deviceChild);
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
    Future.delayed(const Duration(milliseconds: 2500), () {
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

class _KavachSplash extends StatelessWidget {
  const _KavachSplash({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepBlue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Shield icon
            Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.emeraldGreen,
                        AppColors.emeraldGreenLight,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.emeraldGreen.withValues(alpha: 0.3),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text('🛡️', style: TextStyle(fontSize: 38)),
                  ),
                )
                .animate()
                .fadeIn(duration: 600.ms)
                .scale(
                  begin: const Offset(0.4, 0.4),
                  duration: 700.ms,
                  curve: Curves.easeOutBack,
                ),
            const SizedBox(height: 24),
            // App Name
            const Text(
                  'KavachVerify',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                )
                .animate()
                .fadeIn(delay: 300.ms, duration: 500.ms)
                .slideY(
                  begin: 0.2,
                  delay: 300.ms,
                  duration: 500.ms,
                  curve: Curves.easeOutCubic,
                ),
            const SizedBox(height: 6),
            Text(
              'Truth Shield for the Digital Age',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 13,
              ),
            ).animate().fadeIn(delay: 500.ms, duration: 500.ms),
            const SizedBox(height: 40),
            // Loading dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _SplashDot(delay: 600),
                const SizedBox(width: 6),
                _SplashDot(delay: 750),
                const SizedBox(width: 6),
                _SplashDot(delay: 900),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SplashDot extends StatelessWidget {
  final int delay;
  const _SplashDot({required this.delay});
  @override
  Widget build(BuildContext context) {
    return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: AppColors.emeraldGreen,
            shape: BoxShape.circle,
          ),
        )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .fadeIn(delay: Duration(milliseconds: delay))
        .scaleXY(
          begin: 0.4,
          end: 1.0,
          delay: Duration(milliseconds: delay),
          duration: 600.ms,
          curve: Curves.easeInOut,
        );
  }
}
