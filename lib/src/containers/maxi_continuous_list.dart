import 'dart:async';

import 'package:flutter/material.dart';
import 'package:maxi_flutter_library/maxi_flutter_library.dart';
import 'package:maxi_library/maxi_library.dart';

class MaxiContinuousList<T> extends StatefulWidget with IMaxiAnimatorWidget {
  final FutureOr<List<Stream<bool>>> Function()? reloaders;
  final FutureOr<List<Stream>> Function()? valueUpdaters;
  final int Function(T) gettetIdentifier;
  final FutureOr<List<T>> Function(int from) valueGetter;
  final Widget Function(BuildContext cont, T item, int ind) childGenerator;
  final Widget Function(BuildContext)? emptyGenerator;
  final bool Function()? ascendant;
  final Duration waitingReupdated;
  final Duration animationDuration;
  final Curve animationCurve;
  final void Function(MaxiContinuousListOperator<T>)? onCreatedOperator;

  @override
  final IMaxiAnimatorManager? animatorManager;

  const MaxiContinuousList({
    super.key,
    required this.valueGetter,
    required this.childGenerator,
    required this.gettetIdentifier,
    this.reloaders,
    this.valueUpdaters,
    this.emptyGenerator,
    this.ascendant,
    this.waitingReupdated = const Duration(seconds: 1),
    this.animationDuration = const Duration(milliseconds: 500),
    this.animationCurve = Curves.decelerate,
    this.onCreatedOperator,
    this.animatorManager,
  });

  @override
  State<MaxiContinuousList<T>> createState() => _MaxiContinuousListState<T>();
}

mixin MaxiContinuousListOperator<T> on IMaxiUpdatebleValueState {
  List<T> get content;
  bool get ascendant;
  bool get isLoading;
  Stream<MaxiContinuousListOperator<T>> get onValueUpdate;
  set ascendant(bool value);
}

class _MaxiContinuousListState<T> extends StateWithLifeCycle<MaxiContinuousList<T>> with StartableState<void>, MaxiContinuousListOperator<T>, IMaxiAnimatorState {
  @override
  final content = <T>[];

  late ScrollController scrollController;
  late StreamController<MaxiContinuousListOperator<T>> onValueUpdateControler;

  NegativeResult? lastError;

  @override
  bool isLoading = false;
  int lastID = 0;

  late bool _ascendant;

  @override
  Duration? get waitingReupdated => widget.waitingReupdated;
  @override
  Duration get duration => widget.animationDuration;
  @override
  Curve get curve => widget.animationCurve;
  @override
  Stream<MaxiContinuousListOperator<T>> get onValueUpdate => onValueUpdateControler.stream;

  @override
  bool get ascendant => _ascendant;

  @override
  void initState() {
    super.initState();

    _ascendant = widget.ascendant == null ? true : widget.ascendant!();

    scrollController = ScrollController();
    scrollController.addListener(onScroll);

    onValueUpdateControler = createEventController(isBroadcast: true);

    if (widget.reloaders != null) {
      maxiScheduleMicrotask(() async {
        final reloaders = await widget.reloaders!();
        for (final item in reloaders) {
          joinEvent<bool>(event: item, onData: _reload);
        }
      });
    }

    if (widget.valueUpdaters != null) {
      maxiScheduleMicrotask(() async {
        final valueUpdaters = await widget.valueUpdaters!();
        for (final item in valueUpdaters) {
          joinEvent(event: item, onData: _updateValues);
        }
      });
    }

    if (widget.onCreatedOperator != null) {
      widget.onCreatedOperator!(this);
    }

    initializeAnimator();
  }

  void _reload(bool x) {
    reloadWidgets(changeState: x);
  }

  void _updateValues(_) {
    updateValue();
  }

  @override
  void updateValue() {
    content.clear();
    super.updateValue();
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
  }

  @override
  Future<void> initializedAsynchronous() async {
    _ascendant = widget.ascendant == null ? true : widget.ascendant!();
    lastID = 0;
    lastError = null;
    content.clear();

    onValueUpdateControler.addIfActive(this);

    scrollController.dispose();
    scrollController = ScrollController();
    scrollController.addListener(onScroll);

    List<T> result = await widget.valueGetter(0);

    if (result.isNotEmpty) {
      if (_ascendant) {
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
      if (!_ascendant && lastID - 1 == 0) {
        lastResult = [];
      } else {
        lastResult = await widget.valueGetter(_ascendant ? lastID + 1 : lastID - 1);
      }
    } catch (ex) {
      lastError = NegativeResult.searchNegativity(item: ex, actionDescription: Oration(message: 'Getting values from %1', textParts: [lastID]));
      isLoading = false;
      reloadWidgets(changeState: false);
      return;
    }

    if (lastResult.isNotEmpty) {
      if (_ascendant) {
        lastResult = lastResult.orderByFunction((x) => widget.gettetIdentifier(x));
      } else {
        lastResult = lastResult.orderByFunction((x) => widget.gettetIdentifier(x)).reversed.toList();
      }

      lastID = widget.gettetIdentifier(lastResult.last);

      content.addAll(lastResult);
    }

    isLoading = false;
    reloadWidgets(changeState: false); //<<--- Ver si los listados se continuan bugueando
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

  @override
  set ascendant(bool newValue) {
    if (newValue != _ascendant) {
      _ascendant = newValue;
      updateValue();
    }
  }
}
