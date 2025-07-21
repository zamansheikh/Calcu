import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:calcu/core/controllers/improved_input_controller.dart';

class CalculatorProvider extends ChangeNotifier {
  final InputController _inputController = InputController();
  final ScrollController _scrollController = ScrollController();

  InputController get inputController => _inputController;
  ScrollController get scrollController => _scrollController;

  String _output = '';
  String get output => _output;

  List<String> _savedValues = <String>[];
  List<String> get savedValues => _savedValues;

  bool _isCalculated = false;
  bool get isCalculated => _isCalculated;

  CalculatorProvider() {
    _inputController.addListener(_onInputChanged);
    _loadSavedValues();
  }

  void _onInputChanged() {
    // Only auto-calculate when input is a complete expression
    if (_inputController.input.isNotEmpty &&
        _isCompleteExpression(_inputController.input)) {
      _calculateExpression();
    } else {
      _output = '';
    }
    notifyListeners();
  }

  /// Check if expression is complete enough to calculate
  bool _isCompleteExpression(String input) {
    // Don't calculate if ending with an operator (except %)
    if (input.isEmpty) return false;

    String lastChar = input[input.length - 1];
    List<String> operators = ['+', '-', '×', '÷', '*', '/', '^'];

    // Allow calculation if ending with % or numbers or )
    if (operators.contains(lastChar)) {
      return false;
    }

    // Check for balanced parentheses
    int openCount = 0;
    for (int i = 0; i < input.length; i++) {
      if (input[i] == '(') openCount++;
      if (input[i] == ')') openCount--;
    }

    // Don't calculate if parentheses are not balanced
    if (openCount != 0) return false;

    return true;
  }

