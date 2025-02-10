import 'dart:async';

import 'package:flutter/material.dart';
import 'package:maxi_flutter_library/maxi_flutter_library.dart';
import 'package:maxi_library/maxi_library.dart';

class LoadingScreen<T> extends StatefulWidget {
  final bool startActive;

  final void Function(ILoadingScreenOperator<T>)? onCreatedOperator;
  final Future<T> Function() getterValue;
  final void Function(T)? onGetValue;
  final void Function()? onLoading;
  final void Function()? whenCompleted;
  final void Function(NegativeResult)? onError;
  final Widget Function(BuildContext context, T item) builder;

  final Widget loadingWidget;
  final Widget inactiveWidget;

  final FutureOr<List<Stream>> Function()? updateStreamList;
  final FutureOr<List<Stream<bool>>> Function()? reloadWidgets;
  final bool canRetry;
  final double iconSize;
  final double textSize;
  final Duration duration;
  final Curve curve;
  final Duration? waitingReupdated;

  const LoadingScreen({
    super.key,
    this.onCreatedOperator,
    required this.startActive,
    required this.getterValue,
    required this.builder,
    this.loadingWidget = const CircularProgressIndicator(),
    this.canRetry = true,
    this.iconSize = 42,
    this.textSize = 15,
    this.duration = const Duration(milliseconds: 500),
    this.reloadWidgets,
    this.curve = Curves.decelerate,
    this.inactiveWidget = const SizedBox(),
    this.updateStreamList,
    this.onGetValue,
    this.onLoading,
    this.onError,
    this.whenCompleted,
    this.waitingReupdated,
  });

  @override
  State<LoadingScreen<T>> createState() => _LoadingScreenState<T>();
}

mixin ILoadingScreenOperator<T> {
  bool get isActive;
  void updateValue();
  void reloadWidgets({required bool changeState});
  void cancel();
}

class _LoadingScreenState<T> extends StateWithLifeCycle<LoadingScreen<T>> with ILoadingScreenOperator<T> {
  @override
  bool get isActive => updaterSynchronizer.isActive;
  bool wasFailed = false;

  late String errorMessage;
  late T item;

  late final QueuingSemaphore updaterSynchronizer;
  ISingleStackScreenOperator? singleStackScreenOperator;

  Completer<T>? waitingForCancellation;

  //final executor = Semaphore();

  late final StreamController<bool> _reloader;

  @override
  void initState() {
    super.initState();

    updaterSynchronizer = QueuingSemaphore(reservedFunction: _getValue);

    _reloader = createEventController<bool>(isBroadcast: true);

    if (widget.updateStreamList != null) {
      getUpdateStream();
    }

    if (widget.startActive) {
      updaterSynchronizer.execute();
    }

    if (widget.onCreatedOperator != null) {
      widget.onCreatedOperator!(this);
    }
  }

  Future<void> getUpdateStream() async {
    final list = await widget.updateStreamList!();

    for (final item in list) {
      joinEvent(event: item, onData: (_) => updateValue());
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleStackScreen(
      curve: widget.curve,
      duration: widget.duration,
      initialChildBuild: (p0) => widget.inactiveWidget,
      onCreatedOperator: _onCreatedOperator,
    );
  }

  @override
  void updateValue() async {
    if (widget.waitingReupdated == null || !isActive) {
      updaterSynchronizer.reExecute();
    } else {
      await Future.delayed(widget.waitingReupdated!);
      updaterSynchronizer.executeIfNotActive();
    }
  }

  @override
  void reloadWidgets({required bool changeState}) {
    if (mounted) {
      _reloader.add(changeState);
    }
  }

  Future<void> _getValue() async {
    wasFailed = false;
    await continueOtherFutures();

    if (singleStackScreenOperator == null) {
      await continueOtherFutures();
    }

    programmingFailure(reasonFailure: const Oration(message: 'The screen operator has not yet been defined'), function: () => singleStackScreenOperator != null);

    await singleStackScreenOperator!.waitForConstruction();

    singleStackScreenOperator!.changeScreen(newChild: widget.loadingWidget);

    // singleStackScreenOperator.changeScreen(newChild: widget.loadingWidget);

    await continueOtherFutures();
    late Future<T> getterPromise;

    try {
      waitingForCancellation = Completer<T>();
      getterPromise = widget.getterValue();

      item = await Future.any([getterPromise, waitingForCancellation!.future]);

      waitingForCancellation?.completeIfIncomplete(item);
      getterPromise.ignore();

      waitingForCancellation = null;
      if (mounted) {
        if (widget.reloadWidgets == null) {
          singleStackScreenOperator!.changeScreen(
            newChild: MaxiAsyncBuildBox(
              reloaders: () => [_reloader.stream],
              cached: false,
              builer: (x) => widget.builder(x, item),
            ),
          );
        } else {
          singleStackScreenOperator!.changeScreen(
            newChild: MaxiAsyncBuildBox(
              reloaders: () async => [_reloader.stream, ...await widget.reloadWidgets!()],
              cached: false,
              builer: (x) => widget.builder(x, item),
            ),
          );
        }
        if (widget.onGetValue != null) {
          widget.onGetValue!(item);
        }

        if (widget.whenCompleted != null) {
          widget.whenCompleted!();
        }
      }
    } catch (ex) {
      waitingForCancellation?.completeErrorIfIncomplete(ex);
      getterPromise.ignore();

      final error = NegativeResult.searchNegativity(item: ex, actionDescription: const Oration(message: 'Getting value to widget'));
      errorMessage = error.message.toString();
      wasFailed = true;

      if (mounted) {
        singleStackScreenOperator!.changeScreen(newChild: _createErrorWidget(context));

        if (widget.onError != null) {
          widget.onError!(error);
        }

        if (widget.whenCompleted != null) {
          widget.whenCompleted!();
        }
      }
    }
  }

  Widget _createErrorWidget(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color.fromARGB(255, 90, 90, 90), // Color del borde
          width: 1.0,
          // Grosor del borde
        ),
        borderRadius: BorderRadius.circular(5.0),
      ),
      padding: const EdgeInsets.all(8.0),
      margin: const EdgeInsets.all(2.0),
      child: Flex(
        direction: Axis.vertical,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Flex(
            direction: Axis.horizontal,
            mainAxisSize: MainAxisSize.max,
            children: [
              Icon(
                Icons.dangerous,
                color: Colors.red,
                size: widget.iconSize,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: MaxiText(
                  aling: TextAlign.center,
                  text: errorMessage,
                  size: widget.textSize,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          MaxiTransparentButton(
            text: const Oration(message: 'Retry'),
            icon: const Icon(Icons.replay_outlined),
            onTouch: updateValue,
          ),
        ],
      ),
    );
  }

  void _onCreatedOperator(ISingleStackScreenOperator newOperator) {
    singleStackScreenOperator = newOperator;
    //singleStackScreenOperator!.changeScreen(newChild: widget.loadingWidget);
  }

  @override
  void cancel() {
    waitingForCancellation?.completeErrorIfIncomplete(
      NegativeResult(
        identifier: NegativeResultCodes.functionalityCancelled,
        message: const Oration(message: 'The functionality was canceled'),
      ),
    );

    waitingForCancellation = null;
  }
}
