import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:maxi_flutter_library/maxi_flutter_library.dart';
import 'package:maxi_library/export_reflectors.dart';

class MaxiAnimatedValue<T extends Object?> extends ValueListenable<T> with IDisposable, ChangeNotifier, IMaxiAnimatedValue<T> {
  final Tween<T> Function(T begin, T end)? tweenBuiler;

  final TickerProvider _vsync;
  final _semaphore = Semaphore();

  late final AnimationController _animator;
  late Animation<T> _animation;

  Duration _duration;
  Curve _curve;
  T _value;
  bool _wasAnimating = false;
  bool _isPause = false;
  T _lastValue;

  Completer<bool>? _waiter;
  StreamController<T>? _notifyChangeValueController;

  @override
  T get value => _value;
  @override
  bool get isAnimating => _wasAnimating;
  @override
  bool get isPause => _isPause;

  @override
  Type get valueType => T;

  @override
  set value(T newValue) => changeValue(value: newValue, stopIfItAnimating: true);

  Stream<T> get notifyChangeValue async* {
    _notifyChangeValueController ??= StreamController<T>.broadcast();
    yield* _notifyChangeValueController!.stream;
  }

  MaxiAnimatedValue({
    required T value,
    required Duration duration,
    required Curve curve,
    required TickerProvider vsync,
    this.tweenBuiler,
  })  : _vsync = vsync,
        _curve = curve,
        _value = value,
        _duration = duration,
        _lastValue = value {
    _animator = AnimationController(vsync: _vsync, duration: _duration);
    _animator.addStatusListener(_reactStatusChange);
  }

  factory MaxiAnimatedValue.searchByType({
    required T value,
    required Duration duration,
    required Curve curve,
    required TickerProvider vsync,
    Tween<T> Function(T, T)? tweenBuiler,
  }) {
    final optionalTipe = T.toString();
    if (T == Color || optionalTipe == 'Color?') {
      return MaxiAnimatedColor(value: value as Color?, duration: duration, curve: curve, vsync: vsync) as MaxiAnimatedValue<T>;
    }

    if (T == Size || optionalTipe == 'Size?') {
      return MaxiAnimatedSize(value: value as Size?, duration: duration, curve: curve, vsync: vsync) as MaxiAnimatedValue<T>;
    }

    if (T == Rect || optionalTipe == 'Rect?') {
      return MaxiAnimatedRect(value: value as Rect?, duration: duration, curve: curve, vsync: vsync) as MaxiAnimatedValue<T>;
    }

    return MaxiAnimatedValue<T>(curve: curve, duration: duration, value: value, vsync: vsync, tweenBuiler: tweenBuiler);
  }

  @override
  void stopAnimation() {
    _isPause = false;
    _animator.stop();
    _waiter?.completeIfIncomplete(false);
    _waiter = null;
  }

  @override
  T pauseAnimation() {
    if (isAnimating && !_isPause) {
      _isPause = true;
      _animator.stop();
    }
    return value;
  }

  @override
  void resumeAnimation() {
    if (isAnimating && isPause) {
      _isPause = false;
      _animator.forward();
    }
  }

  @override
  void resetAnimation() {
    if (isAnimating && isPause) {
      _isPause = false;
      _animator.forward(from: 0);
    } else if (!isAnimating) {
      startAnimation();
    }
  }

  @override
  Future<bool> reverseAnimation({required bool stopIfItAnimating, Duration? duration, Curve? curve}) {
    return changeValue(stopIfItAnimating: stopIfItAnimating, value: _lastValue, curve: curve, duration: duration);
  }

  @override
  Future<bool> changeValue({required T value, required bool stopIfItAnimating, Duration? duration, Curve? curve}) {
    if (stopIfItAnimating && _wasAnimating) {
      stopAnimation();
    }
    return _semaphore.execute(function: () => _changeValueSecured(value: value, duration: duration, curve: curve));
  }

  @override
  Future<bool> waitAnimationFinish() async {
    if (wasDiscarded || !isAnimating) {
      return false;
    }
    _waiter ??= MaxiCompleter<bool>();
    return await _waiter!.future.whenComplete(() => _waiter = null);
  }

