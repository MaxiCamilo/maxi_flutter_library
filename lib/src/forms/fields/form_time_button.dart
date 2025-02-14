import 'package:flutter/material.dart';
import 'package:maxi_flutter_library/maxi_flutter_library.dart';
import 'package:maxi_library/maxi_library.dart';

class FormTimeButton extends OneValueFormField<DateTime> {
  final Widget? icon;
  final Oration? textIfEmpty;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColors;
  final double padding;
  final double circularRadius;
  final double borderWidth;
  final DateTime? initialDate;
  final void Function(DateTime)? onChangeDate;

  const FormTimeButton({
    super.key,
    required super.propertyName,
    super.formalName = Oration.empty,
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
  OneValueFormFieldImplementation<DateTime, OneValueFormField<DateTime>> createState() => _FormTimeButton();
}

class _FormTimeButton extends OneValueFormFieldImplementation<DateTime, FormTimeButton> {
  DateTime? actualDate;
  late Oration buttonText;

  @override
  DateTime get getDefaultValue => actualDate ?? DateTime.now();

  @override
  void initState() {
    actualDate = widget.initialDate;

    if (actualDate == null) {
      buttonText = Oration.empty;
    } else {
      buttonText = _createText();
    }

    super.initState();
  }

  Oration _createText() {
    return TranslatedOration(message: '${actualDate?.hour}:${actualDate?.minute}');
  }

  @override
  void renderingNewValue(DateTime newValue) {
    actualDate = newValue;
    buttonText = _createText();

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
    final result = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(actualValue),
      cancelText: const Oration(message: 'Cancel').toString(),
      confirmText: const Oration(message: 'Done').toString(),
    );

    if (result != null) {
      actualDate ??= DateTime.now();
      final newValue = DateTime(
        actualDate!.year,
        actualDate!.month,
        actualDate!.day,
        result.hour,
        result.minute,
        0,
      );
      declareChangedValue(value: newValue);
      if (widget.onChangeDate != null) {
        widget.onChangeDate!(newValue);
      }
    }
  }
}
