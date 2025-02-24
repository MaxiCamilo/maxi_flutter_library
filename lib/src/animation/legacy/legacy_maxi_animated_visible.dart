import 'dart:async';
import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:maxi_flutter_library/maxi_flutter_library.dart';
import 'package:maxi_library/maxi_library.dart';

class LegacyMaxiAnimatedVisible with LegacyMaxiWidgetAnimator {
  final bool visible;
  final bool maintainState;

  final void Function(LegacyMaxiAnimatedVisibleState)? onCreated;

  const LegacyMaxiAnimatedVisible({
    this.visible = true,
    this.maintainState = true,
    this.onCreated,
  });

  @override
  Widget build({required BuildContext context, required Widget child}) {
    return _LegacyMaxiAnimatedVisibleWidget(
      maintainState: maintainState,
      visible: visible,
      onCreated: onCreated,
      child: child,
    );
  }
}

abstract class LegacyMaxiAnimatedVisibleState extends State<_LegacyMaxiAnimatedVisibleWidget> {
  Future<void> changeVisibility({required bool visibility, required bool animated, Duration? duration, Curve? curve, bool sincronized = false});
}

class _LegacyMaxiAnimatedVisibleWidget extends StatefulWidget {
  final bool visible;
  final bool maintainState;
  final Widget child;
  final void Function(LegacyMaxiAnimatedVisibleState)? onCreated;

  const _LegacyMaxiAnimatedVisibleWidget({
    required this.visible,
    required this.maintainState,
    required this.child,
    required this.onCreated,
  });

  @override
  State<StatefulWidget> createState() => _LegacyMaxiAnimatedVisibleState();
}

class _LegacyMaxiAnimatedVisibleState extends LegacyMaxiAnimatedVisibleState {
  late bool visible;
  late bool maintainState;

  bool _obtainedOpacity = false;
  LegacyMaxiAnimatedOpacityState? _animatedOpacity;

  Semaphore? _sincronizer;

  @override
  void initState() {
    super.initState();
    visible = widget.visible;
    maintainState = widget.maintainState;

    if (widget.onCreated != null) {
      widget.onCreated!(this);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_obtainedOpacity) {
      _obtainedOpacity = true;
      _animatedOpacity = LegacyMaxiWidgetAnimator.getAnimatorByAncestorOptional<LegacyMaxiAnimatedOpacityState>(context);
    }

    if (widget.maintainState) {
      return Offstage(
        offstage: !visible,
        child: widget.child,
      );
    } else {
      return visible ? widget.child : const SizedBox();
    }
/*
    return Visibility(
      visible: visible,
      maintainState: maintainState,
      child: widget.child,
    );*/
  }

  @override
  Future<void> changeVisibility({required bool visibility, required bool animated, Duration? duration, Curve? curve, bool sincronized = false}) async {
    if (sincronized) {
      _sincronizer ??= Semaphore();
      _sincronizer!.execute(function: () => changeVisibility(animated: animated, visibility: visibility, curve: curve, duration: duration, sincronized: false));
      return;
    }

    if (visible == visibility) {
      return;
    }

    if (animated && _animatedOpacity != null) {
      if (visible) {
        await _animatedOpacity!.changeOpacity(opacity: 0, duration: duration, curve: curve);
        visible = visibility;
        if (mounted) {
          setState(() {});
        }
      } else {
        visible = visibility;
        if (mounted) {
          setState(() {});
          await Future.delayed(Duration.zero);
          await _animatedOpacity!.changeOpacity(opacity: 1, duration: duration, curve: curve);
        }
      }

      return;
    } else if (animated) {
      log('[LegacyMaxiAnimatedVisible] The widget must first have an opacity animator to be able to animate the opacity');
    }

    visible = visibility;

    if (mounted) {
      setState(() {});
    }
  }
}
