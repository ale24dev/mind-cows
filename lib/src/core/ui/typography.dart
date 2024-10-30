import 'package:flutter/material.dart';
import 'package:mind_cows/src/core/ui/colors.dart';

class AppTextStyle {
  static const fontFamily = 'Poppins';
  static const secondaryFontFamily = 'Sniglet';

  // Custom text theme overriding material 3 properties.
  // This class has few implemented styles and by default is not applied to the theme.
  TextTheme textTheme(TextTheme theme) => theme.copyWith(
        titleMedium: switchListTile,
      );

  /// Base Text Style
  static const _default = TextStyle(
    fontWeight: FontWeight.w400,
    fontFamily: fontFamily,
    decoration: TextDecoration.none,
    textBaseline: TextBaseline.alphabetic,
    color: AppColor.bodyText,
  );

  /// Display Text Style
  TextStyle get display => _default.copyWith(
        fontSize: 57,
        fontWeight: FontWeight.bold,
        height: 1.12,
        letterSpacing: -0.25,
      );
  TextStyle get emptyData => _default.copyWith(
        fontWeight: FontWeight.w400,
        letterSpacing: -0.25,
      );

  TextStyle get drawerUsername => _default.copyWith(
        fontSize: 25,
        fontWeight: FontWeight.w400,
        height: 1.12,
        letterSpacing: -0.25,
      );

  TextStyle get snackBar => _default.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.25,
      );

  TextStyle get appBarTitle => _default.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
        height: 1.3,
      );

  TextStyle get tableTitle => _default.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        letterSpacing: 0,
        // height: 1.3,
      );

  TextStyle get tabBarSelected => _default.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: AppColor.primary,
        letterSpacing: 0,
        height: 1.3,
      );

  TextStyle get tabBarUnselected => _default.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: Colors.white,
        letterSpacing: 0,
        height: 1.3,
      );

  TextStyle get labelMedium => _default.copyWith(
        fontSize: 11,
        letterSpacing: 0,
        fontWeight: FontWeight.w400,
        color: AppColor.headerText,
      );

  TextStyle get settings => _default.copyWith(
        fontSize: 11,
        letterSpacing: 0,
        fontWeight: FontWeight.w600,
        color: AppColor.settingsTitleText,
      );

  TextStyle get switchListTile => _default.copyWith(
        fontSize: 14,
        letterSpacing: 0,
        fontWeight: FontWeight.w400,
        color: AppColor.headerText,
      );

  TextStyle get profileEmail => _default.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColor.headerText,
        letterSpacing: -.6,
      );

  TextStyle get textButton => _default.copyWith(
        fontSize: 15,
        letterSpacing: -.2,
        fontWeight: FontWeight.w600,
      );

  TextStyle get primaryButtonLeading => _default.copyWith(
        fontSize: 15,
        letterSpacing: -.2,
        fontWeight: FontWeight.w500,
        height: .9,
      );

  TextStyle get primaryButtonTrailing => _default.copyWith(
        fontSize: 14,
        letterSpacing: 0,
        fontWeight: FontWeight.w500,
      );

  TextStyle get dialogTitle => _default.copyWith(
        fontSize: 16,
        letterSpacing: 0,
        fontWeight: FontWeight.w500,
      );

  TextStyle get sliverAppBar => _default.copyWith(
        fontSize: 16,
        letterSpacing: 0,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      );

  TextStyle get bottomSheetTitle => _default.copyWith(
        fontSize: 18,
        letterSpacing: 0,
        fontWeight: FontWeight.w500,
      );

  TextStyle get body =>
      _default.copyWith(fontSize: 14, fontWeight: FontWeight.w400);

  TextStyle get bodyMedium =>
      _default.copyWith(fontSize: 18, fontWeight: FontWeight.w400);

  TextStyle get bodyLarge =>
      _default.copyWith(fontSize: 22, fontWeight: FontWeight.w400);

  TextStyle get title =>
      _default.copyWith(fontSize: 28, fontWeight: FontWeight.w400);

  TextStyle get label =>
      _default.copyWith(fontSize: 20, fontWeight: FontWeight.w400);

  TextStyle headline =
      _default.copyWith(fontSize: 35, fontWeight: FontWeight.w700);
}
