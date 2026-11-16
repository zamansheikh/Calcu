import '../math/real.dart';

/// Display-side number helpers. Pure functions; no UI dependencies.
class NumberFormatter {
  NumberFormatter._();

  /// Significant digits shown for a result that is not a whole number.
  static const _digits = 12;

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

  /// Formats a result for display.
  ///
  /// A whole number is written out in full. Anything else is rounded to
  /// twelve significant digits, which also hides binary floating-point
  /// residue (0.1 + 0.2 reads 0.3). A value too large or too small to write
  /// out is put in scientific form, `m×10^n`.
  static String format(Real value) {
    if (value.isPlain) return formatResult(value.toDouble());
    final parts = value.scientific;
    // The digits of a result this size came from its logarithm, which spends
    // some of its precision on the exponent.
    final digits = (15 - '${parts.exponent.abs()}'.length).clamp(3, _digits);
    return _scientific(parts.mantissa, parts.exponent, digits: digits);
  }

  /// [value] to exactly [decimals] decimal places. In scientific form the
  /// places are those of the mantissa.
  static String formatFixed(Real value, int decimals) {
    if (value.isPlain) return formatPrecise(value.toDouble(), decimals);
    final parts = value.scientific;
    return _scientific(parts.mantissa, parts.exponent, decimals: decimals);
  }

  /// [format] for a value already known to fit a double.
  static String formatResult(double value) {
    if (value.isNaN) return 'Error';
    if (value.isInfinite) return value > 0 ? '∞' : '-∞';
    if (value == 0) return '0';

    final magnitude = value.abs();
    if (value == value.truncateToDouble() && magnitude < 1e15) {
      return value.toInt().toString();
    }
    if (magnitude >= 1e15 || magnitude < 1e-6) {
      final parts = Real(value).scientific;
      return _scientific(parts.mantissa, parts.exponent, digits: _digits);
    }

    // Twelve significant digits, but never fewer than it takes to keep the
    // whole part intact.
    final wholeDigits = magnitude < 1 ? 1 : '${magnitude.truncate()}'.length;
    final text = wholeDigits >= _digits
        ? value.toStringAsFixed((15 - wholeDigits).clamp(0, 3))
        : value.toStringAsPrecision(_digits);
    if (text.contains('e')) {
      // Rounding carried it up to the next power of ten.
      final parts = Real(value).scientific;
      return _scientific(parts.mantissa, parts.exponent, digits: _digits);
    }
    return _trimZeros(text);
  }

  /// [formatFixed] for a value already known to fit a double.
  static String formatPrecise(double value, int decimals) {
    if (value.isNaN) return 'Error';
    if (value.isInfinite) return value > 0 ? '∞' : '-∞';
    if (value.abs() >= 1e15) {
      final parts = Real(value).scientific;
      return _scientific(parts.mantissa, parts.exponent, decimals: decimals);
    }
    return value.toStringAsFixed(decimals);
  }

  /// `m×10^n`, with the mantissa rounded either to [digits] significant
  /// digits (trailing zeros dropped) or to exactly [decimals] places.
  static String _scientific(
    double mantissa,
    int exponent, {
    int? digits,
    int? decimals,
  }) {
    String write(double m) => decimals != null
        ? m.toStringAsFixed(decimals)
        : _trimZeros(m.toStringAsPrecision(digits!));

    var text = write(mantissa);
    // 9.9999… rounds up to 10: that is one more power of ten.
    if (text.replaceFirst('-', '').startsWith('10')) {
      text = write(mantissa / 10);
      exponent++;
    }
    return '$text×10^$exponent';
  }

  /// Drops trailing zeros after a decimal point, and the point with them.
  static String _trimZeros(String text) {
    if (!text.contains('.')) return text;
    var end = text.length;
    while (text[end - 1] == '0') {
      end--;
    }
    if (text[end - 1] == '.') end--;
    return text.substring(0, end);
  }
}
