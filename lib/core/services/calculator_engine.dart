import '../math/exact_form.dart';
import '../math/math_document.dart';
import '../math/math_evaluator.dart';
import '../math/real.dart';
import '../utils/number_formatter.dart';

/// Result of a calculator evaluation. Either holds a formatted display string
/// or an error flag that the UI renders as a short message.
class CalculationResult {
  const CalculationResult._({
    required this.display,
    required this.isError,
    this.number,
    this.exact,
  });

  /// The result as text, or the message for an error. A very large or very
  /// small result is written `m×10^n`, which is expression source and can be
  /// typeset or pasted back like any other.
  final String display;
  final bool isError;

  /// The computed value. Null for an error or an empty result.
  final Real? number;

  /// The result as a fraction, root or multiple of π, written as expression
  /// source (`frac(3,4)`), when it has such a form. Null for whole numbers
  /// and for values with no simple closed form.
  final String? exact;

  /// The value as a double, infinite if it is out of a double's range.
  double? get value => number?.toDouble();

  static const CalculationResult empty =
      CalculationResult._(display: '', isError: false);

  static const CalculationResult error =
      CalculationResult._(display: 'Error', isError: true);

  factory CalculationResult.success(Real number, {int? decimals}) {
    return CalculationResult._(
      display: decimals == null
          ? NumberFormatter.format(number)
          : NumberFormatter.formatFixed(number, decimals),
      isError: false,
      number: number,
      // The closed form needs every digit, so it is only looked for among
      // ordinary values.
      exact: number.isPlain ? ExactForm.of(number.toDouble()) : null,
    );
  }

  factory CalculationResult.failure(MathErrorKind kind) {
    return CalculationResult._(
      display: switch (kind) {
        MathErrorKind.divideByZero => "Can't divide by 0",
        MathErrorKind.notReal => 'Not a real number',
        MathErrorKind.tooLarge => 'Too large',
        MathErrorKind.syntax => 'Error',
      },
      isError: true,
    );
  }
}

/// Pure expression evaluator: parses the calculator's display syntax
/// (`×`, `÷`, `√`, `^`, `%`, fractions, logarithms, …) and computes it.
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
      return CalculationResult.success(
        MathEvaluator.evaluate(document),
        decimals: decimals,
      );
    } on MathError catch (error) {
      return CalculationResult.failure(error.kind);
    }
  }
}
