import 'package:flutter/material.dart';

class AppColors {
  // Light Theme Colors
  static const Color lightPrimary = Color(0xFF184DB8);
  static const Color lightPrimaryDark = Color(0xFF0A2260);
  static const Color lightSecondary = Color(0xFF2855AE);
  static const Color lightAccent = Color(0xFF3966B9);

  static const Color lightBackground = Color(0xFFF5F7FA);
  static const Color lightSurface = Colors.white;
  static const Color lightCardBorder = Color(0xFFE0E6EF);

  static const Color lightTextPrimary = Color(0xFF1E293B);
  static const Color lightTextSecondary = Color(0xFF5B6473);
  static const Color lightTextTertiary = Color(0xFF7B8491);

  // Dark Theme Colors
  static const Color darkPrimary = Color(0xFF3A7BFF);
  static const Color darkPrimaryDark = Color(0xFF1E4DBF);
  static const Color darkSecondary = Color(0xFF5B8DEF);
  static const Color darkAccent = Color(0xFF7BA3F7);

  static const Color darkBackground = Color(0xFF0B0E13);
  static const Color darkSurface = Color(0xFF1A1F2E);
  static const Color darkCardBorder = Color(0xFF2A3142);

  static const Color darkTextPrimary = Color(0xFFE8EAF0);
  static const Color darkTextSecondary = Color(0xFFB8BFCC);
  static const Color darkTextTertiary = Color(0xFF8E95A3);

  // Common Colors (used in both themes)
  static const Color success = Color(0xFF00C853);
  static const Color successDark = Color(0xFF2C630A);
  static const Color warning = Color(0xFFFF6D00);
  static const Color warningDark = Color(0xFF844D17);
  static const Color error = Colors.red;
  static const Color purple = Color(0xFF9C27B0);
  static const Color purpleDark = Color(0xFF661374);
  static const Color cyan = Color(0xFF00BCD4);
  static const Color cyanDark = Color(0xFF11727F);
  static const Color deepPurple = Color(0xFF5E35B1);
  static const Color deepPurpleDark = Color(0xFF391C6A);
  static const Color grey = Color(0xFF546E7A);
  static const Color greyDark = Color(0xFF134259);

  // Gradient Colors
  static const List<Color> lightPrimaryGradient = [
    Color(0xFF184DB8),
    Color(0xFF0A2260),
  ];

  static const List<Color> darkPrimaryGradient = [
    Color(0xFF3A7BFF),
    Color(0xFF1E4DBF),
  ];

  static const List<Color> lightHeaderGradient = [
    Color(0xFF142D71),
    Color(0xFF1A3786),
    Color(0xFF3966B9),
  ];

  static const List<Color> darkHeaderGradient = [
    Color(0xFF1E2A4A),
    Color(0xFF2A3F6A),
    Color(0xFF3D5A8F),
  ];

  static const List<Color> splashGradient = [
    // 1. Deep Saturated Blue (Starts the rich color)
    Color.fromARGB(255, 11, 21, 128),
    // 2. Dark Indigo/Violet (Adds complex richness)
    Color.fromARGB(255, 29, 7, 86),
    // 3. Near-Black Navy (Deep transition)
    Color.fromARGB(255, 32, 44, 83),
    // 4. Deepest Blue/Near-Black (Final depth)
    Color.fromRGBO(4, 15, 98, 1),
  ];
  static const List<Color> motivationGradient = [
    Color(0xFF1A237E),
    Color(0xFF3949AB),
  ];
}
