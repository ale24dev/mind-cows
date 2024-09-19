abstract class Utils {
  static bool isValidPlayerNumber(String value) {
    final values = value.split('');

    if (values.length != 4) return false;

    final uniqueValues = values.toSet();

    return uniqueValues.length == values.length;
  }
}
