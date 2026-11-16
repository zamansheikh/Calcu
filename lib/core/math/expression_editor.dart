import 'math_document.dart';
import 'math_node.dart';

/// Expression text together with the caret's index in it.
class EditState {
  const EditState(this.text, this.cursor);

  final String text;
  final int cursor;

  @override
  bool operator ==(Object other) =>
      other is EditState && other.text == text && other.cursor == cursor;

  @override
  int get hashCode => Object.hash(text, cursor);
}

/// Structures the keypad inserts whole, with the caret left in the first
/// slot. [close] holds everything after that slot.
enum MathTemplate {
  squareRoot('√(', ')'),
  absolute('abs(', ')'),
  fraction('frac(', ',)'),
  logarithm('log(', ',)'),
  naturalLog('ln(', ')'),
  modulo('mod(', ')');

  const MathTemplate(this.open, this.close);

  final String open;
  final String close;
}

/// Editing operations on expression source.
///
/// The source is plain text, but several of its characters are not drawn —
/// the brackets around an exponent, the comma inside a fraction — so editing
/// it one character at a time would let the user delete things they cannot
/// see. These operations work on the parsed structure instead and always
/// leave the caret on a valid stop.
abstract final class ExpressionEditor {
  static EditState insert(String text, int cursor, String value) {
    if (value == ')') return _close(text, cursor, literalFallback: true);
    return _spliced(text, cursor, cursor, value, cursor + value.length);
  }

  static EditState insertTemplate(
    String text,
    int cursor,
    MathTemplate template,
  ) {
    if (template == MathTemplate.fraction) {
      // "3, fraction key" reads as "3 over …": take the operand just typed
      // as the numerator and go straight to the denominator.
      final start = _operandStartBefore(MathDocument.parse(text), cursor);
      if (start != null) {
        final numerator = text.substring(start, cursor);
        final open = '${template.open}$numerator,';
        return _spliced(text, start, cursor, '$open)', start + open.length);
      }
    }
    return _spliced(
      text,
      cursor,
      cursor,
      template.open + template.close,
      cursor + template.open.length,
    );
  }

  static EditState backspace(String text, int cursor) {
    if (cursor <= 0 || text.isEmpty) return EditState(text, cursor);
    final doc = MathDocument.parse(text);
    final row = doc.ownerOf(cursor);
    if (row == null) return _snapped(text, cursor);

    final container = doc.containerOf(row);
    if (cursor == row.start && container != null) {
      return _backspaceAtSlotStart(text, row, container);
    }

    MathNode? before;
    for (final child in row.children) {
      if (child.end == cursor) before = child;
    }

    if (before != null && before.slots.isNotEmpty && before.closed) {
      if (before is GroupNode) {
        // Visible parentheses delete like any other character.
        return _spliced(text, cursor - 1, cursor, '', cursor - 1);
      }
      if (before.slots.every((slot) => slot.isEmpty)) {
        return _spliced(text, before.start, before.end, '', before.start);
      }
      // The closing delimiter is not drawn, so there is nothing to delete
      // yet: step inside, where the next press removes what is visible.
      return EditState(text, before.slots.last.end);
    }
    if (before is TextNode) {
      return _spliced(text, before.start, before.end, '', before.start);
    }
    return _spliced(text, cursor - 1, cursor, '', cursor - 1);
  }

  static EditState moveLeft(String text, int cursor) {
    final stops = MathDocument.parse(text).stops;
    for (final stop in stops.reversed) {
      if (stop < cursor) return EditState(text, stop);
    }
    return EditState(text, stops.first);
  }

  /// Moves to the next stop. At the very end there is none, so this instead
  /// leaves whatever the caret is still inside — an unclosed bracket, an
  /// exponent — which is how the caret gets back down to the baseline.
  static EditState moveRight(String text, int cursor) {
    final stops = MathDocument.parse(text).stops;
    for (final stop in stops) {
      if (stop > cursor) return EditState(text, stop);
    }
    return _close(text, cursor, literalFallback: false);
  }

  /// [source] in a form that can be dropped into the middle of another
  /// expression without changing what it means: `1+2` becomes `(1+2)`, so
  /// that pasting it after `3×` still multiplies the whole of it. A lone
  /// number or a single closed structure needs no brackets.
  static String asOperand(String source) {
    final children = MathDocument.parse(source).root.children;
    if (children.length == 1) {
      final only = children.single;
      final isAtomic = switch (only) {
        NumberNode() || ConstantNode() => true,
        SymbolNode() || TextNode() || PowerNode() || RowNode() => false,
        _ => only.closed,
      };
      if (isAtomic) return source;
    }
    return '($source)';
  }

