import 'dart:async';

import 'package:flutter/material.dart';
import 'package:maxi_flutter_library/maxi_flutter_library.dart';
import 'package:maxi_library/maxi_library.dart';

class MaxiSelectableList<T> extends StatefulWidget {
  final FutureOr<List<Stream<bool>>> Function()? reloaders;
  final FutureOr<List<Stream>> Function()? valueUpdaters;
  final int Function(T) gettetIdentifier;
  final FutureOr<List<T>> Function(int id, String filtre, bool reverse) valueGetter;
  final Widget Function(BuildContext cont, T item, int ind) childGenerator;
  final List<int> Function()? initialSelected;
  final Widget Function(BuildContext)? emptyGenerator;
  final void Function(IMaxiSelectableList<T>)? onCreatedOperator;
  final bool Function()? ascendant;
  final Duration waitingReupdated;
  final Duration animationDuration;
  final Curve animationCurve;

  final bool touchingMakesSelecting;
  final bool showReverseButton;

  const MaxiSelectableList({
    super.key,
    required this.gettetIdentifier,
    required this.valueGetter,
    required this.childGenerator,
    this.initialSelected,
    this.reloaders,
    this.valueUpdaters,
    this.emptyGenerator,
    this.onCreatedOperator,
    this.ascendant,
    this.touchingMakesSelecting = true,
    this.waitingReupdated = const Duration(seconds: 1),
    this.animationDuration = const Duration(milliseconds: 500),
    this.animationCurve = Curves.decelerate,
    this.showReverseButton = true,
  });

