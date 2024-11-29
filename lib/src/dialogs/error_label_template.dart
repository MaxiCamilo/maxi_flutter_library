import 'package:flutter/material.dart';
import 'package:maxi_flutter_library/maxi_flutter_library.dart';
import 'package:maxi_library/maxi_library.dart';

class ErrorLabelTemplate extends StatelessWidget {
  final TranslatableText message;
  final bool expand;
  final Color iconColor;
  final double iconSize;
  final double? textSize;
  final IconData icon;
  final double rowFrom;

  const ErrorLabelTemplate({
    super.key,
    required this.message,
    this.expand = true,
    this.iconColor = Colors.orange,
    this.iconSize = 42,
    this.icon = Icons.warning,
    this.rowFrom = 400,
    this.textSize,
  });

  @override
  Widget build(BuildContext context) {
    return MaxiFlex(
      rowFrom: rowFrom,
      useScreenSize: true,
      expandRow: expand,
      children: [
        Icon(icon, color: iconColor, size: iconSize),
        const SizedBox(height: 15, width: 15),
        OnlyRow(
          child: expand
              ? Expanded(
                  child: MaxiTranslatableText(
                  text: message,
                  size: textSize,
                  aling: TextAlign.center,
                ))
              : Flexible(
                  child: MaxiTranslatableText(
                    text: message,
                    size: textSize,
                    aling: TextAlign.center,
                  ),
                ),
        ),
        OnlyColumn(
          child: Flexible(
            child: MaxiTranslatableText(
              text: message,
              size: textSize,
              aling: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}
