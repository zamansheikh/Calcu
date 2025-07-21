import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InputController extends ChangeNotifier {
  final TextEditingController _textController = TextEditingController();
  int _cursorPosition = 0;

  String get input => _textController.text;
  int get cursorPosition => _cursorPosition;
  TextEditingController get textController => _textController;

  InputController() {
    _textController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    _cursorPosition = _textController.selection.baseOffset;
    notifyListeners();
  }

  /// Insert text at current cursor position
  void insertText(String text) {
    final currentText = _textController.text;
    final selection = _textController.selection;

    if (selection.isValid) {
      final newText = currentText.replaceRange(
        selection.start,
        selection.end,
        text,
      );

      final newCursorPosition = selection.start + text.length;

      _textController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: newCursorPosition),
      );

      _cursorPosition = newCursorPosition;
    } else {
      _textController.text += text;
      _cursorPosition = _textController.text.length;
    }

    HapticFeedback.lightImpact();
    notifyListeners();
  }

  /// Delete character before cursor position (backspace)
  void deleteCharacter() {
    if (_textController.text.isEmpty) return;

    final currentText = _textController.text;
    final selection = _textController.selection;

    if (selection.isValid && selection.start > 0) {
      final newText = currentText.replaceRange(
        selection.start - 1,
        selection.start,
        '',
      );

      final newCursorPosition = selection.start - 1;

      _textController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: newCursorPosition),
      );

      _cursorPosition = newCursorPosition;
    }

    HapticFeedback.heavyImpact();
    notifyListeners();
  }

  /// Set cursor position
  void setCursorPosition(int position) {
    final clampedPosition = position.clamp(0, _textController.text.length);
    _textController.selection = TextSelection.collapsed(
      offset: clampedPosition,
    );
    _cursorPosition = clampedPosition;
    notifyListeners();
  }

  /// Clear all input
  void clear() {
    _textController.clear();
    _cursorPosition = 0;
    HapticFeedback.heavyImpact();
    notifyListeners();
  }

  /// Set the complete input text
  void setInput(String text) {
    _textController.text = text;
    _cursorPosition = text.length;
    notifyListeners();
  }

  /// Get text with cursor position marked (for debugging)
  String getInputWithCursor() {
    final text = _textController.text;
    if (_cursorPosition >= 0 && _cursorPosition <= text.length) {
      return '${text.substring(0, _cursorPosition)}|${text.substring(_cursorPosition)}';
    }
    return text;
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
