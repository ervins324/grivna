import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';

class AccentColorOption {
  final String name;
  final Color color;

  const AccentColorOption({required this.name, required this.color});
}

class GoogleFontOption {
  final String name;
  final String category;

  const GoogleFontOption({required this.name, required this.category});
}

class PersonalisationState {
  final Color accentColor;
  final String fontFamily;

  const PersonalisationState({
    required this.accentColor,
    required this.fontFamily,
  });

  PersonalisationState copyWith({
    Color? accentColor,
    String? fontFamily,
  }) {
    return PersonalisationState(
      accentColor: accentColor ?? this.accentColor,
      fontFamily: fontFamily ?? this.fontFamily,
    );
  }
}

class PersonalisationNotifier extends Notifier<PersonalisationState> {
  static const String _accentKey = 'pref_accent_color';
  static const String _fontKey = 'pref_font_family';

  static const List<AccentColorOption> accentPresets = [
    AccentColorOption(name: 'Neon Matrix', color: Color(0xFF00FF87)),
    AccentColorOption(name: 'Cyberpunk Cyan', color: Color(0xFF00E5FF)),
    AccentColorOption(name: 'Electric Purple', color: Color(0xFFA855F7)),
    AccentColorOption(name: 'Sunset Orange', color: Color(0xFFFF6D00)),
    AccentColorOption(name: 'Neon Rose', color: Color(0xFFFF2A6D)),
    AccentColorOption(name: 'Sapphire Blue', color: Color(0xFF3B82F6)),
    AccentColorOption(name: 'Electric Yellow', color: Color(0xFFFFD600)),
    AccentColorOption(name: 'Emerald Mint', color: Color(0xFF10B981)),
    AccentColorOption(name: 'Minimal White', color: Color(0xFFFAFAFA)),
  ];

  static const List<GoogleFontOption> fontPresets = [
    GoogleFontOption(name: 'Space Grotesk', category: 'Modern Tech'),
    GoogleFontOption(name: 'Inter', category: 'Minimalist Clean'),
    GoogleFontOption(name: 'Plus Jakarta Sans', category: 'Modern Geometric'),
    GoogleFontOption(name: 'JetBrains Mono', category: 'Developer Monospace'),
    GoogleFontOption(name: 'Outfit', category: 'Futuristic Sans'),
    GoogleFontOption(name: 'Poppins', category: 'Friendly Geometric'),
    GoogleFontOption(name: 'Montserrat', category: 'Classic Modern'),
    GoogleFontOption(name: 'Syne', category: 'Artistic Neo-Brutalist'),
    GoogleFontOption(name: 'Fira Code', category: 'Crisp Code Monospace'),
    GoogleFontOption(name: 'Cinzel', category: 'Luxury Serif'),
  ];

  @override
  PersonalisationState build() {
    _loadFromPrefs();
    return const PersonalisationState(
      accentColor: Color(0xFF00FF87),
      fontFamily: 'Space Grotesk',
    );
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final colorVal = prefs.getInt(_accentKey);
    final fontVal = prefs.getString(_fontKey);

    final color = colorVal != null ? Color(colorVal) : const Color(0xFF00FF87);
    final font = fontVal ?? 'Space Grotesk';

    AppColors.currentAccent = color;
    AppTypography.currentFontFamily = font;

    state = PersonalisationState(
      accentColor: color,
      fontFamily: font,
    );
  }

  Future<void> setAccentColor(Color color) async {
    AppColors.currentAccent = color;
    state = state.copyWith(accentColor: color);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_accentKey, color.toARGB32());
  }

  Future<void> setFontFamily(String font) async {
    AppTypography.currentFontFamily = font;
    state = state.copyWith(fontFamily: font);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_fontKey, font);
  }
}

final personalisationProvider =
    NotifierProvider<PersonalisationNotifier, PersonalisationState>(
  PersonalisationNotifier.new,
);
