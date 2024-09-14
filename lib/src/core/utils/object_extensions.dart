extension LetExtension<T> on T? {
  /// Verify is value is null
  bool get isNull => this == null;

  /// Verify is value is not null
  bool get isNotNull => this != null;

  /// Executes a code [block] only if the value is not null,
  /// returning the block's result or 'null'
  /// if the original value was null
  /// Example
  /// ```dart
  ///    String? name = 'World';
  ///    String? result = nombre?.let((it) => "Hello, $it!");
  ///    print(result); // Hello World
  /// ```
  R? let<R>(R Function(T it) block) {
    if (isNotNull) {
      return block(this as T);
    }
    return null;
  }
}
