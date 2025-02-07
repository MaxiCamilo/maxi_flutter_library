import 'package:flutter/widgets.dart';
import 'package:maxi_flutter_library/maxi_flutter_library.dart';
import 'package:maxi_flutter_library/src/forms/reflection_field_implementation.dart';
import 'package:maxi_library/maxi_library.dart';

class ReflectedFormEnum extends ReflectionFieldImplementation {
  final bool expandHorizontally;
  final Widget? icon;
  final bool useDropdown;
  final Widget Function(dynamic)? widgetBuilder;

  const ReflectedFormEnum({
    super.key,
    required super.entityType,
    required super.propertyName,
    required super.fieldManager,
    required this.expandHorizontally,
    this.widgetBuilder,
    this.icon,
    this.useDropdown = true,
  });

  @override
  State<StatefulWidget> createState() => _StateReflectedFormEnum();
}

class _StateReflectedFormEnum extends StateReflectionFieldImplementation<ReflectedFormEnum> {
  late final TypeEnumeratorReflector enumType;
  late final Map<dynamic, Widget> widgetOptions;

  List<EnumOption> get optionsList => enumType.optionsList;
  late final Enum _initialValue;

  @override
  void initState() {
    super.initState();

    enumType = volatile(detail: tr('Property %1 is not an Enum', [widget.propertyName]), function: () => fieldReflection.reflectedType as TypeEnumeratorReflector);

    widgetOptions = {};
    for (final opt in optionsList) {
      if (widget.widgetBuilder == null) {
        widgetOptions[opt.value] = _createStandardOption(opt);
      } else {
        widgetOptions[opt.value] = widget.widgetBuilder!(opt);
      }
    }

    final rawInitialValue = widget.fieldManager.getValue(propertyName: widget.propertyName);
    if (rawInitialValue != null) {
      _initialValue = _convertRawValue(rawInitialValue);
    } else {
      _initialValue = optionsList.first.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.useDropdown) {
      return FormDropDown(
        propertyName: widget.propertyName,
        formalName: fieldReflection.formalName,
        optionsBuild: () => widgetOptions,
        getterInitialValue: () => _initialValue,
        onChangeValue: _dropdownChanged,
      );
    } else {
      return FormToggles(
        propertyName: widget.propertyName,
        formalName: fieldReflection.formalName,
        options: widgetOptions,
        selecteds: [_initialValue],
        isSingleOption: true,
        onChangeValue: _togglesChanged,
      );
    }
  }

  Widget _createStandardOption(EnumOption opt) {
    if (opt.description.isEmpty) {
      return MaxiTranslatableText(text: opt.formalName, bold: true);
    } else {
      return Flex(
        direction: Axis.vertical,
        mainAxisSize: MainAxisSize.min,
        children: [
          MaxiTranslatableText(text: opt.formalName, bold: true),
          const SizedBox(height: 3),
          MaxiTranslatableText(text: opt.description),
        ],
      );
    }
  }

  Enum _convertRawValue(rawInitialValue) {
    if (rawInitialValue is int) {
      return volatile(
        detail: tr('Option %1 not found in the enumeration', [rawInitialValue]),
        function: () => optionsList.selectItem((x) => x.position == rawInitialValue)!.value,
      );
    } else if (rawInitialValue is String) {
      return volatile(
        detail: tr('Option %1 not found in the enumeration', [rawInitialValue]),
        function: () => optionsList.selectItem((x) => x.name.toLowerCase() == rawInitialValue.toLowerCase())!.value,
      );
    } else if (rawInitialValue is Enum) {
      return volatile(
        detail: tr('Option %1 not found in the enumeration', [rawInitialValue]),
        function: () => optionsList.selectItem((x) => x.value == rawInitialValue)!.value,
      );
    } else {
      throw NegativeResult(
        identifier: NegativeResultCodes.wrongType,
        message: tr('This widget only uses integer, string or Enum values;  but a type %1 was defined', [rawInitialValue.runtimeType]),
      );
    }
  }

  void _dropdownChanged(dynamic value, NegativeResult? error) {
    widget.fieldManager.setValue(propertyName: widget.propertyName, value: value);
  }

  void _togglesChanged(List list, NegativeResult? error) {
    widget.fieldManager.setValue(propertyName: widget.propertyName, value: [list]);
  }
}
