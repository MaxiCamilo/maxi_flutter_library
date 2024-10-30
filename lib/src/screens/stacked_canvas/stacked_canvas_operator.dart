import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:maxi_flutter_library/src/screens/stacked_canvas/stacked_canvas_widget.dart';
import 'package:maxi_library/maxi_library.dart';

class StackedCanvasOperator {
  final _childers = <StackedCanvasWidget>[];
  final _notifyUpdate = StreamController<StackedCanvasOperator>.broadcast();
  final _notifyChangeSize = StreamController<BoxConstraints>.broadcast();

  List<StackedCanvasWidget>? _orderChildrers;
  BoxConstraints? currentSize;

  Stream<StackedCanvasOperator> get notifyUpdate => _notifyUpdate.stream;
  Stream<BoxConstraints> get notifyChangeSize => _notifyChangeSize.stream;

  static BoxConstraints getCurrentSize(BuildContext context) {
    final size = fromAncestor(context).currentSize;

    checkProgrammingFailure(thatChecks: tr('This function was consulted after running the rederizer'), result: () => size != null);

    return size!;
  }

  static StackedCanvasOperator fromAncestor(BuildContext context) {
    final located = fromAncestorOptional(context);
    if (located == null) {
      throw NegativeResult(
        identifier: NegativeResultCodes.contextInvalidFunctionality,
        message: tr('Widget is not encapsulated in a Stacked Canvas operator'),
      );
    }
    return located;
  }

  static StackedCanvasOperator? fromAncestorOptional(BuildContext context) {
    final located = StackedCanvasWidget.fromAncestorOptional(context);

    if (located == null) {
      return null;
    } else {
      return located.canvasOperator;
    }
  }

  StackedCanvasWidget createCanvas({
    required Widget child,
    required Duration animationDuration,
    Curve curve = Curves.linear,
    int? position,
    bool isVisible = true,
    double? left,
    double? top,
    double? right,
    double? bottom,
    double? width,
    double? height,
  }) {
    final newCanvas = StackedCanvasWidget(
      canvasOperator: this,
      child: child,
      duration: animationDuration,
      position: position ?? _childers.length,
      bottom: bottom,
      curve: curve,
      height: height,
      left: left,
      right: right,
      top: top,
      width: width,
    );

    addCanvas(newCanvas);
    return newCanvas;
  }

  void addCanvas(StackedCanvasWidget canvas) {
    _childers.add(canvas);
    notifyChildChanged(child: canvas);
  }

  void notifyChildChanged({required StackedCanvasWidget child}) {
    _orderChildrers = _childers.orderByFunction((x) => x.position);
    //SplayTreeMap<int, StackedCanvasWidget>.fromIterable(_childers, key: (x) => (x as StackedCanvasWidget).position, value: (x) => x).values.toList(growable: false);

    _notifyUpdate.add(this);
  }

  void removeAll() {
    _childers.clear();
    _orderChildrers?.clear();
    _notifyUpdate.add(this);
  }

  void dispose() {
    _childers.iterar((x) => x.dispose());
    _childers.clear();
    _notifyUpdate.close();
    _notifyChangeSize.close();
  }

  Widget buildWidget(BuildContext context) {
    _orderChildrers ??= _childers.orderByFunction((x) => x.position);
    return LayoutBuilder(builder: (x, y) {
      currentSize ??= y;

      if (currentSize != y) {
        currentSize = y;
        _notifyChangeSize.add(y);
      }

      return Stack(
        children: _orderChildrers!.map((x) => x.generateWidget(boxConstraints: y, context: context)).toList(),
      );
    });
  }
}
