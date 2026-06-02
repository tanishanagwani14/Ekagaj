import 'package:flutter/material.dart';

sealed class EkColors {
  static const blue500 = Color(0xFF3B82F6);
  static const purple600 = Color(0xFF7C3AED);

  static const indigo600 = Color(0xFF4F46E5);

  static const orange500 = Color(0xFFF97316);
  static const red500 = Color(0xFFEF4444);

  static const pink500 = Color(0xFFEC4899);

  static const gray50 = Color(0xFFF9FAFB);
  static const gray100 = Color(0xFFF3F4F6);
  static const gray200 = Color(0xFFE5E7EB);
  static const gray400 = Color(0xFF9CA3AF);
  static const gray500 = Color(0xFF6B7280);
  static const gray600 = Color(0xFF4B5563);
  static const gray700 = Color(0xFF374151);
  static const gray800 = Color(0xFF1F2937);

  static LinearGradient blueToPurple() {
    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [blue500, purple600],
    );
  }
}

