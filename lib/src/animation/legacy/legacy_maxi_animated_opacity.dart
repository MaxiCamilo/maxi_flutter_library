import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:maxi_flutter_library/maxi_flutter_library.dart';
import 'package:maxi_library/maxi_library.dart';

class LegacyMaxiAnimatedOpacity with LegacyMaxiWidgetAnimator {
  final double initialopacity;
  final Duration duration;
  final Curve curve;
  final void Function(LegacyMaxiAnimatedOpacityState)? onCreated;

  const LegacyMaxiAnimatedOpacity({
    required this.duration,
    this.initialopacity = 1.0,
    this.curve = Curves.linear,
    this.onCreated,
  });

  @override
  Widget build({required BuildContext context, required Widget child}) {
    return _LegacyMaxiAnimatedOpacityWidget(
      opacity: initialopacity,
      curve: curve,
      duration: duration,
      onCreated: onCreated,
      child: child,
    );
  }
}

mixin LegacyMaxiAnimatedOpacityState<T extends StatefulWidget> on State<T> {
  double get opacity;

  Stream<double> get opacityChanged;

  Future<void> changeOpacity({
    double? opacity,
    Duration? duration,
    Curve? curve,
    Widget? child,
    bool sincronized = false,
  });
}

class _LegacyMaxiAnimatedOpacityWidget extends StatefulWidget {
  final Widget child;
  final double opacity;
  final Duration duration;
  final Curve curve;
  final void Function(LegacyMaxiAnimatedOpacityState)? onCreated;

  const _LegacyMaxiAnimatedOpacityWidget({
    required this.opacity,
    required this.child,
    required this.duration,
    required this.curve,
    required this.onCreated,
  });

  @override
  State<StatefulWidget> createState() => _LegacyMaxiAnimatedOpacityState();
}

class _LegacyMaxiAnimatedOpacityState extends StateWithLifeCycle<_LegacyMaxiAnimatedOpacityWidget> with LegacyMaxiAnimatedOpacityState {
  @override
  late double opacity;
  late Duration duration;
  late Curve curve;
  late Widget child;

  Completer? _waitFinish;
  Semaphore? _sincronizer;

  @override
  Stream<double> get opacityChanged => _opacityChangedController.stream;
  late StreamController<double> _opacityChangedController;

  @override
  void initState() {
    super.initState();

    _opacityChangedController = createEventController<double>(isBroadcast: true);

    opacity = widget.opacity;
    duration = widget.duration;
    curve = widget.curve;
    child = widget.child;

    if (widget.onCreated != null) {
      widget.onCreated!(this);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: duration,
      opacity: opacity,
      curve: curve,
      child: child,
      onEnd: () {
        _waitFinish?.complete();
        _waitFinish = null;
      },
    );
  }

  @override
  Future<void> changeOpacity({double? opacity, Duration? duration, Curve? curve, Widget? child, bool sincronized = false}) async {
    if (sincronized) {
      _sincronizer ??= Semaphore();
      _sincronizer!.execute(function: () => changeOpacity(child: child, duration: duration, curve: curve, opacity: opacity, sincronized: false));
      return;
    }

    bool isChange = false;
    final actualOpacity = this.opacity;

    if (opacity != null && opacity != this.opacity) {
      this.opacity = opacity;
      isChange = true;
    }

    if (duration != null && duration != this.duration) {
      this.duration = duration;
      isChange = true;
    }

    if (curve != null && curve != this.curve) {
      this.curve = curve;
      isChange = true;
    }

    if (child != null && child != this.child) {
      this.child = child;
      isChange = true;
    }

    if (isChange && mounted) {
      _waitFinish ??= MaxiCompleter();
      setState(() {});
      await _waitFinish!.future;
      if (actualOpacity != this.opacity) {
        _opacityChangedController.add(this.opacity);
      }
    }
  }
}
