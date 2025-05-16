import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:maxi_flutter_library/maxi_flutter_library.dart';
import 'package:maxi_library/maxi_library.dart';

class SingleStatusAnimation<S, T extends Object?> with IDisposable, IMaxiAnimatedValue<T>, IMaxiAnimatedValueMask<T>, IExecutionStatesManagerPoint<S> {
  @override
  final IMaxiAnimatedValue<T> animator;
  final Map<S, T> options;
  final T initialValue;
  final T? defaultValue;
  final bool useDefaultValue;

  SingleStatusAnimation({
    required this.animator,
    required this.options,
    required this.initialValue,
    this.defaultValue,
    this.useDefaultValue = false,
  });

  factory SingleStatusAnimation.makeAnimator({
    required Map<S, T> options,
    required T initialValue,
    required Duration duration,
    required Curve curve,
    required TickerProvider vsync,
    bool useDefaultValue = false,
    Tween<T> Function(T, T)? tweenBuiler,
    T? defaultValue,
  }) {
    return SingleStatusAnimation(
      options: options,
      initialValue: initialValue,
      defaultValue: defaultValue,
      useDefaultValue: useDefaultValue,
      animator: MaxiAnimatedValue(
        curve: curve,
        duration: duration,
        value: initialValue,
        vsync: vsync,
        tweenBuiler: tweenBuiler,
      ),
    );
  }

  @override
  bool isThisPoint(S item) {
    final exists = options.keys.any((x) => item == x);

    if (!exists && useDefaultValue) {
      return true;
    }

    return exists;
  }

  @override
  FutureOr<void> declareActive(S newValue) async {
    final value = options[newValue];
    if (value == null) {
      if (useDefaultValue) {
        await animator.changeValue(value: defaultValue ?? initialValue, stopIfItAnimating: true);
      } else {
        return;
      }
    } else {
      await animator.changeValue(value: value, stopIfItAnimating: true);
    }
  }

  @override
  FutureOr<void> declareInactive() async {
   // if (useDefaultValue) {
    //  await animator.changeValue(value: defaultValue ?? initialValue, stopIfItAnimating: true);
    //} else {
      animator.stopAnimation();
   // }
  }
}
