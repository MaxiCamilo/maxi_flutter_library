import 'package:flutter/widgets.dart';
import 'package:maxi_flutter_library/maxi_flutter_library.dart';
import 'package:maxi_flutter_library/src/forms/reflection_field_implementation.dart';
import 'package:maxi_library/maxi_library.dart';

class ReflectionFormNumber extends ReflectionFieldImplementation {
  final bool enable;
  final TranslatableText? title;
  final Widget? icon;
  final double interval;
  final bool showButtons;
  final bool expandHorizontally;
  final void Function(num, NegativeResult?)? onSubmitted;

  const ReflectionFormNumber({
    super.key,
    required super.entityType,
    required super.propertyName,
    required super.fieldManager,
    this.enable = true,
    this.title,
    this.icon,
    this.interval = 1,
    this.showButtons = true,
    this.expandHorizontally = false,
    this.onSubmitted,
  });

  @override
  State<StatefulWidget> createState() => _StateReflectionFormNumber();
}

class _StateReflectionFormNumber extends StateReflectionFieldImplementation<ReflectionFormNumber> {
  late final String _translatedTitle;

  @override
  void initState() {
    super.initState();

    _translatedTitle = (widget.title ?? formalName).toString();
  }

  @override
  Widget build(BuildContext context) {
    return FormNumber(
      propertyName: widget.propertyName,
      title: _translatedTitle,
      manager: widget.fieldManager,
      enable: widget.enable,
      icon: widget.icon,
      isDecimal: fieldReflection.reflectedType.type != int,
      expandHorizontally: widget.expandHorizontally,
      interval: widget.interval,
      showButtons: widget.showButtons,
      onSubmitted: widget.onSubmitted,
    );
  }
}
