import 'package:flutter/material.dart';
import 'teesams_colors.dart';

class AppTheme {
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,

      colorScheme: ColorScheme.fromSeed(seedColor: TeesamsColors.primary),

      scaffoldBackgroundColor: TeesamsColors.background,

      appBarTheme: const AppBarTheme(elevation: 0, centerTitle: false),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: TeesamsColors.primary,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }
}
