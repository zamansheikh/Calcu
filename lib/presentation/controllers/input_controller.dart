import 'package:flutter/material.dart';

/// Owns the calculator's expression text and cursor position.
///
/// Wraps a `TextEditingController` so the cursor work integrates naturally
/// with Flutter's text APIs while keeping the controller decoupled from the
/// providers that consume it.
class InputController extends ChangeNotifier {
  final TextEditingController _textController = TextEditingController();
  int _cursor = 0;

  String get input => _textController.text;
  int get cursor => _cursor;
  TextEditingController get textController => _textController;

  /// Insert at current cursor; cursor advances past the inserted text.
  void insertText(String text) {
    if (text.isEmpty) return;
    final current = _textController.text;
    final newText =
        current.substring(0, _cursor) + text + current.substring(_cursor);
    _textController.text = newText;
    _setCursor(_cursor + text.length);
  }

  /// Backspace: delete the character immediately before the cursor.
  bool deleteCharacter() {
    if (_cursor <= 0 || input.isEmpty) return false;
    final newText =
        input.substring(0, _cursor - 1) + input.substring(_cursor);
    _textController.text = newText;
    _setCursor(_cursor - 1);
    return true;
  }

  /// Replace the entire input. Cursor moves to the end.
  void setText(String text) {
    _textController.text = text;
    _setCursor(text.length);
  }

  /// Reset to empty. Cursor returns to position 0.
  void clear() {
    _textController.clear();
    _setCursor(0);
  }

  /// Move the cursor; values outside `[0, input.length]` are clamped.
  void moveCursorTo(int position) {
    final clamped = position.clamp(0, input.length);
    if (clamped == _cursor) return;
    _setCursor(clamped);
  }

  void _setCursor(int position) {
    _cursor = position;
    _textController.selection =
        TextSelection.fromPosition(TextPosition(offset: position));
    notifyListeners();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
