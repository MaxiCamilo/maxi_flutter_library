import 'package:flutter/material.dart';
import 'package:maxi_flutter_library/src/forms/one_value_form_field_implementation.dart';
import 'package:maxi_library/maxi_library.dart';

class FormToggles<T> extends OneValueFormField<List<T>> {
  final Map<T, Widget> options;
  final List<T> selecteds;
  final Axis direction;
  final bool isSingleOption;
  final void Function(List<T>)? onSelected;

  final MouseCursor? mouseCursor;
  final MaterialTapTargetSize? tapTargetSize;
  final TextStyle? textStyle;
  final BoxConstraints? constraints;
  final Color? color;
  final Color? selectedColor;
  final Color? disabledColor;
  final Color? fillColor;
  final Color? focusColor;
  final Color? highlightColor;
  final Color? hoverColor;
  final Color? splashColor;
  final bool renderBorder;
  final Color? borderColor;
  final Color? selectedBorderColor;
  final Color? disabledBorderColor;
  final BorderRadius? borderRadius;
  final double? borderWidth;
  final VerticalDirection verticalDirection;

  const FormToggles({
    required super.propertyName,
    required this.options,
    required this.selecteds,
    required this.isSingleOption,
    super.formalName = TranslatableText.empty,
    this.onSelected,
    super.key,
    super.manager,
    super.getterInitialValue,
    super.onChangeValue,
    super.validators,
    this.direction = Axis.vertical,
    this.mouseCursor,
    this.tapTargetSize,
    this.textStyle,
    this.constraints,
    this.color,
    this.selectedColor,
    this.disabledColor,
    this.fillColor,
    this.focusColor,
    this.highlightColor,
    this.hoverColor,
    this.splashColor,
    this.renderBorder = true,
    this.borderColor,
    this.selectedBorderColor,
    this.disabledBorderColor,
    this.borderRadius,
    this.borderWidth,
    this.verticalDirection = VerticalDirection.down,
  });

  @override
  OneValueFormFieldImplementation<List<T>, FormToggles<T>> createState() => _StateFormToggles<T>();
}

class _StateFormToggles<T> extends OneValueFormFieldImplementation<List<T>, FormToggles<T>> {
  late final List<DropdownMenuItem<T>> _optionWidgets;
  late final List<bool> _optionsSelecteds;

  late int _actualOptionPosition;

  @override
  List<T> get getDefaultValue => _getSelectedItems();

  @override
  void initState() {
    checkProgrammingFailure(thatChecks: tr('Options list is not empty'), result: () => widget.options.isNotEmpty);

    _optionWidgets = widget.options.entries.map<DropdownMenuItem<T>>((MapEntry<T, Widget> value) {
      return DropdownMenuItem<T>(
        value: value.key,
        child: value.value,
      );
    }).toList();

    _optionsSelecteds = _optionWidgets.map((x) => widget.selecteds.contains(x.value)).toList();

    checkProgrammingFailure(thatChecks: tr('in a single option, there is only one item selected'), result: () => !widget.isSingleOption || _optionsSelecteds.isEmpty || _optionsSelecteds.length == 1);

    if (widget.isSingleOption) {
      _actualOptionPosition = _optionsSelecteds.selectPosition((x) => x);
    }

    super.initState();
  }

  List<T> _getSelectedItems() {
    if (widget.isSingleOption) {
      if (_actualOptionPosition == -1) {
        return [];
      } else {
        return [_optionWidgets[_actualOptionPosition].value as T];
      }
    }

    final list = <T>[];
    for (int i = 0; i < _optionsSelecteds.length; i++) {
      if (_optionsSelecteds[i]) {
        list.add(_optionWidgets[i].value as T);
      }
    }

    return list;
  }

  @override
  Widget buildField(BuildContext context) {
    return ToggleButtons(
      direction: widget.direction,
      isSelected: _optionsSelecteds,
      mouseCursor: widget.mouseCursor,
      tapTargetSize: widget.tapTargetSize,
      textStyle: widget.textStyle,
      constraints: widget.constraints,
      color: widget.color,
      selectedColor: widget.selectedColor,
      disabledColor: widget.disabledColor,
      fillColor: widget.fillColor,
      focusColor: widget.focusColor,
      highlightColor: widget.highlightColor,
      hoverColor: widget.hoverColor,
      splashColor: widget.splashColor,
      renderBorder: widget.renderBorder,
      borderColor: widget.borderColor,
      selectedBorderColor: widget.selectedBorderColor,
      disabledBorderColor: widget.disabledBorderColor,
      borderRadius: widget.borderRadius,
      borderWidth: widget.borderWidth,
      verticalDirection: widget.verticalDirection,
      onPressed: _onPressed,
      children: _optionWidgets,
    );
  }

  @override
  void renderingNewValue(List<T> newValue) {
    setState(() {});
  }

  void _onPressed(int index) {
    if (index >= widget.options.length) {
      return;
    }

    if (widget.isSingleOption) {
      if (_actualOptionPosition > -1) {
        _optionsSelecteds[_actualOptionPosition] = false;
      }
      _actualOptionPosition = index;
      _optionsSelecteds[index] = true;
    } else {
      _optionsSelecteds[index] = !_optionsSelecteds[index];
    }

    final list = _getSelectedItems();

    declareChangedValue(value: list);
    if (widget.onSelected != null) {
      widget.onSelected!(list);
    }
  }
}
