import 'package:flutter/material.dart';

/// The app icon, drawn in code so it is sharp at any size and needs no
/// bundled image. Matches the launcher artwork in tool/icon/make.py: four
/// keys on the brand blue, the `=` key lit.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 64});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: const CustomPaint(painter: _LogoPainter()),
    );
  }
}

class _LogoPainter extends CustomPainter {
  const _LogoPainter();

  static const _blue = Color(0xFF0A60E6);

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final bounds = Offset.zero & size;
    canvas.clipRRect(
      RRect.fromRectAndRadius(bounds, Radius.circular(s * 0.225)),
    );
    canvas.drawRect(
      bounds,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4C97FF), _blue, Color(0xFF2A26BE)],
          stops: [0, 0.48, 1],
        ).createShader(bounds),
    );
    canvas.drawRect(
      bounds,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.6, -0.8),
          radius: 0.8,
          colors: [
            Colors.white.withValues(alpha: 0.32),
            Colors.white.withValues(alpha: 0),
          ],
        ).createShader(bounds),
    );

    final span = s * 0.58;
    final gap = span * 0.075;
    final tile = (span - gap) / 2;
    final origin = (s - span) / 2;
    final stroke = tile * 0.155;
    final reach = tile * 0.255;

    for (final (symbol, column, row) in const [
      ('+', 0, 0),
      ('-', 1, 0),
      ('×', 0, 1),
      ('=', 1, 1),
    ]) {
      final rect = Rect.fromLTWH(
        origin + column * (tile + gap),
        origin + row * (tile + gap),
        tile,
        tile,
      );
      final key = RRect.fromRectAndRadius(rect, Radius.circular(tile * 0.27));
      final lit = symbol == '=';
      if (lit) {
        canvas.drawRRect(
          key.shift(Offset(0, tile * 0.07)),
          Paint()
            ..color = const Color(0xFF04155C).withValues(alpha: 0.35)
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, tile * 0.09),
        );
        canvas.drawRRect(key, Paint()..color = Colors.white);
      } else {
        canvas.drawRRect(
          key,
          Paint()..color = Colors.white.withValues(alpha: 0.2),
        );
        canvas.drawRRect(
          key,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = s * 0.003
            ..color = Colors.white.withValues(alpha: 0.34),
        );
      }

      final ink = Paint()
        ..color = lit ? _blue : Colors.white
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round;
      final c = rect.center;
      void bar(Offset from, Offset to) =>
          canvas.drawLine(c + from, c + to, ink);
      switch (symbol) {
        case '+':
          bar(Offset(-reach, 0), Offset(reach, 0));
          bar(Offset(0, -reach), Offset(0, reach));
        case '-':
          bar(Offset(-reach, 0), Offset(reach, 0));
        case '×':
          final d = reach * 0.72;
          bar(Offset(-d, -d), Offset(d, d));
          bar(Offset(-d, d), Offset(d, -d));
        default:
          final lift = reach * 0.5;
          bar(Offset(-reach, -lift), Offset(reach, -lift));
          bar(Offset(-reach, lift), Offset(reach, lift));
      }
    }
  }

  @override
  bool shouldRepaint(_LogoPainter oldDelegate) => false;
}
