import 'dart:async';

import 'package:flutter/material.dart';
import 'package:maxi_flutter_library/maxi_flutter_library.dart';
import 'package:maxi_library/export_reflectors.dart';

class MaxiItemList<T> extends StatefulWidget {
  final FutureOr<List<Stream<bool>>> Function()? reloaders;
  final FutureOr<List<Stream>> Function()? valueUpdaters;
  final int Function(T x) gettetIdentifier;
  final FutureOr<List<T>> Function(int from, String nameFiltre, bool reverse) valueGetter;
  final Widget Function(BuildContext cont, T item, int ind) childGenerator;
  final Widget Function(BuildContext)? emptyGenerator;
  final bool startReverse;
  final Duration waitingReupdated;
  final Duration animationDuration;
  final Curve animationCurve;
  final Oration titleFiltre;
  final bool showReverseButton;
  final bool showNameFiltre;
  final bool showUpdateButton;
  final Color borderColor;
  final int Function()? startFrom;
  final void Function(MaxiContinuousListOperator<T>)? onCreatedOperator;
  final Widget extraWidget;

  const MaxiItemList({
    super.key,
    required this.valueGetter,
    required this.childGenerator,
    required this.gettetIdentifier,
    this.reloaders,
    this.valueUpdaters,
    this.emptyGenerator,
    this.titleFiltre = const Oration(message: 'Filtre name'),
    this.waitingReupdated = const Duration(seconds: 1),
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.decelerate,
    this.startReverse = false,
    this.showReverseButton = true,
    this.showNameFiltre = true,
    this.borderColor = Colors.white,
    this.onCreatedOperator,
    this.startFrom,
    this.extraWidget = const SizedBox(),
    this.showUpdateButton = true,
  });

  @override
  State<MaxiItemList<T>> createState() => _MaxiItemListState<T>();

  Future<T?> showDialog({
    required BuildContext context,
    Oration? title,
    Oration? buttonDone,
    double? width,
    IconData doneIcon = Icons.done,
  }) {
    return DialogUtilities.showWidgetAsMaterialDialog<T>(
      context: context,
      builder: (context, dialogOperator) => SizedBox(
        //height: MediaQuery.of(context).size.height - 200,
        width: width ?? MediaQuery.of(context).size.width - 30,
        child: Flex(
          direction: Axis.vertical,
          mainAxisSize: MainAxisSize.min,
          children: [
            Flex(
              direction: Axis.horizontal,
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: title == null ? const SizedBox() : MaxiTranslatableText(text: title, bold: true, size: 24)),
                const SizedBox(width: 5),
                MaxiRectangle(
                  borderColor: Colors.white,
                  borderWidth: 1,
                  borderRadious: 45.0,
                  child: MaxiTapArea(
                    child: const Padding(
                      padding: EdgeInsets.all(2.0),
                      child: Icon(Icons.close),
                    ),
                    onTouch: () => dialogOperator.defineResult(context),
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Divider(height: 5),
            ),
            Expanded(
              child: MaxiItemList<T>(
                gettetIdentifier: gettetIdentifier,
                valueGetter: valueGetter,
                reloaders: reloaders,
                emptyGenerator: emptyGenerator,
                animationCurve: animationCurve,
                animationDuration: animationDuration,
                waitingReupdated: waitingReupdated,
                valueUpdaters: valueUpdaters,
                showReverseButton: showReverseButton,
                borderColor: borderColor,
                extraWidget: extraWidget,
                showNameFiltre: showNameFiltre,
                startFrom: startFrom,
                startReverse: startReverse,
                titleFiltre: titleFiltre,
                childGenerator: (cont, item, ind) => MaxiTapArea(
                  onTouch: () => dialogOperator.defineResult(context, item),
                  child: childGenerator(cont, item, ind),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MaxiItemListState<T> extends StateWithLifeCycle<MaxiItemList<T>> {
  String textFiltre = '';
  MaxiContinuousListOperator<T>? listOperator;

  bool reverse = false;

  @override
  void initState() {
    super.initState();

    reverse = widget.startReverse;
  }

  Widget buildOrderButton(BuildContext context) {
    return widget.showReverseButton
        ? MaxiTooltip(
            text: reverse ? const Oration(message: 'Change to ascending order') : const Oration(message: 'Change to descending order'),
            child: MaxiTransparentButton(
              icon: MaxiText(text: reverse ? '321' : '123'),
              onTouch: () {
                reverse = !reverse;
                setState(() {});
                listOperator?.ascendant = !reverse;
              },
            ),
          )
        : const SizedBox();
  }

  Widget buildUpdateButton(BuildContext context) {
    if (!widget.showUpdateButton) {
      return const SizedBox();
    }

    return MaxiTransparentButton(
      icon: const Icon(Icons.update, size: 27),
      onTouch: () {
        listOperator?.updateValue();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Flex(
      direction: Axis.vertical,
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Flex(
          direction: Axis.horizontal,
          mainAxisSize: MainAxisSize.max,
          children: [
            buildOrderButton(context),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.0),
              child: SizedBox(height: 40, child: VerticalDivider(width: 5)),
            ),
            Expanded(
              child: widget.showNameFiltre
                  ? FormText(
                      propertyName: 'nameFitre',
                      title: widget.titleFiltre,
                      icon: const Icon(Icons.search),
                      getterInitialValue: () => textFiltre,
                      validators: const [CheckTextLength(maximum: 50, maximumLines: 1)],
                      onChangeValue: (x, _) {
                        textFiltre = x;
                        listOperator?.updateValue();
                      },
                    )
                  : const SizedBox(),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.0),
              child: SizedBox(height: 40, child: VerticalDivider(width: 5)),
            ),
            buildUpdateButton(context),
            widget.extraWidget,
          ],
        ),
        Expanded(
          child: MaxiRectangle(
            margin: const EdgeInsets.only(top: 5.0),
            padding: const EdgeInsets.all(2.0),
            borderRadious: 5,
            borderColor: widget.borderColor,
            borderWidth: 1,
            child: MaxiContinuousList<T>(
              animationDuration: widget.animationDuration,
              animationCurve: widget.animationCurve,
              ascendant: () => !reverse,
              waitingReupdated: widget.waitingReupdated,
              valueUpdaters: widget.valueUpdaters,
              reloaders: widget.reloaders,
              valueGetter: (from) => widget.valueGetter(from, textFiltre, reverse),
              childGenerator: widget.childGenerator,
              gettetIdentifier: widget.gettetIdentifier,
              emptyGenerator: widget.emptyGenerator,
              startFrom: widget.startFrom,
              onCreatedOperator: (x) {
                listOperator = x;
                if (widget.onCreatedOperator != null) {
                  widget.onCreatedOperator!(x);
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}
