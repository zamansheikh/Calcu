import 'math_node.dart';

/// Parses expression source into a [RowNode] tree.
///
/// The parser never fails: this runs on every keystroke, so half-typed input
/// (`2^`, `(3+`, `frac(1,`) has to produce a tree that can still be drawn.
/// Anything without a better reading becomes a [SymbolNode].
class MathParser {
  MathParser._(this._source);

  static RowNode parse(String source) =>
      MathParser._(source)._row(closeOnParen: false);

  /// Names that take a parenthesised argument. Other letter runs are text.
  static const _functions = {'abs', 'frac', 'log', 'ln', 'mod'};

  final String _source;
  int _pos = 0;

  bool get _atEnd => _pos >= _source.length;
  String get _char => _source[_pos];

  bool _eat(String char) {
    if (_atEnd || _char != char) return false;
    _pos++;
    return true;
  }

  RowNode _row({required bool closeOnParen, bool closeOnComma = false}) {
    final start = _pos;
    final children = <MathNode>[];
    while (!_atEnd) {
      if (closeOnParen && _char == ')') break;
      if (closeOnComma && _char == ',') break;
      children.add(_item());
    }
    return RowNode(start, _pos, children);
  }

  MathNode _item() {
    final start = _pos;
    final char = _char;

    if (_isNumeric(char)) {
      while (!_atEnd && _isNumeric(_char)) {
        _pos++;
      }
      return NumberNode(start, _pos, _source.substring(start, _pos));
    }

    switch (char) {
      case '(':
        _pos++;
        final body = _row(closeOnParen: true);
        final closed = _eat(')');
        return GroupNode(start, _pos, body, closed: closed);
      case '^':
        _pos++;
        final operand = _operand();
        return PowerNode(
          start,
          _pos,
          operand.row,
          grouped: operand.grouped,
          closed: operand.closed,
        );
      case '√':
        _pos++;
        final operand = _operand();
        return RadicalNode(
          start,
          _pos,
          operand.row,
          grouped: operand.grouped,
          closed: operand.closed,
        );
      case 'π':
        _pos++;
        return ConstantNode(start, _pos, 'π');
    }

    if (_isLetter(char)) return _word();

    _pos++;
    return SymbolNode(start, _pos, char);
  }

  /// What `^` or `√` applies to: a parenthesised group, or failing that the
  /// single operand that follows, so `2^5+3` raises only the 5.
  ({RowNode row, bool grouped, bool closed}) _operand() {
    if (_eat('(')) {
      final row = _row(closeOnParen: true);
      return (row: row, grouped: true, closed: _eat(')'));
    }

    final start = _pos;
    final children = <MathNode>[];
    // A sign belongs to the operand: 10^-2.
    while (!_atEnd && (_char == '-' || _char == '+')) {
      children.add(SymbolNode(_pos, _pos + 1, _char));
      _pos++;
    }
    if (!_atEnd && _startsOperand(_char)) {
      children.add(_item());
      // Towers associate to the right: 2^3^2 is 2^(3^2).
      while (!_atEnd && _char == '^') {
        children.add(_item());
      }
    }
    return (row: RowNode(start, _pos, children), grouped: false, closed: true);
  }

  MathNode _word() {
    final start = _pos;
    while (!_atEnd && _isLetter(_char)) {
      _pos++;
    }
    final name = _source.substring(start, _pos);

    if (!_functions.contains(name) || _atEnd || _char != '(') {
      // A leading `e` is Euler's number; whatever follows it is read on its
      // own, so `e(2+1)` and `eln(2)` both work.
      if (name.startsWith('e')) {
        _pos = start + 1;
        return ConstantNode(start, _pos, 'e');
      }
      return TextNode(start, _pos, name);
    }

    _pos++; // the opening parenthesis
    switch (name) {
      case 'abs':
        final body = _row(closeOnParen: true);
        final closed = _eat(')');
        return AbsNode(start, _pos, body, closed: closed);
      case 'frac':
        final numerator = _row(closeOnParen: true, closeOnComma: true);
        _eat(',');
        final denominator = _row(closeOnParen: true);
        final closed = _eat(')');
        return FractionNode(start, _pos, numerator, denominator,
            closed: closed);
      case 'log':
        final first = _row(closeOnParen: true, closeOnComma: true);
        if (_eat(',')) {
          final argument = _row(closeOnParen: true);
          final closed = _eat(')');
          return LogNode(start, _pos, first, argument, closed: closed);
        }
        final closed = _eat(')');
        return FunctionNode(start, _pos, name, first, closed: closed);
      default:
        final argument = _row(closeOnParen: true);
        final closed = _eat(')');
        return FunctionNode(start, _pos, name, argument, closed: closed);
    }
  }

  static bool _isNumeric(String c) {
    final code = c.codeUnitAt(0);
    return (code >= 0x30 && code <= 0x39) || c == '.';
  }

  static bool _isLetter(String c) {
    final code = c.codeUnitAt(0);
    return (code >= 0x41 && code <= 0x5A) || (code >= 0x61 && code <= 0x7A);
  }

  static bool _startsOperand(String c) =>
      _isNumeric(c) || _isLetter(c) || c == '(' || c == '√' || c == 'π';
}