  /// Load saved values from SharedPreferences
  Future<void> _loadSavedValues() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? saved = prefs.getStringList('calculator_saved_values');
    if (saved != null) {
      _savedValues = saved;
      notifyListeners();
    }
  }

  /// Save values to SharedPreferences
  Future<void> _saveToPersistence() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('calculator_saved_values', _savedValues);
  }

  /// Insert number or operator
  void insertInput(String value) {
    _isCalculated = false;
    _inputController.insertText(value);
    HapticFeedback.lightImpact();
  }

  /// Delete character
  void deleteCharacter() {
    _inputController.deleteCharacter();
    HapticFeedback.heavyImpact();
  }

  /// Clear all
  void clearAll() {
    _inputController.clear();
    _output = '';
    _isCalculated = false;
    HapticFeedback.heavyImpact();
    notifyListeners();
  }

  /// Calculate expression
  void calculate() {
    if (_inputController.input.isNotEmpty) {
      _calculateExpression();
      _isCalculated = true;
      HapticFeedback.heavyImpact();
    }
  }

  /// Calculate with 3 decimal precision
  void calculatePrecise() {
    if (_inputController.input.isNotEmpty) {
      _calculateExpression();
      double? val = double.tryParse(_output);
      if (val != null && _output != 'Error') {
        _output = val.toStringAsFixed(3);
      }
      _isCalculated = true;
      HapticFeedback.vibrate();
      notifyListeners();
    }
  }

  /// Internal calculation method
  void _calculateExpression() {
    try {
      String expression = _preprocessExpression(_inputController.input);
      ShuntingYardParser parser = ShuntingYardParser();
      Expression exp = parser.parse(expression);

      // Use RealEvaluator instead of deprecated evaluate method
      RealEvaluator evaluator = RealEvaluator();
      double result = evaluator.evaluate(exp).toDouble();

      // Handle special cases
      if (result.isNaN) {
        _output = 'Error';
      } else if (result.isInfinite) {
        _output = result > 0 ? '∞' : '-∞';
      } else {
        _output = _formatResult(result);
      }
    } catch (e) {
      _output = 'Error';
    }
  }

  /// Preprocess expression for calculation
  String _preprocessExpression(String input) {
    String processed = input;

    // Replace custom operators with standard mathematical operators
    processed = processed.replaceAll('×', '*');
    processed = processed.replaceAll('÷', '/');
    processed = processed.replaceAll('π', '3.14159265359');
    processed = processed.replaceAll('e', '2.71828182846');

    // Handle percentage - convert X% to (X/100)
    processed = processed.replaceAllMapped(
      RegExp(r'(\d+(?:\.\d+)?)%'),
      (match) => '(${match.group(1)}/100)',
    );

    // Handle square root
    processed = processed.replaceAll('√', 'sqrt');

    // Handle power operator - need proper syntax for math_expressions
    processed = processed.replaceAllMapped(
      RegExp(r'(\d+(?:\.\d+)?)\^(\d+(?:\.\d+)?)'),
      (match) => 'pow(${match.group(1)}, ${match.group(2)})',
    );

    return processed;
  }

  /// Format calculation result
  String _formatResult(double result) {
    if (result == result.toInt()) {
      return result.toInt().toString();
    } else {
      return result.toString();
    }
  }

  /// Save current result to saved values
  void saveResult() {
    if (_output.isNotEmpty && _output != 'Error') {
      _savedValues.add(_output);
      _saveToPersistence();
      _scrollToEnd();
      HapticFeedback.lightImpact();
      notifyListeners();
    }
  }

  /// Save input result (when long pressing input)
  void saveInputResult() {
    if (_inputController.input.isNotEmpty) {
      _calculateExpression();
      if (_output != 'Error' && _output.isNotEmpty) {
        _savedValues.add(_convertDoubleToInt(_output));
        _saveToPersistence();
        _scrollToEnd();
        HapticFeedback.heavyImpact();
        notifyListeners();
      }
    }
  }

  /// Convert double to int string if it's a whole number
  String _convertDoubleToInt(String input) {
    double? doubleValue = double.tryParse(input);
    if (doubleValue != null && doubleValue == doubleValue.toInt()) {
      return doubleValue.toInt().toString();
    }
    return input;
  }

  /// Use saved value
  void useSavedValue(int index) {
    if (index >= 0 && index < _savedValues.length) {
      _inputController.insertText(_savedValues[index]);
      HapticFeedback.lightImpact();
    }
  }

  /// Delete single saved value
  void deleteSavedValue(int index) {
    if (index >= 0 && index < _savedValues.length) {
      _savedValues.removeAt(index);
      _saveToPersistence();
      HapticFeedback.lightImpact();
      notifyListeners();
    }
  }

  /// Clear all saved values
  void clearAllSavedValues() {
    _savedValues.clear();
    _saveToPersistence();
    HapticFeedback.heavyImpact();
    notifyListeners();
  }

  /// Scroll to end of saved values
  void _scrollToEnd() {
    if (_savedValues.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  /// Add comma formatting to numbers
  String addCommasToNumbers(String input) {
    return input.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(\.|$))'),
      (Match match) => '${match.group(1)},',
    );
  }

  /// Mathematical functions
  void insertSin() => insertInput('sin(');
  void insertCos() => insertInput('cos(');
  void insertTan() => insertInput('tan(');
  void insertLog() => insertInput('log(');
  void insertLn() => insertInput('ln(');
  void insertSqrt() => insertInput('√(');
  void insertPi() => insertInput('π');
  void insertE() => insertInput('e');
  void insertPower() => insertInput('^');

  /// Basic operations
  void insertNumber(String number) => insertInput(number);
  void insertOperator(String operator) => insertInput(operator);
  void insertDecimal() => insertInput('.');
  void insertOpenParenthesis() => insertInput('(');
  void insertCloseParenthesis() => insertInput(')');
  void insertMultiply() => insertInput('×');
  void insertDivide() => insertInput('÷');
  void insertAdd() => insertInput('+');
  void insertSubtract() => insertInput('-');
  void insertPercent() => insertInput('%');

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
