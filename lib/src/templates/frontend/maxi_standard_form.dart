import 'dart:async';

import 'package:flutter/material.dart';
import 'package:maxi_flutter_library/maxi_flutter_library.dart';
import 'package:maxi_library/export_reflectors.dart';

class MaxiStandardForm extends StatefulWidget {
  final double determiningWidthShowScroll;
  final double determiningHeigthShowScroll;
  final Oration title;
  final double? titleSize;
  final bool expandVertically;
  final bool allowToRestoreValues;
  final double? maxWidth;

  final Widget Function({required BuildContext context, required IFormFieldManager fieldManager, required void Function() defineAsApplied}) builder;

  final IFormFieldManager Function()? operatorGetter;
  final Map<String, dynamic> Function()? valueGetter;

  final void Function(BuildContext)? onCancel;
  final FutureOr Function(BuildContext, Map<String, dynamic>)? onApply;
  final void Function(BuildContext, dynamic)? onApplyDone;

  const MaxiStandardForm({
    required this.title,
    required this.onApply,
    required this.builder,
    super.key,
    this.determiningWidthShowScroll = 500,
    this.determiningHeigthShowScroll = 500,
    this.expandVertically = true,
    this.allowToRestoreValues = true,
    this.maxWidth,
    this.titleSize,
    this.operatorGetter,
    this.onCancel,
    this.onApplyDone,
    this.valueGetter,
  });

