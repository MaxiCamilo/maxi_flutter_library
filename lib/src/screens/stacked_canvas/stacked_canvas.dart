import 'package:flutter/material.dart';
import 'package:maxi_flutter_library/src/screens/stacked_canvas/stacked_canvas_operator.dart';

class StackedCanvas extends StatefulWidget {
  final StackedCanvasOperator? canvasOperator;
  final void Function(StackedCanvasOperator)? canvasOperatorCreated;

  const StackedCanvas({
    super.key,
    this.canvasOperator,
    this.canvasOperatorCreated,
  });

  @override
  State<StackedCanvas> createState() => _StackedCanvasState();
}

class _StackedCanvasState extends State<StackedCanvas> {
  late final StackedCanvasOperator canvasOperator;

  @override
  void initState() {
    super.initState();

    if (widget.canvasOperator == null) {
      canvasOperator = StackedCanvasOperator();
    } else {
      canvasOperator = widget.canvasOperator!;
    }

    if (widget.canvasOperatorCreated != null) {
      widget.canvasOperatorCreated!(canvasOperator);
    }

    canvasOperator.notifyUpdate.listen((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    super.dispose();

    canvasOperator.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return canvasOperator.buildWidget(context);
  }
}
