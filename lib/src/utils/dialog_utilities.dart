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
  static Future<T?> showWidgetAsBottomSheet<T>({required BuildContext context, required Widget Function(BuildContext context, IDialogWindow<T> dialogOperator) builder}) {
    final dialogOperator = _DialogWindowPop<T>();
    return showModalBottomSheet(
      context: context,
      builder: (context) => builder(context, dialogOperator),
    );
  }

  static Future<T?> showWidgetAsMaterialDialog<T>({
    required BuildContext context,
    required Widget Function(BuildContext context, IDialogWindow<T> dialogOperator) builder,
    bool barrierDismissible = true,
    RoundedRectangleBorder? shape,
    Color? backgroundColor,
  }) async {
    final dialogOperator = _DialogWindowPop<T>();
    return showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (BuildContext context) {
        return AlertDialog(
            shape: shape ??
                const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(7.0)),
                ),
            backgroundColor: backgroundColor ?? const Color.fromARGB(255, 46, 46, 46),
            content: Material(
              color: Colors.transparent,
              child: builder(context, dialogOperator),
            ));
      },
    );
  }
}
