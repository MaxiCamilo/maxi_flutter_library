import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:maxi_flutter_library/maxi_flutter_library.dart';
import 'package:maxi_library/maxi_library.dart';

class FormNumber extends OneValueFormField<num> {
  final bool enable;
  final Oration title;
  final Widget? icon;
  final num? minimum;
  final num? maximum;
  final double interval;
  final int maxDecimalDigit;
  final bool isDecimal;
  final bool showButtons;
  final bool expandHorizontally;

  final void Function(num, NegativeResult?)? onSubmitted;

  const FormNumber({
    required super.propertyName,
    required this.title,
    required this.isDecimal,
    super.formalName = Oration.empty,
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
    this.maxDecimalDigit = 2,
    this.onSubmitted,
  });

  @override
  OneValueFormFieldImplementation<num, OneValueFormField<num>> createState() => _FormNumberState();
}

class _FormNumberState extends OneValueFormFieldImplementation<num, FormNumber> {
  late double minimum;
  late double maximum;
  late String translateTitle;
  late FocusNode focusNode;

  num actualNumberOnField = 0;

  bool firstSelection = true;

  late final TextEditingController textController;

  @override
  num get getDefaultValue => minimum;

  late String previousText;

  late bool _wasValid;

  @override
  void initState() {
    translateTitle = widget.title.toString();
    focusNode = joinObject(item: FocusNode());
    focusNode.addListener(focusChange);

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

    previousText = _formatText(widget.isDecimal ? actualValue.toDouble() : actualValue.toInt());
    actualNumberOnField = actualValue;
    textController.text = previousText;

    textController.addListener(_changeTextController);
    _wasValid = isValid;
  }

  @override
  void dispose() {
    focusNode.removeListener(focusChange);
    super.dispose();
  }

