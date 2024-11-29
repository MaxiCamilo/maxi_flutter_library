import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:maxi_flutter_library/maxi_flutter_library.dart';
import 'package:maxi_flutter_library/src/forms/reflection_field_implementation.dart';
import 'package:maxi_library/maxi_library.dart';

class ReflectedFormText extends ReflectionFieldImplementation {
  final bool enable;
  final TranslatableText? title;
  final int? maxCharacter;
  final int? maxLines;
  final TextInputAction? inputAction;
  final Widget? icon;
  final void Function(String, NegativeResult?)? onChangeValue;
  final void Function(String, NegativeResult?)? onSubmitted;

  const ReflectedFormText({
    required super.entityType,
    required super.propertyName,
    required super.fieldManager,
    super.key,
    this.enable = true,
    this.title,
    this.maxCharacter,
    this.maxLines,
    this.inputAction,
    this.icon,
    this.onChangeValue,
    this.onSubmitted,
  });

  @override
  State<StatefulWidget> createState() => _StateReflectedFormText();
}

class _StateReflectedFormText extends StateReflectionFieldImplementation<ReflectedFormText> {
  late final String _translatedTitle;

  @override
  void initState() {
    super.initState();

    _translatedTitle = (widget.title ?? formalName).toString();
  }

  @override
  Widget build(BuildContext context) {
    return FormText(
      propertyName: widget.propertyName,
      title: _translatedTitle,
      enable: widget.enable,
      icon: widget.icon,
      inputAction: widget.inputAction,
      manager: widget.fieldManager,
      maxCharacter: widget.maxCharacter,
      maxLines: widget.maxLines,
      validators: validators,
      onChangeValue: widget.onChangeValue,
      onSubmitted: widget.onSubmitted,
    );
  }
}
