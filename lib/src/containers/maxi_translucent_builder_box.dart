import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:maxi_flutter_library/maxi_flutter_library.dart';

class MaxiTranslucentBuildBox extends StatefulWidget with IMaxiAnimatorWidget {
  final FutureOr<List<Stream>> Function()? reloaders;
  final bool changeIfStreamReturnWidget;
  final Widget Function(BuildContext) builer;
  final void Function(IMaxiTranslucentBuildBoxOperator)? onCreatedOperator;

  final Duration duration;
  final Curve curve;

  @override
  final IMaxiAnimatorManager? animatorManager;

  const MaxiTranslucentBuildBox({
    super.key,
    required this.reloaders,
    required this.builer,
    this.changeIfStreamReturnWidget = true,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.decelerate,
    this.onCreatedOperator,
    this.animatorManager,
  });

  @override
  State<MaxiTranslucentBuildBox> createState() => _MaxiBuildWidgetState();
}

mixin IMaxiTranslucentBuildBoxOperator on IMaxiUpdatebleValueState {
  void reloadWidget(bool changeStateWidget);
  Future<void> changeScreen({required Widget newChild, Duration? duration, Curve? curve});
}

class _MaxiBuildWidgetState extends StateWithLifeCycle<MaxiTranslucentBuildBox> with IMaxiUpdatebleValueState, IMaxiTranslucentBuildBoxOperator, IMaxiAnimatorState<MaxiTranslucentBuildBox> {
  int stateNumber = 0;
  ISingleStackScreenOperator? screenOperator;

  @override
  void initState() {
    super.initState();
    if (widget.reloaders != null) {
      getReloadWidgets();
    }

    if (widget.onCreatedOperator != null) {
      widget.onCreatedOperator!(this);
    }

    initializeAnimator();
  }

  Future<void> getReloadWidgets() async {
    final list = await widget.reloaders!();

    for (final item in list) {
      joinEvent(event: item, onData: reloadWidget);
    }
  }

  @override
  void reloadWidget(dynamic value) {
    if (mounted) {
      if (widget.changeIfStreamReturnWidget && value is Widget) {
        screenOperator?.changeScreen(newChild: value);
      } else {
        screenOperator?.changeScreen(newChild: widget.builer(value));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleStackScreen(
      curve: widget.curve,
      duration: widget.duration,
      initialChildBuild: widget.builer,
      onCreatedOperator: (x) => screenOperator = x,
    );
  }

  @override
  void updateValue() => reloadWidget(true);

  @override
  Future<void> changeScreen({required Widget newChild, Duration? duration, Curve? curve}) async {
    return screenOperator?.changeScreen(newChild: newChild, duration: duration, curve: curve);
  }
}
