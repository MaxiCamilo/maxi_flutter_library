import 'dart:async';

import 'package:flutter/material.dart';
import 'package:maxi_flutter_library/maxi_flutter_library.dart';
import 'package:maxi_library/maxi_library.dart';

class FunctionalTextStreamerWidget<T> extends StatefulWidget {
  final bool canCancel;
  final bool canRetry;
  final bool startWhenDisplayed;

  final FutureOr<TextableFunctionality<T>> Function() function;

  final void Function(T)? onDone;
  final void Function()? onStart;
  final void Function()? onCancel;
  final void Function(NegativeResult)? onError;
  final void Function()? onReset;

  const FunctionalTextStreamerWidget({
    super.key,
    required this.canCancel,
    required this.canRetry,
    required this.function,
    this.startWhenDisplayed = true,
    this.onCancel,
    this.onDone,
    this.onStart,
    this.onError,
    this.onReset,
  });

  static Future<T?> showMaterialDialog<T>({required BuildContext context, required bool canCancel, required bool canRetry, required FutureOr<TextableFunctionality<T>> Function() function, void Function(T)? onDone}) {
    return DialogUtilities.showWidgetAsMaterialDialog<T>(
      context: context,
      barrierDismissible: false,
      builder: (context, dialogOperator) => FunctionalTextStreamerWidget(
        canCancel: canCancel,
        canRetry: canRetry,
        function: function,
        startWhenDisplayed: true,
        onDone: (x) {
          dialogOperator.defineResult(context, x);
          if (onDone != null) {
            onDone(x);
          }
        },
        onCancel: () => dialogOperator.defineResult(context),
      ),
    );
  }

  static Future<T?> showFutureMaterialDialog<T>({
    required BuildContext context,
    required bool canCancel,
    required bool canRetry,
    required FutureOr<T> Function() function,
    void Function(T)? onDone,
    Oration text = const Oration(message: 'Wait for the task to complete its execution'),
    bool barrierDismissible = false,
  }) {
    return DialogUtilities.showWidgetAsMaterialDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context, dialogOperator) => FunctionalTextStreamerWidget(
        canCancel: canCancel,
        canRetry: canRetry,
        startWhenDisplayed: true,
        onDone: (x) {
          dialogOperator.defineResult(context, x);
          if (onDone != null) {
            onDone(x);
          }
        },
        onCancel: () => dialogOperator.defineResult(context),
        function: () => InteractiveFunctionality.express<Oration, T>((manager) => _runAsFuture(manager: manager, function: function, text: text)),
      ),
    );
  }

  static Future<T> _runAsFuture<T>({
    required InteractiveFunctionalityExecutor<Oration, T> manager,
    required Oration text,
    required FutureOr<T> Function() function,
  }) async {
    await manager.sendItemAsync(text);
    return await function();
  }

  @override
  State<FunctionalTextStreamerWidget<T>> createState() => _FunctionalTextStreamerWidgetState<T>();
}

class _FunctionalTextStreamerWidgetState<T> extends StateWithLifeCycle<FunctionalTextStreamerWidget<T>> {
  bool isActive = false;
  bool isDone = false;
  bool wasFailure = false;
  bool wasExecute = false;

  late Oration lastText;
  T? lastResult;
  //StreamSubscription<StreamState<Oration, T>>? actualStream;
  TextableFunctionalityOperator<T>? manager;

  List<NegativeResultValue> invalidProperties = [];

  @override
  void initState() {
    super.initState();

    if (widget.startWhenDisplayed) {
      isActive = true;
      lastText = const Oration(message: 'Please wait a moment');
      maxiScheduleMicrotask(strartStream);
    } else {
      lastText = const Oration(message: 'Press "start" to start the function execution');
    }
  }

  Future<void> strartStream() async {
    isActive = true;
    wasFailure = false;
    isDone = false;
    lastResult = null;
    wasExecute = true;
    lastText = const Oration(message: 'Please wait a moment');

    try {
      final functionality = await widget.function();
      if (mounted) {
        setState(() {});
      }

      manager = functionality.createOperator();
      lastResult = await manager!.waitResult(onItem: reactNewText);

      isDone = true;

      if (widget.onDone != null && lastResult is T) {
        widget.onDone!(lastResult as T);
      }
    } catch (ex) {
      wasFailure = true;
      final lastError = NegativeResult.searchNegativity(item: ex, actionDescription: const Oration(message: 'Obtaining a functional stream'));

      if (lastError is NegativeResultValue) {
        invalidProperties = lastError.invalidProperties;
      } else {
        invalidProperties = [];
      }

      if (widget.onError != null) {
        widget.onError!(lastError);
      }

      lastText = lastError.message;
    } finally {
      if (isActive && mounted) {
        setState(() {});
      }
      isActive = false;
      manager = null;
    }
  }

