import 'dart:async';

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
  final FocusNode? focusNode;
  final Widget? icon;
  final void Function(String, NegativeResult?)? onSubmitted;
  final void Function(String)? onIsValid;
  final void Function(NegativeResult)? onIsInvalid;

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
    this.onSubmitted,
    this.onIsValid,
    this.focusNode,
    this.onIsInvalid,
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

  TranslatableText lastTextError = TranslatableText.empty;
  String lastTranslatedErrorText = '';

  @override
  void initState() {
    textController = joinObject(item: TextEditingController());
    super.initState();

    if (widget.maxCharacter != null) {
      maxCharacter = widget.maxCharacter;
      _maxLines = widget.maxLines;
    } else if (widget.validators.any((element) => element is CheckTextLength)) {
      final rango = widget.validators.firstWhere((element) => element is CheckTextLength) as CheckTextLength;
      maxCharacter = rango.maximum == double.infinity ? null : rango.maximum.toInt();
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
    if (newValue != textController.text || _wasValid != isValid || (!isValid && lastTextError != lastError.message)) {
      lastTextError = lastError.message;
      lastTranslatedErrorText = lastTextError.toString();
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
      focusNode: widget.focusNode,
      textInputAction: widget.inputAction,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: widget.title,
        icon: widget.icon,
        errorText: isValid ? null : lastTranslatedErrorText,
      ),
      inputFormatters: _createFormat(),
      onEditingComplete: () {
        declareChangedValue(value: textController.text);
      },
      onSubmitted: (_) {
        declareChangedValue(value: textController.text);
        if (widget.onSubmitted != null) {
          widget.onSubmitted!(actualValue, isValid ? null : lastError);
        }
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

  @override
  bool declareChangedValue({required String value}) {
    final wasValid = isValid;
    late final bool nowIsValid;

    if (ApplicationManager.instance.isWeb && textController.selection.start >= 0) {
      final position = textController.selection.start;

      final isCorrect = super.declareChangedValue(value: value);

      if (wasValid != isCorrect) {
        scheduleMicrotask(() {
          textController.value = TextEditingValue(
            text: textController.text,
            selection: TextSelection.collapsed(offset: textController.selection.end),
          );
          textController.selection = TextSelection.collapsed(offset: position);
        });
      }

      nowIsValid = isCorrect;
    } else {
      nowIsValid = super.declareChangedValue(value: value);
    }

    if (nowIsValid != wasValid) {
      if (nowIsValid && widget.onIsValid != null) {
        widget.onIsValid!(value);
      } else if (!nowIsValid && widget.onIsInvalid != null) {
        widget.onIsInvalid!(lastError);
      }
    }

    return nowIsValid;
  }
}
