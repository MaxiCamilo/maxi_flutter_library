import 'package:flutter/widgets.dart';

mixin IStackedScreenOperator {
  void goBack();

  void pushScreen({required Widget newWidget});

  void resetScreen({required Widget newWidget});
}
