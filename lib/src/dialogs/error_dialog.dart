import 'package:flutter/material.dart';
import 'package:maxi_flutter_library/maxi_flutter_library.dart';
import 'package:maxi_library/maxi_library.dart';

class ErrorDialog extends StatelessWidget {
  static const EdgeInsets _standardPadding = EdgeInsets.zero;

  final NegativeResult negativeResult;
  final Color iconColor;
  final double iconSize;
  final double? textSize;
  final IconData icon;
  final double rowFrom;
  final TranslatableText doneButtonText;

  final void Function() onDone;

  const ErrorDialog(
      {super.key,
      required this.negativeResult,
      required this.onDone,
      this.iconColor = Colors.orange,
      this.iconSize = 42,
      this.icon = Icons.warning,
      this.rowFrom = 400,
      this.textSize,
      this.doneButtonText = const TranslatableText(message: 'Understood')});

  static Future<void> showMaterialDialog({
    required BuildContext context,
    required NegativeResult negativeResult,
    Color iconColor = Colors.orange,
    double iconSize = 42,
    double? textSize,
    IconData icon = Icons.warning,
    double rowFrom = 400,
    EdgeInsets? padding,
    TranslatableText doneButtonText = const TranslatableText(message: 'Understood'),
  }) {
    return DialogUtilities.showWidgetAsMaterialDialog(
      context: context,
      builder: (context, dialogOperator) => Padding(
        padding: padding ?? _standardPadding,
        child: ErrorDialog(
          negativeResult: negativeResult,
          doneButtonText: doneButtonText,
          icon: icon,
          iconColor: iconColor,
          iconSize: iconSize,
          rowFrom: rowFrom,
          textSize: textSize,
          onDone: () => dialogOperator.defineResult(context),
        ),
      ),
    );
  }

  static Future<void> showBottomSheet({
    required BuildContext context,
    required NegativeResult negativeResult,
    Color iconColor = Colors.orange,
    double iconSize = 42,
    double? textSize,
    IconData icon = Icons.warning,
    double rowFrom = 400,
    EdgeInsets? padding,
    TranslatableText doneButtonText = const TranslatableText(message: 'Understood'),
  }) {
    return DialogUtilities.showWidgetAsBottomSheet(
      context: context,
      builder: (context, dialogOperator) => Padding(
        padding: padding ?? _standardPadding,
        child: ErrorDialog(
          negativeResult: negativeResult,
          doneButtonText: doneButtonText,
          icon: icon,
          iconColor: iconColor,
          iconSize: iconSize,
          rowFrom: rowFrom,
          textSize: textSize,
          onDone: () => dialogOperator.defineResult(context),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Flex(
      direction: Axis.vertical,
      mainAxisSize: MainAxisSize.min,
      children: [
        ErrorLabelTemplate(
          negativeResult: negativeResult,
          expand: true,
          icon: icon,
          iconColor: iconColor,
          iconSize: iconSize,
          rowFrom: rowFrom,
          textSize: textSize,
        ),
        const SizedBox(height: 15),
        Align(
          alignment: Alignment.topRight,
          child: MaxiTransparentButton(
            text: doneButtonText,
            onTouch: onDone,
          ),
        ),
      ],
    );
  }
}
