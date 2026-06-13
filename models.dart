// admin/lib/utils/theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AC {
  static const brand1   = Color(0xFFF57F56);
  static const brand2   = Color(0xFFFF2562);
  static const bg       = Color(0xFF050816);
  static const surface  = Color(0xFF0E1225);
  static const surface2 = Color(0xFF151B34);
  static const surface3 = Color(0xFF1C2340);
  static const text1    = Color(0xFFFFFFFF);
  static const text2    = Color(0xFFA5ACC7);
  static const text3    = Color(0xFF4A5180);
  static const border   = Color(0xFF1E2540);
  static const success  = Color(0xFF22C55E);
  static const error    = Color(0xFFEF4444);
  static const warning  = Color(0xFFF59E0B);

  static const grad = LinearGradient(
    colors: [Color(0xFFF57F56), Color(0xFFFF2562)],
    begin: Alignment.centerLeft, end: Alignment.centerRight,
  );
  static const glow1 = Color(0x40F57F56);
  static const glow2 = Color(0x40FF2562);
}

class AdminTheme {
  static ThemeData get dark {
    final base = GoogleFonts.spaceGroteskTextTheme();
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AC.bg,
      colorScheme: const ColorScheme.dark(
        primary: AC.brand1, secondary: AC.brand2,
        surface: AC.surface, error: AC.error,
      ),
      textTheme: base.copyWith(
        titleLarge: base.titleLarge?.copyWith(color: AC.text1, fontWeight: FontWeight.w600),
        bodyLarge: base.bodyLarge?.copyWith(color: AC.text1),
        bodyMedium: base.bodyMedium?.copyWith(color: AC.text2),
        bodySmall: base.bodySmall?.copyWith(color: AC.text3),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AC.surface,
        elevation: 0,
        iconTheme: IconThemeData(color: AC.text1),
        titleTextStyle: TextStyle(
          fontFamily: 'SpaceGrotesk', fontSize: 17,
          fontWeight: FontWeight.w600, color: AC.text1),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true, fillColor: AC.surface2,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AC.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AC.border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AC.brand1, width: 1.5)),
        labelStyle: const TextStyle(color: AC.text2),
        hintStyle: const TextStyle(color: AC.text3),
      ),
      cardTheme: CardTheme(
        color: AC.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AC.border)),
        elevation: 0, margin: EdgeInsets.zero,
      ),
      dividerTheme: const DividerThemeData(color: AC.border, thickness: 1),
      drawerTheme: const DrawerThemeData(backgroundColor: AC.surface),
    );
  }
}
