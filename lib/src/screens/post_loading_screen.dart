import 'dart:async';

import 'package:flutter/material.dart';
import 'package:maxi_flutter_library/maxi_flutter_library.dart';
import 'package:maxi_library/maxi_library.dart';

class PostLoadingScreen<T> extends StatefulWidget {
  final FutureOr<T> Function() function;
  final Widget Function(BuildContext context, T item) builder;
  final Widget Function(BuildContext context)? loadingBuilder;
  final Widget Function(BuildContext context)? initialChildBuild;
  final Widget Function(BuildContext context, NegativeResult nr)? errorBuilder;
  final void Function(IPostLoadingScreenOperator<T>)? onCreatedOperator;
  final FutureOr<List<Stream>> Function()? updatersStreams;
  final Curve curve;
  final Duration duration;
  final void Function()? onLoading;
  final void Function(T)? onResult;
  final void Function(NegativeResult)? onError;

  const PostLoadingScreen({
    super.key,
    required this.function,
    required this.builder,
    this.duration = const Duration(seconds: 1),
    this.curve = Curves.linear,
    this.loadingBuilder,
    this.errorBuilder,
    this.onCreatedOperator,
    this.initialChildBuild,
    this.updatersStreams,
    this.onLoading,
    this.onResult,
    this.onError,
  });

  @override
  State<PostLoadingScreen<T>> createState() => _PostLoadingScreenState<T>();
}

mixin IPostLoadingScreenOperator<T> {
  Stream<T> get onResult;
  Stream<NegativeResult> get onError;

  void changeToLoading();
  void reverse();
}

class _PostLoadingScreenState<T> extends StateWithLifeCycle<PostLoadingScreen<T>> with IPostLoadingScreenOperator<T> {
  final semaphore = Semaphore();

  late ISingleStackScreenOperator screenOperator;

  @override
  Stream<NegativeResult> get onError => onErrorController.stream;

  @override
  Stream<T> get onResult => onResultController.stream;

  late final StreamController<T> onResultController;
  late final StreamController<NegativeResult> onErrorController;

  @override
  void initState() {
    super.initState();

    onResultController = createEventController<T>(isBroadcast: true);
    onErrorController = createEventController<NegativeResult>(isBroadcast: true);

    if (widget.updatersStreams != null) {
      maxiScheduleMicrotask(() async {
        final streamList = await widget.updatersStreams!();
        for (final stream in streamList) {
          joinEvent(event: stream, onData: updaterOnData);
        }
      });
    }

    if (widget.onCreatedOperator != null) {
      widget.onCreatedOperator!(this);
    }
  }

  void updaterOnData(_) {
    if (mounted) {
      changeToLoading();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleStackScreen(
      curve: widget.curve,
      duration: widget.duration,
      onCreatedOperator: (x) => screenOperator = x,
      initialChildBuild: defineInitialChild,
    );
  }

  @override
  void changeToLoading() {
    semaphore.executeIfStopped(function: loadingData);
  }

  Future<void> loadingData() async {
    if (!mounted) {
      return;
    }

    screenOperator.changeScreen(newChild: widget.loadingBuilder == null ? const CircularProgressIndicator() : widget.loadingBuilder!(context));

    if (widget.onLoading != null) {
      widget.onLoading!();
    }

    try {
      final result = await widget.function();
      if (mounted) {
        screenOperator.changeScreen(newChild: widget.builder(context, result));
      }
      if (widget.onResult != null) {
        widget.onResult!(result);
      }
    } catch (ex, st) {
      final rn = NegativeResult.searchNegativity(item: ex, actionDescription: const Oration(message: 'Loading data'), stackTrace: st);
      if (widget.errorBuilder == null) {
        if (mounted) {
          screenOperator.changeScreen(newChild: ErrorLabelTemplate(message: rn.message));
        }
      } else {
        if (mounted) {
          screenOperator.changeScreen(newChild: widget.errorBuilder!(context, rn));
        }
      }

      if (widget.onError != null) {
        widget.onError!(rn);
      }
    }
  }

  Widget defineInitialChild(BuildContext x) {
    if (widget.initialChildBuild == null) {
      return const SizedBox();
    } else {
      return widget.initialChildBuild!(x);
    }
  }

  @override
  void reverse() {
    if (mounted) {
      defineInitialChild(context);
    }
  }
}
