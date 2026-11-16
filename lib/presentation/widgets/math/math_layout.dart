import 'dart:math' as math;

import 'package:flutter/painting.dart';

import '../../../core/math/math_document.dart';
import '../../../core/math/math_node.dart';
import '../../../core/utils/number_formatter.dart';

/// Visual parameters for a [MathLayout].
class MathStyle {
  const MathStyle({
    required this.fontSize,
    required this.color,
    required this.placeholderColor,
    this.fontFamily = 'Urbanist',
    this.fontWeight = FontWeight.w600,
    this.placeholderStroke = 0.035,
  });

  /// Size of text on the main line. Scripts and fractions derive from it.
  final double fontSize;
  final Color color;

  /// Colour of the box drawn in a slot that has nothing in it yet.
  final Color placeholderColor;
  final String fontFamily;
  final FontWeight fontWeight;

  /// Line weight of that box, as a fraction of the font size it is drawn at.
  final double placeholderStroke;

  MathStyle copyWith({double? fontSize, Color? color}) => MathStyle(
        fontSize: fontSize ?? this.fontSize,
        color: color ?? this.color,
        placeholderColor: placeholderColor,
        fontFamily: fontFamily,
        fontWeight: fontWeight,
        placeholderStroke: placeholderStroke,
      );
}

/// Where to draw the caret for one caret stop.
class CaretMetrics {
  const CaretMetrics({required this.x, required this.top, required this.bottom});

  final double x;
  final double top;
  final double bottom;

  double get height => bottom - top;
}

/// A typeset expression: exponents raised, fractions stacked, radicands
/// under a bar.
///
/// One layout serves three jobs — painting, placing the caret, and turning a
/// tap into a caret index — so the three cannot disagree about where
/// anything is. Call [dispose] when it is no longer shown.
class MathLayout {
  MathLayout(this.document, this.style) {
    final fontSize = style.fontSize;
    final root = _row(document.root, fontSize);
    // Never shorter than a plain line of text, so the caret fits and simple
    // expressions sit where ordinary text would.
    final ascent = math.max(root.ascent + 0.06 * fontSize, 0.90 * fontSize);
    final descent = math.max(root.descent + 0.06 * fontSize, 0.20 * fontSize);
    size = Size(root.width, ascent + descent);
    baseline = ascent;
    root.place(0, ascent, this);
    _root = root;
  }

  final MathDocument document;
  final MathStyle style;

  late final Size size;

  /// Distance from the top of [size] to the main line's baseline.
  late final double baseline;

  late final _Box _root;
  final Map<int, CaretMetrics> _carets = {};
  final List<TextPainter> _painters = [];

  // Font metrics of the display face, as fractions of the font size.
  static const _digitAscent = 0.72;
  static const _digitDescent = 0.02;
  static const _descender = 0.20;
  static const _parenAscent = 0.75;
  static const _parenDescent = 0.19;
  // Height above the baseline of the centre of `+`, `−` and `=`. Fraction
  // bars sit here so they line up with the operators around them.
  static const _axis = 0.34;

  static const _scriptScale = 0.62;
  static const _fractionScale = 0.82;

  /// Nested scripts stop shrinking here, as a fraction of [MathStyle.fontSize].
  static const _minScale = 0.42;

  void paint(Canvas canvas, Offset offset) {
    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    _root.paint(canvas);
    canvas.restore();
  }

  /// Caret geometry for [stop], which must be a caret stop of [document].
  CaretMetrics caretAt(int stop) {
    return _carets[stop] ??
        _carets[document.snap(stop)] ??
        CaretMetrics(x: size.width, top: 0, bottom: size.height);
  }

  /// The caret stop nearest to [position].
  int stopAt(Offset position) {
    var best = document.stops.last;
    var bestDistance = double.infinity;
    for (final entry in _carets.entries) {
      final caret = entry.value;
      final dx = (position.dx - caret.x).abs();
      final dy = position.dy < caret.top
          ? caret.top - position.dy
          : position.dy > caret.bottom
              ? position.dy - caret.bottom
              : 0.0;
      final distance = dx * dx + dy * dy;
      if (distance < bestDistance) {
        bestDistance = distance;
        best = entry.key;
      }
    }
    return best;
  }

  void dispose() {
    for (final painter in _painters) {
      painter.dispose();
    }
    _painters.clear();
  }

  // ---------------------------------------------------------------- Building

  double get _minFontSize => style.fontSize * _minScale;

