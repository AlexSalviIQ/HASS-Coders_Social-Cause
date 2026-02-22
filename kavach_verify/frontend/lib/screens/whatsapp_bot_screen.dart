import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';

class WhatsAppBotScreen extends StatelessWidget {
  const WhatsAppBotScreen({super.key});

  static const _whatsappLink =
      'https://wa.me/14155238886?text=join%20typical-nest';

  Future<void> _openWhatsApp() async {
    final uri = Uri.parse(_whatsappLink);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      try {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          // ── Hero header ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 36, 24, 28),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF128C7E), Color(0xFF25D366)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(
                    Icons.smart_toy_rounded,
                    color: Colors.white,
                    size: 34,
                  ),
                ).animate().scale(duration: 400.ms, curve: Curves.easeOut),
                const SizedBox(height: 14),
                const Text(
                  'KavachVerify Bot',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ).animate().fadeIn(delay: 100.ms, duration: 350.ms),
                const SizedBox(height: 6),
                Text(
                  'Your AI-powered truth shield on WhatsApp',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ).animate().fadeIn(delay: 200.ms, duration: 350.ms),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── QR Card ──
          Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(
                      color: isDark
                          ? AppColors.darkBorder
                          : Colors.grey.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Scan to Connect',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.white : AppColors.charcoal,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Scan this QR code with your phone camera',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? AppColors.mediumGrey
                              : AppColors.darkGrey,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            'assets/images/qrcode.jpeg',
                            width: 200,
                            height: 200,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'or tap the button below',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark
                              ? AppColors.mediumGrey
                              : AppColors.darkGrey,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .animate()
              .fadeIn(delay: 250.ms, duration: 400.ms)
              .slideY(begin: 0.05, end: 0, delay: 250.ms, duration: 400.ms),

          const SizedBox(height: 20),

          // ── Chat Button ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _openWhatsApp,
                icon: const Icon(Icons.chat, size: 20),
                label: const Text(
                  'Chat on WhatsApp',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 4,
                  shadowColor: const Color(0xFF25D366).withValues(alpha: 0.4),
                ),
              ),
            ),
          ).animate().fadeIn(delay: 400.ms, duration: 350.ms),

          const SizedBox(height: 28),

          // ── What the Bot Can Do ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'What the Bot Can Do',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.white : AppColors.charcoal,
                  ),
                ),
                const SizedBox(height: 14),
                _FeatureTile(
                  icon: Icons.image_search_rounded,
                  title: 'Verify Images & Videos',
                  subtitle: 'Send media to detect deepfakes & manipulations',
                  color: const Color(0xFF1E40AF),
                  isDark: isDark,
                ),
                _FeatureTile(
                  icon: Icons.description_rounded,
                  title: 'Analyze Documents',
                  subtitle: 'Forward PDFs & docs for authenticity checks',
                  color: const Color(0xFF2563EB),
                  isDark: isDark,
                ),
                _FeatureTile(
                  icon: Icons.record_voice_over_rounded,
                  title: 'Audio Analysis',
                  subtitle: 'Send voice notes to detect AI-generated speech',
                  color: const Color(0xFF3B82F6),
                  isDark: isDark,
                ),
                _FeatureTile(
                  icon: Icons.speed_rounded,
                  title: 'Instant Results',
                  subtitle: 'Get a detailed verification report in seconds',
                  color: const Color(0xFF0EA5E9),
                  isDark: isDark,
                ),
              ],
            ),
          ).animate().fadeIn(delay: 500.ms, duration: 400.ms),

          const SizedBox(height: 24),

          // ── How It Works ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkBorder.withValues(alpha: 0.4)
                    : AppColors.offWhite,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'How It Works',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.white : AppColors.charcoal,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _StepRow(
                    step: '1',
                    text: 'Send "join typical-nest" to activate the bot',
                    isDark: isDark,
                  ),
                  const SizedBox(height: 8),
                  _StepRow(
                    step: '2',
                    text: 'Forward any suspicious content to the bot',
                    isDark: isDark,
                  ),
                  const SizedBox(height: 8),
                  _StepRow(
                    step: '3',
                    text: 'Receive an AI-powered verification report',
                    isDark: isDark,
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(delay: 600.ms, duration: 400.ms),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ── Helper widgets ──

class _FeatureTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final bool isDark;

  const _FeatureTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.white : AppColors.charcoal,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? AppColors.mediumGrey : AppColors.darkGrey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  final String step;
  final String text;
  final bool isDark;

  const _StepRow({
    required this.step,
    required this.text,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: const Color(0xFF25D366).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(7),
          ),
          child: Center(
            child: Text(
              step,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF25D366),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppColors.mediumGrey : AppColors.darkGrey,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
