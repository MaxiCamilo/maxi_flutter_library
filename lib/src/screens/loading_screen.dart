import 'package:flutter/material.dart';
import 'package:maxi_flutter_library/maxi_flutter_library.dart';
import 'package:maxi_library/maxi_library.dart';

class LoadingScreen<T> extends StatefulWidget {
  final void Function(ILoadingScreenOperator)? onCreatedOperator;
  final Future<T> Function() getterValue;
  final Widget Function(BuildContext context, T item) builder;
  final Widget waitingWidget;
  final Future<List<Stream>> Function()? updateStreamList;
  final bool canRetry;
  final double iconSize;
  final double textSize;
  final Duration duration;
  final Curve curve;

  const LoadingScreen({
    super.key,
    this.onCreatedOperator,
    required this.getterValue,
    required this.builder,
    this.waitingWidget = const CircularProgressIndicator(),
    this.canRetry = true,
    this.iconSize = 42,
    this.textSize = 12,
    this.duration = const Duration(milliseconds: 500),
    this.curve = Curves.linear,
    this.updateStreamList,
  });

  @override
  State<LoadingScreen<T>> createState() => _LoadingScreenState<T>();
}

mixin ILoadingScreenOperator<T> {
  bool get isActive;
  void reload();
}

class _LoadingScreenState<T> extends StateWithLifeCycle<LoadingScreen<T>> with ILoadingScreenOperator<T> {
  @override
  bool isActive = true;
  bool wasFailed = false;

  late String errorMessage;
  late T item;
  late ISingleStackScreenOperator singleStackScreenOperator;

  final executor = Semaphore();

  @override
  void initState() {
    super.initState();

    executor.execute(function: _getValue);

    if (widget.updateStreamList != null) {
      getUpdateStream();
    }
  }

  Future<void> getUpdateStream() async {
    final list = await widget.updateStreamList!();

    for (final item in list) {
      joinEvent(event: item, onData: (_) => reload());
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleStackScreen(
      curve: widget.curve,
      duration: widget.duration,
      initialChild: widget.waitingWidget,
      onCreatedOperator: _onCreatedOperator,
    );
  }

  @override
  void reload() async {
    if (isActive) {
      return;
    }

    isActive = true;
    singleStackScreenOperator.changeScreen(newChild: widget.waitingWidget);
    executor.executeIfStopped(function: _getValue);
  }

  Future<void> _getValue() async {
    isActive = true;
    wasFailed = false;

    await Future.delayed(Duration.zero);

    try {
      item = await widget.getterValue();
      if (mounted) {
        singleStackScreenOperator.changeScreen(newChild: widget.builder(context, item));
      }
    } catch (ex) {
      final error = NegativeResult.searchNegativity(item: ex, actionDescription: tr('Getting value to widget'));
      errorMessage = error.message.toString();
      wasFailed = true;

      if (mounted) {
        singleStackScreenOperator.changeScreen(newChild: _createErrorWidget(context));
      }
    } finally {
      isActive = false;
    }
  }

  Widget _createErrorWidget(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey, // Color del borde
          width: 1.0, // Grosor del borde
        ),
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
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.dangerous,
                color: Colors.red,
                size: widget.iconSize,
              ),
              const SizedBox(width: 10),
              Flexible(
                child: MaxiText(
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
            onTouch: reload,
          ),
        ],
      ),
    );
  }

  void _onCreatedOperator(ISingleStackScreenOperator newOperator) {
    singleStackScreenOperator = newOperator;
  }
}
