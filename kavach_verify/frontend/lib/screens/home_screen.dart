import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/detection_item.dart';
import '../services/api_service.dart';
import '../providers/language_provider.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<DetectionItem> _detections = [];
  bool _loadingDetections = true;

  @override
  void initState() {
    super.initState();
    _fetchDetections();
  }

  Future<void> _fetchDetections() async {
    final result = await ApiService.listDetections(limit: 20);
    if (!mounted) return;
    if (result['status'] == 'success') {
      final list = (result['detections'] as List?) ?? [];
      setState(() {
        _detections = list
            .map((d) => DetectionItem.fromJson(d))
            .where((d) => d.isFake)
            .take(3)
            .toList();
        _loadingDetections = false;
      });
    } else {
      setState(() => _loadingDetections = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = Provider.of<LanguageProvider>(context);
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 6),
            child: Text(
              lang.tr('quick_access'),
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.white : AppColors.charcoal,
              ),
            ),
          ).animate().fadeIn(duration: 350.ms),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              lang.tr('pick_content_type'),
              style: TextStyle(
                fontSize: 13,
                color: isDark ? AppColors.mediumGrey : AppColors.darkGrey,
              ),
            ),
          ).animate().fadeIn(delay: 80.ms, duration: 280.ms),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.55,
              children: [
                _QuickAccessCard(
                  icon: Icons.photo_library_rounded,
                  label: lang.tr('image_video'),
                  subtitle: lang.tr('photos_clips'),
                  gradient: const [Color(0xFF1565C0), Color(0xFF1E40AF)],
                  delay: 0,
                  onTap: () => _pickMediaOrVideo(context),
                ),
                _QuickAccessCard(
                  icon: Icons.description_rounded,
                  label: lang.tr('document_verify'),
                  subtitle: lang.tr('pdfs_docs'),
                  gradient: const [Color(0xFF1E40AF), Color(0xFF2563EB)],
                  delay: 80,
                  onTap: () => _pickDocument(context),
                ),
                _QuickAccessCard(
                  icon: Icons.badge_rounded,
                  label: lang.tr('gov_id_check'),
                  subtitle: lang.tr('id_verification'),
                  gradient: const [Color(0xFF2563EB), Color(0xFF3B82F6)],
                  delay: 160,
                  onTap: () => _pickGovID(context),
                ),
                _QuickAccessCard(
                  icon: Icons.flag_rounded,
                  label: lang.tr('report'),
                  subtitle: lang.tr('report_fake_content'),
                  gradient: const [Color(0xFF3B82F6), Color(0xFF60A5FA)],
                  delay: 240,
                  onTap: () => context.go('/report'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    color: AppColors.primaryMuted,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  lang.tr('latest_detections'),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.white : AppColors.charcoal,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => context.go('/library'),
                  child: Text(
                    lang.tr('view_all'),
                    style: TextStyle(
                      color: AppColors.deepBlueLight,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 350.ms, duration: 350.ms),
          const SizedBox(height: 6),
          if (_loadingDetections)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_detections.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Text(
                  lang.tr('no_detections'),
                  style: TextStyle(
                    color: isDark ? AppColors.mediumGrey : AppColors.darkGrey,
                    fontSize: 13,
                  ),
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _detections.length,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              itemBuilder: (context, i) =>
                  _DetectionFeedCard(item: _detections[i], index: i),
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _pickMediaOrVideo(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = Provider.of<LanguageProvider>(context, listen: false);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        margin: const EdgeInsets.all(14),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.mediumGrey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              lang.tr('image_video'),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.white : AppColors.charcoal,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _PickOption(
                  icon: Icons.camera_alt_rounded,
                  label: lang.tr('camera'),
                  color: const Color(0xFF1E40AF),
                  onTap: () async {
                    Navigator.pop(ctx);
                    final file = await ImagePicker().pickImage(
                      source: ImageSource.camera,
                      requestFullMetadata: false,
                    );
                    if (file != null && context.mounted) {
                      context.go(
                        '/chat',
                        extra: {
                          'attachmentPath': file.path,
                          'attachmentType': 'image',
                          'attachmentName': file.name,
                        },
                      );
                    }
                  },
                ),
                _PickOption(
                  icon: Icons.photo_library_rounded,
                  label: lang.tr('gallery'),
                  color: const Color(0xFF2563EB),
                  onTap: () async {
                    Navigator.pop(ctx);
                    final file = await ImagePicker().pickImage(
                      source: ImageSource.gallery,
                      requestFullMetadata: false,
                    );
                    if (file != null && context.mounted) {
                      context.go(
                        '/chat',
                        extra: {
                          'attachmentPath': file.path,
                          'attachmentType': 'image',
                          'attachmentName': file.name,
                        },
                      );
                    }
                  },
                ),
                _PickOption(
                  icon: Icons.videocam_rounded,
                  label: lang.tr('video'),
                  color: const Color(0xFF3B82F6),
                  onTap: () async {
                    Navigator.pop(ctx);
                    final file = await ImagePicker().pickVideo(
                      source: ImageSource.gallery,
                    );
                    if (file != null && context.mounted) {
                      context.go(
                        '/chat',
                        extra: {
                          'attachmentPath': file.path,
                          'attachmentType': 'video',
                          'attachmentName': file.name,
                        },
                      );
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ).animate().fadeIn(duration: 180.ms),
    );
  }

  void _pickDocument(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt'],
      );
      if (result != null && result.files.isNotEmpty && context.mounted) {
        context.go(
          '/chat',
          extra: {
            'attachmentPath': result.files.single.path,
            'attachmentType': 'document',
            'attachmentName': result.files.single.name,
          },
        );
      }
    } catch (e) {
      // file pick cancelled
    }
  }

  void _pickGovID(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = Provider.of<LanguageProvider>(context, listen: false);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) =>
          Container(
                margin: const EdgeInsets.all(14),
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 32,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.mediumGrey.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      lang.tr('gov_id_check'),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.white : AppColors.charcoal,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _PickOption(
                          icon: Icons.camera_alt_rounded,
                          label: lang.tr('capture_id'),
                          color: const Color(0xFF2563EB),
                          onTap: () async {
                            Navigator.pop(ctx);
                            final file = await ImagePicker().pickImage(
                              source: ImageSource.camera,
                              requestFullMetadata: false,
                            );
                            if (file != null && context.mounted) {
                              context.go(
                                '/chat',
                                extra: {
                                  'attachmentPath': file.path,
                                  'attachmentType': 'govid',
                                  'attachmentName': file.name,
                                },
                              );
                            }
                          },
                        ),
                        _PickOption(
                          icon: Icons.upload_file_rounded,
                          label: lang.tr('upload_id'),
                          color: const Color(0xFF0EA5E9),
                          onTap: () async {
                            Navigator.pop(ctx);
                            final file = await ImagePicker().pickImage(
                              source: ImageSource.gallery,
                              requestFullMetadata: false,
                            );
                            if (file != null && context.mounted) {
                              context.go(
                                '/chat',
                                extra: {
                                  'attachmentPath': file.path,
                                  'attachmentType': 'govid',
                                  'attachmentName': file.name,
                                },
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              )
              .animate()
              .slideY(begin: 0.25, duration: 280.ms, curve: Curves.easeOutCubic)
              .fadeIn(duration: 180.ms),
    );
  }
}

class _PickOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _PickOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.lightGrey
                  : AppColors.darkGrey,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAccessCard extends StatelessWidget {
  final IconData icon;
  final String label, subtitle;
  final List<Color> gradient;
  final int delay;
  final VoidCallback onTap;
  const _QuickAccessCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.gradient,
    required this.delay,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: onTap,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: gradient[0].withValues(alpha: 0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(icon, color: Colors.white, size: 20),
                    ),
                    const Spacer(),
                    Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(
          delay: Duration(milliseconds: 180 + delay),
          duration: 350.ms,
        )
        .scale(
          begin: const Offset(0.96, 0.96),
          delay: Duration(milliseconds: 180 + delay),
          duration: 350.ms,
          curve: Curves.easeOutCubic,
        );
  }
}

class _DetectionFeedCard extends StatelessWidget {
  final DetectionItem item;
  final int index;
  const _DetectionFeedCard({required this.item, required this.index});

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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = Provider.of<LanguageProvider>(context);
    final timeAgo = _formatTimeAgo(item.detectedAt, lang);
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
              blurRadius: 8,
              offset: const Offset(0, 3),
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
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.danger.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              lang.tr('fake_badge'),
                              style: TextStyle(
                                color: AppColors.danger,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _categoryColor.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(5),
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
                          Text(
                            timeAgo,
                            style: const TextStyle(
                              color: AppColors.mediumGrey,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
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
                      const SizedBox(height: 3),
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
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 12,
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
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _categoryColor.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              '${(item.confidenceScore * 100).toInt()}%',
                              style: TextStyle(
                                color: _categoryColor,
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(
      delay: Duration(milliseconds: 400 + (index * 80)),
      duration: 350.ms,
    );
  }

  String _formatTimeAgo(DateTime dt, LanguageProvider lang) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}${lang.tr('time_m_ago')}';
    if (diff.inHours < 24) return '${diff.inHours}${lang.tr('time_h_ago')}';
    if (diff.inDays < 7) return '${diff.inDays}${lang.tr('time_d_ago')}';
    return DateFormat('MMM d').format(dt);
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
}
