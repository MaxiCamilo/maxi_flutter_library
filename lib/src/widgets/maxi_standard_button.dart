import 'package:flutter/material.dart';
import 'package:maxi_library/maxi_library.dart';

class MaxiStandardButton extends StatefulWidget {
  final Widget icon;
  final Oration text;
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
  State<MaxiStandardButton> createState() => _MaxiStandardButtonState();
}

class _MaxiStandardButtonState extends State<MaxiStandardButton> {
  late String text;

  @override
  void initState() {
    super.initState();

    text = widget.text.toString();
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: widget.onTouch,
      style: ElevatedButton.styleFrom(
        backgroundColor: widget.backgroundColor,
        foregroundColor: widget.textColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(widget.circularRadius),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(widget.padding),
        child: Flex(
          direction: Axis.horizontal,
          mainAxisSize: MainAxisSize.min,
          children: [
            widget.icon,
            const SizedBox(width: 5),
            Flexible(child: Text(text)),
          ],
        ),
      ),
    );
  }
}
