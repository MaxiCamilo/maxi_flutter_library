import 'dart:async';

import 'package:flutter/material.dart';
import 'package:maxi_flutter_library/maxi_flutter_library.dart';
import 'package:maxi_library/maxi_library.dart';

class MaxiContinuousList<T> extends StatefulWidget {
  final FutureOr<List<Stream>> Function()? reloaders;
  final FutureOr<List<Stream>> Function()? valueUpdaters;
  final int Function(T) gettetIdentifier;
  final FutureOr<List<T>> Function(int from) valueGetter;
  final Widget Function(BuildContext cont, T item, int ind) childGenerator;
  final Widget Function(BuildContext, List<Widget>)? listGenerator;
  final Widget Function(BuildContext)? emptyGenerator;
  final bool ascendant;

  const MaxiContinuousList({
    super.key,
    required this.valueGetter,
    required this.childGenerator,
    required this.gettetIdentifier,
    this.reloaders,
    this.valueUpdaters,
    this.listGenerator,
    this.emptyGenerator,
    this.ascendant = true,
  });

  @override
  State<MaxiContinuousList<T>> createState() => _MaxiContinuousListState<T>();
}

class _MaxiContinuousListState<T> extends StateWithLifeCycle<MaxiContinuousList<T>> with StartableState<MaxiBasicList<T>, void> {
  final content = <T>[];

  late ScrollController scrollController;

  NegativeResult? lastError;

  bool isLoading = false;
  int lastID = 0;

  @override
  void initState() {
    super.initState();

    scrollController = ScrollController();
    scrollController.addListener(onScroll);

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

  void _reload(_) {
    reloadWidgets();
  }

  void _updateValues(_) {
    content.clear();
    updateValue();
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
  }

  @override
  Future<void> initializedAsynchronous() async {
    lastID = 0;
    lastError = null;
    content.clear();

    scrollController.dispose();
    scrollController = ScrollController();
    scrollController.addListener(onScroll);

    List<T> result = await widget.valueGetter(0);

    if (result.isNotEmpty) {
      if (widget.ascendant) {
        result = result.orderByFunction((x) => widget.gettetIdentifier(x));
      } else {
        result = result.orderByFunction((x) => widget.gettetIdentifier(x)).reversed.toList();
      }

      lastID = widget.gettetIdentifier(result.last);
      /*
      if (widget.ascendant) {
        lastID = content.map((x) => widget.gettetIdentifier(x)).maximumOfIdentifier((x) => x);
      } else {
        lastID = content.map((x) => widget.gettetIdentifier(x)).minimumOfIdentifier((x) => x);
      }
      */
      content.addAll(result);
    }
  }

  void onScroll() {
    if (scrollController.position.pixels >= scrollController.position.maxScrollExtent && !isLoading) {
      loadMoreItems();
    }
  }

  Future<void> loadMoreItems() async {
    lastError = null;
    setState(() {
      isLoading = true;
    });

    late List<T> lastResult;

    try {
      if (!widget.ascendant && lastID - 1 == 0) {
        lastResult = [];
      } else {
        lastResult = await widget.valueGetter(widget.ascendant ? lastID + 1 : lastID - 1);
      }
    } catch (ex) {
      lastError = NegativeResult.searchNegativity(item: ex, actionDescription: tr('Getting values from %1', [lastID]));
      isLoading = false;
      reloadWidgets();
      return;
    }

    if (lastResult.isNotEmpty) {
      if (widget.ascendant) {
        lastResult = lastResult.orderByFunction((x) => widget.gettetIdentifier(x));
      } else {
        lastResult = lastResult.orderByFunction((x) => widget.gettetIdentifier(x)).reversed.toList();
      }

      lastID = widget.gettetIdentifier(lastResult.last);

      content.addAll(lastResult);
    }

    isLoading = false;
    reloadWidgets();
  }

  @override
  Widget buildAfterInitialized(BuildContext context, _) {
    if (content.isEmpty) {
      if (widget.emptyGenerator == null) {
        return const SizedBox();
      } else {
        return widget.emptyGenerator!(context);
      }
    }
//widget.childGenerator(context, content[index], index)
    return Scrollbar(
      controller: scrollController,
      thumbVisibility: true,
      child: ListView.builder(
        controller: scrollController,
        itemCount: content.length + 1,
        itemBuilder: (context, index) {
          if (index < content.length) {
            return widget.childGenerator(context, content[index], index);
          } else {
            if (lastError == null) {
              return isLoading ? const Center(child: CircularProgressIndicator()) : const SizedBox(height: 20);
            } else {
              return ErrorLabelTemplate(message: lastError!.message);
            }
          }
        },
      ),
    );
  }
}
