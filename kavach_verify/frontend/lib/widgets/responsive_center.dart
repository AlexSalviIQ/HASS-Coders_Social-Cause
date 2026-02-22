import 'package:flutter/material.dart';

/// Wraps content in a centered, max-width constrained container.
/// On narrow screens (< maxWidth), content fills the full width.
/// On wide screens (>= maxWidth), content is centered with a background.
class ResponsiveCenter extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const ResponsiveCenter({super.key, required this.child, this.maxWidth = 600});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
