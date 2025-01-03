import 'package:flutter/material.dart';
import 'package:maxi_flutter_library/maxi_flutter_library.dart';
import 'package:maxi_library/maxi_library.dart';

class FormDateButton extends OneValueFormField<DateTime> {
  final Widget? icon;
  final TranslatableText? textIfEmpty;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColors;
  final double padding;
  final double circularRadius;
  final double borderWidth;
  final DateTime? initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final void Function(DateTime)? onChangeDate;

  const FormDateButton({
    super.key,
    required super.propertyName,
    required this.firstDate,
    required this.lastDate,
    super.formalName = TranslatableText.empty,
    super.manager,
    super.validators,
    super.onChangeValue,
    super.getterInitialValue,
    this.textIfEmpty,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.padding = 2.0,
    this.circularRadius = 5.0,
    this.borderWidth = 1.0,
    this.borderColors,
    this.initialDate,
    this.onChangeDate,
  });

  @override
  OneValueFormFieldImplementation<DateTime, OneValueFormField<DateTime>> createState() => _FormDateButton();
}

class _FormDateButton extends OneValueFormFieldImplementation<DateTime, FormDateButton> {
  DateTime? actualDate;
  late TranslatableText buttonText;

  @override
  DateTime get getDefaultValue => actualDate ?? DateTime.now();

  @override
  void initState() {
    actualDate = widget.initialDate;

    if (actualDate == null) {
      buttonText = TranslatableText.empty;
    } else {
      buttonText = AlreadyTranslatedText(message: TextUtilities.formatDate(actualDate!, putTime: false));
    }

    super.initState();
  }

  @override
  void renderingNewValue(DateTime newValue) {
    actualDate = newValue;
    buttonText = AlreadyTranslatedText(message: TextUtilities.formatDate(actualDate!, putTime: false));

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget buildField(BuildContext context) {
    return MaxiTransparentButton(
      text: buttonText,
      backgroundColor: widget.backgroundColor,
      borderColors: widget.borderColors,
      borderWidth: widget.borderWidth,
      circularRadius: widget.circularRadius,
      icon: widget.icon,
      padding: widget.padding,
      textColor: widget.textColor,
      onTouch: _onTouch,
    );
  }

  Future<void> _onTouch() async {
    final result = await showDatePicker(
      context: context,
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      initialDate: actualDate,
      firstDate: widget.firstDate,
      lastDate: widget.lastDate,
    );

    if (result != null) {
      declareChangedValue(value: result);
      if (widget.onChangeDate != null) {
        widget.onChangeDate!(result);
      }
    }
  }
}
