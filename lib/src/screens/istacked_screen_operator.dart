import 'package:flutter/widgets.dart';

mixin StackedScreenOperator {
  int get numberOfScreens;

  void goBack({Duration? duration, Curve? curve});

  void pushScreen({required Widget newWidget, Duration? duration, Curve? curve});

  void resetScreen({required Widget newWidget, Duration? duration, Curve? curve});
}
