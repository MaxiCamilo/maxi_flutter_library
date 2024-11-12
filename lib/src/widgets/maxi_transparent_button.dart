import 'package:flutter/material.dart';
import 'package:maxi_library/maxi_library.dart';

class MaxiTransparentButton extends StatefulWidget {
  final IconData? icon;
  final TranslatableText? text;
  final void Function()? onTouch;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColors;
  final double padding;
  final double circularRadius;
  final double borderWidth;

  const MaxiTransparentButton({
    super.key,
    this.text,
    this.icon,
    this.onTouch,
    this.backgroundColor,
    this.textColor,
    this.padding = 2.0,
    this.circularRadius = 5.0,
    this.borderWidth = 1.0,
    this.borderColors,
  });

  @override
  State<MaxiTransparentButton> createState() => _MaxiTransparentButtonState();
}

class _MaxiTransparentButtonState extends State<MaxiTransparentButton> {
  late String text;

  @override
  void initState() {
    super.initState();

    text = widget.text?.toString() ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: widget.onTouch,
      style: OutlinedButton.styleFrom(
        backgroundColor: widget.backgroundColor,
        foregroundColor: widget.textColor,
        side: BorderSide(width: widget.borderWidth, color: widget.borderColors ?? widget.textColor ?? Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(widget.circularRadius),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(widget.padding),
        child: _createContent(context),
      ),
    );
  }

  Widget _createContent(BuildContext context) {
    if (widget.icon == null) {
      return Text(text);
    } else {
      return Flex(
        direction: Axis.horizontal,
        mainAxisSize: MainAxisSize.min,
        children: text.isNotEmpty
            ? [
                Icon(widget.icon),
                const SizedBox(width: 5),
                Flexible(child: Text(text)),
              ]
            : [
                Icon(widget.icon),
              ],
      );
    }
  }
}
