import 'package:flutter/material.dart';
import 'package:my_app/l10n/l10n.dart';

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

  static Locale getLocaleByCode(String? languageString) {
    switch (languageString) {
      case 'en':
        return const Locale('en', 'US');
      case 'es':
        return const Locale('es', 'ES');
      default:
        return const Locale('en', 'US');
    }
  }
}
