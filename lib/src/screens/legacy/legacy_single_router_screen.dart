import 'dart:async';

import 'package:flutter/material.dart';
import 'package:maxi_flutter_library/maxi_flutter_library.dart';
import 'package:maxi_library/maxi_library.dart';

class LegacySingleRouterScreen extends StatefulWidget {
  final Duration duration;
  final Curve curve;

  final void Function(IStackedScreenOperator)? onCreatedOperator;

  const LegacySingleRouterScreen({
    super.key,
    this.duration = const Duration(seconds: 1),
    this.curve = Curves.linear,
    this.onCreatedOperator,
  });

  @override
  State<LegacySingleRouterScreen> createState() => _LegacySingleRouterScreenState();
}

class _LegacySingleRouterScreenState extends StateWithLifeCycle<LegacySingleRouterScreen> with IStackedScreenOperator {
  late BoxConstraints actualConstraints;

  final children = <LegacyMaxiAnimatedWidget>[];
  final positioners = <LegacyMaxiAnimatedPositionedState>[];
  final visibles = <LegacyMaxiAnimatedVisibleState>[];
  final opacity = <LegacyMaxiAnimatedOpacityState>[];

  LegacyMaxiAnimatedWidget? get activeChild => children.isEmpty ? null : children.last;

  @override
  Stream<int> get notifyChangeScreen => notifyChangeScreenController.stream;

  @override
  Stream get notifyDispose => notifyDisposeController.stream;

  bool wasBuilt = false;
  int _actualPage = 0;

  final _sincronizer = Semaphore();
  late final StreamController<int> notifyChangeScreenController;
  late final StreamController notifyDisposeController;

  @override
  int get numberOfScreens => children.length;

  @override
  int get actualPage => _actualPage;

  @override
  void initState() {
    super.initState();

    notifyChangeScreenController = createEventController<int>(isBroadcast: true);
    notifyDisposeController = createEventController(isBroadcast: true);

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
        return Container(
          constraints: BoxConstraints(
            maxHeight: constraints.maxHeight,
            maxWidth: constraints.maxWidth,
          ),
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

    checkProgrammingFailure(thatChecks: const Oration(message: 'Must be built before'), result: () => wasBuilt);
    checkProgrammingFailure(thatChecks: const Oration(message: 'Single stacked screen  is still active'), result: () => mounted);

    _sincronizer.execute(function: () => _pushScreen(newWidget: newWidget, curve: curve, duration: duration));
  }

  Future<void> _pushScreen({required Widget newWidget, Duration? duration, Curve? curve}) async {
    final completerVisible = Completer<LegacyMaxiAnimatedVisibleState>();
    final completerPosition = Completer<LegacyMaxiAnimatedPositionedState>();
    final completerOpacity = Completer<LegacyMaxiAnimatedOpacityState>();

    final newScreen = LegacyMaxiAnimatedWidget(
      animators: [
        LegacyMaxiAnimatedVisible(
          onCreated: (x) => completerVisible.complete(x),
        ),
        LegacyMaxiAnimatedOpacity(
          duration: duration ?? widget.duration,
          onCreated: (x) => completerOpacity.complete(x),
        ),
        LegacyMaxiAnimatedPositioned(
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
    _actualPage += 1;

    notifyChangeScreenController.addIfActive(children.length);
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

    checkProgrammingFailure(thatChecks: const Oration(message: 'Single stacked screen  is still active'), result: () => mounted);
    checkProgrammingFailure(thatChecks: const Oration(message: 'Must be built before'), result: () => wasBuilt);

    _actualPage -= 1;
    notifyChangeScreenController.addIfActive(children.length - 1);

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
    checkProgrammingFailure(thatChecks: const Oration(message: 'Must be built before'), result: () => wasBuilt);
    checkProgrammingFailure(thatChecks: const Oration(message: 'Single stacked screen  is still active'), result: () => mounted);
    _sincronizer.execute(function: () {
      _actualPage = 0;
      if (children.isEmpty) {
        return _pushScreen(newWidget: newWidget, curve: curve, duration: duration);
      } else {
        return _resetScreen(newWidget: newWidget, curve: curve, duration: duration);
      }
    });
  }

  @override
  void dispose() {
    notifyDisposeController.addIfActive(null);
    super.dispose();
  }

  Future<void> _resetScreen({required Widget newWidget, Duration? duration, Curve? curve}) async {
    await opacity.last.changeOpacity(opacity: 0, duration: Duration(milliseconds: (duration ?? widget.duration).inMilliseconds ~/ 5));

    children.clear();
    opacity.clear();
    positioners.clear();
    visibles.clear();

    notifyChangeScreenController.addIfActive(0);

    setState(() {});

    await Future.delayed(Duration.zero);
    await Future.delayed(Duration.zero);
    await Future.delayed(Duration.zero);

    await _pushScreen(newWidget: newWidget, duration: duration, curve: curve);
  }
}
