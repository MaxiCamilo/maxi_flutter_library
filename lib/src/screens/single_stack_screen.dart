import 'dart:async';

import 'package:flutter/material.dart';
import 'package:maxi_flutter_library/maxi_flutter_library.dart';
import 'package:maxi_library/maxi_library.dart';

class SingleStackScreen extends StatefulWidget {
  final void Function(ISingleStackScreenOperator)? onCreatedOperator;

  final Widget Function(BuildContext)? initialChildBuild;
  final Duration duration;
  final Curve curve;

  const SingleStackScreen({
    super.key,
    this.initialChildBuild,
    this.duration = const Duration(seconds: 1),
    this.curve = Curves.linear,
    this.onCreatedOperator,
  });

  static ISingleStackScreenOperator getOperatorByAncestor(BuildContext context) {
    return volatile(detail: const Oration(message: 'Not encapsulated in Single stack screen'), function: () => WidgetUtilities.findAncestorState<_SingleStackScreenState>(context)!);
  }

  @override
  State<SingleStackScreen> createState() => _SingleStackScreenState();
}

mixin ISingleStackScreenOperator {
  Widget get actualWidget;
  String get actuanWidgetName;
  bool get wasBuild;

  Future<void> waitAnimationEnd();
  Future<void> waitForConstruction();
  Future<void> changeScreen({required Widget newChild, Duration? duration, Curve? curve});
  void changeScreenWithoutAnimation({required Widget newChild});
}

class _SingleStackScreenState extends State<SingleStackScreen> with ISingleStackScreenOperator {
  late Duration duration;
  late Curve curve;
  @override
  late Widget actualWidget;

  @override
  bool wasBuild = false;
  int childID = 0;

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

  Widget _buildChild(Widget child) {
    return SizedBox(
      key: ValueKey(childID),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!wasBuild) {
      wasBuild = true;
      /*
      Future.delayed(Duration.zero).whenComplete(() {
        if (mounted) {
          // ignore: use_build_context_synchronously
          changeScreen(newChild: widget.initialChildBuild == null ? const SizedBox() : widget.initialChildBuild!(context));
          waiterPortrait.completeIfIncomplete();
        }
      });
      */
      actualWidget = _buildChild(widget.initialChildBuild == null ? const SizedBox() : widget.initialChildBuild!(context));
      waiterPortrait.completeIfIncomplete();
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
/*
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
  */

  @override
  Future<void> changeScreen({required Widget newChild, Duration? duration, Curve? curve}) async {
    await waitForConstruction();

    actuanWidgetName = newChild.runtimeType.toString();

    await changeSemaphore.execute(function: () => _changeScreen(newChild: newChild, curve: curve, duration: duration));
  }

  Future<void> _changeScreen({required Widget newChild, Duration? duration, Curve? curve}) async {
    await Future.delayed(Duration.zero);

    if (!mounted) {
      throw NegativeResult(identifier: NegativeResultCodes.implementationFailure, message: const Oration(message: 'You can\'t change the screen of a widget that no longer exists'));
    }

    if (duration != null && this.duration != duration) {
      this.duration = duration;
    }

    if (curve != null && this.curve != curve) {
      this.curve = curve;
    }
    childID += 1;
    actualWidget = _buildChild(newChild);
    setState(() {});
  }

  @override
  Future<void> waitAnimationEnd() {
    waiterAnimationEnd ??= Completer();
    return waiterAnimationEnd!.future;
  }

  @override
  void changeScreenWithoutAnimation({required Widget newChild}) {
    if (mounted) {
      childID += 1;
      actualWidget = _buildChild(newChild);
      setState(() {});
    }
  }
}
