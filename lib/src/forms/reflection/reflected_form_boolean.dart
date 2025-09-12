import 'package:flutter/widgets.dart';
import 'package:maxi_flutter_library/maxi_flutter_library.dart';
import 'package:maxi_flutter_library/src/forms/reflection_field_implementation.dart';
import 'package:maxi_library/maxi_library.dart';

class ReflectedFormBoolean extends ReflectionFieldImplementation {
  final bool useSwitch;
  final bool expandHorizontally;
  final Oration? description;
  final Widget? icon;
  final void Function(bool, NegativeResult?)? onChangeValue;

  const ReflectedFormBoolean({
    super.key,
    required super.entityType,
    required super.propertyName,
    required super.fieldManager,
    required this.useSwitch,
    required this.expandHorizontally,
    required this.description,
    this.icon,
    this.onChangeValue,
  });

  @override
  State<StatefulWidget> createState() => _StateReflectedFormBoolean();
}

class _StateReflectedFormBoolean extends StateReflectionFieldImplementation<ReflectedFormBoolean> {
  late final Oration _translatedDescription;

  @override
  void initState() {
    super.initState();

    _translatedDescription = (widget.description ?? Description.searchDescription(annotations: fieldReflection.annotations));
  }

  @override
  Widget build(BuildContext context) {
    return FormBoolean(
      propertyName: widget.propertyName,
      formalName: fieldReflection.formalName,
      expandHorizontally: widget.expandHorizontally,
      description: _translatedDescription,
      useSwitch: widget.useSwitch,
      manager: widget.fieldManager,
      icon: widget.icon,
      onChangeValue: widget.onChangeValue,
    );
  }
}
