import 'dart:async';

import 'package:flutter/material.dart';
import 'package:maxi_flutter_library/src/animation/legacy/legacy_maxi_widget_animator.dart';
import 'package:maxi_library/maxi_library.dart';

abstract class LegacyMaxiAnimatedPositionedState extends State<_LegacyMaxiAnimatedPositionedWidget> {
  Future<void> changePosition({
    double? left,
    double? top,
    double? right,
    double? bottom,
    double? width,
    double? height,
    Duration? duration,
    Curve? curve,
    Widget? child,
    bool sincronized = false,
  });
}

class LegacyMaxiAnimatedPositioned with LegacyMaxiWidgetAnimator {
  final double? left;
  final double? top;
  final double? right;
  final double? bottom;
  final double? width;
  final double? height;

  final Duration duration;
  final Curve curve;
  final void Function(LegacyMaxiAnimatedPositionedState)? onCreated;

  const LegacyMaxiAnimatedPositioned({
    required this.duration,
    this.left,
    this.top,
    this.right,
    this.bottom,
    this.width,
    this.height,
    this.curve = Curves.linear,
    this.onCreated,
  });

  @override
  Widget build({required BuildContext context, required Widget child}) {
    return _LegacyMaxiAnimatedPositionedWidget(
      left: left,
      top: top,
      right: right,
      bottom: bottom,
      width: width,
      height: height,
      duration: duration,
      curve: curve,
      onCreated: onCreated,
      child: child,
    );
  }
}

class _LegacyMaxiAnimatedPositionedWidget extends StatefulWidget {
  final double? left;
  final double? top;
  final double? right;
  final double? bottom;
  final double? width;
  final double? height;

  final Duration duration;
  final Curve curve;
  final Widget child;
  final void Function(LegacyMaxiAnimatedPositionedState)? onCreated;

  const _LegacyMaxiAnimatedPositionedWidget({
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
    required this.width,
    required this.height,
    required this.duration,
    required this.curve,
    required this.child,
    required this.onCreated,
  });

  @override
  State<StatefulWidget> createState() => _LegacyMaxiAnimatedPositionedState();
}

class _LegacyMaxiAnimatedPositionedState extends LegacyMaxiAnimatedPositionedState {
  late double? left;
  late double? top;
  late double? right;
  late double? bottom;
  late double? width;
  late double? height;

  late Duration duration;
  late Curve curve;
  late Widget child;

  Completer? _waitFinish;
  Semaphore? _sincronizer;

  @override
  void initState() {
    super.initState();

    left = widget.left;
    top = widget.top;
    right = widget.right;
    bottom = widget.bottom;
    width = widget.width;
    height = widget.height;

    duration = widget.duration;
    curve = widget.curve;
    child = widget.child;

    if (widget.onCreated != null) {
      widget.onCreated!(this);
    }
  }

  @override
  void dispose() {
    _sincronizer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: duration,
      bottom: bottom,
      curve: curve,
      height: height,
      left: left,
      right: right,
      top: top,
      width: width,
      child: child,
      onEnd: () {
        _waitFinish?.complete();
        _waitFinish = null;
      },
    );
  }

  @override
  Future<void> changePosition({
    double? left,
    double? top,
    double? right,
    double? bottom,
    double? width,
    double? height,
    Duration? duration,
    Curve? curve,
    Widget? child,
    bool sincronized = false,
  }) async {
    if (sincronized) {
      _sincronizer ??= Semaphore();

      _sincronizer!.execute(function: () => changePosition(bottom: bottom, child: child, curve: curve, duration: duration, height: height, left: left, right: right, top: top, width: width, sincronized: false));

      return;
    }

    bool isChange = false;

    if (left != null && left != this.left) {
      this.left = left;
      isChange = true;
    }

    if (left != null && top != this.top) {
      this.top = top;
      isChange = true;
    }

    if (right != null && right != this.right) {
      this.right = right;
      isChange = true;
    }

    if (bottom != null && bottom != this.bottom) {
      this.right = bottom;
      isChange = true;
    }

    if (width != null && width != this.width) {
      this.width = width;
      isChange = true;
    }

    if (height != null && height != this.height) {
      this.height = height;
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
      setState(() {});
      _waitFinish ??= MaxiCompleter();
      await _waitFinish!.future;
    }
  }
}
