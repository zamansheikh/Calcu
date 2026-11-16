import 'dart:async';

import 'package:flutter/material.dart';

/// Small wrapper that adds a press-down scale animation to any child. Used by
/// every tappable surface in the app for a consistent tactile feel.
class AnimatedTap extends StatefulWidget {
  const AnimatedTap({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.repeat = false,
    this.scale = 0.96,
    this.duration = const Duration(milliseconds: 90),
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  /// Holding fires [onTap] over and over, like a held keyboard key, instead
  /// of calling [onLongPress].
  final bool repeat;
  final double scale;
  final Duration duration;

  @override
  State<AnimatedTap> createState() => _AnimatedTapState();
}

class _AnimatedTapState extends State<AnimatedTap> {
  static const _repeatInterval = Duration(milliseconds: 70);

  bool _down = false;
  Timer? _repeatTimer;

  @override
  void dispose() {
    _repeatTimer?.cancel();
    super.dispose();
  }

  void _setDown(bool value) {
    if (_down == value) return;
    setState(() => _down = value);
  }

  void _startRepeat() {
    _setDown(true);
    widget.onTap?.call();
    _repeatTimer?.cancel();
    _repeatTimer = Timer.periodic(_repeatInterval, (_) => widget.onTap?.call());
  }

  void _stopRepeat() {
    _repeatTimer?.cancel();
    _repeatTimer = null;
    _setDown(false);
  }

  @override
  Widget build(BuildContext context) {
    final repeat = widget.repeat;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _setDown(true),
      onTapUp: (_) => _setDown(false),
      onTapCancel: () => _setDown(false),
      onTap: widget.onTap,
      onLongPress: repeat ? null : widget.onLongPress,
      onLongPressStart: repeat ? (_) => _startRepeat() : null,
      onLongPressEnd: repeat ? (_) => _stopRepeat() : null,
      onLongPressCancel: repeat ? _stopRepeat : null,
      child: AnimatedScale(
        duration: widget.duration,
        scale: _down ? widget.scale : 1.0,
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
