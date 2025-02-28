import 'package:flutter/material.dart';
import 'package:maxi_flutter_library/maxi_flutter_library.dart';
import 'package:maxi_library/maxi_library.dart';

class MaxiTransparentButton extends StatelessWidget {
  final Widget? icon;
  final Oration? text;
  final bool enable;
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
    this.enable = true,
    this.borderColors,
  });

  //late String text;
  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: enable ? onTouch : null,
      style: OutlinedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        side: BorderSide(width: borderWidth, color: enable && onTouch != null ? (borderColors ?? textColor ?? Colors.white) : Colors.blueGrey),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(circularRadius),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: _createContent(context),
      ),
    );
  }

  Widget _createContent(BuildContext context) {
    if (icon == null) {
      return text == null
          ? const SizedBox()
          : MaxiTranslatableText(
              text: text!,
              color: enable && onTouch != null ? (textColor ?? borderColors ?? Colors.white) : Colors.blueGrey,
            );
    } else {
      return Flex(
        direction: Axis.horizontal,
        mainAxisSize: MainAxisSize.min,
        children: text != null && text!.isNotEmpty
            ? [
                icon ?? const SizedBox(),
                icon == null ? const SizedBox() : const SizedBox(width: 5),
                Flexible(child: MaxiTranslatableText(text: text!, color: enable && onTouch != null ? (textColor ?? borderColors ?? Colors.white) : Colors.blueGrey)),
              ]
            : [
                icon ?? const SizedBox(),
              ],
      );
    }
  }
}
