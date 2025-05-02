import 'dart:async';

import 'package:flutter/material.dart';
import 'package:maxi_flutter_library/maxi_flutter_library.dart';
import 'package:maxi_flutter_library/src/animation/legacy/legacy_maxi_widget_animator.dart';
import 'package:maxi_library/maxi_library.dart';

class LegacyMaxiAnimatedWidget extends StatefulWidget {
  final List<LegacyMaxiWidgetAnimator> animators;
  final bool isFixedAnimatorsList;
  final Widget child;

  const LegacyMaxiAnimatedWidget({
    super.key,
    required this.animators,
    required this.child,
    this.isFixedAnimatorsList = true,
  });

  @override
  State<LegacyMaxiAnimatedWidget> createState() => _LegacyMaxiAnimatedWidgetAnimatedWidgetState();
}

class _LegacyMaxiAnimatedWidgetAnimatedWidgetState extends State<LegacyMaxiAnimatedWidget> {
  List<LegacyMaxiWidgetAnimator>? _lastAnimations;

  Widget _buildFixed(BuildContext context) {
    Widget result = widget.child;

    for (final animator in widget.animators) {
      result = animator.build(context: context, child: result);
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isFixedAnimatorsList) {
      return _buildFixed(context);
    }

    if (_isDiferentList()) {
      _lastAnimations = widget.animators.toList(growable: false);
      maxiScheduleMicrotask(() => setState(() {}));
      return const SizedBox();
    }

    _lastAnimations = widget.animators.toList(growable: false);

    Widget result = widget.child;

    for (final animator in _lastAnimations!) {
      result = animator.build(context: context, child: result);
    }

    return result;
  }

  bool _isDiferentList() {
    if (_lastAnimations == null) {
      return false;
    }

    if (_lastAnimations!.length != widget.animators.length) {
      return true;
    }

    for (int i = 0; i < widget.animators.length; i++) {
      if (widget.animators[i] != _lastAnimations![i]) {
        return true;
      }
    }

    return false;
  }
}
