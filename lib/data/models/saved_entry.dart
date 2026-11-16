import 'dart:convert';

/// A result kept in the saved-values strip, with the expression it came from
/// so that either one can be pasted back.
class SavedEntry {
  const SavedEntry({required this.value, this.expression});

  /// The result, as the number that gets inserted: `0.75`.
  final String value;

  /// Source of the expression that produced [value]: `3÷4`. Null for entries
  /// saved before expressions were recorded.
  final String? expression;

  String encode() => jsonEncode({
        'value': value,
        if (expression != null) 'expression': expression,
      });

  /// Reads what [encode] wrote. Anything else is taken to be a bare value,
  /// which is how entries were stored originally.
  static SavedEntry decode(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        final value = decoded['value'];
        final expression = decoded['expression'];
        if (value is String) {
          return SavedEntry(
            value: value,
            expression: expression is String ? expression : null,
          );
        }
      }
    } on FormatException {
      // Not JSON: a bare value.
    }
    return SavedEntry(value: raw);
  }

  @override
  bool operator ==(Object other) =>
      other is SavedEntry &&
      other.value == value &&
      other.expression == expression;

  @override
  int get hashCode => Object.hash(value, expression);
}
