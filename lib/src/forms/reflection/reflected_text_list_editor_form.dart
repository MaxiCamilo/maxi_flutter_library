import 'package:flutter/material.dart';
import 'package:maxi_flutter_library/src/forms/fields/form_text_list_editor.dart';
import 'package:maxi_flutter_library/src/forms/reflection_field_implementation.dart';
import 'package:maxi_library/maxi_library.dart';

class ReflectedTextListEditorForm extends ReflectionFieldImplementation {
  final Oration? title;
  final bool useListView;
  final Color firstBackgroudColor;
  final Color secondBackgroundColor;

  const ReflectedTextListEditorForm({
    super.key,
    required super.entityType,
    required super.propertyName,
    required super.fieldManager,
    required this.useListView,
    this.firstBackgroudColor = const Color.fromARGB(55, 71, 71, 71),
    this.secondBackgroundColor = const Color.fromARGB(120, 71, 71, 71),
    this.title,
  });

  @override
  State<StatefulWidget> createState() => _StateReflectedTextListEditorForm();
}

class _StateReflectedTextListEditorForm extends StateReflectionFieldImplementation<ReflectedTextListEditorForm> {
  @override
  Widget build(BuildContext context) {
    return FormTextListEditor(
      propertyName: widget.propertyName,
      useListView: widget.useListView,
      formalName: fieldReflection.formalName,
      firstBackgroudColor: widget.firstBackgroudColor,
      secondBackgroundColor: widget.secondBackgroundColor,
      validators: validators,
      manager: widget.fieldManager,
    );
  }
}
