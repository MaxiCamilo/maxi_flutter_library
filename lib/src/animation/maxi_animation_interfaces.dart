import 'package:flutter/widgets.dart';
import 'package:maxi_flutter_library/maxi_flutter_library.dart';
import 'package:maxi_library/maxi_library.dart';

mixin IMaxiAnimatorManager {
  void declareNewAnimator(IMaxiAnimatorState animator);
  void removeAnimator(IMaxiAnimatorState animator);
  List<T> obtainCompatibleAnimations<T>();
  T? tryGetAnimator<T>();
  T? tryGetAnimatorByKey<T>(Key key);


  T getAnimator<T>() {
    final animator = tryGetAnimator<T>();
    if (animator == null) {
      throw NegativeResult(
        identifier: NegativeResultCodes.implementationFailure,
        message: Oration(
          message: 'The container does not have the animator %1 or was not previously defined',
          textParts: [T],
        ),
      );
    } else {
      return animator;
    }
  }

   T getAnimatorByKey<T>(Key key) {
    final animator = tryGetAnimatorByKey<T>(key);
    if (animator == null) {
      throw NegativeResult(
        identifier: NegativeResultCodes.implementationFailure,
        message: Oration(
          message: 'The container does not have the animator with the key %1',
          textParts: [key],
        ),
      );
    } else {
      return animator;
    }
  }

  void dispose();
}

mixin IMaxiAnimatorWidget {
  IMaxiAnimatorManager? get animatorManager;
}

mixin IMaxiAnimatorState<T extends StatefulWidget> on StateWithLifeCycle<T> {
  void initializeAnimator() {
    if (widget is IMaxiAnimatorWidget) {
      final animatorWidget = widget as IMaxiAnimatorWidget;

      if (animatorWidget.animatorManager != null) {
        animatorWidget.animatorManager!.declareNewAnimator(this);
        onDispose.whenComplete(() => animatorWidget.animatorManager!.removeAnimator(this));
      }
    }
  }
}

mixin IMaxiUpdatebleValueState {
  void updateValue();
}
