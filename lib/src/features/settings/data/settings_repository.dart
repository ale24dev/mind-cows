import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:my_app/src/core/preferences/preferences.dart';
import 'package:my_app/src/core/services/settings_datasource.dart';
import 'package:my_app/src/core/utils/utils.dart';

@Singleton(as: SettingsLocalDatasource)
class SettingsRepository extends SettingsLocalDatasource {
  SettingsRepository(this._preferences);

  final Preferences _preferences;

  @override
  Locale changeLanguage(String language) {
    _preferences.setLanguage(language);
    return Utils.getLocaleByCode(language);
  }

  @override
  ThemeMode changeTheme() {
    _preferences.changeTheme();

    return _preferences.getTheme();
  }

  @override
  Locale getLanguage() {
    return _preferences.getLanguage();
  }

  @override
  ThemeMode getTheme() {
    return _preferences.getTheme();
  }
}