  _RowBox _row(RowNode node, double fontSize) {
    final row = _RowBox(node, fontSize);

    if (node.isEmpty) {
      if (identical(node, document.root)) {
        row.stops.add((node.start, 0));
        return row;
      }
      final placeholder = _placeholder(fontSize);
      row.add(placeholder, 0);
      row.stops.add((node.start, placeholder.width / 2));
      row.width = placeholder.width;
      return row;
    }

    var x = 0.0;
    row.stops.add((node.start, 0));
    _Box? previousBox;
    MathNode? previousNode;

    for (final child in node.children) {
      if (child is PowerNode && previousBox == null) {
        // A power with nothing to raise: show where the base goes.
        final base = _placeholder(fontSize);
        row.add(base, x);
        x += base.width;
        previousBox = base;
      }

      final box = _node(child, fontSize, previousBox, previousNode);
      row.add(box, x);
      if (child is NumberNode && box is _TextBox) {
        final formatted = box.text;
        for (var i = 1; i <= child.text.length; i++) {
          final offset = _formattedOffset(formatted, i);
          row.stops.add((child.start + i, x + box.caretX(offset)));
        }
      } else {
        row.stops.add((child.end, x + box.width));
      }
      x += box.width;
      previousBox = box;
      previousNode = child;
    }

    row.width = x;
    return row;
  }

  _Box _node(
    MathNode node,
    double fontSize,
    _Box? previousBox,
    MathNode? previousNode,
  ) {
    switch (node) {
      case NumberNode():
        return _text(
          NumberFormatter.addThousandsSeparators(node.text),
          fontSize,
        );

      case SymbolNode():
        if (!node.isOperator) return _text(node.char, fontSize);
        // Binary operators get breathing room; a sign hugs its operand.
        final isBinary = previousNode != null &&
            !(previousNode is SymbolNode && previousNode.isOperator);
        final pad = (isBinary ? 0.17 : 0.03) * fontSize;
        return _text(
          _operatorGlyph(node.char),
          fontSize,
          padLeft: pad,
          padRight: pad,
        );

      case ConstantNode():
        return _text(node.name, fontSize, padLeft: 0.02 * fontSize);

      case TextNode():
        return _text(node.text, fontSize, descent: _descender);

      case GroupNode():
        return _group(node.body, fontSize, closed: node.closed);

      case PowerNode():
        final exponent = _row(node.exponent, _scriptSize(fontSize));
        // Raise further for a tall base, so the exponent sits at its
        // top-right corner rather than halfway up it.
        final baseAscent = previousBox?.ascent ?? 0;
        final shift = 0.40 * fontSize +
            math.max(0, baseAscent - _parenAscent * fontSize);
        return _ScriptBox(exponent, shift: shift, kern: 0.03 * fontSize);

      case RadicalNode():
        return _RadicalBox(_row(node.radicand, fontSize), fontSize, style.color);

      case AbsNode():
        return _AbsBox(_row(node.body, fontSize), fontSize, style.color);

      case FractionNode():
        final partSize = math.max(fontSize * _fractionScale, _minFontSize);
        return _FractionBox(
          _row(node.numerator, partSize),
          _row(node.denominator, partSize),
          fontSize,
          style.color,
        );

      case LogNode():
        final base = _row(node.base, _scriptSize(fontSize));
        return _HBox([
          _text('log', fontSize, descent: _descender),
          _ScriptBox(base, shift: -0.22 * fontSize, kern: 0.02 * fontSize),
          _group(node.argument, fontSize, closed: node.closed),
        ]);

      case FunctionNode():
        // `mod` is an operator written between its operands.
        final pad = (node.name == 'mod' ? 0.16 : 0.0) * fontSize;
        return _HBox([
          _text(
            node.name,
            fontSize,
            padLeft: pad,
            padRight: pad,
            descent: _hasDescender(node.name) ? _descender : _digitDescent,
          ),
          _group(node.argument, fontSize, closed: node.closed),
        ]);

      case RowNode():
        return _row(node, fontSize);
    }
  }

  _PlaceholderBox _placeholder(double fontSize) => _PlaceholderBox(
        fontSize,
        style.placeholderColor,
        math.max(1.0, style.placeholderStroke * fontSize),
      );

  double _scriptSize(double fontSize) =>
      math.max(fontSize * _scriptScale, _minFontSize);

