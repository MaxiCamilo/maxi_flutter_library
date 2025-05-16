import 'package:flutter/widgets.dart';
import 'package:maxi_flutter_library/maxi_flutter_library.dart';
import 'package:maxi_library/maxi_library.dart';

class MaxiAnimationSequences<T extends Object?> with IDisposable, IMaxiAnimatedValue<T> {
  final _semaphore = Semaphore();

  late final MaxiAnimatedValue<T> _animator;

  int _pointIndex = -1;

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
  List<MaxiAnimationPoint<T>> _guide;

  MaxiAnimationSequences({
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

  void changeScript(List<MaxiAnimationPoint<T>> newScript) {
    _guide = newScript;
    stopAnimation();
    _pointIndex = -1;
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
    _pointIndex = -1;
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
      _pointIndex = -1;
    }
    return _semaphore.execute(function: () => _startAnimationScript(reversed: true));
  }

  @override
  Future<bool> startAnimation() {
    return _semaphore.execute(function: () => _startAnimationScript(reversed: false));
  }

  @override
  void resetAnimation({bool? reversed}) {
    _animator.stopAnimation();
    _semaphore.execute(function: () {
      _pointIndex = -1;
      if (reversed != null && reversed != _wasReversed) {
        _wasReversed = reversed;
      }
      _startAnimationScript(reversed: _wasReversed);
    });
  }

  Future<bool> _startAnimationScript({required bool reversed}) {
    _wasReversed = reversed;
    if (reversed) {
      return _startAnimationScriptOnReverse();
    } else {
      return _startAnimationScriptStandart();
    }
  }

  Future<bool> _startAnimationScriptStandart() async {
    if (_pointIndex >= _guide.length || _pointIndex < 0) {
      _pointIndex = 0;
    }
    while (_pointIndex < _guide.length) {
      final point = _guide[_pointIndex];

      final completed = await _animator.changeValue(
        value: point.value,
        stopIfItAnimating: false,
        curve: point.curve,
        duration: point.duration,
      );
      if (!completed) {
        return false;
      }
      _pointIndex += 1;
    }

    return true;
  }

  Future<bool> _startAnimationScriptOnReverse() async {
    if (_pointIndex < 0 || _pointIndex >= _guide.length) {
      _pointIndex = _guide.length - 1;
    }

    while (_pointIndex >= 0) {
      final point = _guide[_pointIndex];

      final completed = await _animator.changeValue(
        value: point.value,
        stopIfItAnimating: false,
        curve: point.curve,
        duration: point.duration,
      );
      if (!completed) {
        return false;
      }
      _pointIndex -= 1;
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
