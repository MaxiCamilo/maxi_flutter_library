import 'package:flutter/widgets.dart';
import 'package:maxi_flutter_library/maxi_flutter_library.dart';
import 'package:maxi_library/maxi_library.dart';

//TODO Hacer que puede ejecutar el guión desde el principio, elegir lugar especifico, etc

class MaxiAnimationScript<T extends Object?> with IDisposable, IMaxiAnimatedValue<T> {
  final List<MaxiAnimationPoint<T>> _guide;
  final _semaphore = Semaphore();

  late final MaxiAnimatedValue<T> _animator;

  int _pointIndex = 0;

  @override
  Type get valueType => List<MaxiAnimationPoint<T>>;

  @override
  T get value => _animator.value;

  @override
  set value(T newGuide) => changeValue(value: newGuide, stopIfItAnimating: true);

  @override
  bool get isAnimating => _animator.isAnimating;

  @override
  bool get isPause => _animator.isPause;

  bool _wasReversed = false;

  MaxiAnimationScript({
    required TickerProvider vsync,
    required List<MaxiAnimationPoint<T>> guide,
    Tween<T> Function(T, T)? tweenBuiler,
  }) : _guide = guide {
    assert(guide.isNotEmpty);
    final initialStatus = _guide.first;
    _animator = MaxiAnimatedValue<T>(
      curve: initialStatus.curve ?? Curves.linear,
      duration: initialStatus.duration ?? const Duration(seconds: 1),
      value: initialStatus.value,
      vsync: vsync,
      tweenBuiler: tweenBuiler,
    );
  }

  @override
  void addListener(VoidCallback listener) {
    _animator.addListener(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    _animator.removeListener(listener);
  }

  @override
  Future<bool> changeValue({required T value, required bool stopIfItAnimating, Duration? duration, Curve? curve}) {
    _pointIndex = 0;
    return _animator.changeValue(value: value, stopIfItAnimating: stopIfItAnimating, duration: duration, curve: curve);
  }

  @override
  T pauseAnimation() {
    return _animator.pauseAnimation();
  }

  @override
  void resumeAnimation() {
    _animator.resumeAnimation();
  }

  @override
  Future<bool> reverseAnimation({required bool stopIfItAnimating, Duration? duration, Curve? curve}) {
    if (stopIfItAnimating && _animator.isAnimating) {
      _animator.stopAnimation();
    }
    return _semaphore.execute(function: () => _startAnimationScript(reversed: true));
  }

  @override
  Future<bool> startAnimation() {
    return _semaphore.execute(function: () => _startAnimationScript(reversed: false));
  }

  @override
  void resetAnimation() {
    _animator.stopAnimation();
    _semaphore.execute(function: () {
      _startAnimationScript(reversed: _wasReversed);
    });
  }

  Future<bool> _startAnimationScript({required bool reversed}) async {
    _wasReversed = reversed;
    if (reversed) {
      if (_pointIndex < 0 || _pointIndex >= _guide.length) {
        _pointIndex = _guide.length - 1;
      }

      while (_pointIndex >= 0) {
        //SEPARAR ESTO EN UNA FUNCIÓN APARTE
        final point = _guide[_pointIndex];
        _pointIndex -= 1;
        final completed = await _animator.changeValue(
          value: point.value,
          stopIfItAnimating: false,
          curve: point.curve,
          duration: point.duration,
        );
        if (!completed) {
          return false;
        }
      }
    } else {
      //SEPARAR ESTO EN UNA FUNCIÓN APARTE
      if (_pointIndex >= _guide.length) {
        _pointIndex = 0;
      }
      while (_pointIndex < _guide.length) {
        final point = _guide[_pointIndex];
        _pointIndex += 1;
        final completed = await _animator.changeValue(
          value: point.value,
          stopIfItAnimating: false,
          curve: point.curve,
          duration: point.duration,
        );
        if (!completed) {
          return false;
        }
      }
    }

    return true;
  }

  @override
  void stopAnimation() {
    _pointIndex = 0;
    _animator.stopAnimation();
  }

  @override
  Future<bool> waitAnimationFinish() {
    return _animator.waitAnimationFinish();
  }

  @override
  void performObjectDiscard() {
    _animator.dispose();
  }
}
