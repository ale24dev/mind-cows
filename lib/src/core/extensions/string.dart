extension StringX on String {
  /// Parse a string to an email address (GMAIL by default).
  String get parseStringToEmail => '${trim()}@gmail.com';

  /// Convert a camelCase string to snake_case.
  String get camelToSnakeCase {
    return replaceAllMapped(
      RegExp('([a-z])([A-Z])'),
      (Match match) => '${match.group(1)}_${match.group(2)}',
    ).toLowerCase();
  }

  /// Convert a string to a list of integers.
  List<int> get parseOptToNumberValue => split('').map(int.parse).toList();
}
