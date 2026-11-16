import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/math/expression_editor.dart';
import '../../core/services/calculator_engine.dart';
import '../../core/utils/number_formatter.dart';
import '../../data/models/saved_entry.dart';
import '../../data/repositories/saved_values_repository.dart';
import '../controllers/input_controller.dart';

/// How the result is written. Pressing `=` again steps through these.
enum ResultFormat {
  /// The plain decimal: 0.75.
  decimal,

  /// The closed form, when there is one: ¾, √2, π/2.
  fraction,

  /// Rounded to three decimal places: 0.750.
  precise,
}

/// Mediates between the input controller, the calculator engine, and the
/// saved-values repository. UI subscribes here for everything it needs.
class CalculatorProvider extends ChangeNotifier {
  static const _preciseDecimals = 3;

  CalculatorProvider({
    required CalculatorEngine engine,
    required SavedValuesRepository savedValuesRepository,
  })  : _engine = engine,
        _savedValuesRepository = savedValuesRepository {
    _input.addListener(_onInputChanged);
    _savedEntries = List<SavedEntry>.of(_savedValuesRepository.read());
  }

  final CalculatorEngine _engine;
  final SavedValuesRepository _savedValuesRepository;

  final InputController _input = InputController();
  final ScrollController _savedScrollController = ScrollController();

  CalculationResult _preview = CalculationResult.empty;
  ResultFormat _format = ResultFormat.decimal;
  // The expression `_preview` was computed from.
  String _evaluatedText = '';
  bool _isCalculated = false;
  late List<SavedEntry> _savedEntries;

  // ---------------------------------------------------------------- Getters
  InputController get input => _input;
  ScrollController get savedScrollController => _savedScrollController;
  String get expression => _input.input;
  bool get hasError => _preview.isError;

  /// The format the result is currently shown in.
  ResultFormat get resultFormat => _format;

  /// The result in [resultFormat]. For [ResultFormat.fraction] this is
  /// expression source to typeset; otherwise it is plain text.
  String get output {
    final value = _preview.value;
    return switch (_format) {
      ResultFormat.fraction => _preview.exact ?? _preview.display,
      ResultFormat.precise when value != null =>
        NumberFormatter.formatPrecise(value, _preciseDecimals),
      _ => _preview.display,
    };
  }

  /// What pressing `=` again will switch the result to, or null while there
  /// is no finished result to reformat.
  ResultFormat? get nextResultFormat =>
      _isCalculated && _preview.value != null ? _formatAfter(_format) : null;

  ResultFormat _formatAfter(ResultFormat format) => switch (format) {
        ResultFormat.decimal => _preview.exact != null
            ? ResultFormat.fraction
            : ResultFormat.precise,
        ResultFormat.fraction => ResultFormat.precise,
        ResultFormat.precise => ResultFormat.decimal,
      };
  bool get isCalculated => _isCalculated;
  List<SavedEntry> get savedEntries => List.unmodifiable(_savedEntries);

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

  /// Insert a fraction, root, logarithm… with the caret in its first slot.
  void insertTemplate(MathTemplate template) {
    _afterEdit();
    _input.insertTemplate(template);
    HapticFeedback.selectionClick();
  }

  void backspace() {
    final removed = _input.deleteCharacter();
    if (removed) HapticFeedback.lightImpact();
  }

  void moveCursorLeft() {
    _input.moveLeft();
    HapticFeedback.selectionClick();
  }

  void moveCursorRight() {
    _input.moveRight();
    HapticFeedback.selectionClick();
  }

  void clearAll() {
    _input.clear();
    _preview = CalculationResult.empty;
    _evaluatedText = '';
    _format = ResultFormat.decimal;
    _isCalculated = false;
    HapticFeedback.mediumImpact();
    notifyListeners();
  }

  void moveCursor(int position) => _input.moveCursorTo(position);

  // ----------------------------------------------------------- Calculations
  /// `=`. The first press settles the result; each press after that, until
  /// the expression is edited, shows it in the next [ResultFormat].
  void calculate() {
    if (expression.isEmpty) return;
    final next = nextResultFormat;
    if (next != null) {
      _format = next;
    } else {
      _preview = _engine.evaluate(expression);
      _format = ResultFormat.decimal;
      _isCalculated = true;
    }
    HapticFeedback.mediumImpact();
    notifyListeners();
  }

  /// Long-press `=`: go straight to 3 decimal places.
  void calculatePrecise() {
    if (expression.isEmpty) return;
    _preview = _engine.evaluate(expression);
    _format = ResultFormat.precise;
    _isCalculated = true;
    HapticFeedback.heavyImpact();
    notifyListeners();
  }

  // ---------------------------------------------------------- Saved values
  /// Save the current preview result. Returns false if nothing to save or
  /// the result is an error — callers can use that to skip a snackbar.
  bool saveCurrentResult() {
    if (_preview.isError || _preview.display.isEmpty) return false;
    // A saved value is inserted into expressions as a number, so the closed
    // form is saved as its decimal.
    final text =
        _format == ResultFormat.fraction ? _preview.display : output;
    _savedEntries = [
      ..._savedEntries,
      SavedEntry(value: text, expression: expression),
    ];
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
    _savedEntries = [
      ..._savedEntries,
      SavedEntry(value: result.display, expression: expression),
    ];
    _persistSaved();
    _scrollSavedToEnd();
    HapticFeedback.mediumImpact();
    notifyListeners();
    return true;
  }

  /// Paste a saved result at the caret.
  void useSavedValue(int index) {
    if (index < 0 || index >= _savedEntries.length) return;
    _afterEdit();
    _input.insertText(_savedEntries[index].value);
    HapticFeedback.selectionClick();
  }

  /// Paste the expression a saved result came from. Into an empty display it
  /// goes in exactly as it was written, ready to edit; into the middle of
  /// another expression it is bracketed where it needs to be, so that it
  /// still stands for the same value there.
  void useSavedExpression(int index) {
    if (index < 0 || index >= _savedEntries.length) return;
    final source = _savedEntries[index].expression;
    if (source == null) return useSavedValue(index);
    _afterEdit();
    _input.insertText(
      expression.isEmpty ? source : ExpressionEditor.asOperand(source),
    );
    HapticFeedback.selectionClick();
  }

  /// Removes a saved entry and returns it, so the caller can offer to put
  /// it back with [restoreSavedEntry].
  SavedEntry? deleteSavedValue(int index) {
    if (index < 0 || index >= _savedEntries.length) return null;
    final removed = _savedEntries[index];
    _savedEntries = [..._savedEntries]..removeAt(index);
    _persistSaved();
    HapticFeedback.lightImpact();
    notifyListeners();
    return removed;
  }

  /// Puts [entry] back where it was, at [index].
  void restoreSavedEntry(int index, SavedEntry entry) {
    final at = index.clamp(0, _savedEntries.length);
    _savedEntries = [..._savedEntries]..insert(at, entry);
    _persistSaved();
    HapticFeedback.selectionClick();
    notifyListeners();
  }

  void clearSavedValues() {
    if (_savedEntries.isEmpty) return;
    _savedEntries = const <SavedEntry>[];
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
    // Also runs when only the caret moved, which leaves the result alone.
    if (expression != _evaluatedText) {
      _evaluatedText = expression;
      _preview = _engine.evaluate(expression);
      _format = ResultFormat.decimal;
      _isCalculated = false;
    }
    notifyListeners();
  }

  void _persistSaved() {
    _savedValuesRepository.write(_savedEntries);
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
