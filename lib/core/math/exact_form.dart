import 'dart:math' as math;

/// Finds the closed form behind a decimal result: 0.75 is ¾, 1.41421356… is
/// √2, 1.57079632… is π/2.
///
/// The answer is expression source in the calculator's own syntax
/// (`frac(3,4)`, `frac(√(2),2)`), so the display can typeset it like any
/// other expression.
abstract final class ExactForm {
  /// Returns null when [value] is a whole number (it already reads exactly)
  /// or when no simple form matches it.
  static String? of(double value) {
    if (value.isNaN || value.isInfinite) return null;
    final x = value.abs();
    final sign = value < 0 ? '-' : '';

    final rational = _rational(x, maxDenominator: 10000, noise: 1e-14);
    if (rational != null) {
      if (rational.q == 1) return null;
      return '${sign}frac(${rational.p},${rational.q})';
    }

    // A square root of a fraction: √(p/q) = √(p·q) / q.
    // Squaring and dividing each roughly double the relative error.
    final square = _rational(x * x, maxDenominator: 1000, noise: 4e-14);
    if (square != null && square.p <= 1000000) {
      var inside = square.p * square.q;
      var outside = 1;
      for (var f = 2; f * f <= inside; f++) {
        while (inside % (f * f) == 0) {
          inside ~/= f * f;
          outside *= f;
        }
      }
      final shared = outside.gcd(square.q);
      return sign +
          _over(
            _times(outside ~/ shared, '√($inside)'),
            square.q ~/ shared,
          );
    }

    // A fraction of π.
    final turns = _rational(x / math.pi, maxDenominator: 1000, noise: 2e-14);
    if (turns != null && turns.p <= 1000) {
      return sign + _over(_times(turns.p, 'π'), turns.q);
    }

    return null;
  }

  static String _times(int coefficient, String symbol) =>
      coefficient == 1 ? symbol : '$coefficient$symbol';

  static String _over(String numerator, int denominator) =>
      denominator == 1 ? numerator : 'frac($numerator,$denominator)';

  /// The fraction p/q that [x] is, if it is one, by continued fractions.
  ///
  /// "Is one" has to be strict. Every number is *near* some fraction, so a
  /// match only counts when it is as close as floating-point [noise] (a
  /// relative error) allows, and the denominator is small enough that so
  /// close a match cannot be a coincidence: an arbitrary number lands within
  /// `tolerance` of a fraction with denominator up to `limit` with
  /// probability about `tolerance × limit²`, held here to one in a million.
  /// Large values carry less precision after the decimal point, so they are
  /// allowed smaller denominators.
  static ({int p, int q})? _rational(
    double x, {
    required int maxDenominator,
    required double noise,
  }) {
    final tolerance = math.max(1.0, x) * noise;
    final limit = math.min(
      maxDenominator.toDouble(),
      math.sqrt(1e-6 / tolerance),
    );

    var previousP = 0, p = 1;
    var previousQ = 1, q = 0;
    var remainder = x;
    for (var i = 0; i < 40; i++) {
      final whole = remainder.floorToDouble();
      if (whole > 1e15) return null;
      final nextP = whole.toInt() * p + previousP;
      final nextQ = whole.toInt() * q + previousQ;
      if (nextQ > limit) return null;
      previousP = p;
      previousQ = q;
      p = nextP;
      q = nextQ;
      if ((x - p / q).abs() <= tolerance) return (p: p, q: q);

      final fraction = remainder - whole;
      if (fraction < 1e-15) return null;
      remainder = 1 / fraction;
    }
    return null;
  }
}
