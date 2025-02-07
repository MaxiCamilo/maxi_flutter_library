import 'dart:async';

import 'package:flutter/material.dart';
import 'package:maxi_flutter_library/maxi_flutter_library.dart';
import 'package:maxi_library/maxi_library.dart';

class SingleRouterScreen extends StatefulWidget {
  final Duration duration;
  final Curve curve;
  

  final void Function(StackedScreenOperator)? onCreatedOperator;

  const SingleRouterScreen({
    super.key,
    this.duration = const Duration(seconds: 1),
    this.curve = Curves.linear,
    this.onCreatedOperator,
  });

  @override
  State<SingleRouterScreen> createState() => _SingleRouterScreenState();
}

class _SingleRouterScreenState extends State<SingleRouterScreen> with StackedScreenOperator {
  late BoxConstraints actualConstraints;

  final children = <MaxiAnimatedWidget>[];
  final positioners = <MaxiAnimatedPositionedState>[];
  final visibles = <MaxiAnimatedVisibleState>[];
  final opacity = <MaxiAnimatedOpacityState>[];

  MaxiAnimatedWidget? get activeChild => children.isEmpty ? null : children.last;

  bool wasBuilt = false;

  final _sincronizer = Semaphore();

  @override
  int get numberOfScreens => children.length;

