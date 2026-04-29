import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/services/calculator_engine.dart';
import '../../data/repositories/saved_values_repository.dart';
import '../controllers/input_controller.dart';

/// Mediates between the input controller, the calculator engine, and the
/// saved-values repository. UI subscribes here for everything it needs.
class CalculatorProvider extends ChangeNotifier {
  CalculatorProvider({
    required CalculatorEngine engine,
    required SavedValuesRepository savedValuesRepository,
  })  : _engine = engine,
        _savedValuesRepository = savedValuesRepository {
    _input.addListener(_onInputChanged);
    _savedValues = List<String>.from(_savedValuesRepository.read());
  }

  final CalculatorEngine _engine;
  final SavedValuesRepository _savedValuesRepository;

  final InputController _input = InputController();
  final ScrollController _savedScrollController = ScrollController();

  CalculationResult _preview = CalculationResult.empty;
  bool _isCalculated = false;
  late List<String> _savedValues;

  // ---------------------------------------------------------------- Getters
  InputController get input => _input;
  ScrollController get savedScrollController => _savedScrollController;
  String get expression => _input.input;
  String get output => _preview.display;
  bool get hasError => _preview.isError;
  bool get isCalculated => _isCalculated;
  List<String> get savedValues => List.unmodifiable(_savedValues);

  // ----------------------------------------------------------- Input events
  void insertNumber(String value) {
    _afterEdit();
    _input.insertText(value);
    HapticFeedback.selectionClick();
  }

  void insertOperator(String value) {
    _afterEdit();
    _input.insertText(value);
    HapticFeedback.selectionClick();
  }

  void insertSymbol(String value) {
    _afterEdit();
    _input.insertText(value);
    HapticFeedback.selectionClick();
  }

  void backspace() {
    final removed = _input.deleteCharacter();
    if (removed) HapticFeedback.lightImpact();
  }

  void clearAll() {
    _input.clear();
    _preview = CalculationResult.empty;
    _isCalculated = false;
    HapticFeedback.mediumImpact();
    notifyListeners();
  }

  void moveCursor(int position) => _input.moveCursorTo(position);

  // ----------------------------------------------------------- Calculations
  void calculate() {
    if (expression.isEmpty) return;
    _preview = _engine.evaluate(expression);
    _isCalculated = true;
    HapticFeedback.mediumImpact();
    notifyListeners();
  }

  /// Long-press `=`: evaluate to 3 decimal places.
  void calculatePrecise() {
    if (expression.isEmpty) return;
    _preview = _engine.evaluate(expression, decimals: 3);
    _isCalculated = true;
    HapticFeedback.heavyImpact();
    notifyListeners();
  }

  // ---------------------------------------------------------- Saved values
  /// Save the current preview result. Returns false if nothing to save or
  /// the result is an error — callers can use that to skip a snackbar.
  bool saveCurrentResult() {
    if (_preview.isError || _preview.display.isEmpty) return false;
    _savedValues = [..._savedValues, _preview.display];
    _persistSaved();
    _scrollSavedToEnd();
    HapticFeedback.mediumImpact();
    notifyListeners();
    return true;
  }

  /// Long-press on the input area: evaluate now and save the result.
  bool saveExpressionResult() {
    if (expression.isEmpty) return false;
    final result = _engine.evaluate(expression);
    if (result.isError || result.display.isEmpty) return false;
    _preview = result;
    _savedValues = [..._savedValues, result.display];
    _persistSaved();
    _scrollSavedToEnd();
    HapticFeedback.mediumImpact();
    notifyListeners();
    return true;
  }

  void useSavedValue(int index) {
    if (index < 0 || index >= _savedValues.length) return;
    _afterEdit();
    _input.insertText(_savedValues[index]);
    HapticFeedback.selectionClick();
  }

  void deleteSavedValue(int index) {
    if (index < 0 || index >= _savedValues.length) return;
    _savedValues = [..._savedValues]..removeAt(index);
    _persistSaved();
    HapticFeedback.lightImpact();
    notifyListeners();
  }

  void clearSavedValues() {
    if (_savedValues.isEmpty) return;
    _savedValues = const <String>[];
    _persistSaved();
    HapticFeedback.heavyImpact();
    notifyListeners();
  }

  // ------------------------------------------------------------- Internals
  void _afterEdit() {
    if (_isCalculated) {
      _isCalculated = false;
    }
  }

  void _onInputChanged() {
    _preview = _engine.evaluate(expression);
    notifyListeners();
  }

  void _persistSaved() {
    _savedValuesRepository.write(_savedValues);
  }

  void _scrollSavedToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_savedScrollController.hasClients) return;
      _savedScrollController.animateTo(
        _savedScrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    _input.removeListener(_onInputChanged);
    _input.dispose();
    _savedScrollController.dispose();
    super.dispose();
  }
}
