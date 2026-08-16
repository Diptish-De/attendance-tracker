import 'package:flutter/material.dart';
import '../models/models.dart';

class AppColors {
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF94A3B8);

  static const Color safe = Color(0xFF22C55E);
  static const Color safeBg = Color(0xFFDCFCE7);

  static const Color caution = Color(0xFFF59E0B);
  static const Color cautionBg = Color(0xFFFEF9C3);

  static const Color danger = Color(0xFFF97316);
  static const Color dangerBg = Color(0xFFFFEDD5);

  static const Color critical = Color(0xFFEF4444);
  static const Color criticalBg = Color(0xFFFEE2E2);

  static const Color primary = Color(0xFF22C55E);
  static const Color primaryDark = Color(0xFF16A34A);

  static Color getRiskColor(AttendanceRisk risk) {
    switch (risk) {
      case AttendanceRisk.safe:
        return safe;
      case AttendanceRisk.caution:
        return caution;
      case AttendanceRisk.danger:
        return danger;
      case AttendanceRisk.critical:
        return critical;
    }
  }

  static Color getRiskBg(AttendanceRisk risk) {
    switch (risk) {
      case AttendanceRisk.safe:
        return safeBg;
      case AttendanceRisk.caution:
        return cautionBg;
      case AttendanceRisk.danger:
        return dangerBg;
      case AttendanceRisk.critical:
        return criticalBg;
    }
  }

  static String getRiskLabel(AttendanceRisk risk) {
    switch (risk) {
      case AttendanceRisk.safe:
        return 'SAFE';
      case AttendanceRisk.caution:
        return 'CAUTION';
      case AttendanceRisk.danger:
        return 'RISKY';
      case AttendanceRisk.critical:
        return 'CRITICAL';
    }
  }
}
