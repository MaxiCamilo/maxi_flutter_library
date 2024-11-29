import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:maxi_flutter_library/maxi_flutter_library.dart';

class MaxiBuildBox extends StatefulWidget {
  final FutureOr<List<Stream>> Function() reloaders;
  final bool cached;
  final Widget Function(BuildContext) builer;

  const MaxiBuildBox({super.key, required this.reloaders, required this.cached, required this.builer});

  @override
  State<MaxiBuildBox> createState() => _MaxiBuildWidgetState();
}

class _MaxiBuildWidgetState extends StateWithLifeCycle<MaxiBuildBox> {
  Widget? savedItem;

  @override
  void initState() {
    super.initState();
    getReloadWidgets();
  }

  Future<void> getReloadWidgets() async {
    final list = await widget.reloaders();

    for (final item in list) {
      joinEvent(
          event: item,
          onData: (_) {
            if (mounted) {
              savedItem = null;
              setState(() {});
            }
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.cached) {
      savedItem ??= widget.builer(context);
      return savedItem!;
    } else {
      return widget.builer(context);
    }
  }
}
