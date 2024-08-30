import 'dart:async';

import 'package:flutter/widgets.dart';

mixin IScreenOperator {
  

  Future<void> showWidgetOnScreen({
    required BuildContext context,
    required Widget widget,
  });
  Future<void> showWidgetAsDialog({
    required BuildContext context,
    required Widget widget,
    required Stream closingStream,
  });
  void goBack({
    required BuildContext context,
  });
}
