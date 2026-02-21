import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../data/mock_data.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final profile = mockProfile;

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
                        profile.communityRank,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${profile.totalVerified} verifications • ${profile.accuracyScore}% accuracy',
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
                    'Top 5%',
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
                  label: 'Text Checks',
                  points: '52',
                  icon: Icons.text_fields_rounded,
                  color: const Color(0xFF5B7DB1),
                  delay: 0,
                ),
                const SizedBox(width: 10),
                _PointCard(
                  label: 'Media Checks',
                  points: '68',
                  icon: Icons.image_rounded,
                  color: const Color(0xFFD4714E),
                  delay: 80,
                ),
                const SizedBox(width: 10),
                _PointCard(
                  label: 'Doc Checks',
                  points: '27',
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
                  'Safety Guidelines',
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
            'Verify Before Sharing',
            'Always fact-check information through multiple credible sources before forwarding messages, posts, or news to others.',
            0,
          ),
          _guideline(
            isDark,
            '🔗',
            'Check URLs Carefully',
            'Look for misspellings in domain names, missing HTTPS, and unusual domain extensions. Hover over links before clicking.',
            1,
          ),
          _guideline(
            isDark,
            '🖼️',
            'Reverse Image Search',
            'Use Google Reverse Image Search to check if photos have been manipulated or taken out of context from older events.',
            2,
          ),
          _guideline(
            isDark,
            '🎙️',
            'Be Wary of Audio Clips',
            'AI-generated voice clones are increasingly realistic. Verify audio claims through official channels before believing them.',
            3,
          ),
          _guideline(
            isDark,
            '📄',
            'Inspect Documents',
            'Check official documents for proper letterheads, file numbers, consistent fonts, and valid digital signatures.',
            4,
          ),
          _guideline(
            isDark,
            '🎥',
            'Spot Deepfake Videos',
            'Look for unnatural blinking, lip-sync issues, blurry edges around faces, and inconsistent lighting in video content.',
            5,
          ),
          _guideline(
            isDark,
            '🚫',
            'Don\'t Spread Panic',
            'If content evokes extreme emotion (fear, anger, outrage), it\'s more likely to be designed to manipulate. Pause and verify.',
            6,
          ),
          _guideline(
            isDark,
            '📱',
            'Use KavachVerify',
            'Submit any suspicious content to KavachVerify for AI-powered analysis. Be part of the solution against misinformation.',
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
