import 'package:flutter/widgets.dart';
import 'package:maxi_flutter_library/maxi_flutter_library.dart';
import 'package:maxi_library/maxi_library.dart';

class _StackedCanvasWidgetInstance extends StatelessWidget {
  final StackedCanvasWidget instance;
  final Widget child;

  const _StackedCanvasWidgetInstance({required this.instance, required this.child});

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

class StackedCanvasWidget {
  final StackedCanvasOperator canvasOperator;
  Widget child;
  Duration duration;
  int position;
  Curve curve;

  bool isVisible = true;
  bool firstRender = true;

  double? left;
  double? top;
  double? right;
  double? bottom;
  double? width;
  double? height;

  late BoxConstraints boxConstraints;

  StackedCanvasWidget({
    required this.canvasOperator,
    required this.child,
    required this.duration,
    required this.position,
    this.left,
    this.top,
    this.right,
    this.bottom,
    this.width,
    this.height,
    this.curve = Curves.linear,
  });

  static StackedCanvasWidget fromAncestor(BuildContext context) {
    final located = fromAncestorOptional(context);
    if (located == null) {
      throw NegativeResult(
        identifier: NegativeResultCodes.contextInvalidFunctionality,
        message: tr('Widget is not encapsulated in a Stacked Canvas'),
      );
    }
    return located;
  }

  static StackedCanvasWidget? fromAncestorOptional(BuildContext context) {
    final located = context.findAncestorWidgetOfExactType<_StackedCanvasWidgetInstance>();

    if (located == null) {
      return null;
    } else {
      return located.instance;
    }
  }

  Widget generateWidget({required BuildContext context, required BoxConstraints boxConstraints}) {
    this.boxConstraints = boxConstraints;

    if (firstRender) {
      firstRender = false;
      if (child is IStackedCanvasWidgetDefinePosition) {
        final newPosition = (child as IStackedCanvasWidgetDefinePosition).getInitialPosition(context: context, boxConstraints: boxConstraints);

        duration = newPosition.duration ?? duration;
        bottom = newPosition.bottom;
        curve = newPosition.curve ?? curve;
        height = newPosition.height;
        left = newPosition.left;
        right = newPosition.right;
        top = newPosition.top;
      }
    }

    return _StackedCanvasWidgetInstance(
      instance: this,
      child: AnimatedPositioned(
        duration: duration,
        bottom: bottom,
        curve: curve,
        height: height,
        left: left,
        right: right,
        top: top,
        width: width,
        child: isVisible ? child : const SizedBox(),
        //onEnd: ,
      ),
    );
  }

  void changeChild({required Widget child}) {
    this.child = child;
    canvasOperator.notifyChildChanged(child: this);
  }

  void dispose() {}

  void autoRemove() {
    changeChild(child: const SizedBox());
  }

  void changePositionByCoordenates({required StackedCanvasPosition position}) {
    changePosition(
      isVisible: position.isVisible,
      bottom: position.bottom,
      curve: position.curve,
      duration: position.duration,
      height: position.height,
      left: position.left,
      right: position.right,
      top: position.top,
      width: position.width,
    );
  }

  void changePosition({
    bool? isVisible,
    Duration? duration,
    double? left,
    double? top,
    double? right,
    double? bottom,
    double? width,
    double? height,
    Curve? curve,
  }) {
    bool isChanged = false;

    if (isVisible != null && isVisible != this.isVisible) {
      this.isVisible = isVisible;
      isChanged = true;
    }

    if (duration != null && duration != this.duration) {
      this.duration = duration;
      isChanged = true;
    }

    if (left != null && left != this.left) {
      this.left = left;
      isChanged = true;
    }

    if (top != null && top != this.top) {
      this.top = top;
      isChanged = true;
    }

    if (right != null && right != this.right) {
      this.right = right;
      isChanged = true;
    }

    if (bottom != null && bottom != this.bottom) {
      this.bottom = bottom;
      isChanged = true;
    }

    if (width != null && width != this.width) {
      this.width = width;
      isChanged = true;
    }

    if (height != null && height != this.height) {
      this.height = height;
      isChanged = true;
    }

    if (curve != null && curve != this.curve) {
      this.curve = curve;
      isChanged = true;
    }

    if (isChanged) {
      canvasOperator.notifyChildChanged(child: this);
    }
  }
}
