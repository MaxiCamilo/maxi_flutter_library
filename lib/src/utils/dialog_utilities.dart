import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_media_store/flutter_media_store.dart';
import 'package:maxi_flutter_library/maxi_flutter_library.dart';
import 'package:maxi_library/maxi_library.dart';
export 'package:file_selector/file_selector.dart';

mixin IDialogWindow<T> {
  void defineResult(BuildContext context, [T? result]);
}

class _DialogWindowPop<T> with IDialogWindow<T> {
  @override
  void defineResult(BuildContext context, [T? result]) {
    if (context.mounted) {
      Navigator.pop(context, result);
    }
  }
}

mixin DialogUtilities {
  static Future<void> closeAllDialogs({required BuildContext context}) async {
    while (Navigator.of(context, rootNavigator: true).canPop()) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

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
    EdgeInsetsGeometry? contentPadding,
  }) async {
    final dialogOperator = _DialogWindowPop<T>();
    return showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (BuildContext context) {
        return AlertDialog(
            contentPadding: contentPadding,
            shape: shape ??
                const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(7.0)),
                ),
            backgroundColor: backgroundColor ?? const Color.fromARGB(255, 46, 46, 46),
            content: Material(
                color: Colors.transparent,
                child: AnimatedSize(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.decelerate,
                  child: builder(context, dialogOperator),
                )));
      },
    );
  }

  static Future<T?> showWidgetAsMaterialDialogWithTitle<T>({
    required BuildContext context,
    required Oration title,
    required Widget Function(BuildContext context, IDialogWindow<T> dialogOperator) builder,
    bool expandVertical = false,
    bool expandHorizontal = false,
    bool barrierDismissible = true,
    Widget? icon,
    RoundedRectangleBorder? shape,
    Color? backgroundColor,
    EdgeInsetsGeometry? contentPadding,
    double titleSize = 20,
  }) {
    return showWidgetAsMaterialDialog<T>(
      context: context,
      backgroundColor: backgroundColor,
      barrierDismissible: barrierDismissible,
      contentPadding: contentPadding,
      shape: shape,
      builder: (context, dialogOperator) {
        return Flex(
          direction: Axis.vertical,
          mainAxisSize: expandVertical ? MainAxisSize.max : MainAxisSize.min,
          children: [
            Flex(
              direction: Axis.horizontal,
              mainAxisSize: expandHorizontal ? MainAxisSize.max : MainAxisSize.min,
              children: [
                icon ?? const SizedBox(),
                SizedBox(width: icon == null ? 0 : 5),
                Flexible(
                  fit: FlexFit.tight,
                  child: MaxiTranslatableText(
                    text: title,
                    bold: true,
                    size: titleSize,
                  ),
                ),
                const SizedBox(width: 5),
                MaxiTransparentButton(
                  icon: const Icon(Icons.close),
                  onTouch: () => dialogOperator.defineResult(context),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Divider(height: 5),
            ),
            expandVertical
                ? Expanded(
                    child: builder(
                    context,
                    dialogOperator,
                  ))
                : Flexible(
                    child: builder(
                    context,
                    dialogOperator,
                  )),
          ],
        );
      },
    );
  }

  static Future<XFile?> selectFile({String? initialAddress, List<XTypeGroup> filter = const [], Oration? title}) async {
    initialAddress ??= await ApplicationManager.instance.getCurrentDirectory();

    return openFile(confirmButtonText: title?.toString(), initialDirectory: initialAddress, acceptedTypeGroups: filter);
  }

  static Future<String?> selectFolder({String? initialAddress, Oration? title}) async {
    initialAddress ??= await ApplicationManager.instance.getCurrentDirectory();

    return getDirectoryPath(confirmButtonText: title?.toString(), initialDirectory: initialAddress);
  }

  static Future<T?> showPopMenu<T>({
    required BuildContext context,
    required GlobalKey key,
    required List<PopupMenuItem<T>> options,
  }) async {
    final RenderBox renderBox = key.currentContext!.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;

    return await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy + size.height, // justo debajo del widget
        offset.dx + size.width,
        offset.dy,
      ),
      items: options,
    );
  }

  static Future<bool> createFile({
    required BuildContext context,
    required String fileExtension,
    required String mimeType,
    required TextableFunctionality<List<int>> Function() fileGenerator,
    String? initialAddress,
    List<XTypeGroup> filter = const [],
    bool askIfWantReplace = true,
    Oration? title,
    String? suggestiveName,
    void Function(String)? onDone,
  }) async {
    if (ApplicationManager.instance.isAndroid) {
      final fileName = await TextDialog.showMaterialDialog(
        context: context,
        title: const Oration(message: 'Name for the new file'),
        fieldTitle: const Oration(message: 'File name'),
        icon: const Icon(Icons.file_present_outlined),
        initialText: suggestiveName ?? '',
        maxLines: 1,
        maxCharacter: 250,
        validators: const [
          CheckTextLength(minimum: 1, maximum: 250),
        ],
      );

      if (fileName == null || !context.mounted) {
        return false;
      }

      final fileContent = await FunctionalTextStreamerWidget.showMaterialDialog(
        context: context,
        canCancel: true,
        canRetry: true,
        function: fileGenerator,
      );

      if (fileContent == null) {
        return false;
      }

      final flutterMediaStorePlugin = FlutterMediaStore();
      final waiter = MaxiCompleter<NegativeResult?>();

      await flutterMediaStorePlugin.saveFile(
        fileData: fileContent,
        mimeType: mimeType,
        rootFolderName: '',
        folderName: '',
        fileName: '$fileName.$fileExtension',
        onSuccess: (uri, filePath) {
          waiter.completeIfIncomplete(null);
        },
        /*
        onSuccess: (String uri, String filePath) {
          // Callbacks on success
          print('✅ File saved successfully: $filePath.toString()');
          print('uri: ${uri.toString()}');

          // **appendDataToFile** is used to append new data to the existing file using the returned URI
          flutterMediaStorePlugin.appendDataToFile(
            uri: uri, // append new data using the URI returned by saveFile
            fileData: fileData, // append new data
            onSuccess: (result) {
              print(result);
            },
            onError: (errorMessage) {
              print(errorMessage);
            },
          );
        },
        */
        onError: (String errorMessage) {
          waiter.completeIfIncomplete(NegativeResult(
            identifier: NegativeResultCodes.externalFault,
            message: Oration(
              message: 'An error occurred while generating the file: %1',
              textParts: [errorMessage],
            ),
          ));
        },
      );

      final lastError = await waiter.future;
      if (lastError == null) {
        if (onDone != null) {
          onDone(fileName);
        }
        return true;
      } else {
        // ignore: use_build_context_synchronously
        ErrorDialog.showMaterialDialog(context: context, negativeResult: lastError);
        return false;
      }
    } else {
      final dir = await saveFile(
        context: context,
        fileExtension: fileExtension,
        askIfWantReplace: askIfWantReplace,
        filter: filter,
        initialAddress: initialAddress,
        suggestiveName: suggestiveName,
        title: title,
      );

      if (!context.mounted || dir == null) {
        return false;
      }

      final fileContent = await FunctionalTextStreamerWidget.showMaterialDialog(
        context: context,
        canCancel: true,
        canRetry: true,
        function: fileGenerator,
      );

      if (fileContent == null || !context.mounted) {
        return false;
      }

      await FunctionalTextStreamerWidget.showFutureMaterialDialog(
        context: context,
        canCancel: true,
        canRetry: true,
        function: () async {
          await FileOperatorMask(isLocal: false, rawRoute: dir).write(
            content: fileContent is Uint8List ? fileContent : Uint8List.fromList(fileContent),
          );
        },
      );

      if (onDone != null) {
        onDone(dir);
      }

      return true;
    }
  }

  static Future<String?> saveFile({
    required BuildContext context,
    required String fileExtension,
    String? initialAddress,
    List<XTypeGroup> filter = const [],
    bool askIfWantReplace = true,
    Oration? title,
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
            text: const Oration(message: 'The file already exists, do you want to replace it?'),
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