  _TextBox _text(
    String text,
    double fontSize, {
    double padLeft = 0,
    double padRight = 0,
    double ascent = _digitAscent,
    double descent = _digitDescent,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontFamily: style.fontFamily,
          fontWeight: style.fontWeight,
          fontSize: fontSize,
          height: 1,
          color: style.color,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    _painters.add(painter);
    return _TextBox(
      text,
      painter,
      padLeft: padLeft,
      padRight: padRight,
      ascent: ascent * fontSize,
      descent: descent * fontSize,
    );
  }

  _GroupBox _group(RowNode body, double fontSize, {required bool closed}) {
    return _GroupBox(
      _row(body, fontSize),
      open: _text('(', fontSize, ascent: _parenAscent, descent: _parenDescent),
      close: closed
          ? _text(')', fontSize, ascent: _parenAscent, descent: _parenDescent)
          : null,
      fontSize: fontSize,
    );
  }

  static String _operatorGlyph(String char) => switch (char) {
        '-' => '−',
        '*' => '×',
        '/' => '÷',
        _ => char,
      };

  static bool _hasDescender(String text) =>
      text.contains(RegExp('[gjpqy]'));

  /// Index in [formatted] (which has thousands separators) of the caret that
  /// sits after [rawOffset] characters of the unformatted number.
  static int _formattedOffset(String formatted, int rawOffset) {
    var raw = 0;
    for (var i = 0; i < formatted.length; i++) {
      if (raw == rawOffset) return i;
      if (formatted[i] != ',') raw++;
    }
    return formatted.length;
  }
}

// -------------------------------------------------------------------- Boxes

/// A laid-out piece of the expression. [ascent] and [descent] are measured
/// from the baseline; ([x], [y]) is the left end of that baseline once the
/// box has been placed.
abstract class _Box {
  double width = 0;
  double ascent = 0;
  double descent = 0;
  double x = 0;
  double y = 0;

  void place(double x, double y, MathLayout layout) {
    this.x = x;
    this.y = y;
  }

  void paint(Canvas canvas);
}

class _TextBox extends _Box {
  _TextBox(
    this.text,
    this.painter, {
    required double ascent,
    required double descent,
    this.padLeft = 0,
    double padRight = 0,
  }) : _baseline =
            painter.computeDistanceToActualBaseline(TextBaseline.alphabetic) {
    width = padLeft + painter.width + padRight;
    this.ascent = ascent;
    this.descent = descent;
  }

  final String text;
  final TextPainter painter;
  final double padLeft;
  final double _baseline;

  /// Distance from the painter's top edge to its alphabetic baseline.
  double get baseline => _baseline;

  double caretX(int offset) =>
      padLeft +
      painter.getOffsetForCaret(TextPosition(offset: offset), Rect.zero).dx;

  @override
  void paint(Canvas canvas) {
    painter.paint(canvas, Offset(x + padLeft, y - _baseline));
  }
}

/// A slot's contents, sharing one baseline. Records where the caret goes
/// between them.
class _RowBox extends _Box {
  _RowBox(this.node, this.fontSize);

  final RowNode node;
  final double fontSize;
  final List<_Box> children = [];
  final List<double> offsets = [];

  /// (caret stop, x within this row).
  final List<(int, double)> stops = [];

  void add(_Box child, double dx) {
    children.add(child);
    offsets.add(dx);
    ascent = math.max(ascent, child.ascent);
    descent = math.max(descent, child.descent);
  }

  @override
  void place(double x, double y, MathLayout layout) {
    super.place(x, y, layout);
    for (var i = 0; i < children.length; i++) {
      children[i].place(x + offsets[i], y, layout);
    }
    for (final (stop, dx) in stops) {
      // An index shared with an inner row belongs to the inner row.
      if (!identical(layout.document.ownerOf(stop), node)) continue;
      layout._carets[stop] = CaretMetrics(
        x: x + dx,
        top: y - 0.79 * fontSize,
        bottom: y + 0.09 * fontSize,
      );
    }
  }

  @override
  void paint(Canvas canvas) {
    for (final child in children) {
      child.paint(canvas);
    }
  }
}

/// Boxes side by side on one baseline, with no caret stops between them.
class _HBox extends _Box {
  _HBox(this.children) {
    for (final child in children) {
      width += child.width;
      ascent = math.max(ascent, child.ascent);
      descent = math.max(descent, child.descent);
    }
  }

  final List<_Box> children;

