/// Syntax tree for the calculator's linear expression source.
///
/// The source stays a plain string (`2^(1+2)`, `frac(1,2)`, `√(16)`), which
/// is what gets stored, edited and evaluated. Parsing it into this tree is
/// what lets the display typeset it in two dimensions. Every node records the
/// `[start, end)` range of source it came from, so a caret index can be
/// mapped to a position in the layout and back.
sealed class MathNode {
  const MathNode(this.start, this.end);

  final int start;
  final int end;

  /// Editable sub-expressions of this node, in source order.
  List<RowNode> get slots => const [];

  /// False while a delimited node is still missing its closing `)`.
  bool get closed => true;
}

/// A horizontal run of nodes: the whole expression, or one slot of a
/// structure (an exponent, a numerator, the inside of a pair of parentheses).
final class RowNode extends MathNode {
  const RowNode(super.start, super.end, this.children);

  final List<MathNode> children;

  bool get isEmpty => children.isEmpty;
}

/// A run of digits and decimal points.
final class NumberNode extends MathNode {
  const NumberNode(super.start, super.end, this.text);

  final String text;
}

/// A single character with no structure: an operator, `%`, or anything the
/// parser has no better reading for (a stray `)` for instance).
final class SymbolNode extends MathNode {
  const SymbolNode(super.start, super.end, this.char);

  final String char;

  bool get isOperator => '+-×÷*/'.contains(char);
}

/// `π` or `e`.
final class ConstantNode extends MathNode {
  const ConstantNode(super.start, super.end, this.name);

  final String name;
}

/// Letters that are not a known function or constant. Kept as one unit.
final class TextNode extends MathNode {
  const TextNode(super.start, super.end, this.text);

  final String text;
}

/// Ordinary, visible parentheses.
final class GroupNode extends MathNode {
  const GroupNode(super.start, super.end, this.body, {required this.closed});

  final RowNode body;

  @override
  final bool closed;

  @override
  List<RowNode> get slots => [body];
}

/// `^` and its exponent, drawn as a superscript on whatever precedes it.
///
/// A [grouped] exponent was written as `^(…)`; the parentheses delimit it in
/// the source but are not drawn, because raising it already shows the
/// grouping. An ungrouped one is the single operand after the `^`.
final class PowerNode extends MathNode {
  const PowerNode(
    super.start,
    super.end,
    this.exponent, {
    required this.grouped,
    required this.closed,
  });

  final RowNode exponent;
  final bool grouped;

  @override
  final bool closed;

  @override
  List<RowNode> get slots => [exponent];
}

/// `√` and its radicand, drawn under a bar. [grouped] as for [PowerNode].
final class RadicalNode extends MathNode {
  const RadicalNode(
    super.start,
    super.end,
    this.radicand, {
    required this.grouped,
    required this.closed,
  });

  final RowNode radicand;
  final bool grouped;

  @override
  final bool closed;

  @override
  List<RowNode> get slots => [radicand];
}

/// `abs(…)`, drawn between vertical bars.
final class AbsNode extends MathNode {
  const AbsNode(super.start, super.end, this.body, {required this.closed});

  final RowNode body;

  @override
  final bool closed;

  @override
  List<RowNode> get slots => [body];
}

/// `frac(numerator,denominator)`, drawn stacked.
final class FractionNode extends MathNode {
  const FractionNode(
    super.start,
    super.end,
    this.numerator,
    this.denominator, {
    required this.closed,
  });

  final RowNode numerator;
  final RowNode denominator;

  @override
  final bool closed;

  @override
  List<RowNode> get slots => [numerator, denominator];
}

/// `log(base,argument)`, drawn with the base as a subscript.
final class LogNode extends MathNode {
  const LogNode(
    super.start,
    super.end,
    this.base,
    this.argument, {
    required this.closed,
  });

  final RowNode base;
  final RowNode argument;

  @override
  final bool closed;

  @override
  List<RowNode> get slots => [base, argument];
}

/// A named function with one argument in visible parentheses: `ln(…)`,
/// `mod(…)`, or a single-argument `log(…)`.
final class FunctionNode extends MathNode {
  const FunctionNode(
    super.start,
    super.end,
    this.name,
    this.argument, {
    required this.closed,
  });

  final String name;
  final RowNode argument;

  @override
  final bool closed;

  @override
  List<RowNode> get slots => [argument];
}
