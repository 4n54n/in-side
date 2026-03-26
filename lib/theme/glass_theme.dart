import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GlassTheme {
  // --- Background Gradient ---
  static const Color bgStart = Color(0xFFECECF0);
  static const Color bgEnd = Color(0xFFF6F6F8);

  // Legacy solid (keep for scaffoldBackgroundColor fallback)
  static const Color background = Color(0xFFECECF0);

  // --- Glass Surface Colors ---
  // Low-opacity white fill for glass panels (20% white)
  static const Color surface = Color(0x33FFFFFF);
  // Higher-opacity for nested/inner surfaces (50% white)
  static const Color surfaceHigh = Color(0x80FFFFFF);
  // Opaque surface for dialogs / popups
  static const Color surfaceOpaque = Color(0xF5FFFFFF);

  // --- Glass Border (crisp 75% white) ---
  static const Color glassBorder = Color(0xBFFFFFFF);
  // Legacy subtle border for opaque containers
  static const Color border = Color(0x12000000);

  // --- Text ---
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textMuted = Color(0xFF888888);
  static const Color textSubtle = Color(0xFFBBBBBB);
  static const Color accent = Color(0xFF1A1A1A);

  // --- Semantic ---
  static const Color successBg = Color(0x17059669);
  static const Color successText = Color(0xFF047857);
  static const Color dangerBg = Color(0x17DC2626);
  static const Color dangerText = Color(0xFFDC2626);
  static const Color warningBg = Color(0x14B45309);
  static const Color warningText = Color(0xFFB45309);
  static const Color infoBg = Color(0x142563EB);
  static const Color infoText = Color(0xFF2563EB);

  // --- Shadow Tokens ---
  // Specular inner-top highlight (sharp white, no blur)
  static const BoxShadow specularHighlight = BoxShadow(
    color: Color(0xBBFFFFFF),
    blurRadius: 0,
    offset: Offset(0, 1),
    spreadRadius: 0,
  );
  // Wide, very soft shadow for depth (3% black, large blur)
  static const BoxShadow shadowSoft = BoxShadow(
    color: Color(0x08000000),
    blurRadius: 32,
    offset: Offset(0, 8),
    spreadRadius: 0,
  );
  // A bit crisper mid shadow
  static const BoxShadow shadowMid = BoxShadow(
    color: Color(0x0D000000),
    blurRadius: 12,
    offset: Offset(0, 3),
    spreadRadius: 0,
  );

  // --- Decoration Helpers ---

  /// Premium glass card: low-opacity fill + crisp white border + layered shadows.
  /// Pair with a BackdropFilter (blur σ≈28) wrapper — see GlassCard widget.
  static BoxDecoration glassCard({double radius = 20}) => BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: glassBorder, width: 1.2),
        boxShadow: const [
          specularHighlight,
          shadowMid,
          shadowSoft,
        ],
      );

  /// Slightly more opaque version for App Bar / header panels.
  static BoxDecoration glassPanel({double radius = 0}) => BoxDecoration(
        color: const Color(0x26FFFFFF), // 15% white
        borderRadius: BorderRadius.circular(radius),
        border: const Border(
          bottom: BorderSide(color: Color(0x80FFFFFF), width: 1),
        ),
        boxShadow: const [shadowSoft],
      );

  /// Ghost pill button decoration.
  static BoxDecoration ghostPill({double radius = 12}) => BoxDecoration(
        color: const Color(0x1AFFFFFF),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: glassBorder, width: 1),
        boxShadow: const [specularHighlight, shadowMid],
      );

  /// Content block (more opaque, used in dialogs).
  static BoxDecoration contentBlock({double radius = 18}) => BoxDecoration(
        color: surfaceOpaque,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: border, width: 1),
        boxShadow: const [shadowSoft],
      );

  // --- Typography ---
  static TextStyle get bodyText => GoogleFonts.sora(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: textPrimary,
        letterSpacing: 0.01,
      );

  static TextStyle get pageTitle => GoogleFonts.sora(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        letterSpacing: -0.02,
      );

  static TextStyle get cardTitle => GoogleFonts.sora(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        letterSpacing: -0.01,
      );

  static TextStyle get sectionHeading => GoogleFonts.sora(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      );

  static TextStyle get metaText => GoogleFonts.sora(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: textMuted,
      );

  static TextStyle get mutedText => GoogleFonts.sora(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: textMuted,
      );

  static TextStyle get labelXs => GoogleFonts.sora(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: textMuted,
        letterSpacing: 0.10,
      );

  // --- ThemeData ---
  static ThemeData get theme => ThemeData(
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: accent,
          onPrimary: Colors.white,
          secondary: accent,
          onSecondary: Colors.white,
          error: dangerText,
          onError: Colors.white,
          surface: surfaceOpaque,
          onSurface: textPrimary,
        ),
        scaffoldBackgroundColor: background,
        textTheme: GoogleFonts.soraTextTheme().copyWith(
          bodyMedium: bodyText,
        ),
        useMaterial3: true,
      );
}