  @override
  void place(double x, double y, MathLayout layout) {
    super.place(x, y, layout);
    var dx = 0.0;
    for (final child in children) {
      child.place(x + dx, y, layout);
      dx += child.width;
    }
  }

  @override
  void paint(Canvas canvas) {
    for (final child in children) {
      child.paint(canvas);
    }
  }
}

/// A superscript (positive [shift]) or subscript (negative).
class _ScriptBox extends _Box {
  _ScriptBox(this.inner, {required this.shift, required this.kern}) {
    width = kern + inner.width + kern;
    ascent = math.max(0, inner.ascent + shift);
    descent = math.max(0, inner.descent - shift);
  }

  final _RowBox inner;
  final double shift;
  final double kern;

  @override
  void place(double x, double y, MathLayout layout) {
    super.place(x, y, layout);
    inner.place(x + kern, y - shift, layout);
  }

  @override
  void paint(Canvas canvas) => inner.paint(canvas);
}

/// The outlined box that marks a slot with nothing in it yet.
class _PlaceholderBox extends _Box {
  _PlaceholderBox(this.fontSize, this.color, this.stroke) {
    width = 0.56 * fontSize;
    ascent = 0.70 * fontSize;
    descent = 0.02 * fontSize;
  }

  final double fontSize;
  final Color color;
  final double stroke;

  @override
  void paint(Canvas canvas) {
    final rect = Rect.fromLTRB(
      x + 0.06 * fontSize,
      y - 0.68 * fontSize,
      x + width - 0.06 * fontSize,
      y,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(0.09 * fontSize)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = color,
    );
  }
}

/// Visible parentheses, stretched to the height of what they enclose.
class _GroupBox extends _Box {
  _GroupBox(
    this.body, {
    required this.open,
    required this.close,
    required this.fontSize,
  }) {
    final naturalTop = MathLayout._parenAscent * fontSize;
    final naturalBottom = MathLayout._parenDescent * fontSize;
    final top = math.max(body.ascent + 0.03 * fontSize, naturalTop);
    final bottom = math.max(body.descent + 0.03 * fontSize, naturalBottom);
    final stretch = (top + bottom) / (naturalTop + naturalBottom);
    if (stretch > 1.06) {
      _stretch = stretch;
      _centre = (top - bottom) / 2;
      ascent = top;
      descent = bottom;
    } else {
      _centre = (naturalTop - naturalBottom) / 2;
      ascent = math.max(body.ascent, naturalTop);
      descent = math.max(body.descent, naturalBottom);
    }
    width = open.width + body.width + (close?.width ?? 0);
  }

  final _RowBox body;
  final _TextBox open;
  final _TextBox? close;
  final double fontSize;
  double _stretch = 1;

  /// Height above the baseline of the parentheses' vertical centre.
  late final double _centre;

  @override
  void place(double x, double y, MathLayout layout) {
    super.place(x, y, layout);
    open.place(x, y, layout);
    body.place(x + open.width, y, layout);
    close?.place(x + open.width + body.width, y, layout);
  }

  @override
  void paint(Canvas canvas) {
    _paintParen(canvas, open);
    body.paint(canvas);
    final close = this.close;
    if (close != null) _paintParen(canvas, close);
  }

  void _paintParen(Canvas canvas, _TextBox paren) {
    if (_stretch == 1) {
      paren.paint(canvas);
      return;
    }
    // Scale vertically about the glyph's own centre, moved to the centre of
    // the contents. Vertical-only scaling keeps the stroke weight.
    final naturalCentre = (MathLayout._parenAscent - MathLayout._parenDescent) *
        fontSize /
        2;
    canvas.save();
    canvas.translate(paren.x, y - _centre);
    canvas.scale(1, _stretch);
    paren.painter.paint(canvas, Offset(0, naturalCentre - paren.baseline));
    canvas.restore();
  }
}

class _FractionBox extends _Box {
  _FractionBox(this.numerator, this.denominator, this.fontSize, this.color) {
    _rule = math.max(1.6, 0.058 * fontSize);
    final gap = 0.13 * fontSize;
    final axis = MathLayout._axis * fontSize;
    _inset = 0.07 * fontSize;
    _barWidth = math.max(numerator.width, denominator.width) + 0.24 * fontSize;
    width = _barWidth + 2 * _inset;

    final partSize = numerator.fontSize;
    // Digits do not reach below the baseline, but leave room for the tail
    // of a thousands separator above the bar.
    final numeratorDescent = math.max(numerator.descent, 0.06 * partSize);
    final denominatorAscent = math.max(denominator.ascent, 0.72 * partSize);
    _numeratorShift = axis + _rule / 2 + gap + numeratorDescent;
    _denominatorShift = -axis + _rule / 2 + gap + denominatorAscent;
    ascent = _numeratorShift + numerator.ascent;
    descent = _denominatorShift + denominator.descent;
  }

