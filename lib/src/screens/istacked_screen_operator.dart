import 'package:flutter/widgets.dart';

mixin IStackedScreenOperator {
  int get numberOfScreens;
  int get actualPage;

  Stream<int> get notifyChangeScreen;

  Stream get notifyDispose;

  void goBack({Duration? duration, Curve? curve});

  void pushScreen({required Widget newWidget, Duration? duration, Curve? curve});

  void resetScreen({required Widget newWidget, Duration? duration, Curve? curve});
}
