mixin TableInterface {
  /// Table name in the database.
  String tableName();

  /// Columns to select in the query.
  String columns();
}
