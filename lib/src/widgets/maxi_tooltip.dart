import 'package:flutter/material.dart';
import 'package:maxi_library/maxi_library.dart';

class MaxiTooltip extends StatefulWidget {
  final Oration text;
  final Widget child;

  const MaxiTooltip({super.key, required this.text, required this.child});

  @override
  State<MaxiTooltip> createState() => _MaxiTooltipState();
}

class _MaxiTooltipState extends State<MaxiTooltip> {
  late String translatedOration;
  late Oration text;

  @override
  void initState() {
    super.initState();
    text = widget.text;

    translatedOration = widget.text.toString();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.text != text) {
      text = widget.text;
      translatedOration = widget.text.toString();
    }

    return Tooltip(
      message: translatedOration,
      child: widget.child,
    );
  }
}
