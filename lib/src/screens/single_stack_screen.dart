import 'dart:async';

import 'package:flutter/material.dart';
import 'package:maxi_flutter_library/maxi_flutter_library.dart';
import 'package:maxi_library/maxi_library.dart';

class SingleStackScreen extends StatefulWidget {
  final void Function(ISingleStackScreenOperator)? onCreatedOperator;

  final Widget initialChild;
  final Duration duration;
  final Curve curve;

  const SingleStackScreen({
    super.key,
    this.initialChild = const SizedBox(),
    this.duration = const Duration(seconds: 1),
    this.curve = Curves.linear,
    this.onCreatedOperator,
  });

  static ISingleStackScreenOperator getOperatorByAncestor(BuildContext context) {
    return volatile(detail: tr('Not encapsulated in Single stack screen'), function: () => WidgetUtilities.findAncestorState<_SingleStackScreenState>(context)!);
  }

  @override
  State<SingleStackScreen> createState() => _SingleStackScreenState();
}

mixin ISingleStackScreenOperator {
  Widget get actualWidget;
  String get actuanWidgetName;

  Future<void> waitAnimationEnd();
  Future<void> waitForConstruction();
  Future<void> changeScreen({required Widget newChild, Duration? duration, Curve? curve});
}

class _SingleStackScreenState extends State<SingleStackScreen> with ISingleStackScreenOperator {
  late Duration duration;
  late Curve curve;
  @override
  late Widget actualWidget;

  bool wasBuild = false;
  bool isFirst = true;

  @override
  String actuanWidgetName = '';

  final waiterPortrait = Completer();
  final changeSemaphore = Semaphore();

  Completer? waiterAnimationEnd;

  @override
  void initState() {
    super.initState();

    actualWidget = const SizedBox();
    duration = widget.duration;
    curve = widget.curve;

    if (widget.onCreatedOperator != null) {
      widget.onCreatedOperator!(this);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!wasBuild) {
      wasBuild = true;

      Future.delayed(Duration.zero).whenComplete(() {
        changeScreen(newChild: buildFirstChild(widget.initialChild));
        waiterPortrait.completeIfIncomplete();
      });
    }

    return AnimatedSwitcher(
      duration: duration,
      switchInCurve: curve,
      switchOutCurve: curve,
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      child: actualWidget,
    );
  }

  @override
  Future<void> waitForConstruction() async {
    if (wasBuild) {
      return;
    }

    await waiterPortrait.future;
  }

  Widget buildFirstChild(Widget child) {
    return SizedBox(
      key: const ValueKey(1),
      child: child,
    );
  }

  Widget buildSecondChild(Widget child) {
    return SizedBox(
      key: const ValueKey(2),
      child: child,
    );
  }

  @override
  Future<void> changeScreen({required Widget newChild, Duration? duration, Curve? curve}) async {
    await waitForConstruction();

    actuanWidgetName = newChild.runtimeType.toString();

    await changeSemaphore.execute(function: () => _changeScreen(newChild: newChild, curve: curve, duration: duration));
  }

  Future<void> _changeScreen({required Widget newChild, Duration? duration, Curve? curve}) async {
    await Future.delayed(Duration.zero);
    setState(() {
      if (duration != null && this.duration != duration) {
        this.duration = duration;
      }

      if (curve != null && this.curve != curve) {
        this.curve = curve;
      }

      isFirst = !isFirst;
      actualWidget = isFirst ? buildFirstChild(newChild) : buildSecondChild(newChild);
    });
  }

  @override
  Future<void> waitAnimationEnd() {
    waiterAnimationEnd ??= Completer();
    return waiterAnimationEnd!.future;
  }
}
