import 'dart:async';

import 'package:flutter/material.dart';
import 'package:maxi_flutter_library/maxi_flutter_library.dart';
import 'package:maxi_library/maxi_library.dart';

mixin StartableState<T extends StatefulWidget, R> {
  bool _firstExecution = true;

  Future<R> initializedAsynchronous();

  Widget buildAfterInitialized(BuildContext context, R result);

  Widget get loadingWidget => const CircularProgressIndicator();
  bool get canRetry => true;
  double get iconSize => 42;
  double get textSize => 15;
  Duration get duration => const Duration(milliseconds: 500);
  Curve get curve => Curves.decelerate;
  Widget get inactiveWidget => const SizedBox();

  late ILoadingScreenOperator screenOperator;

  Widget build(BuildContext context) {
    return LoadingScreen<R>(
      startActive: true,
      getterValue: _startEjecution,
      builder: buildAfterInitialized,
      loadingWidget: loadingWidget,
      canRetry: canRetry,
      iconSize: iconSize,
      textSize: textSize,
      duration: duration,
      reloadWidgets: generateReloadersStream,
      curve: curve,
      inactiveWidget: inactiveWidget,
      onGetValue: onGetValue,
      updateStreamList: generateUpdateStreamList,
      onLoading: onLoading,
      onError: onError,
      whenCompleted: whenCompleted,
      onCreatedOperator: (x) => screenOperator = x,
    );
  }

  Future<R> _startEjecution() async {
    if (_firstExecution) {
      await firstExecution();
      _firstExecution = false;
    }

    return await initializedAsynchronous();
  }

  FutureOr<void> firstExecution() {}

  FutureOr<List<Stream<dynamic>>> generateReloadersStream() {
    return [];
  }

  FutureOr<List<Stream<dynamic>>> generateUpdateStreamList() async {
    return [];
  }

  void updateValue() {
    screenOperator.updateValue();
  }

  void reloadWidgets() {
    screenOperator.reloadWidgets();
  }

  void onGetValue(R value) {}

  void onLoading() {}

  void onError(NegativeResult error) {}

  void whenCompleted() {}
}
