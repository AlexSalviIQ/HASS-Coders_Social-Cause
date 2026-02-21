import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math';
import '../theme/app_theme.dart';

class HeatmapScreen extends StatefulWidget {
  const HeatmapScreen({super.key});
  @override
  State<HeatmapScreen> createState() => _HeatmapScreenState();
}

class _HeatmapScreenState extends State<HeatmapScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Text', 'Image', 'Video', 'Document'];
  final TransformationController _transformController =
      TransformationController();

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        // Filter chips
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _filters.length,
            itemBuilder: (context, i) {
              final f = _filters[i];
              final sel = _selectedFilter == f;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedFilter = f),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: sel
                          ? AppColors.deepBlue
                          : (isDark ? AppColors.darkCard : AppColors.lightGrey),
                      borderRadius: BorderRadius.circular(20),
                      border: sel
                          ? null
                          : Border.all(
                              color: isDark
                                  ? AppColors.darkBorder
                                  : AppColors.lightGrey,
                              width: 1,
                            ),
                    ),
                    child: Text(
                      f,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
                        color: sel
                            ? Colors.white
                            : (isDark ? AppColors.white : AppColors.darkGrey),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        // Map area
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 12,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Stack(
                children: [
                  // Zoomable map
                  InteractiveViewer(
                    transformationController: _transformController,
                    minScale: 0.8,
                    maxScale: 5.0,
                    boundaryMargin: const EdgeInsets.all(60),
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1B2838)
                            : const Color(0xFFE8EEF4),
                      ),
                      child: CustomPaint(
                        painter: _GoogleMapPainter(isDark: isDark),
                        child: Stack(children: _buildHeatSpots(isDark)),
                      ),
                    ),
                  ),
                  // Zoom controls
                  Positioned(
                    right: 12,
                    bottom: 12,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _zoomButton(Icons.add_rounded, isDark, () {
                          final s = _transformController.value
                              .getMaxScaleOnAxis();
                          if (s < 5.0) {
                            _transformController.value =
                                _transformController.value *
                                Matrix4.diagonal3Values(1.3, 1.3, 1);
                          }
                        }),
                        const SizedBox(height: 4),
                        _zoomButton(Icons.remove_rounded, isDark, () {
                          final s = _transformController.value
                              .getMaxScaleOnAxis();
                          if (s > 0.8) {
                            _transformController.value =
                                _transformController.value *
                                Matrix4.diagonal3Values(0.77, 0.77, 1);
                          }
                        }),
                        const SizedBox(height: 4),
                        _zoomButton(Icons.my_location_rounded, isDark, () {
                          _transformController.value = Matrix4.identity();
                        }),
                      ],
                    ),
                  ).animate().fadeIn(delay: 700.ms, duration: 400.ms),
                  // Legend
                  Positioned(
                    bottom: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color:
                            (isDark ? AppColors.darkSurface : AppColors.white)
                                .withValues(alpha: 0.94),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Threat Density',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? AppColors.white
                                  : AppColors.charcoal,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              _legendDot(const Color(0xFFEF4444), 'Critical'),
                              const SizedBox(width: 8),
                              _legendDot(const Color(0xFFF59E0B), 'High'),
                              const SizedBox(width: 8),
                              _legendDot(const Color(0xFF3B82F6), 'Medium'),
                              const SizedBox(width: 8),
                              _legendDot(const Color(0xFF10B981), 'Low'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: 600.ms, duration: 400.ms),
                  // Stats panel
                  Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color:
                                (isDark
                                        ? AppColors.darkSurface
                                        : AppColors.white)
                                    .withValues(alpha: 0.94),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: AppColors.danger,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Text(
                                    'LIVE',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.danger,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _selectedFilter == 'All'
                                    ? '2,847'
                                    : _filteredCount,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? AppColors.white
                                      : AppColors.charcoal,
                                ),
                              ),
                              Text(
                                _selectedFilter == 'All'
                                    ? 'active threats'
                                    : '${_selectedFilter.toLowerCase()} threats',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: AppColors.mediumGrey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .animate()
                      .fadeIn(delay: 400.ms, duration: 400.ms)
                      .slideX(
                        begin: 0.1,
                        duration: 400.ms,
                        curve: Curves.easeOutCubic,
                      ),
                  // Search bar
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color:
                            (isDark ? AppColors.darkSurface : AppColors.white)
                                .withValues(alpha: 0.94),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.search_rounded,
                            size: 16,
                            color: isDark
                                ? AppColors.white
                                : AppColors.darkGrey,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Search location...',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.mediumGrey,
                            ),
                          ),
                          const SizedBox(width: 30),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: 500.ms, duration: 400.ms),
                ],
              ),
            ),
          ),
        ),
        // Bottom stats bar
        Container(
              margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightGrey,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _statCol('Hotspots', '12', AppColors.danger, isDark),
                  _divider(isDark),
                  _statCol('Regions', '28', AppColors.deepBlueLight, isDark),
                  _divider(isDark),
                  _statCol('Resolved', '1,204', AppColors.emeraldGreen, isDark),
                  _divider(isDark),
                  _statCol('Pending', '389', AppColors.warning, isDark),
                ],
              ),
            )
            .animate()
            .fadeIn(delay: 500.ms, duration: 400.ms)
            .slideY(begin: 0.05, duration: 400.ms, curve: Curves.easeOutCubic),
      ],
    );
  }

  String get _filteredCount {
    switch (_selectedFilter) {
      case 'Text':
        return '892';
      case 'Image':
        return '634';
      case 'Video':
        return '421';
      case 'Document':
        return '900';
      default:
        return '2,847';
    }
  }

  Widget _zoomButton(IconData icon, bool isDark, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: (isDark ? AppColors.darkSurface : AppColors.white).withValues(
            alpha: 0.94,
          ),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 18,
          color: isDark ? AppColors.white : AppColors.darkGrey,
        ),
      ),
    );
  }

  List<Widget> _buildHeatSpots(bool isDark) {
    final rng = Random(42);
    final hotspots = <_HeatPoint>[
      _HeatPoint(0.32, 0.28, 1.0, const Color(0xFFEF4444), 'Delhi NCR', 'text'),
      _HeatPoint(0.48, 0.35, 0.9, const Color(0xFFEF4444), 'Mumbai', 'image'),
      _HeatPoint(
        0.72,
        0.42,
        0.85,
        const Color(0xFFF59E0B),
        'Bangalore',
        'video',
      ),
      _HeatPoint(0.55, 0.58, 0.75, const Color(0xFFF59E0B), 'Chennai', 'text'),
      _HeatPoint(
        0.25,
        0.65,
        0.7,
        const Color(0xFF3B82F6),
        'Kolkata',
        'document',
      ),
      _HeatPoint(
        0.82,
        0.25,
        0.65,
        const Color(0xFFF59E0B),
        'Hyderabad',
        'image',
      ),
      _HeatPoint(
        0.15,
        0.45,
        0.55,
        const Color(0xFF3B82F6),
        'Ahmedabad',
        'video',
      ),
      _HeatPoint(0.65, 0.72, 0.5, const Color(0xFF10B981), 'Pune', 'document'),
      _HeatPoint(0.88, 0.55, 0.45, const Color(0xFF10B981), 'Jaipur', 'text'),
      _HeatPoint(0.4, 0.8, 0.4, const Color(0xFF10B981), 'Lucknow', 'image'),
    ];
    // Scatter dots
    final categories = ['text', 'image', 'video', 'document'];
    for (int i = 0; i < 15; i++) {
      hotspots.add(
        _HeatPoint(
          rng.nextDouble(),
          rng.nextDouble(),
          0.15 + rng.nextDouble() * 0.3,
          [
            const Color(0xFFEF4444),
            const Color(0xFFF59E0B),
            const Color(0xFF3B82F6),
            const Color(0xFF10B981),
          ][rng.nextInt(4)],
          '',
          categories[rng.nextInt(4)],
        ),
      );
    }
    // Apply filter
    final filtered = _selectedFilter == 'All'
        ? hotspots
        : hotspots
              .where(
                (h) =>
                    h.category.toLowerCase() == _selectedFilter.toLowerCase(),
              )
              .toList();
    return filtered.asMap().entries.map((e) {
      final i = e.key;
      final h = e.value;
      return Positioned(
        left: 0,
        top: 0,
        right: 0,
        bottom: 0,
        child: LayoutBuilder(
          builder: (ctx, c) {
            final radius = h.intensity * 55 + 12;
            final x = h.x * c.maxWidth - radius / 2;
            final y = h.y * c.maxHeight - radius / 2;
            return Stack(
              children: [
                // Glow
                Positioned(
                  left: x,
                  top: y,
                  child:
                      Container(
                            width: radius,
                            height: radius,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  h.color.withValues(alpha: 0.5),
                                  h.color.withValues(alpha: 0.0),
                                ],
                              ),
                            ),
                          )
                          .animate()
                          .fadeIn(
                            delay: Duration(milliseconds: 200 + i * 50),
                            duration: 600.ms,
                          )
                          .scale(
                            begin: const Offset(0.3, 0.3),
                            delay: Duration(milliseconds: 200 + i * 50),
                            duration: 700.ms,
                            curve: Curves.easeOutCubic,
                          ),
                ),
                // Center dot
                if (h.intensity > 0.35)
                  Positioned(
                    left: h.x * c.maxWidth - 5,
                    top: h.y * c.maxHeight - 5,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: h.color,
                        boxShadow: [
                          BoxShadow(
                            color: h.color.withValues(alpha: 0.5),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                  ),
                // Label
                if (h.label.isNotEmpty && h.intensity > 0.5)
                  Positioned(
                    left: h.x * c.maxWidth + 8,
                    top: h.y * c.maxHeight - 8,
                    child:
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color:
                                (isDark
                                        ? AppColors.darkSurface
                                        : AppColors.white)
                                    .withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Text(
                            h.label,
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.white
                                  : AppColors.charcoal,
                            ),
                          ),
                        ).animate().fadeIn(
                          delay: Duration(milliseconds: 600 + i * 60),
                          duration: 400.ms,
                        ),
                  ),
              ],
            );
          },
        ),
      );
    }).toList();
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 3),
        Text(label, style: TextStyle(fontSize: 9, color: AppColors.mediumGrey)),
      ],
    );
  }

  Widget _statCol(String label, String value, Color color, bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isDark ? AppColors.mediumGrey : AppColors.darkGrey,
          ),
        ),
      ],
    );
  }

  Widget _divider(bool isDark) {
    return Container(
      width: 1,
      height: 30,
      color: isDark ? AppColors.darkBorder : AppColors.lightGrey,
    );
  }
}

