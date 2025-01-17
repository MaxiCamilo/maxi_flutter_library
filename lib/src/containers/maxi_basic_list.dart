import 'dart:async';

import 'package:flutter/material.dart';
import 'package:maxi_flutter_library/maxi_flutter_library.dart';
import 'package:maxi_library/maxi_library.dart';

class MaxiBasicList<T> extends StatefulWidget {
  final FutureOr<List<Stream<bool>>> Function()? reloaders;
  final FutureOr<List<Stream>> Function()? valueUpdaters;
  final FutureOr<List<T>> Function() valueGetter;
  final Widget Function(BuildContext cont, T item, int ind) childGenerator;
  final Widget Function(BuildContext, List<Widget>)? listGenerator;
  final Widget Function(BuildContext)? emptyGenerator;

  const MaxiBasicList({
    required this.valueGetter,
    required this.childGenerator,
    super.key,
    this.reloaders,
    this.valueUpdaters,
    this.listGenerator,
    this.emptyGenerator,
  });

  @override
  State<MaxiBasicList> createState() => _MaxiBasicListState<T>();
}

class _MaxiBasicListState<T> extends StateWithLifeCycle<MaxiBasicList<T>> with StartableState<List<T>> {
  @override
  void initState() {
    super.initState();

    if (widget.reloaders != null) {
      scheduleMicrotask(() async {
        final reloaders = await widget.reloaders!();
        for (final item in reloaders) {
          joinEvent(event: item, onData: _reload);
        }
      });
    }

    if (widget.valueUpdaters != null) {
      scheduleMicrotask(() async {
        final valueUpdaters = await widget.valueUpdaters!();
        for (final item in valueUpdaters) {
          joinEvent(event: item, onData: _updateValues);
        }
      });
    }
  }

  void _reload(bool x) {
    reloadWidgets(changeState: x);
  }

  void _updateValues(_) {
    updateValue();
  }

  @override
  Future<List<T>> initializedAsynchronous() async {
    return await widget.valueGetter();
  }

  @override
  Widget buildAfterInitialized(BuildContext context, List<T> lista) {
    if (lista.isEmpty && widget.emptyGenerator != null) {
      return widget.emptyGenerator!(context);
    }

    if (widget.listGenerator != null) {
      return widget.listGenerator!(context, lista.mapWithPosition((x, i) => widget.childGenerator(context, x, i)).toList(growable: false));
    }

    return Flex(
      direction: Axis.vertical,
      mainAxisSize: MainAxisSize.min,
      children: lista.mapWithPosition((x, i) => widget.childGenerator(context, x, i)).toList(growable: false),
    );
  }
}
