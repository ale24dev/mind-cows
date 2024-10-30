import 'package:flutter/material.dart';
import 'package:mind_cows/l10n/l10n.dart';
import 'package:mind_cows/src/features/settings/data/model/rules.dart';

abstract class Utils {
  static bool isValidPlayerNumber(String value) {
    final values = value.split('');

    if (values.length != 4) return false;

    final uniqueValues = values.toSet();

    return uniqueValues.length == values.length;
  }

  static String attemptResult(BuildContext context, int cows, int bulls) {
    return '${context.l10n.cowPlay}$cows  ${context.l10n.bullPlay}$bulls';
  }

  static Locale? getLocaleByCode(String? languageString) {
    switch (languageString) {
      case 'en':
        return const Locale('en', 'US');
      case 'es':
        return const Locale('es', 'ES');
      default:
        return null;
    }
  }

  static Rules getRulesByLanguage(
    String language, {
    required List<Rules> rules,
  }) {
    final rule =
        rules.firstWhere((element) => element.language.name == language);

    return rule;
  }
}
