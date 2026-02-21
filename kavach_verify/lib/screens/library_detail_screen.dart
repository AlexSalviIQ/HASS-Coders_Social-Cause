import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../data/mock_data.dart';
import '../models/detection_item.dart';
import 'package:intl/intl.dart';

class LibraryDetailScreen extends StatefulWidget {
  final String detectionId;
  const LibraryDetailScreen({super.key, required this.detectionId});

  @override
  State<LibraryDetailScreen> createState() => _LibraryDetailScreenState();
}

class _LibraryDetailScreenState extends State<LibraryDetailScreen> {
  final TextEditingController _commentController = TextEditingController();
  late final DetectionItem item;
  final List<Map<String, String>> _comments = List.from(mockComments);

  @override
  void initState() {
    super.initState();
    item = mockDetections.firstWhere(
      (d) => d.id == widget.detectionId,
      orElse: () => mockDetections.first,
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Color get _catColor {
    switch (item.category) {
      case 'text':
        return const Color(0xFF667EEA);
      case 'image':
        return const Color(0xFFF5576C);
      case 'video':
        return const Color(0xFF43E97B);
      case 'voice':
        return const Color(0xFF4FACFE);
      case 'document':
        return const Color(0xFFF093FB);
      case 'link':
        return const Color(0xFFF39C12);
      default:
        return AppColors.danger;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _catColor.withValues(alpha: 0.15),
                  _catColor.withValues(alpha: 0.03),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.go('/library'),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkCard : AppColors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.arrow_back_rounded,
                          size: 20,
                          color: isDark ? AppColors.white : AppColors.charcoal,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.danger,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        '⚠ FAKE CONTENT',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _catColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${(item.confidenceScore * 100).toInt()}% confidence',
                        style: TextStyle(
                          color: _catColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  item.title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.white : AppColors.charcoal,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: AppColors.mediumGrey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      item.location,
                      style: const TextStyle(
                        color: AppColors.mediumGrey,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.access_time_rounded,
                      size: 14,
                      color: AppColors.mediumGrey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('MMM d, yyyy • HH:mm').format(item.detectedAt),
                      style: const TextStyle(
                        color: AppColors.mediumGrey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms),
          // Description
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Description',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.white : AppColors.charcoal,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? AppColors.mediumGrey : AppColors.darkGrey,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
          // Analysis
          Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : AppColors.offWhite,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.danger.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: AppColors.danger.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.analytics_rounded,
                              size: 16,
                              color: AppColors.danger,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Why It\'s Fake — AI Analysis',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        item.analysisDetails,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? AppColors.mediumGrey
                              : AppColors.darkGrey,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .animate()
              .fadeIn(delay: 300.ms, duration: 400.ms)
              .slideY(
                begin: 0.05,
                duration: 400.ms,
                curve: Curves.easeOutCubic,
              ),
          // Comments Section
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Text(
              'Comments & Feedback',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.white : AppColors.charcoal,
              ),
            ),
          ).animate().fadeIn(delay: 400.ms, duration: 400.ms),
          // Comment Input
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: 'Add a comment...',
                      hintStyle: TextStyle(
                        color: AppColors.mediumGrey,
                        fontSize: 13,
                      ),
                      filled: true,
                      fillColor: isDark
                          ? AppColors.darkCard
                          : AppColors.lightGrey.withValues(alpha: 0.5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                    ),
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? AppColors.white : AppColors.charcoal,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    if (_commentController.text.trim().isNotEmpty) {
                      setState(() {
                        _comments.insert(0, {
                          'user': 'You',
                          'comment': _commentController.text.trim(),
                          'time': 'Just now',
                        });
                        _commentController.clear();
                      });
                    }
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.emeraldGreen,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Comments List
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _comments.length,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            itemBuilder: (context, index) {
              final c = _comments[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: AppColors.deepBlue.withValues(
                            alpha: 0.1,
                          ),
                          child: Text(
                            c['user']![0],
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.deepBlue,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          c['user']!,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: isDark
                                ? AppColors.white
                                : AppColors.charcoal,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          c['time']!,
                          style: const TextStyle(
                            color: AppColors.mediumGrey,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      c['comment']!,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? AppColors.mediumGrey
                            : AppColors.darkGrey,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(
                delay: Duration(milliseconds: 500 + (index * 80)),
                duration: 300.ms,
              );
            },
          ),
        ],
      ),
    );
  }
}
