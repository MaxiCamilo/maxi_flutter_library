import 'package:flutter/material.dart';
import 'package:maxi_flutter_library/maxi_flutter_library.dart';
import 'package:maxi_library/maxi_library.dart';

class MaxiTranslatableText extends StatefulWidget {
  final Oration text;
  final double? size;
  final bool bold;
  final Color? color;
  final TextAlign? aling;
  final bool italic;
  final TextDecoration? decoration;
  final bool selectable;
  final List<Stream> Function()? reloaders;

  const MaxiTranslatableText({
    required this.text,
    super.key,
    this.size,
    this.bold = false,
    this.color,
    this.aling,
    this.italic = false,
    this.decoration,
    this.selectable = false,
    this.reloaders,
  });

  @override
  State<MaxiTranslatableText> createState() => _MaxiTranslatableTextState();
}

class _MaxiTranslatableTextState extends StateWithLifeCycle<MaxiTranslatableText> {
  late Oration _originalText;
  late String _text;

  @override
  List<Stream> getReloaderStreams() {
    return widget.reloaders == null ? super.getReloaderStreams() : widget.reloaders!();
  }
/*
  @override
  void reloadWidget(value) {
    if (value is Oration) {
      _originalText = value.message;
      _text = value.toString();
    }

    super.reloadWidget(value);
  }
  */

  @override
  void initState() {
    super.initState();

    _originalText = widget.text;
    _text = widget.text.toString();
  }

  @override
  Widget build(BuildContext context) {
    if (_originalText != widget.text) {
      _originalText = widget.text;
      _text = _originalText.toString();
    }

    return MaxiText(
      text: _text,
      aling: widget.aling /*?? TextAlign.justify*/,
      bold: widget.bold,
      decoration: widget.decoration,
      italic: widget.italic,
      selectable: widget.selectable,
      size: widget.size,
      color: widget.color,
    );
  }
}