  Future<bool> _changeValueSecured({required T value, Duration? duration, Curve? curve}) async {
    if (_wasAnimating) {
      await waitAnimationFinish();
    }
    if (wasDiscarded) {
      return false;
    }
    if (duration != null && _duration != duration) {
      _duration = duration;
    }
    if (curve != null && _curve != curve) {
      _curve = curve;
    }

    if (value == _value) {
      return true;
    }

    _animator.duration = _duration;

    _lastValue = _value;
    late final Tween<T> tween;

    if (tweenBuiler == null) {
      tween = Tween<T>(
        begin: _value,
        end: value,
      );
    } else {
      tween = tweenBuiler!(_value, value);
    }

    _animation = tween.animate(CurvedAnimation(
      parent: _animator,
      curve: _curve,
    ));
    _animation.addListener(_updateValue);

    _waiter ??= MaxiCompleter<bool>();

    _animator.forward(from: 0);
    _wasAnimating = true;
    final result = await _waiter!.future;

    if (_value != _animation.value) {
      _value = _animation.value;
      _notifyChangeValueController?.addIfActive(_value);
    }

    _wasAnimating = false;

    _animation.removeListener(_updateValue);

    return result;
  }

  void _updateValue() {
    _value = _animation.value;
    _notifyChangeValueController?.addIfActive(_value);
    notifyListeners();
  }

  void _reactStatusChange(AnimationStatus status) {
    if (status == AnimationStatus.forward || status == AnimationStatus.reverse) {
      _wasAnimating = true;
    } else if (_wasAnimating && status == AnimationStatus.dismissed) {
      _wasAnimating = false;
      _waiter?.completeIfIncomplete(false);
      _waiter = null;
    } else if (_wasAnimating && status == AnimationStatus.completed) {
      _wasAnimating = false;
      _waiter?.completeIfIncomplete(true);
      _waiter = null;
    } else if (_wasAnimating && status != AnimationStatus.forward && status != AnimationStatus.reverse) {
      _wasAnimating = false;
      _waiter?.completeIfIncomplete(false);
      _waiter = null;
    }
  }

  @override
  void dispose() {
    super.dispose();
    maxi_dispose();
  }

  @override
  void performObjectDiscard() {
    _animator.removeStatusListener(_reactStatusChange);
    _animator.dispose();

    _waiter?.completeIfIncomplete(false);
    _waiter = null;
  }

  @override
  Future<bool> startAnimation() async {
    if (isAnimating) {
      return _waiter!.future;
    }
    return false;
  }
}

class MaxiAnimatedColor extends MaxiAnimatedValue<Color?> {
  static Tween<Color?> _build(Color? x, Color? y) => ColorTween(begin: x, end: y);
  MaxiAnimatedColor({
    required super.value,
    required super.duration,
    required super.curve,
    required super.vsync,
    super.tweenBuiler = _build,
  });
}

class MaxiAnimatedSize extends MaxiAnimatedValue<Size?> {
  static Tween<Size?> _build(Size? x, Size? y) => SizeTween(begin: x, end: y);
  MaxiAnimatedSize({
    required super.value,
    required super.duration,
    required super.curve,
    required super.vsync,
    super.tweenBuiler = _build,
  });
}

class MaxiAnimatedRect extends MaxiAnimatedValue<Rect?> {
  static Tween<Rect?> _build(Rect? x, Rect? y) => RectTween(begin: x, end: y);
  MaxiAnimatedRect({
    required super.value,
    required super.duration,
    required super.curve,
    required super.vsync,
    super.tweenBuiler = _build,
  });
}

class MaxiAnimatedRoundInt extends MaxiAnimatedValue<int?> {
  static Tween<int?> _build(int? x, int? y) => IntTween(begin: x, end: y);
  MaxiAnimatedRoundInt({
    required super.value,
    required super.duration,
    required super.curve,
    required super.vsync,
    super.tweenBuiler = _build,
  });
}

class MaxiAnimatedStepInt extends MaxiAnimatedValue<int?> {
  static Tween<int?> _build(int? x, int? y) => StepTween(begin: x, end: y);
  MaxiAnimatedStepInt({
    required super.value,
    required super.duration,
    required super.curve,
    required super.vsync,
    super.tweenBuiler = _build,
  });
}
