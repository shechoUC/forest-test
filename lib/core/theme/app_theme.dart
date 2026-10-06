import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'forest_colors.dart';

/// Forest uses GT Haptik for body text and Mohr Black Italic for headings,
/// both commercial. Figtree and Archivo Black Italic are their closest
/// open-source matches.
abstract final class ForestText {
  /// Heavy italic used for screen titles and button labels. Pass the text
  /// upper-cased, as Forest does.
  static TextStyle display({
    double fontSize = 28,
    Color color = ForestColors.forestGreen,
  }) => GoogleFonts.archivo(
    fontSize: fontSize,
    fontWeight: FontWeight.w900,
    fontStyle: FontStyle.italic,
    height: 1.1,
    color: color,
  );
}

abstract final class AppTheme {
  static const radius = 16.0;
  static const borderWidth = 1.5;

  static ThemeData light() {
    final textTheme = GoogleFonts.figtreeTextTheme().apply(
      bodyColor: ForestColors.forestGreen,
      displayColor: ForestColors.forestGreen,
    );
    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(
        color: ForestColors.forestGreen,
        width: borderWidth,
      ),
    );

    return ThemeData(
      colorScheme: const ColorScheme.light(
        primary: ForestColors.pineGreen,
        onPrimary: ForestColors.white,
        secondary: ForestColors.acerOrange,
        surface: ForestColors.cream,
        onSurface: ForestColors.forestGreen,
        onSurfaceVariant: ForestColors.darkGray,
        outline: ForestColors.forestGreen,
        error: ForestColors.mapleRed,
      ),
      scaffoldBackgroundColor: ForestColors.cream,
      textTheme: textTheme,
      dividerTheme: const DividerThemeData(color: ForestColors.midGray),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: ForestColors.pineGreen,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ForestColors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        hintStyle: textTheme.bodyLarge?.copyWith(color: ForestColors.darkGray),
        border: inputBorder,
        enabledBorder: inputBorder,
        focusedBorder: inputBorder.copyWith(
          borderSide: const BorderSide(
            color: ForestColors.forestGreen,
            width: 2.5,
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: ForestColors.forestGreen,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: ForestColors.white,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
