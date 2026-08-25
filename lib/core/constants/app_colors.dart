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

  // Soft Green Neon Light Palette
  static const Color neonGreen = Color(0xFF00FF87);          // Vivid soft green neon
  static const Color neonGreenBright = Color(0xFF4EFEA1);    // Bright neon highlight
  static const Color neonGreenMuted = Color(0xFF00B359);     // Controlled neon
  static const Color neonGreenGlow = Color(0x3300FF87);      // Soft diffuse ambient glow
  static const Color neonGreenGlowStrong = Color(0x6600FF87);// Focused glow
  static const Color neonGreenSubtle = Color(0x1400FF87);    // Background tint
  static const Color neonBorder = Color(0x5500FF87);         // Glowing border

  // Text hierarchy
  static const Color textPrimary = Color(0xFFFAFAFA);   // Pure white/zinc 50
  static const Color textSecondary = Color(0xFFA1A1AA); // Zinc 400
  static const Color textTertiary = Color(0xFF71717A);  // Zinc 500
  static const Color textMuted = Color(0xFF52525B);     // Zinc 600
  static const Color textNeon = Color(0xFF00FF87);      // Neon accent text

  // High contrast accent
  static const Color accent = Color(0xFFFAFAFA);
  static const Color accentSubtle = Color(0xFF27272A);

  // Financial Accents
  static const Color positive = Color(0xFF00FF87);      // Neon green for positive cashflow
  static const Color positiveMuted = Color(0xFF05472A); // Deep emerald shadow
  static const Color negative = Color(0xFFFF3366);      // Crisp neon rose
  static const Color negativeMuted = Color(0xFF590E20); // Rose shadow
  static const Color transfer = Color(0xFF38BDF8);      // Sky 400

  // Account Brand Indicators
  static const Color monobank = Color(0xFF161618);      // Monobank dark theme card
  static const Color monobankAccent = Color(0xFFFAFAFA);
  static const Color bybit = Color(0xFFF7A600);         // Bybit Gold
  static const Color cash = Color(0xFF00FF87);          // Neon Cash
  static const Color manual = Color(0xFF8B5CF6);        // Purple Manual

  // Soft Neon Box Shadows
  static List<BoxShadow> neonGlow({double blur = 18, double spread = 0, Color color = neonGreenGlow}) => [
    BoxShadow(
      color: color,
      blurRadius: blur,
      spreadRadius: spread,
    ),
  ];

  static List<BoxShadow> softCardGlow({Color color = const Color(0x1F00FF87)}) => [
    BoxShadow(
      color: color,
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