class _HeatPoint {
  final double x, y, intensity;
  final Color color;
  final String label;
  final String category;
  const _HeatPoint(
    this.x,
    this.y,
    this.intensity,
    this.color,
    this.label,
    this.category,
  );
}

class _GoogleMapPainter extends CustomPainter {
  final bool isDark;
  _GoogleMapPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final rng = Random(456);

    // Background land areas
    final landPaint = Paint()
      ..color = isDark ? const Color(0xFF1F3044) : const Color(0xFFDDE8D6);
    for (int i = 0; i < 8; i++) {
      final cx = rng.nextDouble() * size.width;
      final cy = rng.nextDouble() * size.height;
      final r = 40 + rng.nextDouble() * 120;
      canvas.drawOval(
        Rect.fromCenter(center: Offset(cx, cy), width: r * 1.5, height: r),
        landPaint,
      );
    }

    // Water features
    final waterPaint = Paint()
      ..color = isDark ? const Color(0xFF162335) : const Color(0xFFB8D4E3);
    final waterPath = Path();
    waterPath.moveTo(0, size.height * 0.6);
    waterPath.quadraticBezierTo(
      size.width * 0.2,
      size.height * 0.55,
      size.width * 0.35,
      size.height * 0.65,
    );
    waterPath.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.75,
      size.width * 0.7,
      size.height * 0.6,
    );
    waterPath.lineTo(size.width, size.height * 0.65);
    waterPath.lineTo(size.width, size.height);
    waterPath.lineTo(0, size.height);
    waterPath.close();
    canvas.drawPath(waterPath, waterPaint);

    final waterPath2 = Path();
    waterPath2.moveTo(size.width * 0.6, 0);
    waterPath2.quadraticBezierTo(
      size.width * 0.7,
      size.height * 0.1,
      size.width * 0.8,
      size.height * 0.05,
    );
    waterPath2.lineTo(size.width, 0);
    waterPath2.close();
    canvas.drawPath(waterPath2, waterPaint);

    // Major roads
    final majorRoadPaint = Paint()
      ..color = isDark ? const Color(0xFF2A3F55) : const Color(0xFFCCD4DC)
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(0, size.height * 0.3),
      Offset(size.width, size.height * 0.28),
      majorRoadPaint,
    );
    canvas.drawLine(
      Offset(0, size.height * 0.52),
      Offset(size.width, size.height * 0.55),
      majorRoadPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.25, 0),
      Offset(size.width * 0.28, size.height),
      majorRoadPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.65, 0),
      Offset(size.width * 0.62, size.height),
      majorRoadPaint,
    );

    // Minor roads grid
    final minorRoadPaint = Paint()
      ..color = isDark ? const Color(0xFF243344) : const Color(0xFFD5DCE4)
      ..strokeWidth = 1.2;

    for (double x = 0; x < size.width; x += 45 + rng.nextDouble() * 20) {
      final yOff = rng.nextDouble() * 15 - 7;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x + yOff, size.height),
        minorRoadPaint,
      );
    }
    for (double y = 0; y < size.height; y += 45 + rng.nextDouble() * 20) {
      final xOff = rng.nextDouble() * 15 - 7;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y + xOff),
        minorRoadPaint,
      );
    }

    // Building blocks
    final buildingPaint = Paint()
      ..color = isDark ? const Color(0xFF1A2838) : const Color(0xFFDAE0E6);
    for (int i = 0; i < 35; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      final w = 8 + rng.nextDouble() * 30;
      final h = 8 + rng.nextDouble() * 25;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, w, h),
          const Radius.circular(2),
        ),
        buildingPaint,
      );
    }

    // Park areas
    final parkPaint = Paint()
      ..color = isDark ? const Color(0xFF1A3028) : const Color(0xFFC8E6C9);
    for (int i = 0; i < 5; i++) {
      final cx = rng.nextDouble() * size.width;
      final cy = rng.nextDouble() * size.height * 0.5;
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(cx, cy),
          width: 30 + rng.nextDouble() * 50,
          height: 25 + rng.nextDouble() * 35,
        ),
        parkPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
