import 'package:flutter/material.dart';
import 'package:maxi_flutter_library/src/forms/fields/form_number_list_editor.dart';
import 'package:maxi_flutter_library/src/forms/reflection_field_implementation.dart';
import 'package:maxi_library/maxi_library.dart';

class ReflectedFormNumberList extends ReflectionFieldImplementation {
  final TranslatableText? title;
  final bool useListView;
  final Color firstBackgroudColor;
  final Color secondBackgroundColor;

  final Widget Function(int position, num actualValue)? secondAction;

  const ReflectedFormNumberList({
    super.key,
    required super.entityType,
    required super.propertyName,
    required super.fieldManager,
    required this.useListView,
    this.secondAction,
    this.firstBackgroudColor = const Color.fromARGB(55, 71, 71, 71),
    this.secondBackgroundColor = const Color.fromARGB(120, 71, 71, 71),
    this.title,
  });

  @override
  State<ReflectedFormNumberList> createState() => _ReflectedFormNumberListState();
}

class _ReflectedFormNumberListState extends StateReflectionFieldImplementation<ReflectedFormNumberList> {
  late final bool isDecimal;

  @override
  void initState() {
    super.initState();
    isDecimal = fieldReflection.reflectedType.type != List<int>;
  }

  @override
  Widget build(BuildContext context) {
    return FormNumberListEditor(
      title: widget.title,
      propertyName: widget.propertyName,
      useListView: widget.useListView,
      formalName: fieldReflection.formalName,
      firstBackgroudColor: widget.firstBackgroudColor,
      secondBackgroundColor: widget.secondBackgroundColor,
      validators: validators,
      manager: widget.fieldManager,
      isDecimal: isDecimal,
      secondAction: widget.secondAction,
    );
  }
}