  final _RowBox numerator;
  final _RowBox denominator;
  final double fontSize;
  final Color color;
  late final double _rule;
  late final double _inset;
  late final double _barWidth;

  /// How far the numerator's baseline sits above this box's baseline.
  late final double _numeratorShift;

  /// How far the denominator's baseline sits below it.
  late final double _denominatorShift;

  @override
  void place(double x, double y, MathLayout layout) {
    super.place(x, y, layout);
    final centre = x + width / 2;
    numerator.place(centre - numerator.width / 2, y - _numeratorShift, layout);
    denominator.place(
        centre - denominator.width / 2, y + _denominatorShift, layout);
  }

  @override
  void paint(Canvas canvas) {
    numerator.paint(canvas);
    denominator.paint(canvas);
    final barY = y - MathLayout._axis * fontSize;
    canvas.drawLine(
      Offset(x + _inset, barY),
      Offset(x + _inset + _barWidth, barY),
      Paint()
        ..color = color
        ..strokeWidth = _rule
        ..strokeCap = StrokeCap.round,
    );
  }
}

class _RadicalBox extends _Box {
  _RadicalBox(this.body, this.fontSize, this.color) {
    _rule = math.max(1.6, 0.058 * fontSize);
    final bodyAscent = math.max(body.ascent, 0.70 * fontSize);
    final bodyDescent = math.max(body.descent, 0.02 * fontSize);
    _top = bodyAscent + 0.13 * fontSize;
    _bottom = bodyDescent + 0.04 * fontSize;
    _bodyX = 0.56 * fontSize;
    _barEnd = _bodyX + body.width + 0.07 * fontSize;
    width = _barEnd + 0.07 * fontSize;
    ascent = _top + _rule / 2 + 0.02 * fontSize;
    descent = _bottom + _rule / 2;
  }

  final _RowBox body;
  final double fontSize;
  final Color color;
  late final double _rule;

  /// Height of the bar above the baseline, and depth of the sign's point
  /// below it.
  late final double _top;
  late final double _bottom;
  late final double _bodyX;
  late final double _barEnd;

  @override
  void place(double x, double y, MathLayout layout) {
    super.place(x, y, layout);
    body.place(x + _bodyX, y, layout);
  }

  @override
  void paint(Canvas canvas) {
    body.paint(canvas);
    final top = y - _top;
    final height = _top + _bottom;
    final path = Path()
      ..moveTo(x + 0.05 * fontSize, top + 0.62 * height)
      ..lineTo(x + 0.15 * fontSize, top + 0.55 * height)
      ..lineTo(x + 0.29 * fontSize, top + height)
      ..lineTo(x + 0.49 * fontSize, top)
      ..lineTo(x + _barEnd, top);
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = color
        ..strokeWidth = _rule
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }
}

class _AbsBox extends _Box {
  _AbsBox(this.body, this.fontSize, this.color) {
    _rule = math.max(1.6, 0.06 * fontSize);
    _barInset = 0.10 * fontSize;
    _bodyX = _barInset + 0.11 * fontSize;
    width = body.width + 2 * _bodyX;
    _top = math.max(body.ascent, 0.70 * fontSize) + 0.05 * fontSize;
    _bottom = math.max(body.descent, 0) + 0.09 * fontSize;
    ascent = _top + _rule / 2;
    descent = _bottom + _rule / 2;
  }

  final _RowBox body;
  final double fontSize;
  final Color color;
  late final double _rule;
  late final double _barInset;
  late final double _bodyX;
  late final double _top;
  late final double _bottom;

  @override
  void place(double x, double y, MathLayout layout) {
    super.place(x, y, layout);
    body.place(x + _bodyX, y, layout);
  }

  @override
  void paint(Canvas canvas) {
    body.paint(canvas);
    final paint = Paint()
      ..color = color
      ..strokeWidth = _rule
      ..strokeCap = StrokeCap.round;
    for (final barX in [x + _barInset, x + width - _barInset]) {
      canvas.drawLine(Offset(barX, y - _top), Offset(barX, y + _bottom), paint);
    }
  }
}
