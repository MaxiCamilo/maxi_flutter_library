import 'package:flutter/material.dart';
import 'package:maxi_flutter_library/maxi_flutter_library.dart';
import 'package:maxi_library/maxi_library.dart';
export 'package:file_selector/file_selector.dart';

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

  static Future<String?> saveFile({
    required BuildContext context,
    required String fileExtension,
    String? initialAddress,
    List<XTypeGroup> filter = const [],
    bool askIfWantReplace = true,
    TranslatableText? title,
    String? suggestiveName,
  }) async {
    initialAddress ??= await ApplicationManager.instance.getCurrentDirectory();

    final dio = await getSaveLocation(confirmButtonText: title?.toString(), initialDirectory: initialAddress, acceptedTypeGroups: filter, suggestedName: suggestiveName);
    if (dio == null) {
      return null;
    }

    late final String address;

    if (dio.path.endsWith('.$fileExtension')) {
      address = dio.path;
    } else {
      address = '${dio.path}.$fileExtension';
    }

    if (askIfWantReplace && await FileOperatorMask(isLocal: false, rawRoute: address).existsFile()) {
      if (!context.mounted) {
        return null;
      }
      if (await QuestionDialog.showMaterialDialog(
            context: context,
            text: const TranslatableText(message: 'The file already exists, do you want to replace it?'),
            icon: Icons.warning,
            iconColor: Colors.orangeAccent,
          ) !=
          true) {
        return null;
      }
    }

    return address;
  }
}