  @override
  void initState() {
    super.initState();

    if (widget.onCreatedOperator != null) {
      widget.onCreatedOperator!(this);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (wasBuilt) {
          _checkScreenSize(constraints);
        } else {
          actualConstraints = constraints;
        }

        wasBuilt = true;
        return SizedBox(
          height: constraints.maxHeight,
          width: constraints.maxWidth,
          child: Stack(children: children),
        );
      },
    );
  }

  void _checkScreenSize(BoxConstraints constraints) {
    if (actualConstraints != constraints) {
      actualConstraints = constraints;
      positioners.iterar((x) {
        x.changePosition(
          width: actualConstraints.maxWidth,
          height: actualConstraints.maxHeight,
          duration: Duration.zero,
          left: x == positioners.last ? 0 : actualConstraints.maxWidth * -1,
        );
      });
    }
  }

  @override
  void pushScreen({required Widget newWidget, Duration? duration, Curve? curve, bool retryIfNotBuilt = true}) {
    if (retryIfNotBuilt && !wasBuilt) {
      Future.delayed(Duration.zero).whenComplete(() => pushScreen(newWidget: newWidget, curve: curve, duration: duration, retryIfNotBuilt: false));
      return;
    }

    checkProgrammingFailure(thatChecks: tr('Must be built before'), result: () => wasBuilt);
    checkProgrammingFailure(thatChecks: tr('Single stacked screen  is still active'), result: () => mounted);

    _sincronizer.execute(function: () => _pushScreen(newWidget: newWidget, curve: curve, duration: duration));
  }

  Future<void> _pushScreen({required Widget newWidget, Duration? duration, Curve? curve}) async {
    final completerVisible = Completer<MaxiAnimatedVisibleState>();
    final completerPosition = Completer<MaxiAnimatedPositionedState>();
    final completerOpacity = Completer<MaxiAnimatedOpacityState>();

    final newScreen = MaxiAnimatedWidget(
      animators: [
        MaxiAnimatedVisible(
          onCreated: (x) => completerVisible.complete(x),
        ),
        MaxiAnimatedOpacity(
          duration: duration ?? widget.duration,
          onCreated: (x) => completerOpacity.complete(x),
        ),
        MaxiAnimatedPositioned(
          duration: duration ?? widget.duration,
          curve: curve ?? widget.curve,
          top: 0,
          left: actualConstraints.maxWidth,
          width: actualConstraints.maxWidth,
          height: actualConstraints.maxHeight,
          onCreated: (x) => completerPosition.complete(x),
        ),
      ],
      child: newWidget,
    );
    final int position = children.length;

    children.add(newScreen);
    setState(() {});

    final newVisibleOperator = await completerVisible.future;
    final newPositionOperator = await completerPosition.future;
    final newOpacityOperator = await completerOpacity.future;

    visibles.add(newVisibleOperator);
    positioners.add(newPositionOperator);
    opacity.add(newOpacityOperator);

    final futureChangePosition = newPositionOperator.changePosition(left: 0);

    if (position > 0) {
      final futureHide = _hideScreen(position: position - 1, toLeft: true, curve: curve, duration: duration);
      await Future.wait([futureChangePosition, futureHide]);
    } else {
      await futureChangePosition;
    }
  }

  Future<void> _hideScreen({required int position, required bool toLeft, Duration? duration, Curve? curve}) async {
    final positionOperator = positioners[position];
    final visibleOperator = visibles[position];

    await positionOperator.changePosition(
      curve: curve ?? widget.curve,
      duration: duration,
      left: toLeft ? actualConstraints.maxWidth * -1 : actualConstraints.maxWidth,
      //right: toLeft ? actualConstraints.maxHeight : actualConstraints.maxWidth * -1,
    );

    await visibleOperator.changeVisibility(visibility: false, animated: false, curve: curve ?? widget.curve);
  }

  Future<void> _showScreen({required int position, required bool toLeft, Duration? duration, Curve? curve}) async {
    final positionOperator = positioners[position];
    final visibleOperator = visibles[position];

    await visibleOperator.changeVisibility(visibility: true, animated: false);
    await positionOperator.changePosition(
      curve: curve,
      duration: duration,
      left: 0,
      //right: toLeft ? actualConstraints.maxHeight : actualConstraints.maxWidth * -1,
    );
  }

  @override
  void goBack({Duration? duration, Curve? curve}) {
    _sincronizer.execute(function: () => _goBack(curve: curve, duration: duration));
  }

  Future<void> _goBack({Duration? duration, Curve? curve}) async {
    if (children.length <= 1) {
      return;
    }

    checkProgrammingFailure(thatChecks: tr('Single stacked screen  is still active'), result: () => mounted);
    checkProgrammingFailure(thatChecks: tr('Must be built before'), result: () => wasBuilt);

    final position = children.length - 1;

    final futureShow = _showScreen(position: position - 1, toLeft: true, duration: duration ?? widget.duration, curve: curve ?? widget.curve);
    final futureHide = _hideScreen(position: position, toLeft: false, duration: duration ?? widget.duration, curve: curve ?? widget.curve);

    await Future.wait([futureShow, futureHide]);

    children.removeLast();
    positioners.removeLast();
    visibles.removeLast();
    opacity.removeLast();

    setState(() {});
  }

  @override
  void resetScreen({required Widget newWidget, Duration? duration, Curve? curve}) {
    checkProgrammingFailure(thatChecks: tr('Must be built before'), result: () => wasBuilt);
    checkProgrammingFailure(thatChecks: tr('Single stacked screen  is still active'), result: () => mounted);
    _sincronizer.execute(function: () {
      if (children.isEmpty) {
        return _pushScreen(newWidget: newWidget, curve: curve, duration: duration);
      } else {
        return _resetScreen(newWidget: newWidget, curve: curve, duration: duration);
      }
    });
  }

  Future<void> _resetScreen({required Widget newWidget, Duration? duration, Curve? curve}) async {
    await opacity.last.changeOpacity(opacity: 0, duration: Duration(milliseconds: (duration ?? widget.duration).inMilliseconds ~/ 5));

    children.clear();
    opacity.clear();
    positioners.clear();
    visibles.clear();

    setState(() {});

    await Future.delayed(Duration.zero);
    await Future.delayed(Duration.zero);
    await Future.delayed(Duration.zero);

    await _pushScreen(newWidget: newWidget, duration: duration, curve: curve);
  }
}
