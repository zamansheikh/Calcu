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
}
