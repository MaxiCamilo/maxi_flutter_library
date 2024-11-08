import 'package:flutter/widgets.dart';
import 'package:maxi_flutter_library/maxi_flutter_library.dart';
import 'package:maxi_flutter_library/src/forms/reflection_field_implementation.dart';
import 'package:maxi_library/maxi_library.dart';

class ReflectedFormBoolean extends ReflectionFieldImplementation {
  final bool useSwitch;
  final bool expandHorizontally;
  final TranslatableText? description;

  const ReflectedFormBoolean({
    super.key,
    required super.entityType,
    required super.propertyName,
    required super.fieldManager,
    required this.useSwitch,
    required this.expandHorizontally,
    required this.description,
  });

  @override
  State<StatefulWidget> createState() => _StateReflectedFormBoolean();
}

class _StateReflectedFormBoolean extends StateReflectionFieldImplementation<ReflectedFormBoolean> {
  late final String _translatedDescription;

  @override
  void initState() {
    super.initState();

    _translatedDescription = (widget.description ?? Description.searchDescription(annotations: fieldReflection.annotations)).toString();
  }

  @override
  Widget build(BuildContext context) {
    return FormBoolean(
      propertyName: widget.propertyName,
      expandHorizontally: widget.expandHorizontally,
      description: _translatedDescription,
    );
  }
}
