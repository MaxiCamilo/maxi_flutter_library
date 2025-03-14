import 'package:flutter/material.dart';
import 'package:maxi_flutter_library/src/containers/maxi_scroll.dart';

class MaxiScrollConditional extends StatelessWidget {
  final Widget child;
  final bool Function(BuildContext) scrollCondition;
  final bool expandIfNotScroll;
  final bool flexibleIfNotScroll;

  final Axis scrollDirection;
  final double scrollSpace;

  final double? thickness;
  final Radius? radius;
  final Widget Function(BuildContext, Widget)? buildIfNotScroll;

  const MaxiScrollConditional({
    super.key,
    required this.child,
    required this.scrollCondition,
    this.expandIfNotScroll = false,
    this.flexibleIfNotScroll = false,
    this.scrollDirection = Axis.vertical,
    this.scrollSpace = 0,
    this.thickness,
    this.buildIfNotScroll,
    this.radius,
  });

  @override
  Widget build(BuildContext context) {
    if (scrollCondition(context)) {
      return MaxiScroll(
        radius: radius,
        scrollDirection: scrollDirection,
        thickness: thickness,
        scrollSpace: scrollSpace,
        child: child,
      );
    } else if (expandIfNotScroll) {
      return Expanded(child: child);
    } else if (flexibleIfNotScroll) {
      return Flexible(child: child);
    } else if (buildIfNotScroll != null) {
      return buildIfNotScroll!(context, child);
    } else {
      return child;
    }
  }
}
