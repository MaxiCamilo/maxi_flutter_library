import 'package:flutter/material.dart';
import 'package:maxi_flutter_library/maxi_flutter_library.dart';
import 'package:maxi_library/maxi_library.dart';

class MaxiTapArea extends StatelessWidget {
  final void Function()? onTouch;
  final void Function()? onDoubleTouch;
  final void Function()? onLongSelect;
  final void Function()? onSecondaryTap;
  final Widget child;
  final Color backgroundColor;

  final Color? backgroundColorOnMouseover;
  final Color? backgroundColorOnTouch;
  final Color? backgroundColorOnFocus;
  final Oration? tooltipText;

  const MaxiTapArea({
    super.key,
    required this.child,
    this.backgroundColor = Colors.transparent,
    this.onTouch,
    this.onDoubleTouch,
    this.onLongSelect,
    this.onSecondaryTap,
    this.backgroundColorOnMouseover,
    this.backgroundColorOnTouch,
    this.backgroundColorOnFocus,
    this.tooltipText,
  });

  @override
  Widget build(BuildContext context) {
    if (tooltipText == null) {
      return _buildRectangle(context);
    } else {
      return MaxiTooltip(text: tooltipText!, child: _buildRectangle(context));
    }
  }

  Widget _buildRectangle(BuildContext context) {
    return Material(
      color: backgroundColor,
      child: InkWell(
        onTap: onTouch,
        onDoubleTap: onDoubleTouch,
        onLongPress: onLongSelect,
        onSecondaryTap: onSecondaryTap,
        splashColor: backgroundColorOnTouch,
        hoverColor: backgroundColorOnMouseover,
        focusColor: backgroundColorOnFocus ?? backgroundColorOnMouseover,
        child: child,
      ),
    );
  }
}
