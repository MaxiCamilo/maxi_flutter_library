import 'dart:async';

import 'package:flutter/material.dart';
import 'package:maxi_flutter_library/maxi_flutter_library.dart';
import 'package:maxi_library/maxi_library.dart';

class FunctionalTextStreamerWidget<T> extends StatefulWidget {
  final bool canCancel;
  final bool canRetry;
  final bool startWhenDisplayed;

  final Future<StreamStateTexts<T>> Function() function;

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

  static Future<T?> showMaterialDialog<T>({
    required BuildContext context,
    required bool canCancel,
    required bool canRetry,
    required Future<StreamStateTexts<T>> Function() function,
  }) {
    return DialogUtilities.showWidgetAsMaterialDialog<T>(
      context: context,
      barrierDismissible: false,
      builder: (context, dialogOperator) => FunctionalTextStreamerWidget(
        canCancel: canCancel,
        canRetry: canRetry,
        function: function,
        startWhenDisplayed: true,
        onDone: (x) => dialogOperator.defineResult(context, x),
        onCancel: () => dialogOperator.defineResult(context),
      ),
    );
  }

  @override
  State<FunctionalTextStreamerWidget<T>> createState() => _FunctionalTextStreamerWidgetState<T>();
}

class _FunctionalTextStreamerWidgetState<T> extends StateWithLifeCycle<FunctionalTextStreamerWidget<T>> {
  bool isActive = false;
  bool isDone = false;
  bool wasFailure = false;
  bool wasExecute = false;

  late TranslatableText lastText;
  T? lastResult;
  StreamSubscription<StreamState<TranslatableText, T>>? actualStream;

  @override
  void initState() {
    super.initState();

    if (widget.startWhenDisplayed) {
      isActive = true;
      lastText = tr('Starting stream');
      scheduleMicrotask(strartStream);
    } else {
      lastText = tr('Press "start" to start the function execution');
    }
  }

  Future<void> strartStream() async {
    isActive = true;
    wasFailure = false;
    isDone = false;
    lastResult = null;
    wasExecute = true;
    lastText = tr('Starting stream');

    try {
      final stream = await widget.function();
      if (mounted) {
        setState(() {});
      }
      lastResult = await waitFunctionalStream<TranslatableText, T>(
        stream: stream,
        onDoneOrCanceled: reactOnDoneOrCanceled,
        onData: reactNewText,
        onSubscription: (x) => actualStream = x,
      );

      isDone = true;

      if (widget.onDone != null && lastResult != null) {
        widget.onDone!(lastResult as T);
      }
    } catch (ex) {
      wasFailure = true;
      final lastError = NegativeResult.searchNegativity(item: ex, actionDescription: tr('Obtaining a functional stream'));
      if (widget.onError != null) {
        widget.onError!(lastError);
      }

      lastText = lastError.message;
    } finally {
      actualStream = null;
      if (isActive && mounted) {
        setState(() {});
      }
      isActive = false;
    }
  }

  @override
  void dispose() {
    isActive = false;
    actualStream?.cancel();

    super.dispose();
  }

  void reactOnDoneOrCanceled(T? value) {
    if (!isActive || !mounted) {
      return;
    }

    isActive = false;
    if (value == null) {
      final lastError = NegativeResult(
        identifier: NegativeResultCodes.functionalityCancelled,
        message: tr('The functionality was canceled'),
      );

      lastText = lastError.message;

      if (widget.onCancel != null) {
        widget.onCancel!();
      }

      if (widget.onError != null) {
        widget.onError!(lastError);
      }
    } else {
      lastResult = value;
    }

    if (mounted) {
      setState(() {});
    }
  }

  void reactNewText(TranslatableText text) {
    if (!mounted) {
      return;
    }

    lastText = text;

    setState(() {});
  }

  void startStream() {
    if (!isActive) {
      isActive = true;
      lastText = tr('Starting stream');

      scheduleMicrotask(strartStream);
      setState(() {});
    }
  }

  void cancelStream() {
    if (isActive) {
      actualStream?.cancel();
      actualStream = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Flex(
      direction: Axis.vertical,
      mainAxisSize: MainAxisSize.min,
      //crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _makeTextWidget(context),
        const SizedBox(
          height: 15,
        ),
        _makeButtons(context),
      ],
    );
  }

  Widget _makeTextWidget(BuildContext context) {
    if (wasFailure) {
      return ErrorLabelTemplate(
        message: lastText,
      );
    }

    return MaxiFlex(
      rowFrom: 400,
      useScreenSize: true,
      expandRow: true,
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
        icon: Icons.sports_score_outlined,
        textColor: Colors.green,
        text: tr('Start'),
        onTouch: startStream,
      );
    }

    if (wasFailure && widget.canRetry) {
      return MaxiTransparentButton(
        icon: Icons.published_with_changes,
        textColor: Colors.yellow,
        text: tr('Retry'),
        onTouch: startStream,
      );
    }

    return const SizedBox();
  }

  Widget makeDoneButton(BuildContext context) {
    if (isActive) {
      if (widget.canCancel || widget.onCancel != null) {
        return MaxiTransparentButton(
          icon: Icons.close,
          textColor: Colors.red,
          text: tr('Cancel'),
          onTouch: cancelStream,
        );
      } else {
        return const SizedBox();
      }
    }

    if (widget.onCancel != null) {
      return MaxiTransparentButton(
        icon: Icons.remove,
        textColor: Colors.orange,
        text: tr('Done'),
        onTouch: widget.onCancel,
      );
    }

    return const SizedBox();
  }
}
