import 'package:flutter/material.dart';

class MaxiText extends StatelessWidget {
  final String text;
  final double? size;
  final bool bold;
  final Color? textColor;
  final TextAlign? aling;
  final bool italic;
  final TextDecoration? decoration;
  final bool selectable;

  const MaxiText({
    required this.text,
    super.key,
    this.size,
    this.bold = false,
    this.textColor,
    this.aling,
    this.italic = false,
    this.decoration,
    this.selectable = false,
  });

  @override
  Widget build(BuildContext context) {
    if (selectable) {
      return SelectableText(
        text,
        textAlign: aling,
        style: TextStyle(
          decoration: decoration,
          color: textColor,
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          fontSize: size,
          fontStyle: italic ? FontStyle.italic : FontStyle.normal,
        ),
      );
    } else {
      return Text(
        text,
        textAlign: aling,
        style: TextStyle(
          decoration: decoration,
          color: textColor,
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          fontSize: size,
          fontStyle: italic ? FontStyle.italic : FontStyle.normal,
        ),
      );
    }
  }
}
