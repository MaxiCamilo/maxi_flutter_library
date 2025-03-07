import 'dart:async';

import 'package:flutter/material.dart';
import 'package:maxi_flutter_library/maxi_flutter_library.dart';
import 'package:maxi_library/maxi_library.dart';

class MaxiStreamBox<T> extends StatefulWidget {
  final FutureOr<List<Stream<T>>> Function() streams;
  final T Function() initialValueGetter;
  final bool cached;
  final Widget Function(BuildContext, T) builder;
  final Widget Function(BuildContext, dynamic)? builderError;

  const MaxiStreamBox({
    super.key,
    required this.cached,
    required this.initialValueGetter,
    required this.streams,
    required this.builder,
    this.builderError,
  });

  @override
  State<MaxiStreamBox<T>> createState() => _MaxiStreamBoxState<T>();
}

class _MaxiStreamBoxState<T> extends StateWithLifeCycle<MaxiStreamBox<T>> {
  late T actualValue;
  late final StreamController<bool> reloaderControll;

  bool isError = false;
  dynamic lastError;

  @override
  void initState() {
    super.initState();

    actualValue = widget.initialValueGetter();
    reloaderControll = createEventController(isBroadcast: true);

    getReloadWidgets();
  }

  Future<void> getReloadWidgets() async {
    final list = await widget.streams();

    for (final item in list) {
      joinEvent(
          event: item,
          onData: (x) {
            actualValue = x;
            lastError = null;
            bool wasError = isError;
            isError = false;
            reloaderControll.addIfActive(wasError || widget.cached);
          },
          onError: (x, _) {
            lastError = x;
            isError = true;
            reloaderControll.addIfActive(true);
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaxiBuildBox(
      cached: widget.cached,
      reloaders: () => [reloaderControll.stream],
      builer: (x) {
        if (isError) {
          if (widget.builderError == null) {
            return ErrorLabelTemplate(message: NegativeResult.searchNegativity(item: lastError, actionDescription: const Oration(message: 'Stream error')).message);
          } else {
            return widget.builderError!(x, lastError);
          }
        } else {
          /*
          if (isError) {
            log('[MaxiSTreamBox] There is no Error widget builder, and an error was received');
          }*/
          return widget.builder(x, actualValue);
        }
      },
    );
  }
}
