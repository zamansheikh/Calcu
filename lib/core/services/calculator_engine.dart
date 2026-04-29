import 'package:math_expressions/math_expressions.dart';

import '../utils/number_formatter.dart';

/// Result of a calculator evaluation. Either holds a formatted display string
/// or an error flag that the UI can render as "Error".
class CalculationResult {
  const CalculationResult._({
    required this.display,
    required this.value,
    required this.isError,
  });

  final String display;
  final double? value;
  final bool isError;

  static const CalculationResult empty =
      CalculationResult._(display: '', value: null, isError: false);

  static const CalculationResult error =
      CalculationResult._(display: 'Error', value: null, isError: true);

  factory CalculationResult.success(double value, {int? decimals}) {
    final text = decimals == null
        ? NumberFormatter.formatResult(value)
        : NumberFormatter.formatPrecise(value, decimals);
    return CalculationResult._(display: text, value: value, isError: false);
  }
}

/// Pure expression evaluator. Translates the calculator's display syntax
/// (`×`, `÷`, `√`, `^`, `%`) into the parser's grammar before evaluating.
class CalculatorEngine {
  const CalculatorEngine();

  static const _operators = ['+', '-', '×', '÷', '*', '/', '^'];

  /// Evaluates a complete expression. If `decimals` is provided, the result
  /// is formatted to that many decimal places (used for the long-press `=`
  /// precise mode).
  CalculationResult evaluate(String input, {int? decimals}) {
    if (input.isEmpty) return CalculationResult.empty;
    if (!_isComplete(input)) return CalculationResult.empty;

    try {
      final expression = _preprocess(input);
      final parser = ShuntingYardParser();
      final exp = parser.parse(expression);
      final evaluator = RealEvaluator();
      final result = evaluator.evaluate(exp).toDouble();
      if (result.isNaN || result.isInfinite) return CalculationResult.error;
      return CalculationResult.success(result, decimals: decimals);
    } catch (_) {
      return CalculationResult.error;
    }
  }

  /// Heuristic for "should we show a live preview?". Avoids triggering on
  /// half-typed expressions like `2+` or `(3+4`.
  bool _isComplete(String input) {
    final last = input[input.length - 1];
    if (_operators.contains(last)) return false;
    if (last == '.') return false;
    if (last == '(') return false;

    int depth = 0;
    for (final ch in input.split('')) {
      if (ch == '(') depth++;
      if (ch == ')') depth--;
      if (depth < 0) return false;
    }
    return depth == 0;
  }

  /// Translate display syntax → math_expressions grammar.
  ///
  /// `math_expressions` already accepts `^` as POW and `%` as MOD natively,
  /// so we only rewrite tokens it doesn't understand (`×`, `÷`, `√`, `π`,
  /// percentage semantics, and the `mod(` long-press shortcut).
  String _preprocess(String input) {
    var s = input;
    s = s.replaceAll('×', '*');
    s = s.replaceAll('÷', '/');
    s = s.replaceAll('π', '(3.14159265358979)');
    s = s.replaceAll('√', 'sqrt');

    // The `%` button means percentage-of, NOT modulo (modulo is reachable
    // through the long-press `mod(` shortcut, handled below). Rewrite first
    // so the literal `%` is gone before the parser sees it.
    //   Standalone X% → (X/100)
    s = s.replaceAllMapped(
      RegExp(r'(\d+(?:\.\d+)?)%(?!\d)'),
      (m) => '(${m.group(1)}/100)',
    );
    //   X%Y (digit after) → (X/100)*Y, the calculator-style "percentage of"
    s = s.replaceAllMapped(
      RegExp(r'(\d+(?:\.\d+)?)%(\d+(?:\.\d+)?)'),
      (m) => '(${m.group(1)}/100)*${m.group(2)}',
    );

    // Long-press `%` inserts `mod(`, so users finish a modulo as `Xmod(Y)`.
    // Translate to the parser's native MOD operator. Done AFTER percentage
    // rewrites so the inserted `%` survives to the parser as MOD.
    s = s.replaceAllMapped(
      RegExp(r'(\d+(?:\.\d+)?|\([^()]*\))mod\((\d+(?:\.\d+)?|\([^()]*\))\)'),
      (m) => '(${m.group(1)}%${m.group(2)})',
    );

    return s;
  }
}
