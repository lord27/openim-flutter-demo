import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'app_themes.dart';

class Styles {
  Styles._();

  /// 纯白/纯黑（不随主题变化，用于主色按钮文字、图标等）
  static const Color kWhite = Color(0xFFFFFFFF);
  static const Color kBlack = Color(0xFF000000);

  /// 当前主题卡片/栏背景（原 c_FFFFFF 的卡片用法请改用此色）
  static Color get c_surface => AppThemeService.current.surface;

  // ---------- 主题感知颜色 ----------
  static Color get c_0089FF => AppThemeService.current.primary;
  static Color get c_0C1C33 => AppThemeService.current.textPrimary;
  static Color get c_8E9AB0 => AppThemeService.current.textSecondary;
  static Color get c_E8EAEF => AppThemeService.current.divider;
  static Color get c_F0F2F6 => AppThemeService.current.subBg;
  static Color get c_F2F8FF => AppThemeService.current.subBg;
  static Color get c_F8F9FA => AppThemeService.current.scaffoldBg;
  static Color get c_F4F5F7 => AppThemeService.current.bubbleOther;
  static Color get c_CCE7FE => AppThemeService.current.bubbleSelf;

  // ---------- 固定语义色 ----------
  static const Color c_FFFFFF = kWhite;
  static const Color c_000000 = kBlack;
  static const Color c_FF381F = Color(0xFFFF381F);
  static const Color c_18E875 = Color(0xFF18E875);
  static const Color c_92B3E0 = Color(0xFF92B3E0);
  static const Color c_6085B1 = Color(0xFF6085B1);
  static const Color c_FFB300 = Color(0xFFFFB300);
  static const Color c_FFE1DD = Color(0xFFFFE1DD);
  static const Color c_707070 = Color(0xFF707070);

  // ---------- 透明度派生 ----------
  static Color get c_92B3E0_opacity50 => c_92B3E0.withOpacity(.5);
  static Color get c_E8EAEF_opacity50 => c_E8EAEF.withOpacity(.5);
  static Color get c_FFFFFF_opacity0 => c_FFFFFF.withOpacity(.0);
  static Color get c_FFFFFF_opacity70 => c_FFFFFF.withOpacity(.7);
  static Color get c_FFFFFF_opacity50 => c_FFFFFF.withOpacity(.5);
  static Color get c_0089FF_opacity10 => c_0089FF.withOpacity(.1);
  static Color get c_0089FF_opacity20 => c_0089FF.withOpacity(.2);
  static Color get c_0089FF_opacity50 => c_0089FF.withOpacity(.5);
  static Color get c_FF381F_opacity10 => c_FF381F.withOpacity(.1);
  static Color get c_8E9AB0_opacity13 => c_8E9AB0.withOpacity(.13);
  static Color get c_8E9AB0_opacity15 => c_8E9AB0.withOpacity(.15);
  static Color get c_8E9AB0_opacity16 => c_8E9AB0.withOpacity(.16);
  static Color get c_8E9AB0_opacity30 => c_8E9AB0.withOpacity(.3);
  static Color get c_8E9AB0_opacity50 => c_8E9AB0.withOpacity(.5);
  static Color get c_0C1C33_opacity30 => c_0C1C33.withOpacity(.3);
  static Color get c_0C1C33_opacity60 => c_0C1C33.withOpacity(.6);
  static Color get c_0C1C33_opacity85 => c_0C1C33.withOpacity(.85);
  static Color get c_0C1C33_opacity80 => c_0C1C33.withOpacity(.8);
  static Color get c_FF381F_opacity70 => c_FF381F.withOpacity(.7);
  static Color get c_000000_opacity70 => c_000000.withOpacity(.7);
  static Color get c_000000_opacity15 => c_000000.withOpacity(.15);
  static Color get c_000000_opacity12 => c_000000.withOpacity(.12);
  static Color get c_000000_opacity4 => c_000000.withOpacity(.04);

  // ---------- 文本样式（白色系固定用于主色/深色底） ----------
  static TextStyle get ts_FFFFFF_21sp => TextStyle(color: kWhite, fontSize: 21.sp);
  static TextStyle get ts_FFFFFF_20sp_medium =>
      TextStyle(color: kWhite, fontSize: 20.sp, fontWeight: FontWeight.w500);
  static TextStyle get ts_FFFFFF_18sp_medium =>
      TextStyle(color: kWhite, fontSize: 18.sp, fontWeight: FontWeight.w500);
  static TextStyle get ts_FFFFFF_17sp => TextStyle(color: kWhite, fontSize: 17.sp);
  static TextStyle get ts_FFFFFF_opacity70_17sp =>
      TextStyle(color: kWhite.withOpacity(.7), fontSize: 17.sp);
  static TextStyle get ts_FFFFFF_17sp_semibold =>
      TextStyle(color: kWhite, fontSize: 17.sp, fontWeight: FontWeight.w600);
  static TextStyle get ts_FFFFFF_17sp_medium =>
      TextStyle(color: kWhite, fontSize: 17.sp, fontWeight: FontWeight.w500);
  static TextStyle get ts_FFFFFF_16sp => TextStyle(color: kWhite, fontSize: 16.sp);
  static TextStyle get ts_FFFFFF_14sp => TextStyle(color: kWhite, fontSize: 14.sp);
  static TextStyle get ts_FFFFFF_opacity70_14sp =>
      TextStyle(color: kWhite.withOpacity(.7), fontSize: 14.sp);
  static TextStyle get ts_FFFFFF_14sp_medium =>
      TextStyle(color: kWhite, fontSize: 14.sp, fontWeight: FontWeight.w500);
  static TextStyle get ts_FFFFFF_12sp => TextStyle(color: kWhite, fontSize: 12.sp);
  static TextStyle get ts_FFFFFF_10sp => TextStyle(color: kWhite, fontSize: 10.sp);

