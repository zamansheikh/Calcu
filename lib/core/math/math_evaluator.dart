import 'math_document.dart';
import 'math_node.dart';
import 'real.dart';

/// Computes the value of a parsed expression.
///
/// Works on the tree directly, so every operator applies to whole operands
/// whatever they are: `%` after a bracket or a root, `mod` after a fraction
/// or a power. Throws [MathError] when there is no answer.
abstract final class MathEvaluator {
  static Real evaluate(MathDocument document) => _row(document.root);

  static Real _row(RowNode row) {
    final reader = _RowReader(row.children);
    final value = reader.sum();
    // Anything left over is something the grammar has no place for.
    if (!reader.atEnd) throw const MathError(MathErrorKind.syntax);
    return value;
  }
}

/// Reads one row with the usual precedence, lowest first:
///
///     sum      term (+|− term)*
///     term     sign* factor ((×|÷) sign* factor | mod(…) | factor)*
///     factor   operand (power | %)*
///
/// A factor directly after another, with no operator between, is multiplied:
/// `2π`, `3(4)`, `20%200`.
class _RowReader {
  _RowReader(this._nodes);

  final List<MathNode> _nodes;
  int _index = 0;

  bool get atEnd => _index >= _nodes.length;
  MathNode? get _peek => atEnd ? null : _nodes[_index];

  bool _peekIs(String chars) {
    final node = _peek;
    return node is SymbolNode && chars.contains(node.char);
  }

  Real sum() {
    var total = term();
    while (_peekIs('+-')) {
      final subtract = (_nodes[_index++] as SymbolNode).char == '-';
      final next = term();
      total = subtract ? total - next : total + next;
    }
    return total;
  }

  Real term() {
    // A leading sign covers the whole term, so that −2² is −4 and −7 mod 3
    // is −(7 mod 3).
    final negative = _signs();
    var product = factor();

    while (true) {
      final node = _peek;
      if (node == null) break;
      if (node is SymbolNode) {
        if ('×*'.contains(node.char)) {
          _index++;
          product = product * _signedFactor();
        } else if ('÷/'.contains(node.char)) {
          _index++;
          product = product / _signedFactor();
        } else {
          break;
        }
      } else if (node is FunctionNode && node.name == 'mod') {
        _index++;
        product = product.mod(MathEvaluator._row(node.argument));
      } else {
        product = product * factor();
      }
    }
    return negative ? -product : product;
  }

  /// Consumes any run of signs and reports whether they amount to a minus.
  bool _signs() {
    var negative = false;
    while (_peekIs('+-')) {
      if ((_nodes[_index++] as SymbolNode).char == '-') negative = !negative;
    }
    return negative;
  }

  Real _signedFactor() {
    final negative = _signs();
    final value = factor();
    return negative ? -value : value;
  }

  Real factor() {
    var value = _operand();
    while (true) {
      final node = _peek;
      if (node is PowerNode) {
        _index++;
        value = value.pow(MathEvaluator._row(node.exponent));
      } else if (_peekIs('%')) {
        _index++;
        value = value / Real(100);
      } else {
        return value;
      }
    }
  }

  Real _operand() {
    final node = _peek;
    if (node == null) throw const MathError(MathErrorKind.syntax);
    _index++;
    return switch (node) {
      NumberNode() => Real.parse(node.text),
      ConstantNode() => node.name == 'π' ? Real.pi : Real.e,
      GroupNode() => MathEvaluator._row(node.body),
      RadicalNode() => MathEvaluator._row(node.radicand).sqrt(),
      AbsNode() => MathEvaluator._row(node.body).abs,
      FractionNode() => MathEvaluator._row(node.numerator) /
          MathEvaluator._row(node.denominator),
      LogNode() => MathEvaluator._row(node.argument)
          .log(MathEvaluator._row(node.base)),
      FunctionNode(name: 'ln') => MathEvaluator._row(node.argument).ln(),
      // A bare log is the common logarithm.
      FunctionNode(name: 'log') =>
        MathEvaluator._row(node.argument).log(Real(10)),
      // An operator where a value belongs, a power with nothing to raise,
      // `mod` with nothing before it, or a name that means nothing.
      SymbolNode() ||
      PowerNode() ||
      FunctionNode() ||
      TextNode() ||
      RowNode() =>
        throw const MathError(MathErrorKind.syntax),
    };
  }
}
