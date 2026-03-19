import 'package:flutter/material.dart';
import 'app_font_sizes.dart';

class AppTextStyles {
  AppTextStyles._();

  static const TextStyle loginTitle = TextStyle(
    fontSize: AppFontSizes.titleLarge,
    fontWeight: FontWeight.w700,
    color: Colors.black,
  );

  static const TextStyle subtitle = TextStyle(
    fontSize: AppFontSizes.bodyMedium,
    fontWeight: FontWeight.w500,
    color: Color(0xFF7A7A7A),
  );

  static const TextStyle inputHint = TextStyle(
    fontSize: AppFontSizes.hint,
    fontWeight: FontWeight.w500,
    color: Color(0xFF7A7A7A),
  );

  static const TextStyle error = TextStyle(
    fontSize: AppFontSizes.caption,
    fontWeight: FontWeight.w400,
    color: Color(0xFFE53935),
  );

  static const TextStyle textButton = TextStyle(
    fontSize: AppFontSizes.bodySmall,
    fontWeight: FontWeight.w500,
    color: Colors.black,
  );

  static const TextStyle dividerText = TextStyle(
    fontSize: AppFontSizes.caption,
    fontWeight: FontWeight.w500,
    color: Color(0xFF8A8A8A),
  );

  static const TextStyle primaryButton = TextStyle(
    fontSize: AppFontSizes.buttonLarge,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );

  static const TextStyle bottomText = TextStyle(
    fontSize: AppFontSizes.bodyMedium,
    fontWeight: FontWeight.w600,
    color: Color(0xFF7A7A7A),
  );

  static const TextStyle bottomLink = TextStyle(
    fontSize: AppFontSizes.bodyMedium,
    fontWeight: FontWeight.w600,
    color: Color(0xFF4CAF3D),
  );

  static const TextStyle socialButton = TextStyle(
    fontSize: AppFontSizes.bodySmall,
    fontWeight: FontWeight.w600,
    color: Colors.black,
  );
}