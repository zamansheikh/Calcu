import 'package:flutter/widgets.dart';

import '../../../core/math/math_document.dart';
import 'math_layout.dart';

/// Paints a [MathLayout] at the origin.
class MathPainter extends CustomPainter {
  const MathPainter(this.layout);

  final MathLayout layout;

  @override
  void paint(Canvas canvas, Size size) => layout.paint(canvas, Offset.zero);

  @override
  bool shouldRepaint(MathPainter oldDelegate) =>
      !identical(oldDelegate.layout, layout);
}

/// A short piece of typeset math, drawn by the same engine as the display.
///
/// Used on the keypad so a key shows the notation it produces: `frac(,)`
/// draws two empty boxes either side of a bar, `√()` a root over a box.
class MathLabel extends StatefulWidget {
  const MathLabel(
    this.source, {
    super.key,
    required this.fontSize,
    required this.color,
    this.fontWeight = FontWeight.w600,
  });

  /// Expression source, in the calculator's own syntax.
  final String source;
  final double fontSize;
  final Color color;
  final FontWeight fontWeight;

  @override
  State<MathLabel> createState() => _MathLabelState();
}

class _MathLabelState extends State<MathLabel> {
  MathLayout? _layout;
  // What `_layout` was built from, to know when it is stale.
  Object? _signature;

  @override
  void dispose() {
    _layout?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fontSize = MediaQuery.textScalerOf(context).scale(widget.fontSize);
    final signature =
        (widget.source, fontSize, widget.color, widget.fontWeight);
    if (_layout == null || signature != _signature) {
      _layout?.dispose();
      _signature = signature;
      _layout = MathLayout(
        MathDocument.parse(widget.source),
        MathStyle(
          fontSize: fontSize,
          fontWeight: widget.fontWeight,
          color: widget.color,
          // Empty slots are the point of a key's label, so draw them as
          // firmly as the strokes around them.
          placeholderColor: widget.color.withValues(alpha: 0.8),
          placeholderStroke: 0.065,
        ),
      );
    }
    final layout = _layout!;
    return CustomPaint(size: layout.size, painter: MathPainter(layout));
  }
}
