import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:maxi_flutter_library/maxi_flutter_library.dart';
import 'package:maxi_library/export_reflectors.dart';

class MaxiAnimatorManager with IMaxiAnimatorManager {
  final List<IMaxiAnimatorState> _animators = [];

  @override
  void declareNewAnimator(IMaxiAnimatorState<StatefulWidget> animator) {
    if (_animators.contains(animator)) {
      return;
    }
    final existent = _animators.selectItem((x) => x.runtimeType == animator.runtimeType);
    if (existent != null) {
      if (existent.isDispose) {
        _animators.remove(existent);
      } else {
        log('[MaxiAnimatorManager] WARNING! There is another ${animator.runtimeType} type animator');
      }
    }

    _animators.add(animator);
  }

  @override
  List<T> obtainCompatibleAnimations<T>() {
    return _animators.whereType<T>().toList(growable: false);
  }

  @override
  void removeAnimator(IMaxiAnimatorState<StatefulWidget> animator) {
    _animators.remove(animator);
  }

  @override
  T? tryGetAnimator<T>() {
    return _animators.selectByType<T>();
  }

  @override
  void dispose() {
    _animators.clear();
  }

  @override
  T? tryGetAnimatorByKey<T>(Key key) {
    final state = _animators.selectItem((x) => x.widget.key == key);
    if (state != null) {
      if (state is T) {
        return state as T;
      } else {
        throw NegativeResult(
          identifier: NegativeResultCodes.wrongType,
          message: Oration(
            message: 'The state with key %1 is %2, but it was expected to be %3',
            textParts: [key, state.runtimeType, T],
          ),
        );
      }
    }
    return null;
  }
}
