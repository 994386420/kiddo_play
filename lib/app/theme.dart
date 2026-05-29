import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class KidPalette {
  static const sky = Color(0xFFE0F4FF);
  static const cream = Color(0xFFFFF9E6);
  static const primary = Color(0xFF1A6FB0);
  static const secondary = Color(0xFF5BA4CF);
  static const ink = Color(0xFF17324D);
  static const warmYellow = Color(0xFFFFD93D);
  static const warmYellowBorder = Color(0xFFF4A200);
  static const white = Colors.white;
}

ThemeData buildKidTheme() {
  const colorScheme = ColorScheme.light(
    primary: KidPalette.primary,
    secondary: KidPalette.warmYellow,
    surface: Colors.white,
  );

  final baseTextTheme = GoogleFonts.nunitoTextTheme().copyWith(
    headlineLarge: const TextStyle(
      fontSize: 34,
      fontWeight: FontWeight.w900,
      color: KidPalette.primary,
    ),
    headlineMedium: const TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w900,
      color: KidPalette.primary,
    ),
    titleLarge: const TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w800,
      color: KidPalette.ink,
    ),
    titleMedium: const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w800,
      color: KidPalette.ink,
    ),
    bodyLarge: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w700,
      color: KidPalette.secondary,
      height: 1.35,
    ),
    bodyMedium: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: KidPalette.secondary,
      height: 1.35,
    ),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    fontFamilyFallback: const [
      'Noto Sans SC',
      'PingFang SC',
      'Microsoft YaHei',
      'Arial Unicode MS',
    ],
    scaffoldBackgroundColor: KidPalette.sky,
    textTheme: baseTextTheme,
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      foregroundColor: KidPalette.primary,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: KidPalette.primary,
      contentTextStyle: baseTextTheme.bodyMedium?.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.w800,
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
    ),
  );
}
