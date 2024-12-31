import 'package:flutter/material.dart';
import 'package:maxi_flutter_library/maxi_flutter_library.dart';
import 'package:maxi_library/maxi_library.dart';

abstract class ReflectionFieldImplementation extends StatefulWidget {
  final Type entityType;
  final String propertyName;
  final IFormFieldManager fieldManager;

  const ReflectionFieldImplementation({super.key, required this.entityType, required this.propertyName, required this.fieldManager});
}

abstract class StateReflectionFieldImplementation<T extends ReflectionFieldImplementation> extends State<T> {
  late final ITypeEntityReflection classReflection;
  late final IFieldReflection fieldReflection;

  TranslatableText get formalName => fieldReflection.formalName;
  List<ValueValidator> get validators => fieldReflection.validators;

  @override
  void initState() {
    super.initState();

    classReflection = ReflectionManager.getReflectionEntity(widget.entityType);
    fieldReflection = volatile(detail: tr('Property %1 was not found on entity %2', [widget.propertyName, classReflection.name]), function: () => classReflection.fields.selectItem((x) => x.name == widget.propertyName)!);
  }
}
