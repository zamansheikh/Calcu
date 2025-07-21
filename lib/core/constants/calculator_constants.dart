/// Calculator operation constants
class CalculatorConstants {
  static const String add = '+';
  static const String subtract = '-';
  static const String multiply = '×';
  static const String divide = '÷';
  static const String equals = '=';
  static const String decimal = '.';
  static const String percent = '%';
  static const String sqrt = '√';
  static const String power = '^';
  static const String openParen = '(';
  static const String closeParen = ')';
  static const String pi = 'π';
  static const String e = 'e';

  // Error messages
  static const String errorMessage = 'Error';
  static const String divisionByZero = 'Cannot divide by zero';
  static const String invalidInput = 'Invalid input';

  // Display constants
  static const String defaultDisplay = '0';
  static const int maxDisplayLength = 15;
  static const int maxDecimalPlaces = 10;

  // Storage keys
  static const String savedValuesKey = 'calculator_saved_values';
  static const String themeKey = 'calculator_theme_mode';

  // Animation durations
  static const Duration buttonAnimationDuration = Duration(milliseconds: 100);
  static const Duration pageTransitionDuration = Duration(milliseconds: 300);
  static const Duration cursorBlinkDuration = Duration(milliseconds: 500);
}