  static TextStyle get ts_8E9AB0_10sp_semibold =>
      TextStyle(color: c_8E9AB0, fontSize: 10.sp, fontWeight: FontWeight.w600);
  static TextStyle get ts_8E9AB0_10sp => TextStyle(color: c_8E9AB0, fontSize: 10.sp);
  static TextStyle get ts_8E9AB0_12sp => TextStyle(color: c_8E9AB0, fontSize: 12.sp);
  static TextStyle get ts_8E9AB0_13sp => TextStyle(color: c_8E9AB0, fontSize: 13.sp);
  static TextStyle get ts_8E9AB0_14sp => TextStyle(color: c_8E9AB0, fontSize: 14.sp);
  static TextStyle get ts_8E9AB0_15sp => TextStyle(color: c_8E9AB0, fontSize: 15.sp);
  static TextStyle get ts_8E9AB0_16sp => TextStyle(color: c_8E9AB0, fontSize: 16.sp);
  static TextStyle get ts_8E9AB0_17sp => TextStyle(color: c_8E9AB0, fontSize: 17.sp);
  static TextStyle get ts_8E9AB0_opacity50_17sp =>
      TextStyle(color: c_8E9AB0_opacity50, fontSize: 17.sp);

  static TextStyle get ts_0C1C33_10sp => TextStyle(color: c_0C1C33, fontSize: 10.sp);
  static TextStyle get ts_0C1C33_12sp => TextStyle(color: c_0C1C33, fontSize: 12.sp);
  static TextStyle get ts_0C1C33_12sp_medium =>
      TextStyle(color: c_0C1C33, fontSize: 12.sp, fontWeight: FontWeight.w500);
  static TextStyle get ts_0C1C33_14sp => TextStyle(color: c_0C1C33, fontSize: 14.sp);
  static TextStyle get ts_0C1C33_14sp_medium =>
      TextStyle(color: c_0C1C33, fontSize: 14.sp, fontWeight: FontWeight.w500);
  static TextStyle get ts_0C1C33_17sp => TextStyle(color: c_0C1C33, fontSize: 17.sp);
  static TextStyle get ts_0C1C33_17sp_medium =>
      TextStyle(color: c_0C1C33, fontSize: 17.sp, fontWeight: FontWeight.w500);
  static TextStyle get ts_0C1C33_17sp_semibold =>
      TextStyle(color: c_0C1C33, fontSize: 17.sp, fontWeight: FontWeight.w600);
  static TextStyle get ts_0C1C33_20sp => TextStyle(color: c_0C1C33, fontSize: 20.sp);
  static TextStyle get ts_0C1C33_20sp_medium =>
      TextStyle(color: c_0C1C33, fontSize: 20.sp, fontWeight: FontWeight.w500);
  static TextStyle get ts_0C1C33_20sp_semibold =>
      TextStyle(color: c_0C1C33, fontSize: 20.sp, fontWeight: FontWeight.w600);

  static TextStyle get ts_0089FF_10sp_semibold =>
      TextStyle(color: c_0089FF, fontSize: 10.sp, fontWeight: FontWeight.w600);
  static TextStyle get ts_0089FF_10sp => TextStyle(color: c_0089FF, fontSize: 10.sp);
  static TextStyle get ts_0089FF_12sp => TextStyle(color: c_0089FF, fontSize: 12.sp);
  static TextStyle get ts_0089FF_14sp => TextStyle(color: c_0089FF, fontSize: 14.sp);
  static TextStyle get ts_0089FF_16sp => TextStyle(color: c_0089FF, fontSize: 16.sp);
  static TextStyle get ts_0089FF_16sp_medium =>
      TextStyle(color: c_0089FF, fontSize: 16.sp, fontWeight: FontWeight.w500);
  static TextStyle get ts_0089FF_17sp => TextStyle(color: c_0089FF, fontSize: 17.sp);
  static TextStyle get ts_0089FF_17sp_semibold =>
      TextStyle(color: c_0089FF, fontSize: 17.sp, fontWeight: FontWeight.w600);
  static TextStyle get ts_0089FF_17sp_medium =>
      TextStyle(color: c_0089FF, fontSize: 17.sp, fontWeight: FontWeight.w500);
  static TextStyle get ts_0089FF_14sp_medium =>
      TextStyle(color: c_0089FF, fontSize: 14.sp, fontWeight: FontWeight.w500);
  static TextStyle get ts_0089FF_22sp_semibold =>
      TextStyle(color: c_0089FF, fontSize: 22.sp, fontWeight: FontWeight.w600);

  static TextStyle get ts_FF381F_17sp => TextStyle(color: c_FF381F, fontSize: 17.sp);
  static TextStyle get ts_FF381F_14sp => TextStyle(color: c_FF381F, fontSize: 14.sp);
  static TextStyle get ts_FF381F_12sp => TextStyle(color: c_FF381F, fontSize: 12.sp);
  static TextStyle get ts_FF381F_10sp => TextStyle(color: c_FF381F, fontSize: 10.sp);

  static TextStyle get ts_6085B1_17sp_medium =>
      TextStyle(color: c_6085B1, fontSize: 17.sp, fontWeight: FontWeight.w500);
  static TextStyle get ts_6085B1_17sp => TextStyle(color: c_6085B1, fontSize: 17.sp);
  static TextStyle get ts_6085B1_12sp => TextStyle(color: c_6085B1, fontSize: 12.sp);
  static TextStyle get ts_6085B1_14sp => TextStyle(color: c_6085B1, fontSize: 14.sp);
}
