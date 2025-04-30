import 'dart:async';

import 'package:flutter/material.dart';
import 'package:maxi_flutter_library/maxi_flutter_library.dart';
import 'package:maxi_library/maxi_library.dart';

class MaxiVerticalCollapsor extends StatefulWidget with IMaxiAnimatorWidget {
  final bool startsOpen;
  final Widget Function(BuildContext) makeChild;
  final Duration duration;
  final Curve curveHide;
  final Curve curveSize;

  final FutureOr<List<Stream<bool>>> Function()? modifiers;
  final void Function(IMaxiVerticalCollapsorOperator)? onCreatedOperator;
  final void Function(bool)? onChangedStatus;
  final void Function()? onShow;
  final void Function()? onHide;

  @override
  final IMaxiAnimatorManager? animatorManager;

  const MaxiVerticalCollapsor({
    super.key,
    required this.makeChild,
    this.startsOpen = true,
    this.duration = const Duration(milliseconds: 300),
    this.curveHide = Curves.easeInOut,
    this.curveSize = Curves.easeInOut,
    this.modifiers,
    this.onCreatedOperator,
    this.onChangedStatus,
    this.onHide,
    this.onShow,
    this.animatorManager,
  });

  @override
  State<MaxiVerticalCollapsor> createState() => _MaxiVerticalCollapsorState();
}

mixin IMaxiVerticalCollapsorOperator {
  bool get isOpen;
  Stream<bool> get statusChange;

  Future<void> get waitForWidgetToDisplay;

  void changeState(bool newStatus);

  void updateState();

  void investStatus() {
    changeState(!isOpen);
  }

  void show() {
    if (!isOpen) {
      investStatus();
    } else {
      updateState();
    }
  }

  void hide() {
    if (isOpen) {
      investStatus();
    }
  }
}

class _MaxiVerticalCollapsorState extends StateWithLifeCycle<MaxiVerticalCollapsor> with IMaxiVerticalCollapsorOperator, IMaxiAnimatorState<MaxiVerticalCollapsor> {
  late bool currentStatus;
  late bool showChild;

  bool theShowAnimationEnded = false;

  Completer? _waitForWidgetToDisplay;

  StreamController<bool>? statusChangeController;

  @override
  Stream<bool> get statusChange {
    statusChangeController ??= StreamController<bool>.broadcast();
    return statusChangeController!.stream;
  }

  @override
  bool get isOpen => currentStatus;

  @override
  Future<void> get waitForWidgetToDisplay async {
    if (theShowAnimationEnded) {
      return;
    }

    _waitForWidgetToDisplay ??= MaxiCompleter();
    return _waitForWidgetToDisplay!.future;
  }

  @override
  void updateState() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();

    currentStatus = widget.startsOpen;
    showChild = widget.startsOpen;

    if (showChild) {
      theShowAnimationEnded = true;
    }

    if (widget.modifiers != null) {
      scheduleMicrotask(() => _hookModifierEvents());
    }

    initializeAnimator();

    if (widget.onCreatedOperator != null) {
      widget.onCreatedOperator!(this);
    }
  }

  Future<void> _hookModifierEvents() async {
    final events = await widget.modifiers!();
    for (final eve in events) {
      joinEvent(event: eve, onData: changeState);
    }
  }

  @override
  void changeState(bool newStatus) {
    if (mounted && newStatus != currentStatus) {
      if (!currentStatus && !showChild) {
        showChild = true;
      }
      currentStatus = newStatus;
      if (!newStatus) {
        theShowAnimationEnded = false;
      }

      setState(() {});

      if (newStatus && widget.onShow != null) {
        widget.onShow!();
      }

      if (!newStatus && widget.onHide != null) {
        widget.onHide!();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: AnimatedAlign(
        duration: widget.duration,
        curve: widget.curveHide,
        alignment: currentStatus ? Alignment.topCenter : Alignment.bottomCenter,
        heightFactor: currentStatus ? 1.0 : 0.0,
        onEnd: _onAnimationEnd,
        child: AnimatedSize(
          duration: widget.duration,
          curve: widget.curveSize,
          child: showChild ? widget.makeChild(context) : const SizedBox.shrink(),
        ),
      ),
    );
  }

  void _onAnimationEnd() {
    if (currentStatus) {
      theShowAnimationEnded = true;
      _waitForWidgetToDisplay?.complete();
      _waitForWidgetToDisplay = null;
    }

    if (widget.onChangedStatus != null) {
      widget.onChangedStatus!(currentStatus);
    }

    if (!currentStatus && showChild) {
      showChild = false;
      if (mounted) {
        setState(() {});
      }
    }

    statusChangeController?.add(currentStatus);
  }
}
