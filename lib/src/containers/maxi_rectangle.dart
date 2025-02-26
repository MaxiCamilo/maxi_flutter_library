import 'package:flutter/material.dart';

class MaxiRectangle extends StatelessWidget {
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BoxConstraints? constraints;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? borderRadious;
  final double borderWidth;
  final BorderStyle borderStyle;
  final double borderStrokeAlign;
  final double? width;
  final double? height;
  

  final Widget child;

  const MaxiRectangle({
    super.key,
    this.padding,
    this.margin,
    this.constraints,
    this.backgroundColor,
    this.borderColor,
    this.borderRadious,
    this.width,
    this.height,
    this.borderWidth = 0,
    this.borderStyle = BorderStyle.solid,
    this.borderStrokeAlign = BorderSide.strokeAlignInside,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      margin: margin,
      constraints: constraints,
      decoration: BoxDecoration(
          color: backgroundColor,
          border: borderWidth == 0
              ? null
              : Border.all(
                  color: borderColor ?? Colors.transparent,
                  width: borderWidth,
                  strokeAlign: borderStrokeAlign,
                  style: borderStyle,
                ),
          borderRadius: borderRadious == null ? null : BorderRadius.circular(borderRadious!)),
      child: child,
    );
  }
}
