import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:maxi_flutter_library/src/forms/one_value_form_field_implementation.dart';
import 'package:maxi_library/maxi_library.dart';

class FormNumber extends OneValueFormField<num> {
  final bool enable;
  final String title;
  final Widget? icon;
  final num? minimum;
  final num? maximum;
  final double interval;
  final bool isDecimal;
  final bool showButtons;
  final bool expandHorizontally;
  final void Function(num, NegativeResult?)? onSubmitted;

  const FormNumber({
    required super.propertyName,
    required this.title,
    required this.isDecimal,
    super.key,
    super.manager,
    super.validators,
    super.onChangeValue,
    super.getterInitialValue,
    this.icon,
    this.enable = true,
    this.minimum,
    this.maximum,
    this.interval = 1,
    this.showButtons = true,
    this.expandHorizontally = false,
    this.onSubmitted,
  });

  @override
  OneValueFormFieldImplementation<num, OneValueFormField<num>> createState() => _FormNumberState();
}

class _FormNumberState extends OneValueFormFieldImplementation<num, FormNumber> {
  late double minimum;
  late double maximum;

  late final TextEditingController textController;

  @override
  num get getDefaultValue => minimum;

  late String previousText;

  late bool _wasValid;

  @override
  void initState() {
    final range = widget.validators.selectByType<CheckNumberRange>();
    if (widget.maximum != null) {
      maximum = widget.maximum!.toDouble();
    } else if (range != null) {
      maximum = range.maximum.toDouble();
    } else {
      maximum = double.infinity;
    }

    if (widget.minimum != null) {
      minimum = widget.minimum!.toDouble();
    } else if (range != null && range.minimum.toDouble() != double.negativeInfinity) {
      minimum = range.minimum.toDouble();
    } else {
      minimum = 0;
    }

    super.initState();

    textController = joinObject(item: TextEditingController());

    previousText = _formatText(actualValue);
    textController.text = previousText;

    textController.addListener(_changeTextController);
    _wasValid = isValid;
  }

  @override
  void renderingNewValue(num newValue) {
    if (previousText != _formatText(newValue) || _wasValid != isValid) {
      previousText = _formatText(newValue);
      textController.text = previousText;
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  Widget buildField(BuildContext context) {
    if (widget.showButtons) {
      return Flex(
        direction: Axis.horizontal,
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(child: _buildTextField(context)),
          ..._buildButtons(context),
        ],
      );
    } else {
      return _buildTextField(context);
    }
  }

  String _formatText(num value) {
    if (widget.isDecimal) {
      return value.toString();
    } else {
      return value.toString().split('.').first;
    }
  }

  Widget _buildTextField(BuildContext context) {
    return TextField(
      enabled: widget.enable,
      controller: textController,
      textAlign: TextAlign.end,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: widget.title,
        icon: widget.icon,
        errorText: isValid ? null : lastError.message.toString(),
      ),
      inputFormatters: _makeInputFormatters(),
      onChanged: (x) => _changeText(x),
      onSubmitted: (x) {
        _changeText(x);
        if (widget.onSubmitted != null) {
          widget.onSubmitted!(actualValue, isValid ? null : lastError);
        }
      },
    );
  }

  List<TextInputFormatter> _makeInputFormatters() {
    if (widget.isDecimal) {
      if (maximum != double.infinity) {
        return [LengthLimitingTextInputFormatter(maximum.toString().replaceAll('.0', '').length + 2)];
      } else {
        return [];
      }
    } else {
      if (maximum != double.infinity) {
        return [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(maximum.toString().replaceAll('.0', '').length)];
      } else {
        return [FilteringTextInputFormatter.digitsOnly];
      }
    }
  }

  void _changeText(String text) {
    if (text == previousText) {
      return;
    }

    late final double? dio;

    if (text == '') {
      dio = 0;
    } else {
      dio = double.tryParse(text);
    }

    if (dio == null) {
      textController.text = previousText.toString();
      return;
    }
    /*

    if (minimum > dio) {
      //textController.text = _formatText(minimum);
      declareFailded(
        error: NegativeResult(
          identifier: NegativeResultCodes.invalidValue,
          message: tr('The minimum accepted is %1', [minimum]),
        ),
        value: dio,
      );
      return;
    }

    if (maximum < dio) {
      //textController.text = _formatText(maximum);
      declareFailded(
        error: NegativeResult(
          identifier: NegativeResultCodes.invalidValue,
          message: tr('The maximum accepted is %1', [maximum]),
        ),
        value: dio,
      );
      return;
    }*/

    declareChangedValue(value: dio);
  }

  @override
  NegativeResult? validateValue({required value}) {
    if (minimum > value) {
      //textController.text = _formatText(minimum);
      return NegativeResult(
        identifier: NegativeResultCodes.invalidValue,
        message: tr('The minimum accepted is %1', [minimum]),
      );
    }

    if (maximum < value) {
      //textController.text = _formatText(maximum);
      return NegativeResult(
        identifier: NegativeResultCodes.invalidValue,
        message: tr('The maximum accepted is %1', [maximum]),
      );
    }

    return super.validateValue(value: value);
  }

  void _changeTextController() {
    _changeText(textController.text);
  }

  List<Widget> _buildButtons(BuildContext context) {
    final enableIncrease = widget.enable && isValid && actualValue < maximum;
    final enableDecrease = widget.enable && isValid && actualValue > minimum;

    return [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3.0),
        child: OutlinedButton(
          onPressed: enableIncrease ? _increase : null,
          style: OutlinedButton.styleFrom(
            foregroundColor: enableIncrease ? Colors.blue.shade700 : Colors.grey,
            padding: const EdgeInsets.all(2.0),
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero, side: BorderSide(color: Colors.transparent)),
          ),
          child: const Icon(Icons.add),
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3.0),
        child: TextButton(
          onPressed: enableDecrease ? _decrease : null,
          style: TextButton.styleFrom(foregroundColor: enableDecrease ? Colors.blue.shade700 : Colors.grey),
          child: const Icon(Icons.remove),
        ),
      ),
    ];
  }

  void _increase() {
    final newValue = actualValue + widget.interval;
    if (newValue > maximum) {
      declareChangedValue(value: maximum);
    } else {
      declareChangedValue(value: newValue);
    }
  }

  void _decrease() {
    final newValue = actualValue - widget.interval;
    if (newValue < minimum) {
      declareChangedValue(value: minimum);
    } else {
      declareChangedValue(value: newValue);
    }
  }
}
