// =============================================================
//  core/themes/app_theme.dart — Design system tokens
// =============================================================
import 'package:flutter/material.dart';

abstract class AppColors {
  static const background   = Color(0xFF0A0A0A);
  static const surface      = Color(0xFF1A1A1A);
  static const card         = Color(0xFF242424);
  static const cardBorder   = Color(0xFF2F2F2F);
  static const gold         = Color(0xFFD4AF37);
  static const goldLight    = Color(0xFFE8CB6A);
  static const goldDark     = Color(0xFF9E7F1F);
  static const goldFaint    = Color(0x1AD4AF37);
  static const goldBorder   = Color(0x33D4AF37);
  static const textPrimary  = Color(0xFFFFFFFF);
  static const textSecondary= Color(0xFFB0B0B0);
  static const textMuted    = Color(0xFF606060);
  static const success      = Color(0xFF4CAF82);
  static const warning      = Color(0xFFE8A838);
  static const danger       = Color(0xFFCF6679);
  static const blue         = Color(0xFF378ADD);
  static const divider      = Color(0xFF2A2A2A);
}

abstract class AppTextStyles {
  static const display = TextStyle(
    fontSize: 28, fontWeight: FontWeight.w600,
    color: AppColors.textPrimary, letterSpacing: -0.5,
  );
  static const heading = TextStyle(
    fontSize: 20, fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
  static const title = TextStyle(
    fontSize: 16, fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );
  static const body = TextStyle(
    fontSize: 14, fontWeight: FontWeight.w400,
    color: AppColors.textSecondary, height: 1.6,
  );
  static const label = TextStyle(
    fontSize: 11, fontWeight: FontWeight.w500,
    color: AppColors.textMuted, letterSpacing: 1.0,
  );
  static const score = TextStyle(
    fontSize: 22, fontWeight: FontWeight.w700,
    color: AppColors.gold,
  );
}

abstract class AppRadius {
  static const sm = BorderRadius.all(Radius.circular(8));
  static const md = BorderRadius.all(Radius.circular(12));
  static const lg = BorderRadius.all(Radius.circular(16));
  static const xl = BorderRadius.all(Radius.circular(20));
  static const full = BorderRadius.all(Radius.circular(999));
}

abstract class AppSpacing {
  static const xs  = 4.0;
  static const sm  = 8.0;
  static const md  = 16.0;
  static const lg  = 24.0;
  static const xl  = 32.0;
  static const xxl = 48.0;
}
