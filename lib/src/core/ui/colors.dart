import 'dart:ui';

import 'package:flutter/material.dart';

/// App color palette. These colors can and should be used to construct a custom Theme
abstract class AppColor {
  // static const primary = Color.fromARGB(255, 67, 104, 235);
  static const primary = Color(0xFFE3A700);
  // static const primary = Color(0xFFD2FE73);
  static const secondary = Color(0xFFFFB70A);
  static const container = Color(0xFFFBFEFB);
  static const containerDark = Color(0xFF2B2B2B);
  static const subContainerDark = Color.fromARGB(255, 37, 36, 36);
  static const textFieldDark = Color.fromARGB(255, 64, 64, 64);
  static const shadow = Color.fromARGB(11, 0, 0, 0);
  static const headerText = Color(0xFF2B3445);
  static const settingsTitleText = Color(0xFFA0A4AB);
  // static const textColor = Color(0xFF595960);
  static const titleText = Color(0xFF030136);
  static const bodyText = Color(0xFF323233);
  static const scaffold = Color(0xFFF5F6F6);
  static const inputUnfocused = Color(0xFFDCE8E2);
  static const switchTrackUnfocused = Color(0xFFD5D5D5);
  static const boxShadow = Color(0x8FC5AA29);
  static const radioUnselected = Color(0xFFA8A8A8);
  static const onboardText = Color(0xFFE6E6E6);
  static const frostButtonBackground = Color(0xFFB4B4B4);
  static const frostButtonText = Color(0xFFD9D9D9);
  static const divider = Color.fromRGBO(53, 53, 53, 1);
  static const deliveryText = Color(0xFFACACAC);
  static const success = Color(0xFF4F861A);
  static const warning = Color(0xFFFAAD14);
  static const fail = Color(0xFFFF4D4F);
  static const info = Color(0xFF1890FF);
  static const win = Color.fromARGB(255, 68, 154, 25);
  static const draw = Color.fromARGB(255, 87, 84, 87);
  static const lose = Color.fromARGB(255, 182, 52, 52);
}
