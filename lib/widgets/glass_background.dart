import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/glass_theme.dart';

/// Scaffold-level background.
/// Renders a soft off-white gradient with two large blurred colour blobs
/// (top-right and bottom-left) for an atmospheric, premium feel.
class GlassBackground extends StatelessWidget {
  final Widget child;
  const GlassBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [GlassTheme.bgStart, GlassTheme.bgEnd],
        ),
      ),
      child: Stack(
        children: [
          // Top-right ambient blob
          Positioned(
            top: -80,
            right: -60,
            child: _Blob(
              size: 280,
              color: const Color(0x18C4C9FF),
            ),
          ),
          // Bottom-left ambient blob
          Positioned(
            bottom: -60,
            left: -80,
            child: _Blob(
              size: 240,
              color: const Color(0x14D0D8FF),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

/// A blurred, coloured circle used as an ambient light blob.
class _Blob extends StatelessWidget {
  final double size;
  final Color color;

  const _Blob({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
