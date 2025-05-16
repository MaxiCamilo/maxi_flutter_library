import 'package:flutter/widgets.dart';
import 'package:maxi_flutter_library/maxi_flutter_library.dart';

import 'package:maxi_library/maxi_library.dart';

extension ExecutionStatesManagerExtensions<S> on ExecutionStatesManager<S> {
  IMaxiAnimatedValue<T> buildSingleStatusAnimation<T>({
    required Map<S, T> options,
    required T initialValue,
    required Duration duration,
    required Curve curve,
    required TickerProvider vsync,
    bool useDefaultValue = false,
    Tween<T> Function(T, T)? tweenBuiler,
    T? defaultValue,
  }) {
    final newOperator = SingleStatusAnimation<S, T>.makeAnimator(
      initialValue: initialValue,
      options: options,
      defaultValue: defaultValue,
      useDefaultValue: useDefaultValue,
      duration: duration,
      curve: curve,
      vsync: vsync,
      tweenBuiler: tweenBuiler,
    );

    maxiScheduleMicrotask(() => addState(point: newOperator));

    return newOperator;
  }
}
