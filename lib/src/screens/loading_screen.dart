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
  final FutureOr<List<Stream>> Function()? reloadWidgets;
  final bool canRetry;
  final double iconSize;
  final double textSize;
  final Duration duration;
  final Curve curve;

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
  });

  @override
  State<LoadingScreen<T>> createState() => _LoadingScreenState<T>();
}

mixin ILoadingScreenOperator<T> {
  bool get isActive;
  void updateValue();
  void reloadWidgets();
}

class _LoadingScreenState<T> extends StateWithLifeCycle<LoadingScreen<T>> with ILoadingScreenOperator<T> {
  @override
  bool isActive = true;
  bool wasFailed = false;

  late String errorMessage;
  late T item;
  late ISingleStackScreenOperator singleStackScreenOperator;

  final executor = Semaphore();

  late final StreamController _reloader;

  @override
  void initState() {
    super.initState();

    _reloader = createEventController(isBroadcast: true);

    if (widget.updateStreamList != null) {
      getUpdateStream();
    }

    if (widget.startActive) {
      executor.execute(function: _getValue);
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
      initialChild: widget.inactiveWidget,
      onCreatedOperator: _onCreatedOperator,
    );
  }

  @override
  void updateValue() async {
    if (executor.isActive) {
      return;
    }

    isActive = true;
    singleStackScreenOperator.changeScreen(newChild: widget.loadingWidget);
    executor.executeIfStopped(function: _getValue);

    if (widget.onLoading != null) {
      widget.onLoading!();
    }
  }

  @override
  void reloadWidgets() {
    if (mounted) {
      _reloader.add(null);
    }
  }

  Future<void> _getValue() async {
    isActive = true;
    wasFailed = false;
    // singleStackScreenOperator.changeScreen(newChild: widget.loadingWidget);

    await Future.delayed(Duration.zero);

    try {
      item = await widget.getterValue();
      if (mounted) {
        if (widget.reloadWidgets == null) {
          singleStackScreenOperator.changeScreen(
            newChild: MaxiBuildBox(
              reloaders: () => [_reloader.stream],
              cached: false,
              builer: (x) => widget.builder(x, item),
            ),
          );
        } else {
          singleStackScreenOperator.changeScreen(
            newChild: MaxiBuildBox(
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
      final error = NegativeResult.searchNegativity(item: ex, actionDescription: tr('Getting value to widget'));
      errorMessage = error.message.toString();
      wasFailed = true;

      if (mounted) {
        singleStackScreenOperator.changeScreen(newChild: _createErrorWidget(context));

        if (widget.onError != null) {
          widget.onError!(error);
        }

        if (widget.whenCompleted != null) {
          widget.whenCompleted!();
        }
      }
    } finally {
      isActive = false;
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
            text: const TranslatableText(message: 'Retry'),
            icon: Icons.replay_outlined,
            onTouch: updateValue,
          ),
        ],
      ),
    );
  }

  void _onCreatedOperator(ISingleStackScreenOperator newOperator) {
    singleStackScreenOperator = newOperator;
    if (isActive) {
      singleStackScreenOperator.changeScreen(newChild: widget.loadingWidget);
    }
  }
}
