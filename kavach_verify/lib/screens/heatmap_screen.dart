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
                    ),
                    child: Text(
                      f,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
                        color: sel
                            ? Colors.white
                            : (isDark
                                  ? AppColors.mediumGrey
                                  : AppColors.darkGrey),
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
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 10,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Stack(
                children: [
                  // Map background
                  Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1A2332)
                          : const Color(0xFFE8ECF0),
                    ),
                    child: CustomPaint(
                      painter: _MapPainter(isDark: isDark),
                      size: Size.infinite,
                    ),
                  ),
                  // Heatmap overlay dots
                  ..._buildHeatDots(isDark),
                  // Legend
                  Positioned(
                    bottom: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color:
                            (isDark ? AppColors.darkSurface : AppColors.white)
                                .withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 6,
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
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.white
                                  : AppColors.charcoal,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              _legendDot(
                                const Color(0xFFDC3545).withValues(alpha: 0.7),
                                'Critical',
                              ),
                              const SizedBox(width: 8),
                              _legendDot(
                                const Color(0xFFE8A317).withValues(alpha: 0.7),
                                'High',
                              ),
                              const SizedBox(width: 8),
                              _legendDot(
                                const Color(0xFF2B7DE9).withValues(alpha: 0.6),
                                'Medium',
                              ),
                              const SizedBox(width: 8),
                              _legendDot(
                                AppColors.emeraldGreen.withValues(alpha: 0.5),
                                'Low',
                              ),
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
                                    .withValues(alpha: 0.92),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Live Threats',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? AppColors.white
                                      : AppColors.charcoal,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '2,847',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.danger,
                                ),
                              ),
                              Text(
                                'active today',
                                style: TextStyle(
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
                  _statCol('Hotspots', '12', AppColors.danger),
                  _divider(isDark),
                  _statCol('Regions', '28', AppColors.deepBlueLight),
                  _divider(isDark),
                  _statCol('Resolved', '1,204', AppColors.emeraldGreen),
                  _divider(isDark),
                  _statCol('Pending', '389', AppColors.warning),
                ],
              ),
            )
            .animate()
            .fadeIn(delay: 500.ms, duration: 400.ms)
            .slideY(begin: 0.05, duration: 400.ms, curve: Curves.easeOutCubic),
      ],
    );
  }

  List<Widget> _buildHeatDots(bool isDark) {
    final rng = Random(42);
    final hotspots = <_HeatPoint>[
      _HeatPoint(0.28, 0.35, 0.9, const Color(0xFFDC3545)),
      _HeatPoint(0.45, 0.25, 0.85, const Color(0xFFDC3545)),
      _HeatPoint(0.72, 0.4, 0.8, const Color(0xFFE8A317)),
      _HeatPoint(0.55, 0.6, 0.75, const Color(0xFFE8A317)),
      _HeatPoint(0.35, 0.7, 0.65, const Color(0xFF2B7DE9)),
      _HeatPoint(0.82, 0.55, 0.7, const Color(0xFFE8A317)),
      _HeatPoint(0.18, 0.5, 0.6, const Color(0xFF2B7DE9)),
      _HeatPoint(0.6, 0.15, 0.55, const Color(0xFF2B7DE9)),
      _HeatPoint(0.9, 0.3, 0.5, AppColors.emeraldGreen),
      _HeatPoint(0.15, 0.8, 0.45, AppColors.emeraldGreen),
    ];
    // Add smaller scatter points
    for (int i = 0; i < 20; i++) {
      hotspots.add(
        _HeatPoint(
          rng.nextDouble(),
          rng.nextDouble(),
          0.2 + rng.nextDouble() * 0.3,
          [
            const Color(0xFFDC3545),
            const Color(0xFFE8A317),
            const Color(0xFF2B7DE9),
            AppColors.emeraldGreen,
          ][rng.nextInt(4)],
        ),
      );
    }
    return hotspots.asMap().entries.map((e) {
      final i = e.key;
      final h = e.value;
      return Positioned(
        left: 0,
        top: 0,
        right: 0,
        bottom: 0,
        child: LayoutBuilder(
          builder: (ctx, c) {
            final size = h.intensity * 50 + 15;
            return Stack(
              children: [
                Positioned(
                  left: h.x * c.maxWidth - size / 2,
                  top: h.y * c.maxHeight - size / 2,
                  child:
                      Container(
                            width: size,
                            height: size,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  h.color.withValues(alpha: 0.6),
                                  h.color.withValues(alpha: 0.0),
                                ],
                              ),
                            ),
                          )
                          .animate()
                          .fadeIn(
                            delay: Duration(milliseconds: 200 + i * 40),
                            duration: 500.ms,
                          )
                          .scale(
                            begin: const Offset(0.3, 0.3),
                            delay: Duration(milliseconds: 200 + i * 40),
                            duration: 600.ms,
                            curve: Curves.easeOutCubic,
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
        Text(
          label,
          style: const TextStyle(fontSize: 9, color: AppColors.mediumGrey),
        ),
      ],
    );
  }

  Widget _statCol(String label, String value, Color color) {
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
          style: const TextStyle(fontSize: 10, color: AppColors.mediumGrey),
        ),
      ],
    );
  }

  Widget _divider(bool isDark) {
    return Container(
      width: 1,
      height: 30,
      color: (isDark ? AppColors.mediumGrey : AppColors.lightGrey).withValues(
        alpha: 0.5,
      ),
    );
  }
}

class _HeatPoint {
  final double x, y, intensity;
  final Color color;
  const _HeatPoint(this.x, this.y, this.intensity, this.color);
}

class _MapPainter extends CustomPainter {
  final bool isDark;
  _MapPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final rng = Random(123);
    // Draw grid lines (road-like)
    final gridPaint = Paint()
      ..color = (isDark ? Colors.white : AppColors.deepBlue).withValues(
        alpha: isDark ? 0.04 : 0.06,
      )
      ..strokeWidth = 0.8;
    for (double i = 0; i < size.width; i += 35) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + rng.nextDouble() * 20 - 10, size.height),
        gridPaint,
      );
    }
    for (double i = 0; i < size.height; i += 35) {
      canvas.drawLine(
        Offset(0, i),
        Offset(size.width, i + rng.nextDouble() * 20 - 10),
        gridPaint,
      );
    }
    // Draw some "blocks" (buildings/areas)
    final blockPaint = Paint()
      ..color = (isDark ? Colors.white : AppColors.deepBlue).withValues(
        alpha: isDark ? 0.03 : 0.04,
      );
    for (int i = 0; i < 25; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      final w = 15 + rng.nextDouble() * 40;
      final h = 15 + rng.nextDouble() * 40;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, w, h),
          const Radius.circular(3),
        ),
        blockPaint,
      );
    }
    // Draw some thicker "roads"
    final roadPaint = Paint()
      ..color = (isDark ? Colors.white : AppColors.deepBlue).withValues(
        alpha: isDark ? 0.06 : 0.08,
      )
      ..strokeWidth = 2.5;
    for (int i = 0; i < 6; i++) {
      if (i % 2 == 0) {
        final y = rng.nextDouble() * size.height;
        canvas.drawLine(
          Offset(0, y),
          Offset(size.width, y + rng.nextDouble() * 60 - 30),
          roadPaint,
        );
      } else {
        final x = rng.nextDouble() * size.width;
        canvas.drawLine(
          Offset(x, 0),
          Offset(x + rng.nextDouble() * 60 - 30, size.height),
          roadPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
