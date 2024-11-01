import 'package:flutter/material.dart';
import 'package:maxi_flutter_library/maxi_flutter_library.dart';

class SingleStackedScreen extends StatefulWidget {
  final Duration? animationDuration;
  final Curve? curve;

  final SingleStackedScreenOperator? stackedOperator;
  final void Function(SingleStackedScreenOperator)? stackedOperatorCreated;

  const SingleStackedScreen({
    super.key,
    this.stackedOperator,
    this.stackedOperatorCreated,
    this.animationDuration,
    this.curve,
  });

  @override
  State<SingleStackedScreen> createState() => _SingleStackedScreenState();
}

class _SingleStackedScreenState extends State<SingleStackedScreen> {
  late SingleStackedScreenOperator screenOperator;

  @override
  void initState() {
    super.initState();

    if (widget.stackedOperator == null) {
      screenOperator = SingleStackedScreenOperator();
    } else {
      screenOperator = widget.stackedOperator!;
    }

    if (widget.animationDuration != null) {
      screenOperator.animationDuration = widget.animationDuration!;
    }

    if (widget.curve != null) {
      screenOperator.curve = widget.curve!;
    }

    if (widget.stackedOperatorCreated != null) {
      widget.stackedOperatorCreated!(screenOperator);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.animationDuration != null) {
      screenOperator.animationDuration = widget.animationDuration!;
    }

    if (widget.curve != null) {
      screenOperator.curve = widget.curve!;
    }

    return screenOperator.generateWidget();
  }
}
