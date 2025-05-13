import 'package:flutter/material.dart';
import 'package:maxi_flutter_library/maxi_flutter_library.dart';

class MaxiSingleAnimationContainer<T> extends StatefulWidget {
  final T initialValue;
  final Duration duration;
  final Curve curve;
  final IMaxiAnimatedValue<T>? initialOperator;

  final Widget Function(BuildContext context, T value) builder;
  final void Function(IMaxiAnimatedValue<T>)? onCreated;

  const MaxiSingleAnimationContainer({
    super.key,
    required this.initialValue,
    required this.builder,
    this.duration = const Duration(seconds: 1),
    this.curve = Curves.decelerate,
    this.onCreated,
    this.initialOperator,
  });

  @override
  State<MaxiSingleAnimationContainer<T>> createState() => _MaxiSingleAnimationContainerState<T>();
}

class _MaxiSingleAnimationContainerState<T> extends State<MaxiSingleAnimationContainer<T>> with SingleTickerProviderStateMixin {
  late final IMaxiAnimatedValue<T> _operator;

  bool _createdOperator = false;

  @override
  void initState() {
    super.initState();

    if (widget.initialOperator == null) {
      //_operator = MaxiAnimatedValue<T>(curve: widget.curve, duration: widget.duration, value: widget.initialValue, vsync: this);
      _operator = MaxiAnimatedValue<T>.searchByType(curve: widget.curve, duration: widget.duration, value: widget.initialValue, vsync: this);
      _createdOperator = true;
    } else {
      _operator = widget.initialOperator!;
    }

    if (widget.onCreated != null) {
      widget.onCreated!(_operator);
    }

    _operator.addListener(_updateValue);
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _operator.value);
  }

  void _updateValue() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _operator.removeListener(_updateValue);
    if (_createdOperator) {
      _operator.dispose();
    }
    super.dispose();
  }
}
