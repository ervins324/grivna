import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Monochrome Base Palette (Dark-First Minimalist)
  static const Color background = Color(0xFF070709); // Deep OLED black
  static const Color surface = Color(0xFF131316);    // Zinc 920
  static const Color surfaceElevated = Color(0xFF1F1F24); // Zinc 850
  static const Color surfaceHighlight = Color(0xFF2E2E36); // Zinc 750
  
  // Borders & Dividers
  static const Color border = Color(0xFF26262D);
  static const Color borderSubtle = Color(0xFF1A1A20);
  static const Color borderFocused = Color(0xFFFAFAFA);

  // Dynamic Accent Color (default Neon Matrix)
  static Color currentAccent = const Color(0xFF00FF87);

  // Soft Neon Light Palette
  static Color get neonGreen => currentAccent;
  static Color get neonGreenBright => currentAccent.withValues(alpha: 0.9);
  static Color get neonGreenMuted => currentAccent.withValues(alpha: 0.7);
  static Color get neonGreenGlow => currentAccent.withValues(alpha: 0.2);
  static Color get neonGreenGlowStrong => currentAccent.withValues(alpha: 0.4);
  static Color get neonGreenSubtle => currentAccent.withValues(alpha: 0.1);
  static Color get neonBorder => currentAccent.withValues(alpha: 0.35);

  // Text hierarchy
  static const Color textPrimary = Color(0xFFFAFAFA);   // Pure white/zinc 50
  static const Color textSecondary = Color(0xFFA1A1AA); // Zinc 400
  static const Color textTertiary = Color(0xFF71717A);  // Zinc 500
  static const Color textMuted = Color(0xFF52525B);     // Zinc 600
  static Color get textNeon => currentAccent;

  // High contrast accent
  static const Color accent = Color(0xFFFAFAFA);
  static const Color accentSubtle = Color(0xFF27272A);

  // Financial Accents
  static Color get positive => currentAccent;
  static const Color positiveMuted = Color(0xFF05472A); // Deep emerald shadow
  static const Color negative = Color(0xFFFF3366);      // Crisp neon rose
  static const Color negativeMuted = Color(0xFF590E20); // Rose shadow
  static const Color transfer = Color(0xFF38BDF8);      // Sky 400

  // Account Brand Indicators
  static const Color monobank = Color(0xFF161618);      // Monobank dark theme card
  static const Color monobankAccent = Color(0xFFFAFAFA);
  static const Color bybit = Color(0xFFF7A600);         // Bybit Gold
  static Color get cash => currentAccent;
  static const Color manual = Color(0xFF8B5CF6);        // Purple Manual

  // Soft Neon Box Shadows
  static List<BoxShadow> neonGlow({double blur = 18, double spread = 0, Color? color}) => [
    BoxShadow(
      color: color ?? neonGreenGlow,
      blurRadius: blur,
      spreadRadius: spread,
    ),
  ];

  static List<BoxShadow> softCardGlow({Color? color}) => [
    BoxShadow(
      color: color ?? currentAccent.withValues(alpha: 0.12),
      blurRadius: 24,
      spreadRadius: -4,
      offset: const Offset(0, 4),
    ),
  ];

  // Chart Palette (with soft neon green leading)
  static const List<Color> chartColors = [
    Color(0xFF00FF87), // Soft Neon green
    Color(0xFFFAFAFA), // Crisp white
    Color(0xFFA1A1AA), // Silver zinc
    Color(0xFF38BDF8), // Cyan
    Color(0xFF818CF8), // Indigo
    Color(0xFFC084FC), // Violet
    Color(0xFFFF3366), // Neon Rose
    Color(0xFFFB923C), // Orange
    Color(0xFFFACC15), // Amber
    Color(0xFF34D399), // Mint
  ];
}
