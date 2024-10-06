import 'package:flutter/material.dart';

abstract class SettingsLocalDatasource {
  Locale changeLanguage(String language);

  ThemeMode changeTheme();

  Locale getLanguage();

  ThemeMode getTheme();
}
