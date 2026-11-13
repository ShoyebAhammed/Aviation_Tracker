import 'package:flutter/material.dart';

class AppColors {
  // Brand & Cockpit Palette
  static const Color darkBackground = Color(0xFF0A0F1D);
  static const Color darkSurface = Color(0xFF131D33);
  static const Color darkCard = Color(0xFF1B2846);
  static const Color darkBorder = Color(0xFF263859);

  static const Color lightBackground = Color(0xFFF4F7FC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE2E8F0);

  // Accents & Cockpit Instruments
  static const Color primaryBlue = Color(0xFF1A73E8);
  static const Color radarCyan = Color(0xFF00E5FF);
  static const Color radarGreen = Color(0xFF00E676);
  static const Color skyAccent = Color(0xFF38BDF8);

  // Flight Status Colors
  static const Color statusActive = Color(0xFF00E5FF);     // Cyan (In Flight)
  static const Color statusScheduled = Color(0xFFFFB300);  // Gold / Amber
  static const Color statusLanded = Color(0xFF00E676);     // Bright Green
  static const Color statusDelayed = Color(0xFFFF7043);    // Vibrant Coral / Orange
  static const Color statusCancelled = Color(0xFFFF3366);  // Crimson Red
  static const Color statusDiverted = Color(0xFFAB47BC);   // Purple
  static const Color statusUnknown = Color(0xFF78909C);    // Muted Gray

  // Text Colors
  static const Color textLightPrimary = Color(0xFF0F172A);
  static const Color textLightSecondary = Color(0xFF64748B);
  static const Color textDarkPrimary = Color(0xFFF8FAFC);
  static const Color textDarkSecondary = Color(0xFF94A3B8);
}

