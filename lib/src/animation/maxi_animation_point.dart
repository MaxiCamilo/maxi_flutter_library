import 'package:flutter/animation.dart';

class MaxiAnimationPoint<T extends Object?> {
  final T value;
  final Duration? duration;
  final Curve? curve;

  const MaxiAnimationPoint({required this.value, required this.duration, required this.curve});
}
