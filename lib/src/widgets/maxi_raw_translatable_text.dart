import 'package:flutter/material.dart';
import 'package:maxi_flutter_library/maxi_flutter_library.dart';
import 'package:maxi_library/maxi_library.dart';

class MaxiRawTranslatableText extends StatefulWidget {
  final String text;
  final double? size;
  final bool bold;
  final Color? color;
  final TextAlign? aling;
  final bool italic;
  final TextDecoration? decoration;
  final bool selectable;

  const MaxiRawTranslatableText({
    super.key,
    required this.text,
    this.size,
    this.bold = false,
    this.color,
    this.aling,
    this.italic = false,
    this.decoration,
    this.selectable = false,
  });

  @override
  State<MaxiRawTranslatableText> createState() => _MaxiRawTranslatableTextState();
}

class _MaxiRawTranslatableTextState extends State<MaxiRawTranslatableText> {
  late Oration text;

  late String lastRawText;

  @override
  void initState() {
    super.initState();

    _makeText(widget.text);
  }

  void _makeText(String newText) {
    lastRawText = newText;

    if (newText.isEmpty) {
      text = Oration.empty;
      return;
    }

    final mapText = ConverterUtilities.interpretToObjectJson(text: newText);
    final mapType = volatile(detail: const Oration(message: 'Message type required'), function: () => mapText['\$type']);

    if (mapType == 'Oration') {
      text = Oration.interpretFromJson(text: mapText);
    } else if (mapType.startsWith('error')) {
      text = NegativeResult.interpret(values: mapText, checkTypeFlag: true).message;
    } else {
      text = Oration(message: 'INVALID TEXT TYPE (Format: %1)', textParts: [mapType]);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (lastRawText != widget.text) {
      _makeText(widget.text);
    }

    return MaxiTranslatableText(
      text: text,
      size: widget.size,
      bold: widget.bold,
      color: widget.color,
      aling: widget.aling,
      italic: widget.italic,
      decoration: widget.decoration,
      selectable: widget.selectable,
    );
  }
}
