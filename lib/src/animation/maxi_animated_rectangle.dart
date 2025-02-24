import 'package:flutter/material.dart';
import 'package:maxi_flutter_library/maxi_flutter_library.dart';

class MaxiAnimatedRectangle extends StatefulWidget with IMaxiAnimatorWidget {
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
  final Curve curve;
  final Duration duration;

  @override
  final IMaxiAnimatorManager? animatorManager;

  const MaxiAnimatedRectangle({
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
    this.curve = Curves.decelerate,
    this.duration = const Duration(milliseconds: 300),
    this.animatorManager,
    required this.child,
  });

  @override
  State<MaxiAnimatedRectangle> createState() => _MaxiAnimatedRectangleState();
}

mixin IMaxiAnimatedRectangleOperator {
  void changeRectangle({
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    BoxConstraints? constraints,
    Color? backgroundColor,
    Color? borderColor,
    double? borderRadious,
    double? borderWidth,
    BorderStyle? borderStyle,
    double borderStrokeAlign,
    double? width,
    double? height,
    Widget? child,
    Curve? curve,
    Duration? duration,
  });
}

class _MaxiAnimatedRectangleState extends StateWithLifeCycle<MaxiAnimatedRectangle> with IMaxiAnimatedRectangleOperator, IMaxiAnimatorState<MaxiAnimatedRectangle> {
  late EdgeInsetsGeometry? padding;
  late EdgeInsetsGeometry? margin;
  late BoxConstraints? constraints;
  late Color? backgroundColor;
  late Color? borderColor;
  late double? borderRadious;
  late double borderWidth;
  late BorderStyle borderStyle;
  late double borderStrokeAlign;
  late double? width;
  late double? height;

  late Widget child;
  late Curve curve;
  late Duration duration;

  @override
  void initState() {
    super.initState();

    padding = widget.padding;
    margin = widget.margin;
    constraints = widget.constraints;
    backgroundColor = widget.backgroundColor;
    borderColor = widget.borderColor;
    borderRadious = widget.borderRadious;
    borderWidth = widget.borderWidth;
    borderStyle = widget.borderStyle;
    borderStrokeAlign = widget.borderStrokeAlign;
    width = widget.width;
    height = widget.height;
    child = widget.child;
    curve = widget.curve;
    duration = widget.duration;

    initializeAnimator();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      padding: padding,
      margin: margin,
      duration: duration,
      curve: curve,
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

  @override
  void changeRectangle(
      {EdgeInsetsGeometry? padding,
      EdgeInsetsGeometry? margin,
      BoxConstraints? constraints,
      Color? backgroundColor,
      Color? borderColor,
      double? borderRadious,
      double? borderWidth,
      BorderStyle? borderStyle,
      double? borderStrokeAlign,
      double? width,
      double? height,
      Widget? child,
      Curve? curve,
      Duration? duration}) {
    bool wasChange = false;

    if (this.padding != padding) {
      this.padding = padding;
      wasChange = true;
    }

    if (this.margin != margin) {
      this.margin = margin;
      wasChange = true;
    }
    if (this.constraints != constraints) {
      this.constraints = constraints;
      wasChange = true;
    }
    if (this.backgroundColor != backgroundColor) {
      this.backgroundColor = backgroundColor;
      wasChange = true;
    }
    if (this.borderColor != borderColor) {
      this.borderColor = borderColor;
      wasChange = true;
    }
    if (this.borderRadious != borderRadious) {
      this.borderRadious = borderRadious;
      wasChange = true;
    }
    if (borderWidth != null && this.borderWidth != borderWidth) {
      this.borderWidth = borderWidth;
      wasChange = true;
    }
    if (borderStyle != null && this.borderStyle != borderStyle) {
      this.borderStyle = borderStyle;
      wasChange = true;
    }
    if (this.width != width) {
      this.width = width;
      wasChange = true;
    }
    if (this.height != height) {
      this.height = height;
      wasChange = true;
    }
    if (child != null && this.child != child) {
      this.child = child;
      wasChange = true;
    }

    if (curve != null && this.curve != curve) {
      this.curve = curve;
      wasChange = true;
    }

    if (duration != null && this.duration != duration) {
      this.duration = duration;
      wasChange = true;
    }

    if (wasChange && mounted) {
      setState(() {});
    }
  }
}
