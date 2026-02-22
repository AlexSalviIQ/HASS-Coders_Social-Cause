import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import '../providers/auth_provider.dart';
import '../providers/language_provider.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  Map<String, dynamic> _stats = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    final result = await ApiService.getCommunityStats();
    if (!mounted) return;
    if (result['status'] == 'success') {
      setState(() {
        _stats = result;
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final lang = Provider.of<LanguageProvider>(context);

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Rank Banner
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.deepBlue, AppColors.deepBlueLight],
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Center(
                    child: Text('🏆', style: TextStyle(fontSize: 26)),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        auth.communityRank.isNotEmpty
                            ? auth.communityRank
                            : lang.tr('fact_checker'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${auth.totalVerified} ${lang.tr('verifications')} • ${_stats['accuracy_score'] ?? 95}% ${lang.tr('accuracy')}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    lang.tr('top_5_percent'),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms),
          // Points Breakdown
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _PointCard(
                  label: lang.tr('text_checks'),
                  points: '${_stats['text_checks'] ?? 0}',
                  icon: Icons.text_fields_rounded,
                  color: const Color(0xFF5B7DB1),
                  delay: 0,
                ),
                const SizedBox(width: 10),
                _PointCard(
                  label: lang.tr('media_checks'),
                  points: '${_stats['media_checks'] ?? 0}',
                  icon: Icons.image_rounded,
                  color: const Color(0xFFD4714E),
                  delay: 80,
                ),
                const SizedBox(width: 10),
                _PointCard(
                  label: lang.tr('doc_checks'),
                  points: '${_stats['doc_checks'] ?? 0}',
                  icon: Icons.description_rounded,
                  color: const Color(0xFF7B68AE),
                  delay: 160,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Safety Guidelines
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    color: AppColors.emeraldGreen,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  lang.tr('safety_guidelines'),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.white : AppColors.charcoal,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
          _guideline(
            isDark,
            '🔍',
            lang.tr('guideline_1_title'),
            lang.tr('guideline_1_desc'),
            0,
          ),
          _guideline(
            isDark,
            '🔗',
            lang.tr('guideline_2_title'),
            lang.tr('guideline_2_desc'),
            1,
          ),
          _guideline(
            isDark,
            '🖼️',
            lang.tr('guideline_3_title'),
            lang.tr('guideline_3_desc'),
            2,
          ),
          _guideline(
            isDark,
            '🎙️',
            lang.tr('guideline_4_title'),
            lang.tr('guideline_4_desc'),
            3,
          ),
          _guideline(
            isDark,
            '📄',
            lang.tr('guideline_5_title'),
            lang.tr('guideline_5_desc'),
            4,
          ),
          _guideline(
            isDark,
            '🎥',
            lang.tr('guideline_6_title'),
            lang.tr('guideline_6_desc'),
            5,
          ),
          _guideline(
            isDark,
            '🚫',
            lang.tr('guideline_7_title'),
            lang.tr('guideline_7_desc'),
            6,
          ),
          _guideline(
            isDark,
            '📱',
            lang.tr('guideline_8_title'),
            lang.tr('guideline_8_desc'),
            7,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _guideline(
    bool isDark,
    String emoji,
    String title,
    String desc,
    int idx,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.white : AppColors.charcoal,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.mediumGrey : AppColors.darkGrey,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(
      delay: Duration(milliseconds: 350 + idx * 60),
      duration: 350.ms,
    );
  }
}

class _PointCard extends StatelessWidget {
  final String label, points;
  final IconData icon;
  final Color color;
  final int delay;
  const _PointCard({
    required this.label,
    required this.points,
    required this.icon,
    required this.color,
    required this.delay,
  });
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(height: 6),
            Text(
              points,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.white : AppColors.charcoal,
              ),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: AppColors.mediumGrey),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(
      delay: Duration(milliseconds: 150 + delay),
      duration: 350.ms,
    );
  }
}
