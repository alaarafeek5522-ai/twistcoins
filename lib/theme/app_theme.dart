import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primary = Color(0xFFE91E8C);
  static const Color secondary = Color(0xFF00D4FF);
  static const Color gold = Color(0xFFFFD700);
  static const Color bg = Color(0xFF0A0A0F);
  static const Color surface = Color(0xFF12121A);
  static const Color card = Color(0xFF1A1A26);

  static ThemeData get dark => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: bg,
        colorScheme: const ColorScheme.dark(
          primary: primary,
          secondary: secondary,
          surface: surface,
        ),
        textTheme: GoogleFonts.rajdhaniTextTheme(
          ThemeData.dark().textTheme,
        ),
      );
}
