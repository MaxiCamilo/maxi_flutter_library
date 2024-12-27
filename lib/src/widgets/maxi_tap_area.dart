import 'package:flutter/material.dart';

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
  });

  @override
  Widget build(BuildContext context) {
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
