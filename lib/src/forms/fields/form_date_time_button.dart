import 'package:flutter/material.dart';
import 'package:maxi_flutter_library/maxi_flutter_library.dart';
import 'package:maxi_library/maxi_library.dart';

class FormDateTimeButton extends OneValueFormField<DateTime> {
  final Oration? textIfEmpty;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColors;
  final double padding;
  final double circularRadius;
  final double borderWidth;
  final DateTime? initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final bool showDateButton;
  final bool showTimeButton;
  final void Function(DateTime)? onChangeDate;

  const FormDateTimeButton({
    super.key,
    required super.propertyName,
    required this.firstDate,
    required this.lastDate,
    super.formalName = Oration.empty,
    super.manager,
    super.validators,
    super.onChangeValue,
    super.getterInitialValue,
    this.textIfEmpty,
    this.backgroundColor,
    this.textColor,
    this.padding = 2.0,
    this.circularRadius = 5.0,
    this.borderWidth = 1.0,
    this.borderColors,
    this.initialDate,
    this.onChangeDate,
    this.showDateButton = true,
    this.showTimeButton = true,
  });

  @override
  OneValueFormFieldImplementation<DateTime, OneValueFormField<DateTime>> createState() => _FormDateButton();
}

class _FormDateButton extends OneValueFormFieldImplementation<DateTime, FormDateTimeButton> {
  late Oration buttonDateText;
  late Oration buttonTimeText;

  @override
  DateTime get getDefaultValue => DateTime.now();

  @override
  void initState() {
    super.initState();

    buttonDateText = TranslatedOration(message: TextUtilities.formatDate(actualValue, putTime: false));
    buttonTimeText = TranslatedOration(message: '${TextUtilities.zeroFill(value: actualValue.hour, quantityZeros: 2)}:${TextUtilities.zeroFill(value: actualValue.minute, quantityZeros: 2)}');
  }

  @override
  void renderingNewValue(DateTime newValue) {
    buttonDateText = TranslatedOration(message: TextUtilities.formatDate(actualValue, putTime: false));
    buttonTimeText = TranslatedOration(message: '${TextUtilities.zeroFill(value: actualValue.hour, quantityZeros: 2)}:${TextUtilities.zeroFill(value: actualValue.minute, quantityZeros: 2)}');

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget buildField(BuildContext context) {
    if (widget.showDateButton && widget.showTimeButton) {
      return Wrap(
        spacing: 8.0,
        runSpacing: 8.0,
        children: [
          _buildDateButton(context),
          _buildTimeButton(context),
        ],
      );
    } else if (widget.showDateButton) {
      return _buildDateButton(context);
    } else {
      return _buildTimeButton(context);
    }
  }

  Widget _buildDateButton(BuildContext context) {
    return MaxiTransparentButton(
      text: buttonDateText,
      backgroundColor: widget.backgroundColor,
      borderColors: widget.borderColors,
      borderWidth: widget.borderWidth,
      circularRadius: widget.circularRadius,
      icon: const Icon(Icons.calendar_month),
      padding: widget.padding,
      textColor: widget.textColor,
      onTouch: _onTouchDate,
    );
  }

  Widget _buildTimeButton(BuildContext context) {
    return MaxiTransparentButton(
      text: buttonTimeText,
      backgroundColor: widget.backgroundColor,
      borderColors: widget.borderColors,
      borderWidth: widget.borderWidth,
      circularRadius: widget.circularRadius,
      icon: const Icon(Icons.access_time),
      padding: widget.padding,
      textColor: widget.textColor,
      onTouch: _onTouchTime,
    );
  }

  Future<void> _onTouchDate() async {
    DateTime? result = await showDatePicker(
      context: context,
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      initialDate: actualValue,
      firstDate: widget.firstDate,
      lastDate: widget.lastDate,
      cancelText: const Oration(message: 'Cancel').toString(),
      confirmText: const Oration(message: 'Done').toString(),
    );

    if (result != null) {
      result = DateTime(
        result.year,
        result.month,
        result.day,
        actualValue.hour,
        actualValue.minute,
        actualValue.second,
      );

      declareChangedValue(value: result);
      if (widget.onChangeDate != null) {
        widget.onChangeDate!(result);
      }
    }
  }

  @override
  DateTime? convertUnknownValue(dynamic value) {
    return _formatData(value);
  }

  DateTime _formatData(value) {
    if (value == null || value == 0) {
      return DateTime.now();
    }
    return GeneralConverter(value).toDateTime(propertyName: const Oration(message: 'Date'), isLocal: false).toLocal();
  }

  Future<void> _onTouchTime() async {
    final result = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(actualValue),
      cancelText: const Oration(message: 'Cancel').toString(),
      confirmText: const Oration(message: 'Done').toString(),
    );

    if (result != null) {
      DateTime newValue = DateTime(
        actualValue.year,
        actualValue.month,
        actualValue.day,
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
