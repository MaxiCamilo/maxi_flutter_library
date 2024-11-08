import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:maxi_flutter_library/src/forms/one_value_form_field_implementation.dart';
import 'package:maxi_library/maxi_library.dart';

class FormText extends OneValueFormField<String> {
  final bool enable;
  final String title;
  final int? maxCharacter;
  final int? maxLines;
  final TextInputAction? inputAction;
  final Widget? icon;

  const FormText({
    required super.propertyName,
    required this.title,
    super.key,
    super.getterInitialValue,
    super.manager,
    super.validators,
    super.onChangeValue,
    this.enable = true,
    this.maxCharacter,
    this.maxLines,
    this.icon,
    this.inputAction,
  });

  @override
  OneValueFormFieldImplementation<String, FormText> createState() => _FormTextState();
}

class _FormTextState extends OneValueFormFieldImplementation<String, FormText> {
  late final TextEditingController textController;

  late final int? maxCharacter;

  @override
  String get getDefaultValue => '';

  late bool _wasValid;
  late int? _maxLines;

  @override
  void initState() {
    super.initState();

    textController = joinObject(item: TextEditingController());

    if (widget.maxCharacter != null) {
      maxCharacter = widget.maxCharacter;
      _maxLines = widget.maxLines;
    } else if (widget.validators.any((element) => element is CheckTextLength)) {
      final rango = widget.validators.firstWhere((element) => element is CheckTextLength) as CheckTextLength;
      maxCharacter = rango.maximum.toInt();
      _maxLines = rango.maximumLines ?? widget.maxLines;
    } else {
      maxCharacter = null;
      _maxLines = widget.maxLines;
    }

    textController.text = actualValue;
    textController.addListener(_textControllerChanger);
    _wasValid = isValid;
  }

  @override
  void renderingNewValue(String newValue) {
    if (newValue != textController.text || _wasValid != isValid) {
      _wasValid = isValid;
      textController.text = newValue;
      setState(() {});
    }
  }

  @override
  Widget buildField(BuildContext context) {
    return TextField(
      controller: textController,
      enabled: widget.enable,
      maxLines: _maxLines,
      textInputAction: widget.inputAction,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: widget.title,
        icon: widget.icon,
        errorText: isValid ? null : lastError.message.toString(),
      ),
      inputFormatters: _createFormat(),
      onEditingComplete: () {
        declareChangedValue(value: textController.text);
      },
      onSubmitted: (_) {
        declareChangedValue(value: textController.text);
      },
    );
  }

  List<TextInputFormatter> _createFormat() {
    if (maxCharacter != null) {
      return [LengthLimitingTextInputFormatter(maxCharacter!) /*, FilteringTextInputFormatter.allow(RegExp("^[a-zA-Z0-9_.,-ñÑ ]*\$"))*/];
    } else {
      return [];
    }
  }

  void _textControllerChanger() {
    declareChangedValue(value: textController.text);
  }
}
