import 'package:flutter/widgets.dart';
import 'package:maxi_flutter_library/maxi_flutter_library.dart';
import 'package:maxi_library/maxi_library.dart';

abstract class MaxiMultiplePageScreen<T extends StatefulWidget> extends StateWithLifeCycle<T> {
  Curve get singleStackCurve => Curves.decelerate;
  Duration get stackSreenDuration => const Duration(milliseconds: 300);
  Curve get animatedSizeCurve => Curves.decelerate;
  Duration get animatedSizeDuration => const Duration(milliseconds: 250);
  EdgeInsets get padding => const EdgeInsets.all(8.0);
  bool get itIsInitiallyAvailable => true;

  bool get isEnable => _darkenInteractionOperator?.isEnabled ?? false;

  ISingleStackScreenOperator? _screenOperator;
  IMaxiDarkenInteractionOperator? _darkenInteractionOperator;

  Widget buildInitialScreen(BuildContext context);

  Future<void> changeScreen({required Widget newChild, Duration? duration, Curve? curve}) async {
    if (!mounted) {
      return;
    }

    checkProgrammingFailure(thatChecks: const Oration(message: 'Screen operator was defined'), result: () => _screenOperator != null);
    await _screenOperator!.changeScreen(newChild: newChild, curve: curve, duration: duration);
  }

  set isEnabled(bool newStatus) {
    checkProgrammingFailure(thatChecks: const Oration(message: 'Darken Interaction Operator was defined'), result: () => _darkenInteractionOperator != null);
    checkProgrammingFailure(thatChecks: const Oration(message: 'The widget is mounted'), result: () => mounted);
    _darkenInteractionOperator!.isEnabled = newStatus;
  }

  Future<void> executeFunction<R>({
    required Future<R> Function() function,
    void Function(R)? onDone,
    void Function(Object, StackTrace)? onError,
    IMaxiErrorPosterOperator? posterError,
  }) {
    checkProgrammingFailure(thatChecks: const Oration(message: 'Darken Interaction Operator was defined'), result: () => _darkenInteractionOperator != null);
    checkProgrammingFailure(thatChecks: const Oration(message: 'The widget is mounted'), result: () => mounted);

    return _darkenInteractionOperator!.executeFunction<R>(function: function, onDone: onDone, onError: onError, posterError: posterError);
  }

  Future<void> executeStreamFunctionality<R>({
    required IStreamFunctionality<R> functionality,
    void Function(R)? onDone,
    void Function(Object, StackTrace)? onError,
    IMaxiErrorPosterOperator? posterError,
  }) {
    checkProgrammingFailure(thatChecks: const Oration(message: 'Darken Interaction Operator was defined'), result: () => _darkenInteractionOperator != null);
    checkProgrammingFailure(thatChecks: const Oration(message: 'The widget is mounted'), result: () => mounted);

    return _darkenInteractionOperator!.executeStreamFunctionality<R>(functionality: functionality, onDone: onDone, onError: onError, posterError: posterError);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      curve: animatedSizeCurve,
      duration: animatedSizeDuration,
      child: MaxiDarkenInteractionWidget(
        isEnabled: itIsInitiallyAvailable,
        onCreatedOperator: (x) => _darkenInteractionOperator = x,
        child: Padding(
          padding: padding,
          child: SingleStackScreen(
            duration: stackSreenDuration,
            curve: singleStackCurve,
            onCreatedOperator: (x) => _screenOperator = x,
            initialChildBuild: buildInitialScreen,
          ),
        ),
      ),
    );
  }
}
