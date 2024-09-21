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

  /// Parse a string representing seconds to a time format (mm:ss).
  String get parseToMinutesAndSeconds {
    final totalSeconds = int.tryParse(this) ?? 0;
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Parse a string representing seconds to a DateTime.
  DateTime get parseToDateTime {
    final totalSeconds = int.tryParse(this) ?? 0;
    final now = DateTime.now();

    return now.subtract(Duration(seconds: totalSeconds));
  }
}