  /// The valid caret index nearest to [cursor] in [text].
  static int snap(String text, int cursor) =>
      MathDocument.parse(text).snap(cursor.clamp(0, text.length));

  // ---------------------------------------------------------------- Closing

  /// Handles `)`. In a structure it means "I am done with this part", not
  /// "insert a bracket": it closes what is open, or steps over a delimiter
  /// that is already there. [literalFallback] says whether to insert a plain
  /// `)` when there is nothing to leave.
  static EditState _close(
    String text,
    int cursor, {
    required bool literalFallback,
  }) {
    final doc = MathDocument.parse(text);
    var row = doc.ownerOf(doc.snap(cursor))!;
    var container = doc.containerOf(row);

    // An ungrouped exponent or radicand has no delimiters of its own; look
    // through it to whatever encloses it.
    RowNode? bare;
    while (container != null && _isBare(container)) {
      bare ??= row;
      row = doc.rowOf(container);
      container = doc.containerOf(row);
    }

    if (container == null) {
      if (bare != null && !bare.isEmpty && cursor == bare.end) {
        // 2^5 → 2^(5), caret after it: the exponent is now delimited and the
        // caret is outside, back on the line the base sits on.
        final wrapped = '(${text.substring(bare.start, bare.end)})';
        return _spliced(
            text, bare.start, bare.end, wrapped, bare.end + 2);
      }
      return literalFallback
          ? _spliced(text, cursor, cursor, ')', cursor + 1)
          : EditState(text, cursor);
    }

    if (!container.closed) {
      return _spliced(text, cursor, cursor, ')', cursor + 1);
    }
    if (container is GroupNode && cursor != row.end) {
      return literalFallback
          ? _spliced(text, cursor, cursor, ')', cursor + 1)
          : EditState(text, cursor);
    }
    // Step over the delimiter that ends this slot: into the next slot of a
    // fraction or logarithm, otherwise out of the structure.
    return _snapped(text, row.end + 1);
  }

  static bool _isBare(MathNode node) =>
      (node is PowerNode && !node.grouped) ||
      (node is RadicalNode && !node.grouped);

  // ------------------------------------------------------------- Backspace

  static EditState _backspaceAtSlotStart(
    String text,
    RowNode row,
    MathNode container,
  ) {
    // An operator or bracket that is drawn: delete just that character.
    if (_isBare(container) || container is GroupNode) {
      return _spliced(
          text, container.start, container.start + 1, '', container.start);
    }

    final slots = container.slots;
    if (!identical(row, slots.first)) {
      // Start of a later slot: back into the one before it.
      return EditState(text, slots[slots.indexOf(row) - 1].end);
    }
    if (slots.every((slot) => slot.isEmpty)) {
      return _spliced(text, container.start, container.end, '', container.start);
    }

    // Remove the structure but keep what was typed into it.
    final contents = [
      for (final slot in slots)
        if (!slot.isEmpty) text.substring(slot.start, slot.end),
    ];
    final joiner = container is FractionNode ? '÷' : '';
    return _spliced(
      text,
      container.start,
      container.end,
      contents.join(joiner),
      container.start,
    );
  }

  // ----------------------------------------------------------------- Shared

  /// Start of the operand that ends at [cursor], including any powers on it,
  /// or null if the caret does not directly follow a complete operand.
  static int? _operandStartBefore(MathDocument doc, int cursor) {
    final row = doc.ownerOf(cursor);
    if (row == null) return null;
    var index = row.children.indexWhere((child) => child.end == cursor);
    if (index < 0) return null;

    while (index > 0 && row.children[index] is PowerNode) {
      index--;
    }
    final base = row.children[index];
    final isOperand = switch (base) {
      NumberNode() || ConstantNode() => true,
      SymbolNode() || TextNode() || PowerNode() || RowNode() => false,
      FunctionNode(name: 'mod') => false,
      _ => base.closed,
    };
    return isOperand ? base.start : null;
  }

  static EditState _spliced(
    String text,
    int start,
    int end,
    String replacement,
    int cursor,
  ) {
    final next = text.substring(0, start) + replacement + text.substring(end);
    return _snapped(next, cursor);
  }

  static EditState _snapped(String text, int cursor) =>
      EditState(text, snap(text, cursor));
}