  static Future showBottomSheet({
    required BuildContext context,
    required Oration title,
    required FutureOr Function(BuildContext, Map<String, dynamic>)? onApply,
    required Widget Function({required BuildContext context, required IFormFieldManager fieldManager, required void Function() defineAsApplied}) builder,
    double determiningWidthShowScroll = 500,
    double determiningHeigthShowScroll = 500,
    bool expandVertically = true,
    bool allowToRestoreValues = true,
    Color? backgroundColor,
    double? titleSize,
    double? maxWidth,
    IFormFieldManager Function()? operatorGetter,
    Map<String, dynamic> Function()? valueGetter,
    void Function(BuildContext)? onCancel,
    final void Function(BuildContext, dynamic)? onApplyDone,
  }) async {
    return DialogUtilities.showWidgetAsBottomSheet(
      context: context,
      backgroundColor: backgroundColor,
      builder: (context, dialogOperator) => MaxiStandardForm(
        builder: builder,
        title: title,
        determiningWidthShowScroll: determiningWidthShowScroll,
        determiningHeigthShowScroll: determiningHeigthShowScroll,
        expandVertically: expandVertically,
        allowToRestoreValues: allowToRestoreValues,
        titleSize: titleSize,
        operatorGetter: operatorGetter,
        valueGetter: valueGetter,
        maxWidth: maxWidth,
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

  static Future showMaterialDialog({
    required BuildContext context,
    required Oration title,
    required FutureOr Function(BuildContext, Map<String, dynamic>)? onApply,
    required Widget Function({required BuildContext context, required IFormFieldManager fieldManager, required void Function() defineAsApplied}) builder,
    double determiningWidthShowScroll = 500,
    double determiningHeigthShowScroll = 500,
    bool expandVertically = true,
    bool allowToRestoreValues = true,
    bool barrierDismissible = true,
    double? titleSize,
    double? maxWidth,
    IFormFieldManager Function()? operatorGetter,
    Map<String, dynamic> Function()? valueGetter,
    void Function(BuildContext)? onCancel,
    final void Function(BuildContext, dynamic)? onApplyDone,
  }) {
    return DialogUtilities.showWidgetAsMaterialDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context, dialogOperator) => MaxiStandardForm(
        builder: builder,
        title: title,
        maxWidth: maxWidth,
        determiningWidthShowScroll: determiningWidthShowScroll,
        determiningHeigthShowScroll: determiningHeigthShowScroll,
        expandVertically: expandVertically,
        allowToRestoreValues: allowToRestoreValues,
        titleSize: titleSize,
        operatorGetter: operatorGetter,
        valueGetter: valueGetter,
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
  State<MaxiStandardForm> createState() => _MaxiStandardFormState();
}

class _MaxiStandardFormState extends State<MaxiStandardForm> {
  late IMaxiDarkenInteractionOperator darkenInteractionOperator;

  late final IFormFieldManager fieldManager;
  late IMaxiErrorPosterOperator errorPosterOperator;

  late final Map<String, dynamic> originalValues;

  @override
  void initState() {
    super.initState();

    if (widget.operatorGetter == null) {
      fieldManager = FormFieldManager(values: {});
    } else {
      fieldManager = widget.operatorGetter!();
    }

    if (widget.valueGetter == null) {
      originalValues = {};
    } else {
      originalValues = Map.from(widget.valueGetter!());
      fieldManager.setSeveralValues(originalValues);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaxiDarkenInteractionWidget(
      isEnabled: true,
      onCreatedOperator: (x) => darkenInteractionOperator = x,
      child: widget.maxWidth == null ? buildBody(context) : SizedBox(width: widget.maxWidth, child: buildBody(context)),
    );
  }

  Widget buildBody(BuildContext context) {
    return MaxiBodyWithHeaderAndFooter(
      determiningWidth: widget.determiningWidthShowScroll,
      determiningHeigth: widget.determiningHeigthShowScroll,
      expandVertically: widget.expandVertically,
      header: _buildHeader(context),
      body: widget.builder(context: context, fieldManager: fieldManager, defineAsApplied: _onTocuhApply),
      footer: _buildFooter(context),
    );
  }

  Widget _buildHeader(BuildContext context) {
    if (widget.onCancel == null) {
      return Flex(
        direction: Axis.vertical,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MaxiTranslatableText(text: widget.title, size: widget.titleSize, bold: true),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Divider(height: 5),
          ),
        ],
      );
    } else {
      return Flex(
        direction: Axis.vertical,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Flex(
            direction: Axis.horizontal,
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(child: MaxiTranslatableText(text: widget.title, size: widget.titleSize, bold: true)),
              const SizedBox(width: 5),
              MaxiTransparentButton(
                icon: const Icon(Icons.close),
                onTouch: widget.onCancel == null ? null : () => widget.onCancel!(context),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Divider(height: 5),
          ),
        ],
      );
    }
  }

  Widget _buildFooter(BuildContext context) {
    return Flex(
      direction: Axis.vertical,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Divider(height: 5),
        ),
        MaxiErrorPoster(
          onCreatedOperator: (x) => errorPosterOperator = x,
          padding: const EdgeInsets.only(bottom: 5.0),
        ),
        MaxiFlex(
          rowFrom: 500,
          rowMainAxisAlignment: MainAxisAlignment.spaceBetween,
          expandRow: true,
          reverseColumn: true,
          columnCrossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            widget.allowToRestoreValues
                ? MaxiTransparentButton(
                    icon: const Icon(Icons.restore),
                    text: const Oration(message: 'Restore'),
                    onTouch: _onTocuhRestore,
                  )
                : const SizedBox(),
            const SizedBox(height: 5.0, width: 5.0),
            MaxiBuildBox(
              cached: true,
              reloaders: () => [fieldManager.notifyStatusChange.map((_) => false)],
              builer: (_) => MaxiTransparentButton(
                textColor: Colors.greenAccent,
                text: const Oration(message: 'Apply'),
                icon: const Icon(Icons.done, color: Colors.greenAccent),
                enable: fieldManager.isValid,
                onTouch: _onTocuhApply,
              ),
            ),
          ],
        )
      ],
    );
  }

  void _onTocuhRestore() {
    fieldManager.setSeveralValues(Map.from(originalValues));
  }

  void _onTocuhApply() {
    darkenInteractionOperator.executeFunction(
      function: () async {
        final values = fieldManager.createMap(onlyIfIsValid: true);
        return await widget.onApply!(context, values);
      },
      posterError: errorPosterOperator,
      onDone: (x) async {
        await continueOtherFutures();
        if (x is TextableFunctionality) {
          darkenInteractionOperator.executeTextableFunctionality(
            functionality: x,
            posterError: errorPosterOperator,
            onDone: (y) {
              if (widget.onApplyDone != null) {
                widget.onApplyDone!(context, y);
              }
            },
          );
        } else if (widget.onApplyDone != null && mounted) {
          widget.onApplyDone!(context, x);
        }
      },
    );
  }
}
