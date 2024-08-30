import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:maxi_flutter_library/src/screens/iscreen_operator.dart';

class NavigatorScreenOperator with IScreenOperator {
  const NavigatorScreenOperator();

  @override
  void goBack({required BuildContext context}) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      log('[WARNING] Navigator can\'t go back');
    }
  }

  @override
  Future<void> showWidgetOnScreen({required BuildContext context, required Widget widget}) async {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => widget));
  }

  @override
  Future<void> showWidgetAsDialog({
    required BuildContext context,
    required Widget widget,
    required Stream closingStream,
  }) {
    closingStream.listen(
      (_) {
        if (context.mounted) {
          goBack(context: context);
        }
      },
    );

    return showDialog(
        context: context,
        builder: (BuildContext context) {
          if (widget is AlertDialog) {
            return widget;
          } else {
            return AlertDialog(content: widget);
          }
        });
  }
}