  @override
  void dispose() {
    isActive = false;

    manager?.dispose();
    manager = null;

    super.dispose();
  }

  void reactOnDoneOrCanceled(T? value) {
    if (!isActive || !mounted) {
      return;
    }

    isActive = false;
    if (value is T) {
      lastResult = value;
    } else {
      final lastError = NegativeResult(
        identifier: NegativeResultCodes.functionalityCancelled,
        message: const Oration(message: 'The task was canceled'),
      );

      lastText = lastError.message;

      if (widget.onCancel != null) {
        widget.onCancel!();
      }

      if (widget.onError != null) {
        widget.onError!(lastError);
      }
    }

    if (mounted) {
      setState(() {});
    }
  }

  void reactNewText(Oration text) {
    if (!mounted) {
      return;
    }

    lastText = text;

    setState(() {});
  }

  void startStream() {
    if (!isActive) {
      isActive = true;
      lastText = const Oration(message: 'Please wait a moment');

      maxiScheduleMicrotask(strartStream);
      setState(() {});
    }
  }

  void cancelStream() {
    if (isActive) {
      manager?.cancel();
      manager = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Flex(
      direction: Axis.vertical,
      mainAxisSize: MainAxisSize.min,
      //crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Flexible(
          child: MaxiScroll(
            child: _makeTextWidget(context),
          ),
        ),
        const SizedBox(
          height: 7,
        ),
        _makeButtons(context),
      ],
    );
  }

  Widget _makeTextWidget(BuildContext context) {
    if (wasFailure) {
      return ErrorLabelTemplate(
        message: lastText,
        invalidProperties: invalidProperties,
      );
    }

    return MaxiFlex(
      rowFrom: 400,
      useScreenSize: true,
      expandRow: true,
      columnCrossAxisAlignment: CrossAxisAlignment.center,
      children: [
        isActive
            ? const CircularProgressIndicator()
            : isDone
                ? const Icon(Icons.done, color: Colors.green)
                : const Icon(Icons.lock_clock),
        const SizedBox(width: 10, height: 10),
        OnlyIfWidth(
          width: 400,
          largestChild: Expanded(child: MaxiTranslatableText(text: lastText)),
          smallerChild: MaxiTranslatableText(text: lastText),
        ),
      ],
    );
  }

  Widget _makeButtons(BuildContext context) {
    return MaxiFlex(
      rowFrom: 400,
      useScreenSize: true,
      expandRow: true,
      rowMainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        makeRetryButton(context),
        const SizedBox(height: 10, width: 10),
        makeDoneButton(context),
      ],
    );
  }

  Widget makeRetryButton(BuildContext context) {
    if (!wasExecute) {
      return MaxiTransparentButton(
        icon: const Icon(Icons.sports_score_outlined, color: Colors.green),
        textColor: Colors.green,
        text: const Oration(message: 'Start'),
        onTouch: startStream,
      );
    }

    if (wasFailure && widget.canRetry) {
      return MaxiTransparentButton(
        icon: const Icon(Icons.published_with_changes, color: Colors.yellow),
        textColor: Colors.yellow,
        text: const Oration(message: 'Retry'),
        onTouch: startStream,
      );
    }

    return const SizedBox();
  }

  Widget makeDoneButton(BuildContext context) {
    if (isActive) {
      if (widget.canCancel || widget.onCancel != null) {
        return MaxiTransparentButton(
          icon: const Icon(Icons.close, color: Colors.red),
          textColor: Colors.red,
          text: const Oration(message: 'Cancel'),
          onTouch: cancelStream,
        );
      } else {
        return const SizedBox();
      }
    }

    if (widget.onCancel != null) {
      return MaxiTransparentButton(
        icon: const Icon(Icons.remove, color: Colors.orange),
        textColor: Colors.orange,
        text: const Oration(message: 'Done'),
        onTouch: widget.onCancel,
      );
    }

    return const SizedBox();
  }
}