  Future<List<int>?> showDialog({
    required BuildContext context,
    Oration? title,
    Oration? buttonDone,
    double? width,
    IconData doneIcon = Icons.done,
  }) {
    IMaxiSelectableList<T>? listOperator;
    return DialogUtilities.showWidgetAsMaterialDialog<List<int>>(
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
            Flex(
              direction: Axis.horizontal,
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                MaxiTransparentButton(
                  icon: const Icon(Icons.checklist),
                  onTouch: () => listOperator?.selectAll(),
                ),
                const SizedBox(width: 10),
                MaxiTransparentButton(
                  icon: const Icon(Icons.list),
                  onTouch: () => listOperator?.deselectAll(),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Divider(height: 5),
            ),
            Expanded(
              child: MaxiSelectableList<T>(
                childGenerator: childGenerator,
                gettetIdentifier: gettetIdentifier,
                valueGetter: valueGetter,
                reloaders: reloaders,
                emptyGenerator: emptyGenerator,
                animationCurve: animationCurve,
                animationDuration: animationDuration,
                ascendant: ascendant,
                initialSelected: initialSelected,
                touchingMakesSelecting: touchingMakesSelecting,
                waitingReupdated: waitingReupdated,
                valueUpdaters: valueUpdaters,
                onCreatedOperator: (x) => listOperator = x,
                showReverseButton: showReverseButton,
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Divider(height: 5),
            ),
            Align(
              alignment: Alignment.topRight,
              child: MaxiTransparentButton(
                icon: Icon(doneIcon),
                textColor: Colors.green,
                text: buttonDone ?? const Oration(message: 'Done'),
                onTouch: () => dialogOperator.defineResult(context, listOperator?.selectedIdentifiers),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  State<MaxiSelectableList<T>> createState() => _MaxiSelectableListState<T>();
}

mixin IMaxiSelectableList<T> {
  Stream<(int, bool, List<int>)> get onChangeSelectedList;
  List<int> get selectedIdentifiers;
  void selectAll();
  void deselectAll();
}

class _MaxiSelectableListState<T> extends StateWithLifeCycle<MaxiSelectableList<T>> with IMaxiSelectableList<T> {
  late Set<int> _selectedIdentifiers;
  late StreamController<(int, bool, List<int>)> selectedIdentifiersController;
  late FormFieldManager formOperator;
  late MaxiContinuousListOperator<T> listOperator;

  final synchronizerSelect = Semaphore();

  @override
  List<int> get selectedIdentifiers => _selectedIdentifiers.toList();
  @override
  Stream<(int, bool, List<int>)> get onChangeSelectedList => selectedIdentifiersController.stream;

  @override
  void initState() {
    super.initState();

    _selectedIdentifiers = widget.initialSelected == null ? <int>{} : Set.from(widget.initialSelected!());

    formOperator = joinObject(item: FormFieldManager());
    selectedIdentifiersController = createEventController<(int, bool, List<int>)>(isBroadcast: true);

    for (final id in _selectedIdentifiers) {
      formOperator.setValue(propertyName: id.toString(), value: true);
    }

    if (widget.onCreatedOperator != null) {
      widget.onCreatedOperator!(this);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaxiItemList(
      valueGetter: widget.valueGetter,
      childGenerator: childGenerator,
      gettetIdentifier: widget.gettetIdentifier,
      animationCurve: widget.animationCurve,
      animationDuration: widget.animationDuration,
      startReverse: widget.ascendant == null ? false : !widget.ascendant!(),
      emptyGenerator: widget.emptyGenerator,
      reloaders: widget.reloaders,
      valueUpdaters: widget.valueUpdaters,
      waitingReupdated: widget.waitingReupdated,
      onCreatedOperator: (x) => listOperator = x,
      showReverseButton: widget.showReverseButton,
    );
  }

  Widget childGenerator(BuildContext cont, T item, int ind) {
    if (widget.touchingMakesSelecting) {
      return MaxiTapArea(
        onTouch: () => onTouchSelectInBackground(item),
        child: makeRectangle(cont, item, ind),
      );
    } else {
      return makeRectangle(cont, item, ind);
    }
  }

  Widget makeRectangle(BuildContext cont, T item, int ind) {
    final id = widget.gettetIdentifier(item);

    return Flex(
      direction: Axis.horizontal,
      mainAxisSize: MainAxisSize.max,
      children: [
        FormBoolean(
          propertyName: id.toString(),
          expandHorizontally: false,
          description: Oration.empty,
          useSwitch: false,
          manager: formOperator,
          onChangeValue: (x, _) => onTouchItemChecked(id, x),
        ),
        const SizedBox(width: 10),
        Expanded(child: widget.childGenerator(cont, item, ind)),
      ],
    );
  }

  void onTouchSelectInBackground(T item) {
    final id = widget.gettetIdentifier(item);
    final isChecked = _selectedIdentifiers.contains(id);

    if (isChecked) {
      formOperator.setValue(propertyName: id.toString(), value: false);
    } else {
      formOperator.setValue(propertyName: id.toString(), value: true);
    }
  }

  void onTouchItemChecked(int id, bool isChecked) {
    if (isChecked) {
      _selectedIdentifiers.add(id);
      if (selectedIdentifiersController.hasListener) {
        selectedIdentifiersController.add((id, true, selectedIdentifiers));
      }
    } else {
      _selectedIdentifiers.remove(id);
      if (selectedIdentifiersController.hasListener) {
        selectedIdentifiersController.add((id, true, selectedIdentifiers));
      }
    }
  }

  @override
  void deselectAll() {
    synchronizerSelect.executeIfStopped(function: _deselectAll);
  }

  @override
  void selectAll() {
    synchronizerSelect.executeIfStopped(function: _selectAll);
  }

  Future<void> _selectAll() async {
    final antennaList = await ListUtilities.getFromFunctionWithRange(getter: (id, _) => widget.valueGetter(id, '', false));
    final antennaID = antennaList.map((x) => widget.gettetIdentifier(x)).toList(growable: false);

    _selectedIdentifiers.clear();
    _selectedIdentifiers.addAll(antennaID);
    listOperator.updateValue();
    for (final id in antennaID) {
      formOperator.setValue(propertyName: id.toString(), value: true);
      if (selectedIdentifiersController.hasListener) {
        selectedIdentifiersController.add((id, true, antennaID));
      }
    }
  }

  Future<void> _deselectAll() async {
    final antennaList = await ListUtilities.getFromFunctionWithRange(getter: (id, _) => widget.valueGetter(id, '', false));
    final antennaID = antennaList.map((x) => widget.gettetIdentifier(x)).toList(growable: false);

    _selectedIdentifiers.clear();
    listOperator.updateValue();
    for (final id in antennaID) {
      formOperator.setValue(propertyName: id.toString(), value: false);
      if (selectedIdentifiersController.hasListener) {
        selectedIdentifiersController.add((id, false, antennaID));
      }
    }
  }
}
