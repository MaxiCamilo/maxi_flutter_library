import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:maxi_flutter_library/maxi_flutter_library.dart';

class MaxiBuildBox extends StatefulWidget {
  final List<Stream<bool>> Function() reloaders;
  final bool cached;
  final Widget Function(BuildContext) builer;

  const MaxiBuildBox({
    super.key,
    required this.reloaders,
    required this.cached,
    required this.builer,
  });

  @override
  State<MaxiBuildBox> createState() => _MaxiBuildWidgetState();
}

class _MaxiBuildWidgetState extends StateWithLifeCycle<MaxiBuildBox> {
  int stateNumber = 0;
  Widget? savedItem;

  @override
  void initState() {
    super.initState();
    getReloadWidgets();
  }

  void getReloadWidgets() {
    final list = widget.reloaders();

    for (final item in list) {
      joinEvent(
          event: item,
          onData: (x) {
            if (mounted) {
              if (x) {
                stateNumber += 1;
              }

              savedItem = null;
              setState(() {});
            }
          });
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
}
