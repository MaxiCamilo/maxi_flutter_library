import 'package:flutter/material.dart';
import 'package:maxi_library/maxi_library.dart';

class MaxiTooltip extends StatefulWidget {
  final TranslatableText text;
  final Widget child;

  const MaxiTooltip({super.key, required this.text, required this.child});

  @override
  State<MaxiTooltip> createState() => _MaxiTooltipState();
}

class _MaxiTooltipState extends State<MaxiTooltip> {
  late String translatedText;
  late TranslatableText text;

  @override
  void initState() {
    super.initState();
    text = widget.text;

    translatedText = widget.text.toString();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.text != text) {
      text = widget.text;
      translatedText = widget.text.toString();
    }

    return Tooltip(
      message: translatedText,
      child: widget.child,
    );
  }
}
