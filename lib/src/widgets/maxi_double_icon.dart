import 'package:flutter/material.dart';

class MaxiDoubleIcon extends StatelessWidget {
  final IconData primaryIcon;
  final IconData secondaryIcon;
  final double primaryIconSize;
  final double? secondaryIconSize;
  final Color? primaryIconColor;
  final Color? secondaryIconColor;
  final double bottomPositioned;
  final double rightPositioned;

  const MaxiDoubleIcon({
    super.key,
    required this.primaryIcon,
    required this.secondaryIcon,
    this.primaryIconSize = 32,
    this.secondaryIconSize,
    this.primaryIconColor,
    this.secondaryIconColor,
    this.bottomPositioned = -10,
    this.rightPositioned = -5,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(
          primaryIcon,
          color: primaryIconColor,
          size: primaryIconSize,
        ),
        Positioned(
          bottom: bottomPositioned,
          right: rightPositioned,
          child: Icon(secondaryIcon, color: secondaryIconColor, size: secondaryIconSize ?? (primaryIconSize - 10)),
        ),
      ],
    );
  }
}
