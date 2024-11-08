import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:maxi_flutter_library/maxi_flutter_library.dart';
import 'package:maxi_library/maxi_library.dart';

class MaxiAnimatedOpacity with WidgetAnimator {
  final double initialopacity;
  final Duration duration;
  final Curve curve;
  final void Function(MaxiAnimatedOpacityState)? onCreated;

  const MaxiAnimatedOpacity({
    required this.duration,
    this.initialopacity = 1.0,
    this.curve = Curves.linear,
    this.onCreated,
  });

  @override
  Widget build({required BuildContext context, required Widget child}) {
    return _MaxiAnimatedOpacityWidget(
      opacity: initialopacity,
      curve: curve,
      duration: duration,
      onCreated: onCreated,
      child: child,
    );
  }
}

abstract class MaxiAnimatedOpacityState extends State<_MaxiAnimatedOpacityWidget> {
  double get opacity;

  Future<void> changeOpacity({
    double? opacity,
    Duration? duration,
    Curve? curve,
    Widget? child,
    bool sincronized = false,
  });
}

class _MaxiAnimatedOpacityWidget extends StatefulWidget {
  final Widget child;
  final double opacity;
  final Duration duration;
  final Curve curve;
  final void Function(MaxiAnimatedOpacityState)? onCreated;

  const _MaxiAnimatedOpacityWidget({
    required this.opacity,
    required this.child,
    required this.duration,
    required this.curve,
    required this.onCreated,
  });

  @override
  State<StatefulWidget> createState() => _MaxiAnimatedOpacityState();
}

class _MaxiAnimatedOpacityState extends MaxiAnimatedOpacityState {
  @override
  late double opacity;
  late Duration duration;
  late Curve curve;
  late Widget child;

  Completer? _waitFinish;
  Semaphore? _sincronizer;

  @override
  void initState() {
    super.initState();

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
      _waitFinish ??= Completer();
      setState(() {});
      await _waitFinish!.future;
    }
  }
}
