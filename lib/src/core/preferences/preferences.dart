import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:my_app/src/core/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum PrefsKey {
  darkMode,
  language,
}

@singleton
class Preferences {
  Preferences(this._prefs);

  final SharedPreferences _prefs;

  ThemeMode getTheme() {
    final isDarkMode = _prefs.getBool(PrefsKey.darkMode.name) ?? true;

    return isDarkMode ? ThemeMode.dark : ThemeMode.light;
  }

  void changeTheme() {
    final theme = _prefs.getBool(PrefsKey.darkMode.name) ?? true;

    _prefs.setBool(PrefsKey.darkMode.name, !theme);
  }

  Locale getLanguage() {
    final languageString = _prefs.getString(PrefsKey.language.name);

    return Utils.getLocaleByCode(languageString);
  }

  void setLanguage(String language) {
    _prefs.setString(PrefsKey.language.name, language);
  }
}
