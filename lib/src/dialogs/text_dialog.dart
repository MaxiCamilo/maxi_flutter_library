import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:maxi_flutter_library/maxi_flutter_library.dart';
import 'package:maxi_library/maxi_library.dart';

class TextDialog extends StatefulWidget {
  final Oration title;
  final Oration fieldTitle;
  final Widget? icon;
  final int? maxCharacter;
  final int? maxLines;
  final String initialText;
  final List<ValueValidator> validators;
  final List<TextInputFormatter> inputFormatters;
  final void Function(String) onDone;

  const TextDialog({
    super.key,
    required this.title,
    required this.fieldTitle,
    required this.onDone,
    this.icon,
    this.maxCharacter,
    this.maxLines,
    this.initialText = '',
    this.validators = const [],
    this.inputFormatters = const [],
  });

  static Future<String?> showMaterialDialog({
    required BuildContext context,
    required Oration title,
    required Oration fieldTitle,
    bool barrierDismissible = true,
    Widget? icon,
    int? maxCharacter,
    int? maxLines,
    String initialText = '',
    List<ValueValidator> validators = const [],
    List<TextInputFormatter> inputFormatters = const [],
  }) {
    return DialogUtilities.showWidgetAsMaterialDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context, dialogOperator) => Flex(
        direction: Axis.vertical,
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: MaxiTransparentButton(
              icon: const Icon(Icons.close),
              onTouch: () => dialogOperator.defineResult(context),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Divider(height: 5),
          ),
          TextDialog(
            title: title,
            fieldTitle: fieldTitle,
            icon: icon,
            maxCharacter: maxCharacter,
            maxLines: maxLines,
            initialText: initialText,
            validators: validators,
            inputFormatters: inputFormatters,
            onDone: (x) => dialogOperator.defineResult(context, x),
          ),
        ],
      ),
    );
  }

  @override
  State<TextDialog> createState() => _TextDialogState();
}

class _TextDialogState extends StateWithLifeCycle<TextDialog> {
  late FormFieldManager formManager;

  @override
  void initState() {
    super.initState();

    formManager = joinObject(item: FormFieldManager(values: {'text': widget.initialText}));
  }

  @override
  Widget build(BuildContext context) {
    return Flex(
      direction: Axis.vertical,
      mainAxisSize: MainAxisSize.min,
      children: [
        MaxiTranslatableText(text: widget.title),
        const SizedBox(height: 5),
        FormText(
          propertyName: 'text',
          title: widget.fieldTitle,
          icon: widget.icon,
          inputFormatters: widget.inputFormatters,
          validators: widget.validators,
          manager: formManager,
          maxLines: widget.maxLines,
          maxCharacter: widget.maxCharacter,
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Divider(height: 5),
        ),
        MaxiFlex(
          rowFrom: 500,
          expandRow: true,
          columnCrossAxisAlignment: CrossAxisAlignment.stretch,
          rowMainAxisAlignment: MainAxisAlignment.end,
          children: [
            MaxiBuildBox(
              cached: false,
              reloaders: () => [formManager.notifyStatusChange.map((_) => true)],
              builer: (_) => MaxiTransparentButton(
                textColor: Colors.green,
                enable: formManager.isValid,
                icon: widget.icon,
                text: const Oration(message: 'Done'),
                onTouch: _onTouchDone,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _onTouchDone() {
    if (formManager.isValid) {
      widget.onDone(formManager.getValue(propertyName: 'text') ?? '');
    }
  }
}
