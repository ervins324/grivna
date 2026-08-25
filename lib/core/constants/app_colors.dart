import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Monochrome Base Palette (Dark-First Minimalist)
  static const Color background = Color(0xFF09090B); // Deep zinc/OLED black
  static const Color surface = Color(0xFF18181B);    // Zinc 900
  static const Color surfaceElevated = Color(0xFF27272A); // Zinc 800
  static const Color surfaceHighlight = Color(0xFF3F3F46); // Zinc 700
  
  // Borders & Dividers
  static const Color border = Color(0xFF27272A);
  static const Color borderSubtle = Color(0xFF1F1F23);
  static const Color borderFocused = Color(0xFFFAFAFA);

  // Text hierarchy
  static const Color textPrimary = Color(0xFFFAFAFA);   // Pure white/zinc 50
  static const Color textSecondary = Color(0xFFA1A1AA); // Zinc 400
  static const Color textTertiary = Color(0xFF71717A);  // Zinc 500
  static const Color textMuted = Color(0xFF52525B);     // Zinc 600

  // High contrast accent
  static const Color accent = Color(0xFFFAFAFA);
  static const Color accentSubtle = Color(0xFF27272A);

  // Financial Accents (Subtle, Sophisticated)
  static const Color positive = Color(0xFF10B981);      // Emerald 500
  static const Color positiveMuted = Color(0xFF064E3B); // Emerald 900
  static const Color negative = Color(0xFFF43F5E);      // Rose 500
  static const Color negativeMuted = Color(0xFF881337); // Rose 900
  static const Color transfer = Color(0xFF38BDF8);      // Sky 400

  // Account Brand Indicators
  static const Color monobank = Color(0xFF1E1E1E);      // Monobank dark theme card
  static const Color monobankAccent = Color(0xFFFAFAFA);
  static const Color bybit = Color(0xFFF7A600);         // Bybit Gold
  static const Color cash = Color(0xFF10B981);          // Emerald Cash
  static const Color manual = Color(0xFF8B5CF6);        // Purple Manual

  // Chart Palette (Monochrome & refined distinct hues)
  static const List<Color> chartColors = [
    Color(0xFFFAFAFA), // Crisp white
    Color(0xFFA1A1AA), // Silver zinc
    Color(0xFF71717A), // Slate
    Color(0xFF38BDF8), // Cyan
    Color(0xFF818CF8), // Indigo
    Color(0xFFC084FC), // Violet
    Color(0xFFF472B6), // Pink
    Color(0xFFFB923C), // Orange
    Color(0xFF34D399), // Mint
    Color(0xFFFACC15), // Amber
  ];
}
