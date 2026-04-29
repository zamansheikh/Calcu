/// Display-side number helpers. Pure functions; no UI dependencies.
class NumberFormatter {
  NumberFormatter._();

  // Capture each integer run that is NOT preceded by a digit or '.' (so we
  // skip the fractional part of a number) and not preceded by a digit (so we
  // catch the start of an integer). The optional decimal tail is preserved.
  static final RegExp _numberRegex =
      RegExp(r'(?<![\d.])(\d+)(\.\d+)?');
  static final RegExp _thousandsRegex = RegExp(r'(\d)(?=(\d{3})+$)');

  /// Inserts thousands separators into the integer part of every number found
  /// in `input`. Operators, parentheses, and decimal portions are preserved.
  static String addThousandsSeparators(String input) {
    if (input.isEmpty) return input;
    return input.replaceAllMapped(_numberRegex, (match) {
      final intPart = match.group(1)!;
      final decimalPart = match.group(2) ?? '';
      final formatted = intPart.replaceAllMapped(
        _thousandsRegex,
        (m) => '${m.group(1)},',
      );
      return '$formatted$decimalPart';
    });
  }

  /// Formats a numeric result for display. Whole numbers drop the `.0`,
  /// otherwise we trim trailing zeros to keep the output compact.
  static String formatResult(double value) {
    if (value.isNaN) return 'Error';
    if (value.isInfinite) return value > 0 ? '∞' : '-∞';
    if (value == value.truncateToDouble() && value.abs() < 1e15) {
      return value.toInt().toString();
    }
    String text = value.toString();
    if (text.contains('e') || text.contains('E')) {
      text = value.toStringAsPrecision(12);
    }
    if (text.contains('.')) {
      text = text.replaceFirst(RegExp(r'0+$'), '');
      if (text.endsWith('.')) text = text.substring(0, text.length - 1);
    }
    return text;
  }

  /// Trim a result to N decimal places without producing trailing zeros.
  static String formatPrecise(double value, int decimals) {
    if (value.isNaN) return 'Error';
    if (value.isInfinite) return value > 0 ? '∞' : '-∞';
    return value.toStringAsFixed(decimals);
  }
}
