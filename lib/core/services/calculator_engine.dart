import 'package:math_expressions/math_expressions.dart';

import '../math/exact_form.dart';
import '../math/math_document.dart';
import '../utils/number_formatter.dart';

/// Result of a calculator evaluation. Either holds a formatted display string
/// or an error flag that the UI can render as "Error".
class CalculationResult {
  const CalculationResult._({
    required this.display,
    required this.value,
    required this.isError,
    this.exact,
  });

  final String display;
  final double? value;
  final bool isError;

  /// The result as a fraction, root or multiple of π, written as expression
  /// source (`frac(3,4)`), when it has such a form. Null for whole numbers
  /// and for values with no simple closed form.
  final String? exact;

  static const CalculationResult empty =
      CalculationResult._(display: '', value: null, isError: false);

  static const CalculationResult error =
      CalculationResult._(display: 'Error', value: null, isError: true);

  factory CalculationResult.success(
    double value, {
    int? decimals,
    String? exact,
  }) {
    final text = decimals == null
        ? NumberFormatter.formatResult(value)
        : NumberFormatter.formatPrecise(value, decimals);
    return CalculationResult._(
      display: text,
      value: value,
      isError: false,
      exact: exact,
    );
  }
}

/// Pure expression evaluator. Translates the calculator's display syntax
/// (`×`, `÷`, `√`, `^`, `%`, fractions, logarithms, …) into the parser's
/// grammar before evaluating.
class CalculatorEngine {
  const CalculatorEngine();

  /// Evaluates a complete expression. If `decimals` is provided, the result
  /// is formatted to that many decimal places (used for the long-press `=`
  /// precise mode).
  CalculationResult evaluate(String input, {int? decimals}) {
    if (input.isEmpty) return CalculationResult.empty;
    // Half-typed input (`2+`, `(3+4`, an empty denominator) gets no preview.
    final document = MathDocument.parse(input);
    if (!document.isComplete) return CalculationResult.empty;

    try {
      final expression = _preprocess(document.toEngineSource());
      final parser = ShuntingYardParser();
      final exp = parser.parse(expression);
      final evaluator = RealEvaluator();
      final raw = evaluator.evaluate(exp).toDouble();
      final result = _trimNoise(raw);
      if (result.isNaN || result.isInfinite) return CalculationResult.error;
      return CalculationResult.success(
        result,
        decimals: decimals,
        // From the unrounded value: the closed form needs every digit.
        exact: ExactForm.of(raw),
      );
    } catch (_) {
      return CalculationResult.error;
    }
  }

  /// Rounds away binary floating-point residue, so that log₁₀1000 reads 3
  /// rather than 2.9999999999999996 and 0.1+0.2 reads 0.3.
  static double _trimNoise(double value) {
    if (value.isNaN || value.isInfinite) return value;
    return double.parse(value.toStringAsPrecision(12));
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
