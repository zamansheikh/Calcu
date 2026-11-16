import 'dart:math' as math;

import 'exact_form.dart';

/// Why a calculation has no answer.
enum MathErrorKind {
  /// The expression does not parse into something that can be evaluated.
  syntax,
  divideByZero,

  /// The answer exists only among the complex numbers, or not at all: the
  /// square root of a negative, the logarithm of zero.
  notReal,

  /// Beyond even [Real]'s range.
  tooLarge,
}

class MathError implements Exception {
  const MathError(this.kind);

  final MathErrorKind kind;

  @override
  String toString() => 'MathError(${kind.name})';
}

/// A real number with the precision of a double and a far wider range.
///
/// A double tops out near 1.8 × 10³⁰⁸, which a calculator reaches easily
/// (`2^1024`, `999^99999`) and used to report as an error. This carries a
/// decimal exponent alongside the double, so such results stay numbers.
///
/// Values a double holds comfortably are kept as that double, untouched, and
/// combined with ordinary double arithmetic. Everyday results are therefore
/// bit-for-bit what they were; the exponent only comes into play near the
/// double's limits.
class Real {
  const Real._(this._mantissa, this._exponent);

  /// [value] must be finite.
  factory Real(double value) => _normalized(value, 0);

  static const zero = Real._(0, 0);
  static const one = Real._(1, 0);
  static final pi = Real(math.pi);
  static final e = Real(math.e);

  /// The value is `_mantissa × 10^_exponent`. Ordinary values have an
  /// exponent of 0 and are exactly the double in `_mantissa`; the others are
  /// in scientific form, with 1 ≤ |mantissa| < 10.
  final double _mantissa;
  final int _exponent;

  // A product or power that lands outside this band is recomputed in
  // scientific form rather than trusted: close to a double's limits it may
  // already have overflowed or lost digits to underflow.
  static const _plainMax = 1e290;
  static const _plainMin = 1e-290;

  /// Exponents past this are reported as too large rather than carried: the
  /// exponent is itself held in a double during a power.
  static const _maxExponent = 1000000000000000;

  /// Reads a number literal: digits with at most one decimal point, of any
  /// length.
  static Real parse(String text) {
    if ('.'.allMatches(text).length > 1 || !text.contains(RegExp(r'\d'))) {
      throw const MathError(MathErrorKind.syntax);
    }
    final direct = double.tryParse(text.endsWith('.') ? '${text}0' : text);
    if (direct == null) throw const MathError(MathErrorKind.syntax);
    if (direct == 0 || _isPlain(direct)) return Real._(direct, 0);

    // Too long for a double: take the leading digits as the mantissa and
    // count places for the exponent.
    final point = text.indexOf('.');
    final whole = point < 0 ? text : text.substring(0, point);
    final digits = text.replaceFirst('.', '');
    final first = digits.indexOf(RegExp('[1-9]'));
    if (first < 0) return zero;
    final significant = digits.substring(first);
    final head = significant.length > 17
        ? significant.substring(0, 17)
        : significant;
    final mantissa = double.parse('${head[0]}.${head.substring(1)}0');
    return _normalized(mantissa, whole.length - first - 1);
  }

  bool get isZero => _mantissa == 0;
  bool get isNegative => _mantissa < 0;

  /// Whether this is an ordinary double, as opposed to one carried in
  /// scientific form because it is too large or too small for one.
  bool get isPlain => _exponent == 0;

  /// The value as a double: infinite or zero if it is out of a double's
  /// range.
  double toDouble() {
    if (_exponent == 0) return _mantissa;
    if (_exponent > 308) {
      return _mantissa < 0 ? double.negativeInfinity : double.infinity;
    }
    if (_exponent < -340) return 0;
    return _mantissa * _pow10(_exponent);
  }

  /// The value as `mantissa × 10^exponent` with 1 ≤ |mantissa| < 10.
  ({double mantissa, int exponent}) get scientific {
    if (_exponent != 0 || _mantissa == 0) {
      return (mantissa: _mantissa, exponent: _exponent);
    }
    return _split(_mantissa);
  }

  Real operator -() => Real._(-_mantissa, _exponent);

  Real get abs => Real._(_mantissa.abs(), _exponent);

  Real operator +(Real other) {
    if (isPlain && other.isPlain) {
      final sum = _mantissa + other._mantissa;
      if (sum.isFinite) return Real._(sum, 0);
    }
    if (isZero) return other;
    if (other.isZero) return this;

    var big = scientific, small = other.scientific;
    if (small.exponent > big.exponent) (big, small) = (small, big);
    final gap = big.exponent - small.exponent;
    // Past the mantissa's precision the smaller term changes nothing.
    if (gap > 40) return _normalized(big.mantissa, big.exponent);
    return _normalized(
      big.mantissa + small.mantissa / _pow10(gap),
      big.exponent,
    );
  }

  Real operator -(Real other) => this + (-other);

  Real operator *(Real other) {
    if (isZero || other.isZero) return zero;
    if (isPlain && other.isPlain) {
      final product = _mantissa * other._mantissa;
      if (_isPlain(product)) return Real._(product, 0);
    }
    final a = scientific, b = other.scientific;
    return _normalized(a.mantissa * b.mantissa, a.exponent + b.exponent);
  }

  Real operator /(Real other) {
    if (other.isZero) throw const MathError(MathErrorKind.divideByZero);
    if (isZero) return zero;
    if (isPlain && other.isPlain) {
      final quotient = _mantissa / other._mantissa;
      if (_isPlain(quotient)) return Real._(quotient, 0);
    }
    final a = scientific, b = other.scientific;
    return _normalized(a.mantissa / b.mantissa, a.exponent - b.exponent);
  }

