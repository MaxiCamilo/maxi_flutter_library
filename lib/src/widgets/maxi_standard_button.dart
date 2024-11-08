import 'package:flutter/material.dart';

class MaxiStandardButton extends StatelessWidget {
  final Widget icon;
  final String text;
  final void Function()? onTouch;
  final Color? backgroundColor;
  final Color? textColor;
  final double padding;
  final double circularRadius;

  const MaxiStandardButton({
    super.key,
    required this.icon,
    required this.text,
    this.onTouch,
    this.backgroundColor,
    this.textColor,
    this.padding = 2.0,
    this.circularRadius = 5.0,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(padding),
      child: ElevatedButton(
        onPressed: onTouch,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(circularRadius),
          ),
        ),
        child: Flex(direction: Axis.horizontal, children: [icon, const SizedBox(width: 5), Text(text)]),
      ),
    );
  }
}
