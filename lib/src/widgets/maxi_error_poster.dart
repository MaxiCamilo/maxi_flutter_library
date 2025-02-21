import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:maxi_flutter_library/maxi_flutter_library.dart';
import 'package:maxi_library/export_reflectors.dart';

class MaxiErrorPoster extends StatefulWidget {
  final NegativeResult? initialError;
  final bool hidden;
  final EdgeInsets padding;

  final Duration duration;
  final Curve curve;
  final Widget Function(BuildContext, NegativeResult)? errorBuilder;
  final FutureOr<List<Stream>> Function()? reloaders;
  final void Function(IMaxiErrorPosterOperator)? onCreatedOperator;

  const MaxiErrorPoster({
    super.key,
    this.initialError,
    this.hidden = true,
    this.duration = const Duration(milliseconds: 400),
    this.curve = Curves.decelerate,
    this.padding = EdgeInsets.zero,
    this.errorBuilder,
    this.reloaders,
    this.onCreatedOperator,
  });

  @override
  State<MaxiErrorPoster> createState() => _MaxiErrorPosterState();
}

mixin IMaxiErrorPosterOperator {
  void hidePoster();
  void showPoster({NegativeResult? error});
}

class _MaxiErrorPosterState extends StateWithLifeCycle<MaxiErrorPoster> with IMaxiErrorPosterOperator {
  NegativeResult? lastError;
  IMaxiVerticalCollapsorOperator? collapsorOperator;
  bool hidden = false;

  @override
  void initState() {
    super.initState();

    lastError = widget.initialError;
    hidden = widget.hidden;

    if (widget.reloaders != null) {
      scheduleMicrotask(() async {
        for (final event in await widget.reloaders!()) {
          joinEvent(
              event: event,
              onData: (x) {
                if (!mounted) {
                  return;
                }

                if (x is bool) {
                  if (x) {
                    showPoster();
                  } else {
                    hidePoster();
                  }
                } else {
                  final error = NegativeResult.searchNegativity(item: x, actionDescription: const Oration(message: 'Stream error'));
                  showPoster(error: error);
                }
              });
        }
      });
    }

    if (widget.onCreatedOperator != null) {
      widget.onCreatedOperator!(this);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaxiVerticalCollapsor(
      startsOpen: !hidden && lastError != null,
      makeChild: _makeErrorPoster,
      curveSize: widget.curve,
      duration: widget.duration,
      onCreatedOperator: (x) => collapsorOperator = x,
    );
  }

  Widget _makeErrorPoster(BuildContext context) {
    checkProgrammingFailure(thatChecks: const Oration(message: 'LastMessage is not null'), result: () => lastError != null);
    if (widget.errorBuilder == null) {
      return Padding(
        padding: widget.padding,
        child: MaxiRectangle(
          borderColor: Colors.redAccent,
          borderWidth: 2.0,
          borderRadious: 5.0,
          padding: const EdgeInsets.all(5.0),
          child: Flex(
            direction: Axis.horizontal,
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: ErrorLabelTemplate(
                  message: lastError!.message,
                  invalidProperties: (lastError! is NegativeResultValue) ? (lastError! as NegativeResultValue).invalidProperties : const [],
                ),
              ),
              MaxiRectangle(
                borderRadious: 45.0,
                borderColor: Colors.redAccent,
                borderWidth: 1,
                child: MaxiTapArea(
                  onTouch: hidePoster,
                  child: const Icon(
                    Icons.remove,
                    color: Colors.redAccent,
                    size: 15,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return widget.errorBuilder!(context, lastError!);
    }
  }

  @override
  void hidePoster() {
    collapsorOperator?.hide();
  }

  @override
  void showPoster({NegativeResult? error}) {
    if (error != null) {
      lastError = error;
    }
    if (lastError == null) {
      log('[MaxiErrorPoster] ¡There is no defined error!');
    } else {
      collapsorOperator?.show();
    }
  }
}
