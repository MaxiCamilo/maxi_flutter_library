import 'dart:async';

import 'package:flutter/material.dart';
import 'package:maxi_flutter_library/maxi_flutter_library.dart';
import 'package:maxi_library/export_reflectors.dart';

class MaxiDarkenInteractionWidget extends StatefulWidget with IMaxiAnimatorWidget {
  final bool isEnabled;
  final Widget child;
  final Widget Function(BuildContext, bool)? buildDisableWidget;
  //final Color backgroundColor;
  final double backgroundTransparent;
  final Duration animationDuration;
  final void Function(IMaxiDarkenInteractionOperator)? onCreatedOperator;

  @override
  final IMaxiAnimatorManager? animatorManager;

  const MaxiDarkenInteractionWidget({
    super.key,
    required this.isEnabled,
    required this.child,
    this.buildDisableWidget,
    this.backgroundTransparent = 0.6,
    this.animationDuration = const Duration(milliseconds: 400),
    this.onCreatedOperator,
    this.animatorManager,
    //this.backgroundColor = const Color.fromARGB(139, 0, 0, 0),
    // this.onCreatedOperator,
  });

  @override
  State<MaxiDarkenInteractionWidget> createState() => _MaxiDarkenInteractionWidgetState();
}

mixin IMaxiDarkenInteractionOperator {
  bool get isEnabled;
  set isEnabled(bool newStatus);

  Future<T?> executeFunction<T>({
    required Future<T> Function() function,
    void Function(T)? onDone,
    void Function(Object, StackTrace)? onError,
    IMaxiErrorPosterOperator? posterError,
  });

  Future<void> executeStreamFunctionality<T>({
    required IStreamFunctionality<T> functionality,
    void Function(T)? onDone,
    void Function(Object, StackTrace)? onError,
    IMaxiErrorPosterOperator? posterError,
  });
}

class _MaxiDarkenInteractionWidgetState extends StateWithLifeCycle<MaxiDarkenInteractionWidget> with IMaxiDarkenInteractionOperator, IMaxiAnimatorState<MaxiDarkenInteractionWidget> {
  late bool _isEnabled;
  late Semaphore _semaphore;
  late StreamController<bool> _lastTextChange;

  bool _returnTextState = false;
  Oration _lastText = Oration.empty;

  @override
  bool get isEnabled => _isEnabled;
  @override
  set isEnabled(bool newStatus) {
    if (_isEnabled == newStatus || !mounted) {
      return;
    }

    _isEnabled = newStatus;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    _isEnabled = widget.isEnabled;
    _semaphore = Semaphore();
    _lastTextChange = createEventController<bool>(isBroadcast: true);

    initializeAnimator();

    if (widget.onCreatedOperator != null) {
      widget.onCreatedOperator!(this);
    }
  }

  @override
  void dispose() {
    super.dispose();

    _semaphore.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AbsorbPointer(
          absorbing: !_isEnabled,
          child: FocusScope(
            canRequestFocus: _isEnabled,
            child: widget.child,
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            ignoring: isEnabled,
            child: AnimatedOpacity(
              opacity: isEnabled ? 0.0 : widget.backgroundTransparent,
              duration: widget.animationDuration,
              curve: Curves.easeInOut,
              child: Container(
                color: Colors.black,
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            ignoring: isEnabled,
            child: widget.buildDisableWidget == null
                ? AnimatedOpacity(
                    opacity: isEnabled ? 0.0 : 1.0,
                    duration: widget.animationDuration,
                    curve: Curves.easeInOut,
                    child: Center(
                      child: buildIndicator(context),
                    ),
                  )
                : widget.buildDisableWidget!(context, isEnabled),
          ),
        ),
      ],
    );
  }

  Widget buildIndicator(BuildContext context) {
    if (_returnTextState) {
      return MaxiRectangle(
        padding: const EdgeInsets.all(8.0),
        borderRadious: 5.0,
        backgroundColor: const Color.fromARGB(255, 65, 65, 65),
        child: Flex(
          direction: Axis.vertical,
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 10),
            Flexible(
              child: MaxiBuildBox(
                reloaders: () => [_lastTextChange.stream],
                cached: true,
                builer: (_) => MaxiTranslatableText(text: _lastText),
              ),
            ),
          ],
        ),
      );
    } else {
      return const Center(child: CircularProgressIndicator());
    }
  }

  @override
  Future<T?> executeFunction<T>({
    required Future<T> Function() function,
    void Function(T)? onDone,
    void Function(Object, StackTrace)? onError,
    IMaxiErrorPosterOperator? posterError,
  }) {
    return _semaphore.execute(function: () async {
      T? returnResult;
      _returnTextState = false;
      isEnabled = false;

      _lastText = Oration.empty;
      _lastTextChange.addIfActive(true);

      if (posterError != null) {
        posterError.hidePoster();
      }

      try {
        final result = await function();
        returnResult = result;
        if (onDone != null) {
          onDone(result);
        }
      } catch (x, y) {
        if (onError != null) {
          onError(x, y);
        }
        if (posterError != null) {
          posterError.showPoster(error: NegativeResult.searchNegativity(item: x, actionDescription: const Oration(message: 'Execute functionality')));
        }
      } finally {
        if (_semaphore.pendingLength <= 1) {
          isEnabled = true;
        }
      }

      return returnResult;
    });
  }

  @override
  Future<void> executeStreamFunctionality<T>({
    required IStreamFunctionality<T> functionality,
    void Function(T)? onDone,
    void Function(Object, StackTrace)? onError,
    IMaxiErrorPosterOperator? posterError,
  }) async {
    return _semaphore.execute(function: () async {
      _returnTextState = true;
      isEnabled = false;

      _lastText = Oration.empty;
      _lastTextChange.addIfActive(true);

      if (posterError != null) {
        posterError.hidePoster();
      }

      try {
        final streamOperator = functionality.createManager();
        joinEvent(
          event: streamOperator.textStream,
          onData: (x) {
            _lastText = x;
            _lastTextChange.addIfActive(true);
          },
        );

        final result = await streamOperator.waitStreamResult();
        if (onDone != null) {
          onDone(result);
        }
      } catch (x, y) {
        if (onError != null) {
          onError(x, y);
        }
        if (posterError != null) {
          posterError.showPoster(error: NegativeResult.searchNegativity(item: x, actionDescription: const Oration(message: 'Execute functionality')));
        }
      } finally {
        if (_semaphore.pendingLength <= 1) {
          isEnabled = true;
        }
      }
    });
  }
}

/*

IgnorePointer(
          ignoring: isEnabled,
          child: AnimatedOpacity(
            opacity: isEnabled ? 0.0 : darkenOpacity,
            duration: animationDuration,
            curve: Curves.easeInOut,
            child: Container(
              color: Colors.black,
            ),
          ),
        ),


 */
