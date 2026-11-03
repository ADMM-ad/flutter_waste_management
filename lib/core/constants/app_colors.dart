import 'package:flutter/material.dart';

class AppColors {
  // Brand palette (DESIGN.md Official)
  static const Color primary = Color(0xFF15803D);       // Forest Green #15803D
  static const Color primaryDark = Color(0xFF166534);   // Forest Green Dark #166534
  static const Color primaryLight = Color(0xFFDCFCE7);  // Forest Green Tint #DCFCE7
  static const Color secondary = Color(0xFF0F766E);     // Deep Teal #0F766E
  static const Color accent = Color(0xFF15803D);

  // Neutrals
  static const Color background = Color(0xFFF8FAFC);    // Slate 50
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF0F172A);   // Slate 900
  static const Color textSecondary = Color(0xFF64748B); // Slate 500
  static const Color textMuted = Color(0xFF94A3B8);     // Slate 400
  static const Color border = Color(0xFFE2E8F0);        // Slate 200
  static const Color divider = Color(0xFFF1F5F9);

  // Status & Utility Colors
  static const Color error = Color(0xFFEF4444);         // Red 500
  static const Color success = Color(0xFF10B981);       // Emerald 500
  static const Color warning = Color(0xFFF59E0B);       // Amber 500

  // Status Backgrounds & Foreground
  static const Color pending = Color(0xFFF59E0B);
  static const Color pendingBg = Color(0xFFFEF3C7);
  static const Color inProgress = Color(0xFF3B82F6);
  static const Color inProgressBg = Color(0xFFDBEAFE);
  static const Color completed = Color(0xFF10B981);
  static const Color completedBg = Color(0xFFD1FAE5);
  static const Color rejected = Color(0xFFEF4444);
  static const Color rejectedBg = Color(0xFFFEE2E2);

  // Status Colors (Matching PRD Spec aliases)
  static const Color statusPending = pending;
  static const Color statusInProgress = inProgress;
  static const Color statusCompleted = completed;
  static const Color statusRejected = rejected;

  // Urgency Colors
  static const Color urgencyHigh = Color(0xFFDC2626);
  static const Color urgencyMedium = Color(0xFFF59E0B);
  static const Color urgencyLow = Color(0xFF64748B);
}
