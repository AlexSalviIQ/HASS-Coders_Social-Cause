import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/detection_item.dart';
import '../services/api_service.dart';
import '../providers/language_provider.dart';

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
    final lang = Provider.of<LanguageProvider>(context);
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
                hintText: lang.tr('search_detections'),
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
              '${items.length} ${items.length != 1 ? lang.tr('results_found') : lang.tr('result_found')}',
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
                            ? '${lang.tr('no_results_for')} "$_searchQuery"'
                            : lang.tr('no_detections'),
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

  String _timeAgo(LanguageProvider lang) {
    final diff = DateTime.now().difference(item.detectedAt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}${lang.tr('time_m_ago')}';
    if (diff.inHours < 24) return '${diff.inHours}${lang.tr('time_h_ago')}';
    if (diff.inDays < 7) return '${diff.inDays}${lang.tr('time_d_ago')}';
    return '${diff.inDays ~/ 7}${lang.tr('time_w_ago')}';
  }

  String _categoryLabel(LanguageProvider lang) {
    switch (item.category) {
      case 'text':
        return lang.tr('cat_text');
      case 'image':
        return lang.tr('cat_image');
      case 'video':
        return lang.tr('cat_video');
      case 'voice':
        return lang.tr('cat_voice');
      case 'document':
        return lang.tr('cat_document');
      case 'link':
        return lang.tr('cat_link');
      default:
        return item.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = Provider.of<LanguageProvider>(context);
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
                        lang.trContent(item.title),
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
                        lang.trContent(item.description),
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
                              _categoryLabel(lang),
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
                            _timeAgo(lang),
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
