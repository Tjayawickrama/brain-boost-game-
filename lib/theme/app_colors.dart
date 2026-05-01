import 'package:flutter/material.dart';

/// Centralized color palette for Brain Boost.
class AppColors {
  AppColors._();

  // ── Primary teal ─────────────────────────────────────────────────────────
  static const Color primary      = Color(0xFF0CB5A8);
  static const Color primaryDark  = Color(0xFF068A80);
  static const Color primaryDeep  = Color(0xFF054E48);
  static const Color primaryLight = Color(0xFFE4F7F6);
  static const Color primaryFaint = Color(0xFFF0FAFA);

  // ── Accent colors ─────────────────────────────────────────────────────────
  static const Color orange      = Color(0xFFF5803A);
  static const Color orangeLight = Color(0xFFFFF0E8);

  static const Color purple      = Color(0xFF7C6CC0);
  static const Color purpleLight = Color(0xFFF2EFFF);

  static const Color green       = Color(0xFF3CCB8A);
  static const Color greenLight  = Color(0xFFE8FBF2);

  // ── Text ─────────────────────────────────────────────────────────────────
  static const Color textDark   = Color(0xFF1A2E2C);
  static const Color textMedium = Color(0xFF4A6866);
  static const Color textLight  = Color(0xFF94B0AE);

  // ── Surface ──────────────────────────────────────────────────────────────
  static const Color cardBg     = Color(0xFFF5FAFA);
  static const Color divider    = Color(0xFFE0EDEC);
  static const Color white      = Colors.white;

  // ── Gamification ─────────────────────────────────────────────────────────
  static const Color starGold  = Color(0xFFFFC107);
  static const Color starGray  = Color(0xFFDDE8E7);

  // ── Gradient stops ────────────────────────────────────────────────────────
  static const List<Color> primaryGradient = [
    Color(0xFF0CB5A8),
    Color(0xFF068A80),
  ];

  static const List<Color> darkGradient = [
    Color(0xFF054E48),
    Color(0xFF0A7A7A),
  ];

  // ── Chart bars ───────────────────────────────────────────────────────────
  static const List<Color> barColors = [
    Color(0xFFB2E4E0),
    Color(0xFF0CB5A8),
    Color(0xFF068A80),
  ];
}
