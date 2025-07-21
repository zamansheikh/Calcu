import 'package:flutter/material.dart';

class InputController extends ChangeNotifier {
  final TextEditingController _textController = TextEditingController();
  int _cursorPosition = 0;

  // Getters
  String get input => _textController.text;
  int get cursorPosition => _cursorPosition;
  TextEditingController get textController => _textController;

  // Constructor
  InputController() {
    // Don't add automatic listener that interferes with manual cursor control
  }

  // Set cursor position
  void setCursorPosition(int position) {
    if (position < 0 || position > input.length) return;
    _cursorPosition = position;

    // Update TextEditingController selection
    _textController.selection = TextSelection.fromPosition(
      TextPosition(offset: position),
    );

    notifyListeners();
  }

  // Insert text at cursor position
  void insertText(String text) {
    final newText =
        input.substring(0, _cursorPosition) +
        text +
        input.substring(_cursorPosition);
    _textController.text = newText;
    setCursorPosition(_cursorPosition + text.length);
  }

  // Delete character at cursor position
  void deleteCharacter() {
    if (_cursorPosition <= 0 || input.isEmpty) return;

    final newText =
        input.substring(0, _cursorPosition - 1) +
        input.substring(_cursorPosition);
    _textController.text = newText;
    setCursorPosition(_cursorPosition - 1);
  }

  // Clear all input
  void clear() {
    _textController.clear();
    _cursorPosition = 0;
    notifyListeners();
  }

  // Set complete text and cursor to end
  void setText(String text) {
    _textController.text = text;
    _cursorPosition = text.length;
    notifyListeners();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
