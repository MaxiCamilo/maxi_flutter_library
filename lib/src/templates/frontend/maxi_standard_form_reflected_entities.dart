import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:maxi_flutter_library/maxi_flutter_library.dart';
import 'package:maxi_library/maxi_library.dart';

class MaxiStandardFormReflectedEntities<T> extends StatefulWidget {
  final double determiningWidthShowScroll;
  final double determiningHeigthShowScroll;
  final Oration title;
  final double? titleSize;
  final bool expandVertically;
  final bool allowToRestoreValues;
  final double? maxWidth;

  final Widget Function({required BuildContext context, required IFormFieldManager fieldManager, required void Function() defineAsApplied}) builder;

  final IFormFieldManager Function()? operatorGetter;
  final T? Function()? initialValue;

  final void Function(BuildContext)? onCancel;
  final FutureOr Function(BuildContext, T) onApply;
  final void Function(BuildContext, T)? onApplyDone;
  final bool tryToCorrectNames;

  const MaxiStandardFormReflectedEntities({
    required this.title,
    required this.onApply,
    required this.builder,
    super.key,
    this.determiningWidthShowScroll = 500,
    this.determiningHeigthShowScroll = 500,
    this.expandVertically = true,
    this.allowToRestoreValues = true,
    this.tryToCorrectNames = false,
    this.titleSize,
    this.maxWidth,
    this.operatorGetter,
    this.onCancel,
    this.onApplyDone,
    this.initialValue,
  });

  static Future<T?> showBottomSheet<T>({
    required BuildContext context,
    required Oration title,
    required FutureOr Function(BuildContext, T) onApply,
    required Widget Function({required BuildContext context, required IFormFieldManager fieldManager, required void Function() defineAsApplied}) builder,
    double determiningWidthShowScroll = 500,
    double determiningHeigthShowScroll = 500,
    double? titleSize,
    double? maxWidth,
    bool expandVertically = true,
    bool allowToRestoreValues = true,
    IFormFieldManager Function()? operatorGetter,
    T? initialValue,
    void Function(BuildContext)? onCancel,
    void Function(BuildContext, T)? onApplyDone,
    Color? backgroundColor,
    bool tryToCorrectNames = false,
  }) {
    return DialogUtilities.showWidgetAsBottomSheet<T>(
      context: context,
      backgroundColor: backgroundColor,
      builder: (context, dialogOperator) => MaxiStandardFormReflectedEntities<T>(
        title: title,
        builder: builder,
        determiningWidthShowScroll: determiningWidthShowScroll,
        determiningHeigthShowScroll: determiningHeigthShowScroll,
        expandVertically: expandVertically,
        allowToRestoreValues: allowToRestoreValues,
        titleSize: titleSize,
        maxWidth: maxWidth,
        operatorGetter: operatorGetter,
        initialValue: initialValue == null ? null : () => initialValue,
        tryToCorrectNames: tryToCorrectNames,
        onApply: onApply,
        onCancel: (context) {
          dialogOperator.defineResult(context);
          if (onCancel != null) {
            onCancel(context);
          }
        },
        onApplyDone: (context, x) {
          dialogOperator.defineResult(context, x);
          if (onApplyDone != null) {
            onApplyDone(context, x);
          }
        },
      ),
    );
  }

  static Future<T?> showMaterialDialog<T>({
    required BuildContext context,
    required Oration title,
    required FutureOr Function(BuildContext, T) onApply,
    required Widget Function({required BuildContext context, required IFormFieldManager fieldManager, required void Function() defineAsApplied}) builder,
    bool barrierDismissible = true,
    double determiningWidthShowScroll = 500,
    double determiningHeigthShowScroll = 500,
    double? titleSize,
    double? maxWidth,
    bool expandVertically = true,
    bool allowToRestoreValues = true,
    IFormFieldManager Function()? operatorGetter,
    T? initialValue,
    void Function(BuildContext)? onCancel,
    void Function(BuildContext, T)? onApplyDone,
    bool tryToCorrectNames = false,
  }) {
    return DialogUtilities.showWidgetAsMaterialDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context, dialogOperator) => MaxiStandardFormReflectedEntities<T>(
        builder: builder,
        title: title,
        determiningWidthShowScroll: determiningWidthShowScroll,
        determiningHeigthShowScroll: determiningHeigthShowScroll,
        expandVertically: expandVertically,
        maxWidth: maxWidth,
        allowToRestoreValues: allowToRestoreValues,
        titleSize: titleSize,
        operatorGetter: operatorGetter,
        initialValue: initialValue == null ? null : () => initialValue,
        tryToCorrectNames: tryToCorrectNames,
        onApply: onApply,
        onCancel: (context) {
          dialogOperator.defineResult(context);
          if (onCancel != null) {
            onCancel(context);
          }
        },
        onApplyDone: (context, x) {
          dialogOperator.defineResult(context, x);
          if (onApplyDone != null) {
            onApplyDone(context, x);
          }
        },
      ),
    );
  }

  @override
  State<MaxiStandardFormReflectedEntities<T>> createState() => _MaxiStandardFormReflectedEntitiesState<T>();
}

class _MaxiStandardFormReflectedEntitiesState<T> extends State<MaxiStandardFormReflectedEntities<T>> {
  late final Map<String, dynamic> intialValues;
  late final ITypeEntityReflection reflector;
  late final IFormFieldManager fieldManager;

  T? lastValue;

  @override
  void initState() {
    super.initState();

    reflector = ReflectionManager.getReflectionEntity(T);
    if (widget.initialValue == null) {
      if (widget.operatorGetter == null) {
        intialValues = reflector.serializeToMap(reflector.buildEntity());
      } else {
        intialValues = widget.operatorGetter!().createMap(onlyIfIsValid: false);
      }
    } else {
      final item = widget.initialValue!();
      if (item != null) {
        intialValues = reflector.serializeToMap(item);
      } else {
        intialValues = {};
      }
    }

    if (widget.operatorGetter == null) {
      fieldManager = FormFieldManager(values: intialValues);
    } else {
      fieldManager = widget.operatorGetter!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaxiStandardForm(
      builder: widget.builder,
      title: widget.title,
      titleSize: widget.titleSize,
      allowToRestoreValues: widget.allowToRestoreValues,
      determiningHeigthShowScroll: widget.determiningHeigthShowScroll,
      determiningWidthShowScroll: widget.determiningWidthShowScroll,
      expandVertically: widget.expandVertically,
      onCancel: widget.onCancel,
      maxWidth: widget.maxWidth,
      valueGetter: () => intialValues,
      operatorGetter: () => fieldManager,
      onApply: _onApply,
      onApplyDone: (context, x) {
        if (widget.onApplyDone != null) {
          if (x is T) {
            widget.onApplyDone!(context, x);
          } else if (x == null) {
            widget.onApplyDone!(context, lastValue as T);
          } else {
            log('[MaxiStandardFormReflectedEntities] A result of type $T was expected, but one of type ${x.runtimeType} was received');
          }
        }
      },
    );
  }

  Future _onApply(BuildContext context, Map<String, dynamic> rawValue) async {
    final newValue = reflector.interpret(value: rawValue, tryToCorrectNames: widget.tryToCorrectNames) as T;
    lastValue = newValue;
    return widget.onApply(context, newValue);
  }
}
