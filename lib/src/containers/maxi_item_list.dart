import 'dart:async';

import 'package:flutter/material.dart';
import 'package:maxi_flutter_library/maxi_flutter_library.dart';
import 'package:maxi_library/export_reflectors.dart';

class MaxiItemList<T> extends StatefulWidget {
  final FutureOr<List<Stream<bool>>> Function()? reloaders;
  final FutureOr<List<Stream>> Function()? valueUpdaters;
  final int Function(T) gettetIdentifier;
  final FutureOr<List<T>> Function(int from, String nameFiltre, bool reverse) valueGetter;
  final Widget Function(BuildContext cont, T item, int ind) childGenerator;
  final Widget Function(BuildContext)? emptyGenerator;
  final bool startReverse;
  final Duration waitingReupdated;
  final Duration animationDuration;
  final Curve animationCurve;
  final Oration titleFiltre;
  final bool showReverseButton;
  final Color borderColor;
  final void Function(MaxiContinuousListOperator<T>)? onCreatedOperator;

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
    this.animationDuration = const Duration(milliseconds: 500),
    this.animationCurve = Curves.decelerate,
    this.startReverse = false,
    this.showReverseButton = true,
    this.borderColor = Colors.white,
    this.onCreatedOperator,
  });

  @override
  State<MaxiItemList<T>> createState() => _MaxiItemListState<T>();
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
            widget.showReverseButton
                ? MaxiTransparentButton(
                    icon: MaxiText(text: reverse ? '321' : '123'),
                    onTouch: () {
                      reverse = !reverse;
                      setState(() {});
                      listOperator?.ascendant = !reverse;
                    },
                  )
                : const SizedBox(),
            SizedBox(width: widget.showReverseButton ? 5 : 0),
            Expanded(
              child: FormText(
                propertyName: 'nameFitre',
                title: widget.titleFiltre,
                icon: const Icon(Icons.search),
                getterInitialValue: () => textFiltre,
                validators: const [CheckTextLength(maximum: 50, maximumLines: 1)],
                onChangeValue: (x, _) {
                  textFiltre = x;
                  listOperator?.updateValue();
                },
              ),
            ),
            const SizedBox(width: 5),
            MaxiTransparentButton(
              icon: const Padding(
                padding: EdgeInsets.symmetric(vertical: 7.0),
                child: Icon(Icons.update, size: 27),
              ),
              onTouch: () {
                listOperator?.updateValue();
              },
            ),
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
