import 'package:flutter/material.dart';
import 'package:maxi_flutter_library/maxi_flutter_library.dart';
import 'package:maxi_library/maxi_library.dart';

class MaxiTranslatableText extends StatefulWidget {
  final TranslatableText text;
  final double? size;
  final bool bold;
  final Color? textColor;
  final TextAlign? aling;
  final bool italic;
  final TextDecoration? decoration;
  final bool selectable;

  const MaxiTranslatableText({
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
  State<MaxiTranslatableText> createState() => _MaxiTranslatableTextState();
}

class _MaxiTranslatableTextState extends State<MaxiTranslatableText> {
  late final String _text;

  @override
  void initState() {
    super.initState();

    _text = widget.text.toString();
  }

  @override
  Widget build(BuildContext context) {
    return MaxiText(
      text: _text,
      aling: widget.aling,
      bold: widget.bold,
      decoration: widget.decoration,
      italic: widget.italic,
      selectable: widget.selectable,
      size: widget.size,
      textColor: widget.textColor,
    );
  }
}
