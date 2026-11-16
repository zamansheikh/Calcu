import 'package:flutter/foundation.dart';

import '../../core/math/expression_editor.dart';
import '../../core/math/math_document.dart';

/// Owns the calculator's expression text and caret position.
///
/// Edits go through [ExpressionEditor], so the caret only ever rests on
/// positions the display can show and structures such as fractions are
/// inserted and removed whole.
class InputController extends ChangeNotifier {
  String _text = '';
  int _cursor = 0;
  MathDocument? _document;

  String get input => _text;
  int get cursor => _cursor;

  /// The parsed form of [input], shared by everything that draws it.
  MathDocument get document => _document ??= MathDocument.parse(_text);

  /// Insert at the caret; the caret advances past the inserted text.
  void insertText(String text) {
    if (text.isEmpty) return;
    _apply(ExpressionEditor.insert(_text, _cursor, text));
  }

  /// Insert a structure and leave the caret in its first empty slot.
  void insertTemplate(MathTemplate template) {
    _apply(ExpressionEditor.insertTemplate(_text, _cursor, template));
  }

  /// Backspace. Returns false if there was nothing to do.
  bool deleteCharacter() {
    return _apply(ExpressionEditor.backspace(_text, _cursor));
  }

  /// Replace the entire input. The caret moves to the end.
  void setText(String text) {
    _apply(EditState(text, ExpressionEditor.snap(text, text.length)));
  }

  /// Reset to empty. The caret returns to position 0.
  void clear() {
    _apply(const EditState('', 0));
  }

  /// Move the caret to the valid position nearest [position].
  void moveCursorTo(int position) {
    _apply(EditState(_text, ExpressionEditor.snap(_text, position)));
  }

  void moveLeft() => _apply(ExpressionEditor.moveLeft(_text, _cursor));

  void moveRight() => _apply(ExpressionEditor.moveRight(_text, _cursor));

  bool _apply(EditState next) {
    if (next.text == _text && next.cursor == _cursor) return false;
    if (next.text != _text) _document = null;
    _text = next.text;
    _cursor = next.cursor;
    notifyListeners();
    return true;
  }
}