  @override
  void renderingNewValue(num newValue) {
    final lastBaseOffset = textController.selection.baseOffset;

    if (previousText != _formatText(newValue) || _wasValid != isValid) {
      previousText = _formatText(newValue);

      textController.text = previousText;

      if (lastBaseOffset >= 0 && lastBaseOffset < textController.text.length) {
        textController.selection = TextSelection.collapsed(offset: lastBaseOffset);
      } else {
        textController.selection = TextSelection.collapsed(offset: textController.text.length);
      }

      //log(newValue.toString());
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _buildTextField(context)),
          _buildButtons(context),
        ],
      );
    } else {
      return _buildTextField(context);
    }
  }

  String _formatText(num value) {
    if (widget.isDecimal) {
      /*
      final decimalText = value.toString();
      final decimalParts = decimalText.split('.');
      if (decimalParts.last.length == widget.maxDecimalDigit) {
        return value.toString();
      }
      else if(decimalParts.last.length > widget.maxDecimalDigit){

      }
      else{

      }*/
      return value.toString();
    } else {
      return value.toString().split('.').first;
    }
  }

  Widget _buildTextField(BuildContext context) {
    return TextField(
      focusNode: focusNode,
      enabled: widget.enable,
      controller: textController,
      textAlign: TextAlign.end,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: translateTitle,
        icon: widget.icon,
        errorText: isValid ? null : lastError.message.toString(),
      ),
      inputFormatters: _makeInputFormatters(),
      onChanged: (x) => _reactChangeText(x),
      onSubmitted: (x) {
        _reactChangeText(x);
        if (widget.onSubmitted != null) {
          widget.onSubmitted!(actualValue, isValid ? null : lastError);
        }
      },
    );
  }

  List<TextInputFormatter> _makeInputFormatters() {
    if (widget.isDecimal) {
      if (maximum != double.infinity) {
        return [LengthLimitingTextInputFormatter(maximum.toString().split('.').first.length + widget.maxDecimalDigit + 1)];
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

  void _reactChangeText(String text) {
    if (text == previousText) {
      return;
    }

    late final double? dio;

    if (text == '') {
      return;
    }

    if (text.last == '-') {
      textController.text = previousText.toString();
      selectIntegerSection();
      return;
    }

    dio = double.tryParse(text);

    if (dio == actualNumberOnField) {
      return;
    }

    if (dio == null) {
      final diferentChar = containError(function: () => previousText.getDifferences(text).first.$3);
      if ((diferentChar != null && (diferentChar == '.' || diferentChar == ',')) || text.last == '.') {
        textController.text = previousText.toString();
        selectDecimalSection();
        return;
      } else if ((diferentChar != null && (diferentChar == '-' || diferentChar == ' ')) || text.last == '-') {
        textController.text = previousText.toString();
        selectIntegerSection();
        return;
      }

      final lastBaseOffset = textController.selection.baseOffset - 1;
      textController.text = previousText.toString();
      if (lastBaseOffset >= 0 && lastBaseOffset < textController.text.length) {
        textController.selection = TextSelection.collapsed(offset: lastBaseOffset);
      } else {
        textController.selection = TextSelection.collapsed(offset: textController.text.length);
      }
      return;
    }

    if (widget.isDecimal) {
      final numParts = textController.text.split('.');
      if (numParts.length >= 2 && numParts.first.isEmpty) {
        textController.text = dio.toString();
        textController.selection = const TextSelection(baseOffset: 0, extentOffset: 1);
      }
    }

    actualNumberOnField = dio;

    if (actualNumberOnField < minimum && minimum >= 0 && actualNumberOnField < 0) {
      textController.text = previousText.toString();
      selectIntegerSection();
      return;
    }

    declareChangedValue(value: dio);
  }

  @override
  NegativeResult? validateValue({required value}) {
    if (minimum > value) {
      //textController.text = _formatText(minimum);
      return NegativeResult(
        identifier: NegativeResultCodes.invalidValue,
        message: Oration(message: 'The minimum accepted is %1', textParts: [minimum]),
      );
    }

    if (maximum < value) {
      //textController.text = _formatText(maximum);
      return NegativeResult(
        identifier: NegativeResultCodes.invalidValue,
        message: Oration(message: 'The maximum accepted is %1', textParts: [maximum]),
      );
    }

    return super.validateValue(value: value);
  }

  void _changeTextController() {
    _reactChangeText(textController.text);
  }

  Widget _buildButtons(BuildContext context) {
    final enableIncrease = widget.enable && isValid && actualValue < maximum;
    final enableDecrease = widget.enable && isValid && actualValue > minimum;

    return Flex(direction: Axis.vertical, children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3.0),
        child: MaxiTapArea(
          onTouch: enableIncrease ? _increase : null,
          child: Icon(Icons.arrow_drop_up, color: enableIncrease ? Colors.blue.shade700 : Colors.grey),
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3.0),
        child: MaxiTapArea(
          onTouch: enableDecrease ? _decrease : null,
          child: Icon(Icons.arrow_drop_down, color: enableDecrease ? Colors.blue.shade700 : Colors.grey),
        ),
      ),
    ]);
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

  void focusChange() {
    if (widget.isDecimal) {
      if (focusNode.hasFocus) {
        HardwareKeyboard.instance.addHandler(checkPointKey);
      } else {
        HardwareKeyboard.instance.removeHandler(checkPointKey);
      }
    }

    if (firstSelection) {
      firstSelection = false;
      //if (widget.isDecimal) {
      selectIntegerSection();
      //}
    }

    if (!focusNode.hasFocus) {
      firstSelection = true;
      if (textController.text == '') {
        textController.text = _formatText(minimum);
        declareChangedValue(value: minimum);
      }
    }
  }

  bool checkPointKey(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.period || event.logicalKey == LogicalKeyboardKey.comma) {
        if (widget.isDecimal) {
          maxiScheduleMicrotask(selectDecimalSection);
        }

        return true;
      }
    }
    return false;
  }

  void selectIntegerSection() {
    final intLength = textController.text.split('.').first.length;
    textController.selection = TextSelection(baseOffset: 0, extentOffset: intLength);
  }

  void selectDecimalSection() {
    renderingNewValue(actualValue);
    final comaPosition = textController.text.indexOf('.');
    if (comaPosition > -1) {
      textController.selection = TextSelection(baseOffset: comaPosition + 1, extentOffset: textController.text.length);
    }
  }
}
