import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:maxi_flutter_library/src/forms/one_value_form_field_implementation.dart';
import 'package:maxi_library/maxi_library.dart';

class FormDropDown<T> extends OneValueFormField<T> {
  final Map<T, Widget> Function() optionsBuild;
  final Widget? icon;
  final bool isExpanded;

  final Widget? hint;
  final Widget? disabledHint;
  final void Function()? onTap;
  final void Function(T)? onSelected;
  final int elevation;
  final TextStyle? style;
  final Widget? underline;
  final Color? iconDisabledColor;
  final Color? iconEnabledColor;
  final double iconSize;
  final bool isDense;
  final double? itemHeight;
  final double? menuWidth;
  final Color? focusColor;
  final FocusNode? focusNode;
  final bool autofocus;
  final Color? dropdownColor;
  final double? menuMaxHeight;
  final bool? enableFeedback;
  final AlignmentGeometry alignment;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;

  const FormDropDown({
    required super.propertyName,
    required this.optionsBuild,
    super.formalName = TranslatableText.empty,
    this.onSelected,
    super.key,
    super.manager,
    super.getterInitialValue,
    super.onChangeValue,
    super.validators,
    this.icon,
    this.isExpanded = false,
    this.hint,
    this.disabledHint,
    this.onTap,
    this.elevation = 8,
    this.underline,
    this.iconDisabledColor,
    this.iconEnabledColor,
    this.iconSize = 24.0,
    this.isDense = false,
    this.itemHeight = kMinInteractiveDimension,
    this.menuWidth,
    this.focusColor,
    this.focusNode,
    this.autofocus = false,
    this.dropdownColor,
    this.menuMaxHeight,
    this.enableFeedback,
    this.alignment = AlignmentDirectional.centerStart,
    this.borderRadius,
    this.padding,
    this.style,
  });

  @override
  OneValueFormFieldImplementation<T, OneValueFormField<T>> createState() => _StateFormDropDown<T>();
}

class _StateFormDropDown<T> extends OneValueFormFieldImplementation<T, FormDropDown<T>> {
  late Map<T, Widget> _optionsMap;
  late List<DropdownMenuItem<T>> _optionWidgets;

  @override
  T get getDefaultValue => _optionsMap.entries.first.key;

  @override
  void initState() {
    _optionsMap = widget.optionsBuild();
    _optionWidgets = _optionsMap.entries.map<DropdownMenuItem<T>>((MapEntry<T, Widget> value) {
      return DropdownMenuItem<T>(
        value: value.key,
        child: value.value,
      );
    }).toList();
    checkProgrammingFailure(thatChecks: tr('Options list is not empty'), result: () => _optionWidgets.isNotEmpty);
    super.initState();
  }

  @override
  Widget buildField(BuildContext context) {
    final otherMap = widget.optionsBuild();
    if (_optionsMap != otherMap && !mapEquals(otherMap, _optionsMap)) {
      _optionsMap = otherMap;
      _optionWidgets = _optionsMap.entries.map<DropdownMenuItem<T>>((MapEntry<T, Widget> value) {
        return DropdownMenuItem<T>(
          value: value.key,
          child: value.value,
        );
      }).toList();

      if (!_optionsMap.containsKey(actualValue) && _optionsMap.isNotEmpty) {
        declareChangedValue(value: _optionsMap.entries.first.key);
      }
    }

    return DropdownButton<T>(
      isExpanded: widget.isExpanded,
      value: actualValue,
      icon: widget.icon,
      onChanged: (dynamic value) {
        if (value is! T) {
          return;
        }
        declareChangedValue(value: value);
        if (widget.onSelected != null) {
          widget.onSelected!(value);
        }
      },
      items: _optionWidgets,
      hint: widget.hint,
      disabledHint: widget.disabledHint,
      onTap: widget.onTap,
      elevation: widget.elevation,
      underline: widget.underline,
      iconDisabledColor: widget.iconDisabledColor,
      iconEnabledColor: widget.iconEnabledColor,
      iconSize: widget.iconSize,
      isDense: widget.isDense,
      itemHeight: widget.itemHeight,
      menuWidth: widget.menuWidth,
      focusColor: widget.focusColor,
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      dropdownColor: widget.dropdownColor,
      menuMaxHeight: widget.menuMaxHeight,
      enableFeedback: widget.enableFeedback,
      alignment: widget.alignment,
      borderRadius: widget.borderRadius,
      padding: widget.padding,
      style: widget.style,
    );
  }

  @override
  void renderingNewValue(T newValue) {
    setState(() {});
  }
}
