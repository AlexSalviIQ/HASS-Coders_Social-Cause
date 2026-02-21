import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../data/mock_data.dart';
import '../models/detection_item.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});
  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<DetectionItem> get _filteredItems {
    if (_searchQuery.isEmpty) return mockDetections;
    final q = _searchQuery.toLowerCase();
    return mockDetections.where((item) {
      return item.title.toLowerCase().contains(q) ||
          item.description.toLowerCase().contains(q) ||
          item.category.toLowerCase().contains(q) ||
          item.location.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final items = _filteredItems;
    return Column(
      children: [
        // Search bar
        Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkCard
                      : AppColors.lightGrey.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : Colors.transparent,
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _searchQuery = v),
                  decoration: InputDecoration(
                    hintText: 'Search detections...',
                    hintStyle: TextStyle(
                      color: AppColors.mediumGrey,
                      fontSize: 13,
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: isDark
                          ? AppColors.deepBlueLight
                          : AppColors.deepBlue,
                      size: 20,
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? GestureDetector(
                            onTap: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                            child: const Icon(
                              Icons.close_rounded,
                              color: AppColors.mediumGrey,
                              size: 18,
                            ),
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? AppColors.white : AppColors.charcoal,
                  ),
                ),
              ),
            )
            .animate()
            .fadeIn(duration: 300.ms)
            .slideY(begin: -0.05, duration: 300.ms, curve: Curves.easeOutCubic),
        // Results info
        if (_searchQuery.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 2),
            child: Text(
              '${items.length} result${items.length != 1 ? 's' : ''} found',
              style: TextStyle(fontSize: 11, color: AppColors.mediumGrey),
            ),
          ),
        // List
        Expanded(
          child: items.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off_rounded,
                        size: 48,
                        color: AppColors.mediumGrey.withValues(alpha: 0.4),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No results for "$_searchQuery"',
                        style: TextStyle(
                          color: AppColors.mediumGrey,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  itemCount: items.length,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) =>
                      _LibraryCard(item: items[index], index: index),
                ),
        ),
      ],
    );
  }
}

class _LibraryCard extends StatelessWidget {
  final DetectionItem item;
  final int index;
  const _LibraryCard({required this.item, required this.index});

  IconData get _categoryIcon {
    switch (item.category) {
      case 'text':
        return Icons.text_fields_rounded;
      case 'image':
        return Icons.image_rounded;
      case 'video':
        return Icons.videocam_rounded;
      case 'voice':
        return Icons.mic_rounded;
      case 'document':
        return Icons.description_rounded;
      case 'link':
        return Icons.link_rounded;
      default:
        return Icons.warning_rounded;
    }
  }

  Color get _categoryColor {
    switch (item.category) {
      case 'text':
        return const Color(0xFF2962FF);
      case 'image':
        return const Color(0xFFFF5252);
      case 'video':
        return const Color(0xFF00C853);
      case 'voice':
        return const Color(0xFF7C4DFF);
      case 'document':
        return const Color(0xFF8B5CF6);
      case 'link':
        return const Color(0xFFF59E0B);
      default:
        return AppColors.danger;
    }
  }

  String get _timeAgo {
    final diff = DateTime.now().difference(item.detectedAt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${diff.inDays ~/ 7}w ago';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
          onTap: () => context.go('/library/detail/${item.id}'),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: (isDark ? Colors.black : AppColors.deepBlue)
                      .withValues(alpha: 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Color bar
                  Container(
                    width: 5,
                    decoration: BoxDecoration(
                      color: _categoryColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(14),
                        bottomLeft: Radius.circular(14),
                      ),
                    ),
                  ),
                  // Icon area
                  Container(
                    width: 52,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: _categoryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            _categoryIcon,
                            color: _categoryColor,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  // Content
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 12, 12, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: isDark
                                  ? AppColors.white
                                  : AppColors.charcoal,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isDark
                                  ? AppColors.mediumGrey
                                  : AppColors.darkGrey,
                              fontSize: 11,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: 11,
                                color: AppColors.mediumGrey,
                              ),
                              const SizedBox(width: 3),
                              Flexible(
                                child: Text(
                                  item.location,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: AppColors.mediumGrey,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: _categoryColor.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  item.category,
                                  style: TextStyle(
                                    color: _categoryColor,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.danger.withValues(
                                    alpha: 0.08,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '${(item.confidenceScore * 100).toInt()}%',
                                  style: const TextStyle(
                                    color: AppColors.danger,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Text(
                                _timeAgo,
                                style: const TextStyle(
                                  color: AppColors.mediumGrey,
                                  fontSize: 9,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Chevron
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.mediumGrey.withValues(alpha: 0.5),
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(
          delay: Duration(milliseconds: 100 + index * 60),
          duration: 300.ms,
        )
        .slideY(
          begin: 0.05,
          delay: Duration(milliseconds: 100 + index * 60),
          duration: 300.ms,
          curve: Curves.easeOutCubic,
        );
  }
}
