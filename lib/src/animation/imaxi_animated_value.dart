import 'package:flutter/widgets.dart';
import 'package:maxi_library/maxi_library.dart';

mixin IMaxiAnimatedValue<T extends Object?> on IDisposable {
  Type get valueType;
  T get value;
  set value(T newValue);
  bool get isAnimating;
  bool get isPause;
  void addListener(VoidCallback listener);
  void removeListener(VoidCallback listener);
  Future<bool> reverseAnimation({required bool stopIfItAnimating, Duration? duration, Curve? curve});
  Future<bool> changeValue({required T value, required bool stopIfItAnimating, Duration? duration, Curve? curve});
  Future<bool> waitAnimationFinish();
  Future<bool> startAnimation();

  void stopAnimation();
  T pauseAnimation();
  void resumeAnimation();
  void resetAnimation();
}

mixin IMaxiAnimatedValueMask<T extends Object?> on IDisposable, IMaxiAnimatedValue<T> {
  IMaxiAnimatedValue<T> get animator;

  @override
  bool get isAnimating => animator.isAnimating;

  @override
  bool get isPause => animator.isPause;

  @override
  T get value => animator.value;
  @override
  set value(T item) => animator.value = item;

  @override
  Type get valueType => animator.valueType;

  @override
  void addListener(VoidCallback listener) {
    animator.addListener(listener);
  }

  @override
  Future<bool> changeValue({required T value, required bool stopIfItAnimating, Duration? duration, Curve? curve}) {
    return animator.changeValue(value: value, stopIfItAnimating: stopIfItAnimating, curve: curve, duration: duration);
  }

  @override
  T pauseAnimation() {
    return animator.pauseAnimation();
  }

  @override
  @mustCallSuper
  @protected
  void performObjectDiscard() {
    animator.performObjectDiscard();
  }

  @override
  void removeListener(VoidCallback listener) {
    animator.removeListener(listener);
  }

  @override
  void resetAnimation() {
    animator.resetAnimation();
  }

  @override
  void resumeAnimation() {
    animator.resumeAnimation();
  }

  @override
  Future<bool> reverseAnimation({required bool stopIfItAnimating, Duration? duration, Curve? curve}) {
    return animator.reverseAnimation(stopIfItAnimating: stopIfItAnimating, curve: curve, duration: duration);
  }

  @override
  Future<bool> startAnimation() {
    return animator.startAnimation();
  }

  @override
  void stopAnimation() {
    animator.startAnimation();
  }

  @override
  Future<bool> waitAnimationFinish() {
    return animator.waitAnimationFinish();
  }
}
