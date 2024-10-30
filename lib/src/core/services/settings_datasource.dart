import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mind_cows/src/core/exceptions.dart';
import 'package:mind_cows/src/features/settings/data/model/rules.dart';

abstract class SettingsDatasource {
  Locale changeLanguage(String language);

  ThemeMode changeTheme();

  Locale? getLanguage();

  ThemeMode getTheme();

  Future<Either<AppException?, List<Rules>?>> getRules();
}
