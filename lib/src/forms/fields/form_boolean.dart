import 'package:flutter/material.dart';
import 'package:maxi_flutter_library/maxi_flutter_library.dart';
import 'package:maxi_flutter_library/src/forms/one_value_form_field_implementation.dart';

class FormBoolean extends OneValueFormField<bool> {
  final bool useSwitch;
  final bool expandHorizontally;
  final String description;

  const FormBoolean({
    required super.propertyName,
    super.key,
    super.manager,
    super.getterInitialValue,
    super.onChangeValue,
    super.validators,
    this.useSwitch = false,
    required this.expandHorizontally,
    required this.description,
  });

  @override
  OneValueFormFieldImplementation<bool, OneValueFormField<bool>> createState() => _FormBooleanState();
}

class _FormBooleanState extends OneValueFormFieldImplementation<bool, FormBoolean> {
  @override
  bool get getDefaultValue => false;

  bool? _currentRenderedValue;

  @override
  Widget buildField(BuildContext context) {
    final content = _buildInteractField(context);

    if (isValid) {
      return content;
    } else {
      return Flex(
        direction: Axis.vertical,
        mainAxisSize: MainAxisSize.min,
        children: [
          content,
          const SizedBox(height: 7),
          Flex(
            direction: Axis.horizontal,
            mainAxisSize: widget.expandHorizontally ? MainAxisSize.max : MainAxisSize.min,
            children: [
              const Icon(Icons.error),
              const SizedBox(width: 7),
              widget.expandHorizontally
                  ? Expanded(
                      child: MaxiText(
                      text: lastError.message.toString(),
                      textColor: Colors.red,
                    ))
                  : MaxiText(
                      text: lastError.message.toString(),
                      textColor: Colors.red,
                    ),
            ],
          )
        ],
      );
    }
  }

  Widget _buildInteractField(BuildContext context) {
    final list = <Widget>[];

    if (widget.useSwitch) {
      list.add(Switch(value: actualValue, onChanged: (x) => declareChangedValue(value: x)));
    } else {
      list.add(Checkbox(
          value: actualValue,
          onChanged: (x) {
            if (x != null) {
              declareChangedValue(value: x);
            }
          }));
    }

    if (widget.description.isNotEmpty) {
      list.add(const SizedBox(width: 10));
      if (widget.expandHorizontally) {
        list.add(MaxiText(text: widget.description));
      } else {
        list.add(Expanded(child: MaxiText(text: widget.description)));
      }
    }

    return Flex(
      direction: Axis.horizontal,
      mainAxisSize: widget.expandHorizontally ? MainAxisSize.max : MainAxisSize.min,
      children: list,
    );
  }

  @override
  void renderingNewValue(bool newValue) {
    if (_currentRenderedValue == null || _currentRenderedValue != newValue) {
      _currentRenderedValue = newValue;
      setState(() {});
    }
  }
}
