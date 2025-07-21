import 'dart:math' as math;

/// Mathematical utility functions for the calculator
class MathUtils {
  /// Check if a number is an integer
  static bool isInteger(double value) {
    return value == value.toInt();
  }

  /// Format number for display
  static String formatNumber(double number, {int maxDecimalPlaces = 10}) {
    if (number.isNaN) return 'Error';
    if (number.isInfinite) return number > 0 ? '∞' : '-∞';

    if (isInteger(number)) {
      return number.toInt().toString();
    }

    String formatted = number.toStringAsFixed(maxDecimalPlaces);
    // Remove trailing zeros
    formatted = formatted.replaceAll(RegExp(r'\.?0*$'), '');

    return formatted;
  }

  /// Add commas to large numbers for better readability
  static String addCommas(String numberString) {
    if (numberString.isEmpty || numberString == 'Error') return numberString;

    return numberString.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(\.|$))'),
      (Match match) => '${match.group(1)},',
    );
  }

  /// Calculate factorial
  static double factorial(int n) {
    if (n < 0) return double.nan;
    if (n == 0 || n == 1) return 1;

    double result = 1;
    for (int i = 2; i <= n; i++) {
      result *= i;
    }
    return result;
  }

  /// Calculate percentage
  static double percentage(double value, double percent) {
    return (value * percent) / 100;
  }

  /// Convert degrees to radians
  static double degreesToRadians(double degrees) {
    return degrees * (math.pi / 180);
  }

  /// Convert radians to degrees
  static double radiansToDegrees(double radians) {
    return radians * (180 / math.pi);
  }

  /// Calculate power
  static double power(double base, double exponent) {
    return math.pow(base, exponent).toDouble();
  }

  /// Calculate square root
  static double sqrt(double value) {
    return math.sqrt(value);
  }

  /// Calculate natural logarithm
  static double ln(double value) {
    return math.log(value);
  }

  /// Calculate base-10 logarithm
  static double log10(double value) {
    return math.log(value) / math.ln10;
  }

  /// Trigonometric functions
  static double sin(double value) => math.sin(value);
  static double cos(double value) => math.cos(value);
  static double tan(double value) => math.tan(value);
  static double asin(double value) => math.asin(value);
  static double acos(double value) => math.acos(value);
  static double atan(double value) => math.atan(value);

  /// Validate mathematical expression
  static bool isValidExpression(String expression) {
    if (expression.isEmpty) return false;

    // Check for balanced parentheses
    int openCount = 0;
    for (int i = 0; i < expression.length; i++) {
      if (expression[i] == '(') {
        openCount++;
      } else if (expression[i] == ')') {
        openCount--;
        if (openCount < 0) return false;
      }
    }

    return openCount == 0;
  }

  /// Clean mathematical expression
  static String cleanExpression(String expression) {
    // Remove extra spaces
    expression = expression.replaceAll(' ', '');

    // Replace common alternative operators
    expression = expression.replaceAll('×', '*');
    expression = expression.replaceAll('÷', '/');

    return expression;
  }

  /// Check if character is a digit
  static bool isDigit(String char) {
    return RegExp(r'[0-9]').hasMatch(char);
  }

  /// Check if character is an operator
  static bool isOperator(String char) {
    return ['+', '-', '*', '/', '×', '÷', '^', '%'].contains(char);
  }

  /// Get operator precedence
  static int getOperatorPrecedence(String operator) {
    switch (operator) {
      case '+':
      case '-':
        return 1;
      case '*':
      case '/':
      case '×':
      case '÷':
      case '%':
        return 2;
      case '^':
        return 3;
      default:
        return 0;
    }
  }
}
