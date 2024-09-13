extension StringX on String {

  /// Parse a string to an email address (GMAIL by default).
  String get parseStringToEmail => '${trim()}@gmail.com';
}
