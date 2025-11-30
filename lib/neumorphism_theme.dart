import 'package:flutter/material.dart';

class Neumorphism {
  static const Color backgroundDark = Color(0xFF23272F);
  static const Color accent = Color(0xFF3A3F47);
  static const Color highlight = Color(0xFF2C313A);
  static const Color shadow = Color(0xFF181A20);
  static const Color textPrimary = Color(0xFFE0E0E0);
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color accentYouth = Color(0xFF6C63FF); // Toque juvenil

  static BoxDecoration neumorphicBox({
    double borderRadius = 8.0,
    Color? color,
    bool isPressed = false,
  }) {
    color ??= backgroundDark;
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: [
        BoxShadow(
          color: isPressed ? shadow.withOpacity(0.2) : shadow.withOpacity(0.6),
          offset: const Offset(6, 6),
          blurRadius: 16,
        ),
        BoxShadow(
          color: isPressed ? highlight.withOpacity(0.2) : highlight.withOpacity(0.8),
          offset: const Offset(-6, -6),
          blurRadius: 16,
        ),
      ],
    );
  }

  static TextStyle neumorphicText({
    Color? color,
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.w500,
  }) {
    return TextStyle(
      color: color ?? textPrimary,
      fontSize: fontSize,
      fontWeight: fontWeight,
      shadows: [
        Shadow(
          color: shadow.withOpacity(0.5),
          offset: const Offset(1, 1),
          blurRadius: 2,
        ),
      ],
    );
  }

  static ThemeData themeData = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: backgroundDark,
    primaryColor: accentYouth,
    colorScheme: ColorScheme.dark(
      background: backgroundDark,
      primary: accentYouth,
      secondary: accent,
      surface: accent,
      onBackground: textPrimary,
      onPrimary: textPrimary,
      onSecondary: textSecondary,
      onSurface: textPrimary,
    ),
    textTheme: TextTheme(
      bodyLarge: neumorphicText(fontSize: 18),
      bodyMedium: neumorphicText(fontSize: 16),
      bodySmall: neumorphicText(fontSize: 14, color: textSecondary),
      titleLarge: neumorphicText(fontSize: 22, fontWeight: FontWeight.bold),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: accent,
      elevation: 0,
      titleTextStyle: neumorphicText(fontSize: 20, fontWeight: FontWeight.bold),
      iconTheme: const IconThemeData(color: accentYouth),
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: accentYouth,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  );
}