  /// The remainder of dividing by [other], with the sign Dart gives it.
  Real mod(Real other) {
    if (other.isZero) throw const MathError(MathErrorKind.divideByZero);
    if (isPlain && other.isPlain) {
      return Real._(_mantissa % other._mantissa, 0);
    }
    // Smaller than the divisor: it is its own remainder (counted up from
    // zero, so a negative one wraps round to just under the divisor).
    if (_exponent < other._exponent) {
      return isNegative ? other.abs + this : this;
    }
    // Otherwise the dividend is in scientific form, and has no last digits
    // left to take a remainder of.
    throw const MathError(MathErrorKind.tooLarge);
  }

  Real sqrt() {
    if (isNegative) throw const MathError(MathErrorKind.notReal);
    if (isPlain) return Real._(math.sqrt(_mantissa), 0);
    // Halve an even exponent; shift one place first if it is odd.
    final odd = _exponent.isOdd;
    return _normalized(
      math.sqrt(odd ? _mantissa * 10 : _mantissa),
      (odd ? _exponent - 1 : _exponent) ~/ 2,
    );
  }

  /// The natural logarithm.
  Real ln() {
    if (isZero || isNegative) throw const MathError(MathErrorKind.notReal);
    if (isPlain) return Real(math.log(_mantissa));
    return Real(math.log(_mantissa) + _exponent * math.ln10);
  }

  /// The logarithm of this number to [base].
  Real log(Real base) {
    final divisor = base.ln();
    // There is no logarithm to base 1: every power of 1 is 1.
    if (divisor.isZero) throw const MathError(MathErrorKind.notReal);
    return ln() / divisor;
  }

  Real pow(Real exponent) {
    final x = exponent.toDouble();
    if (isZero) {
      if (x > 0) return zero;
      if (x == 0) return one;
      throw const MathError(MathErrorKind.divideByZero);
    }

    // A negative base has a real power only for whole exponents and for
    // fractions with an odd denominator: (-8)^(1/3) is -2.
    var sign = 1.0;
    if (isNegative) {
      final odd = _oddNumerator(x);
      if (odd == null) throw const MathError(MathErrorKind.notReal);
      if (odd) sign = -1.0;
    }

    if (isPlain) {
      final direct = math.pow(_mantissa.abs(), x).toDouble();
      if (_isPlain(direct)) return Real._(sign * direct, 0);
    }

    // Out of a double's reach: work with the logarithm of the answer, whose
    // whole part is the exponent and fraction the mantissa.
    final base = abs.scientific;
    final log10 = x * (math.log(base.mantissa) / math.ln10 + base.exponent);
    if (log10.isNaN) throw const MathError(MathErrorKind.notReal);
    if (log10 > _maxExponent) throw const MathError(MathErrorKind.tooLarge);
    if (log10 < -_maxExponent) return zero;
    final whole = log10.floor();
    return _normalized(sign * math.pow(10.0, log10 - whole), whole);
  }

  /// For a negative base raised to [x]: whether the result is negative, or
  /// null if it is not real. [x] has to be a whole number or a fraction with
  /// an odd denominator; the result is negative when its numerator is odd.
  static bool? _oddNumerator(double x) {
    if (!x.isFinite) return null;
    final magnitude = x.abs();
    if (magnitude == magnitude.truncateToDouble()) {
      // Beyond 2^53 every double is even.
      return magnitude < 9007199254740992 && magnitude % 2 == 1;
    }
    final fraction =
        ExactForm.rational(magnitude, maxDenominator: 1000, noise: 1e-14);
    if (fraction == null || fraction.q.isEven) return null;
    return fraction.p.isOdd;
  }

  /// 10 to a whole power, as a double. The library `pow` given two integers
  /// does integer arithmetic, and silently wraps around past 10^18.
  static double _pow10(int power) => math.pow(10.0, power).toDouble();

  static bool _isPlain(double value) {
    if (!value.isFinite) return false;
    final magnitude = value.abs();
    return magnitude < _plainMax && magnitude > _plainMin;
  }

  /// [value] as a mantissa in [1, 10) and a power of ten. [value] must be
  /// finite and non-zero.
  static ({double mantissa, int exponent}) _split(double value) {
    var exponent = (math.log(value.abs()) / math.ln10).floor();
    // Dividing by 10^exponent in one step would overflow or underflow at
    // the far ends of a double's range, so go in two.
    final half = exponent ~/ 2;
    var mantissa = value / _pow10(half) / _pow10(exponent - half);
    // The logarithm can be off by one right at a power of ten.
    if (mantissa.abs() >= 10) {
      mantissa /= 10;
      exponent++;
    } else if (mantissa.abs() < 1) {
      mantissa *= 10;
      exponent--;
    }
    return (mantissa: mantissa, exponent: exponent);
  }

  static Real _normalized(double mantissa, int exponent) {
    if (mantissa.isNaN) throw const MathError(MathErrorKind.notReal);
    if (mantissa.isInfinite) throw const MathError(MathErrorKind.tooLarge);
    if (mantissa == 0) return zero;
    if (exponent == 0 && _isPlain(mantissa)) return Real._(mantissa, 0);

    final parts = _split(mantissa);
    final total = exponent + parts.exponent;
    if (total > _maxExponent) throw const MathError(MathErrorKind.tooLarge);
    if (total < -_maxExponent) return zero;
    // Back to an ordinary double once it fits in one again.
    if (total.abs() < 290) {
      return Real._(parts.mantissa * _pow10(total), 0);
    }
    return Real._(parts.mantissa, total);
  }

  @override
  String toString() =>
      isPlain ? '$_mantissa' : '$_mantissa×10^$_exponent';
}
