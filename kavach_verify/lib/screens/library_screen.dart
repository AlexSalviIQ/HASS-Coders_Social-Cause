import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../models/detection_item.dart';
import '../services/api_service.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});
  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<DetectionItem> _allDetections = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchDetections();
  }

  Future<void> _fetchDetections() async {
    final result = await ApiService.listDetections();
    if (!mounted) return;
    if (result['status'] == 'success') {
      final list = (result['detections'] as List?) ?? [];
      setState(() {
        _allDetections = list.map((d) => DetectionItem.fromJson(d)).toList();
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<DetectionItem> get _filteredItems {
    if (_searchQuery.isEmpty) return _allDetections;
    final q = _searchQuery.toLowerCase();
    return _allDetections.where((item) {
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
                hintStyle: TextStyle(color: AppColors.mediumGrey, fontSize: 13),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: isDark ? AppColors.deepBlueLight : AppColors.deepBlue,
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
        ).animate().fadeIn(duration: 300.ms),
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
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : items.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _searchQuery.isNotEmpty
                            ? Icons.search_off_rounded
                            : Icons.inbox_rounded,
                        size: 48,
                        color: AppColors.mediumGrey.withValues(alpha: 0.4),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _searchQuery.isNotEmpty
                            ? 'No results for "$_searchQuery"'
                            : 'No detections yet',
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

  Color get _categoryColor {
    switch (item.category) {
      case 'text':
        return AppColors.catText;
      case 'image':
        return AppColors.catImage;
      case 'video':
        return AppColors.catVideo;
      case 'voice':
        return AppColors.catVoice;
      case 'document':
        return AppColors.catDocument;
      case 'link':
        return AppColors.catLink;
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
              color: (isDark ? Colors.black : AppColors.deepBlue).withValues(
                alpha: 0.04,
              ),
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
              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 12, 12, 12),
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
                          color: isDark ? AppColors.white : AppColors.charcoal,
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
                              color: AppColors.danger.withValues(alpha: 0.08),
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
    ).animate().fadeIn(
      delay: Duration(milliseconds: 100 + index * 60),
      duration: 300.ms,
    );
  }
}
