import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:maxi_flutter_library/maxi_flutter_library.dart';

class MaxiBuildBox extends StatefulWidget with IMaxiAnimatorWidget {
  final FutureOr<List<Stream<bool>>> Function()? reloaders;
  final bool cached;
  final Widget Function(BuildContext) builer;
  final void Function(IMaxiBuildBoxOperator)? onCreatedOperator;

  @override
  final IMaxiAnimatorManager? animatorManager;

  const MaxiBuildBox({
    super.key,
    this.reloaders,
    required this.cached,
    required this.builer,
    this.animatorManager,
    this.onCreatedOperator,
  });

  @override
  State<MaxiBuildBox> createState() => _MaxiBuildWidgetState();
}

mixin IMaxiBuildBoxOperator on IMaxiUpdatebleValueState {
  void reloadWidget(bool changeStateWidget);
}

class _MaxiBuildWidgetState extends StateWithLifeCycle<MaxiBuildBox> with IMaxiUpdatebleValueState, IMaxiBuildBoxOperator, IMaxiAnimatorState<MaxiBuildBox> {
  int stateNumber = 0;
  Widget? savedItem;

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
  void reloadWidget(bool changeStateWidget) {
    if (mounted) {
      if (changeStateWidget) {
        stateNumber += 1;
      }

      savedItem = null;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    late final Widget child;
    if (widget.cached) {
      savedItem ??= widget.builer(context);
      child = savedItem!;
    } else {
      child = widget.builer(context);
    }

    return SizedBox(
      key: ValueKey(stateNumber),
      child: child,
    );
  }

  @override
  void updateValue() => reloadWidget(true);
}
