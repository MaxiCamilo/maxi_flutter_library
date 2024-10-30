import 'package:flutter/widgets.dart';

class StackedCanvasPosition {
  final Curve? curve;
  final Duration? duration;

  final bool? isVisible;

  final double? left;
  final double? top;
  final double? right;
  final double? bottom;
  final double? width;
  final double? height;

  const StackedCanvasPosition({
    this.duration,
    this.left,
    this.top,
    this.right,
    this.bottom,
    this.width,
    this.height,
    this.isVisible,
    this.curve ,
  });
}
