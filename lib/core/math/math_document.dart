import 'math_node.dart';
import 'math_parser.dart';

/// A parsed expression plus the lookups the editor, display and engine need.
class MathDocument {
  MathDocument._(this.source, this.root);

  factory MathDocument.parse(String source) {
    final document = MathDocument._(source, MathParser.parse(source));
    document._index(document.root);
    document.stops = document._owner.keys.toList()..sort();
    return document;
  }

  final String source;
  final RowNode root;

  /// Every source index the caret may rest on, ascending.
  ///
  /// Not every index is one: the caret cannot sit inside a function name or
  /// between a `^` and the parenthesis that delimits its exponent.
  late final List<int> stops;

  final Map<int, RowNode> _owner = {};
  final Map<RowNode, MathNode> _container = Map.identity();
  final Map<MathNode, RowNode> _row = Map.identity();

  /// The row the caret is in when it rests on [stop], or null if [stop] is
  /// not a caret stop.
  RowNode? ownerOf(int stop) => _owner[stop];

  /// The node [row] is a slot of, or null for the root row.
  MathNode? containerOf(RowNode row) => _container[row];

  /// The row [node] is a child of.
  RowNode rowOf(MathNode node) => _row[node]!;

  /// The nearest caret stop at or after [index].
  int snap(int index) {
    for (final stop in stops) {
      if (stop >= index) return stop;
    }
    return stops.last;
  }

  // Where two rows share an index with no character between them — the end of
  // `2^5` is both "after the 5" and "after the power" — the inner row has to
  // win, so that typing there extends the exponent. Indexing a node's own end
  // before descending into its slots gives exactly that.
  void _index(RowNode row) {
    _owner[row.start] = row;
    for (final child in row.children) {
      _row[child] = row;
      if (child is NumberNode) {
        for (var i = child.start + 1; i <= child.end; i++) {
          _owner[i] = row;
        }
        continue;
      }
      _owner[child.end] = row;
      for (final slot in child.slots) {
        _container[slot] = child;
        _index(slot);
      }
    }
  }

  // ------------------------------------------------------------ Evaluation

  /// Whether the expression is finished enough to be worth evaluating.
  /// Half-typed input (`2+`, an empty denominator, an unclosed bracket) is
  /// not, and the live preview stays blank for it.
  bool get isComplete => _isComplete(root);

  bool _isComplete(RowNode row) {
    if (row.isEmpty) return false;

    final last = row.children.last;
    if (last is SymbolNode && last.isOperator) return false;
    if (last is NumberNode && last.text.endsWith('.')) return false;

    for (final child in row.children) {
      if (child is SymbolNode && (child.char == ')' || child.char == ',')) {
        return false;
      }
      if (!child.closed) return false;
      if (!child.slots.every(_isComplete)) return false;
    }
    return true;
  }

  /// The expression rewritten for the evaluator: structures become plain
  /// function calls and brackets, and multiplication that the notation
  /// leaves implicit (`2π`, `3(4)`, `2√9`) is written out.
  String toEngineSource() => _emitRow(root);

  String _emitRow(RowNode row) {
    final parts = <String>[];
    // Index in `parts` where the operand a following power applies to starts.
    var operand = 0;
    MathNode? previous;

    for (final node in row.children) {
      if (node is PowerNode) {
        // A second power on the same base raises the whole of what is drawn
        // to its left, so 2^(3)^(2) is (2³)², not the tower 2^(3²).
        if (previous is PowerNode && operand < parts.length) {
          parts[operand] = '(${parts[operand]}';
          parts.add(')');
        }
        parts.add('^(${_emitRow(node.exponent)})');
      } else {
        if (previous != null && _endsOperand(previous) && _startsOperand(node)) {
          parts.add('×');
        }
        operand = parts.length;
        parts.add(_emit(node));
      }
      previous = node;
    }
    return parts.join();
  }

  String _emit(MathNode node) {
    return switch (node) {
      NumberNode() => node.text,
      SymbolNode() => node.char,
      TextNode() => node.text,
      ConstantNode() =>
        node.name == 'π' ? '(3.141592653589793)' : '(2.718281828459045)',
      GroupNode() => '(${_emitRow(node.body)})',
      PowerNode() => '^(${_emitRow(node.exponent)})',
      RadicalNode() => 'sqrt(${_emitRow(node.radicand)})',
      AbsNode() => 'abs(${_emitRow(node.body)})',
      FractionNode() =>
        '((${_emitRow(node.numerator)})÷(${_emitRow(node.denominator)}))',
      LogNode() =>
        'log(${_emitRow(node.base)},${_emitRow(node.argument)})',
      // A bare log is the common logarithm.
      FunctionNode(name: 'log') => 'log(10,${_emitRow(node.argument)})',
      FunctionNode() => '${node.name}(${_emitRow(node.argument)})',
      RowNode() => _emitRow(node),
    };
  }

  static bool _endsOperand(MathNode node) {
    if (node is SymbolNode) return node.char == '%';
    return true;
  }

  static bool _startsOperand(MathNode node) {
    if (node is SymbolNode || node is PowerNode) return false;
    // `mod` is written between its operands: 8mod(3).
    if (node is FunctionNode && node.name == 'mod') return false;
    return true;
  }
}
