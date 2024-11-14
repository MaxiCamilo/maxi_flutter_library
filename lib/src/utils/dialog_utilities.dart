import 'package:flutter/material.dart';

mixin IDialogWindow<T> {
  void defineResult(BuildContext context, [T? result]);
}

class _DialogWindowPop<T> with IDialogWindow<T> {
  @override
  void defineResult(BuildContext context, [T? result]) {
    Navigator.pop(context, result);
  }
}

mixin DialogUtilities {
  static Future<T?> showWidgetAsBottomSheet<T>(BuildContext context, Widget Function(BuildContext context, IDialogWindow<T> dialogOperator) builder) {
    final dialogOperator = _DialogWindowPop<T>();
    return showModalBottomSheet(
      context: context,
      builder: (context) => builder(context, dialogOperator),
    );
  }
}
