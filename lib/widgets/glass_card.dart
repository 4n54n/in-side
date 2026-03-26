import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/glass_theme.dart';

/// A reusable glass panel widget.
///
/// Wraps [child] in:
///   ClipRRect → BackdropFilter (blur σ=[sigma]) → Container (glassCard decoration)
///
/// Usage:
/// ```dart
/// GlassCard(
///   child: Padding(padding: EdgeInsets.all(18), child: ...),
/// )
/// ```
class GlassCard extends StatelessWidget {
  final Widget child;
  final double radius;
  final double sigma;
  final EdgeInsetsGeometry? padding;

  const GlassCard({
    super.key,
    required this.child,
    this.radius = 20,
    this.sigma = 28,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = child;
    if (padding != null) {
      content = Padding(padding: padding!, child: content);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
        child: Container(
          decoration: GlassTheme.glassCard(radius: radius),
          child: content,
        ),
      ),
    );
  }
}
