import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:maxi_library/maxi_library.dart';

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
  static Future<T?> showWidgetAsBottomSheet<T>({
    required BuildContext context,
    required Widget Function(BuildContext context, IDialogWindow<T> dialogOperator) builder,
    Color? backgroundColor,
  }) {
    final dialogOperator = _DialogWindowPop<T>();
    return showModalBottomSheet(
      backgroundColor: backgroundColor,
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

  static Future<XFile?> selectFile({String? initialAddress, List<XTypeGroup> filter = const [], TranslatableText? title}) async {
    initialAddress ??= await ApplicationManager.instance.getCurrentDirectory();

    return openFile(confirmButtonText: title?.toString(), initialDirectory: initialAddress, acceptedTypeGroups: filter);
  }

  static Future<String?> selectFolder({String? initialAddress, TranslatableText? title}) async {
    initialAddress ??= await ApplicationManager.instance.getCurrentDirectory();

    return getDirectoryPath(confirmButtonText: title?.toString(), initialDirectory: initialAddress);
  }

  static Future<String?> saveFile({required String fileExtension, String? initialAddress, List<XTypeGroup> filter = const [], TranslatableText? title, String? suggestiveName}) async {
    initialAddress ??= await ApplicationManager.instance.getCurrentDirectory();

    final dio = await getSaveLocation(confirmButtonText: title?.toString(), initialDirectory: initialAddress, acceptedTypeGroups: filter, suggestedName: suggestiveName);
    if (dio == null) {
      return null;
    }
    if (dio.path.endsWith('.$fileExtension')) {
      return dio.path;
    } else {
      return '${dio.path}.$fileExtension';
    }
  }
}
