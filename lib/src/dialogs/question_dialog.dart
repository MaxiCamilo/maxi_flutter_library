import 'package:flutter/material.dart';
import 'package:maxi_flutter_library/maxi_flutter_library.dart';
import 'package:maxi_library/maxi_library.dart';

class QuestionDialog extends StatefulWidget {
  final TranslatableText text;
  final TranslatableText firstOption;
  final TranslatableText secondOption;
  final IconData icon;
  final double rowFrom;
  final void Function(bool) onDone;

  const QuestionDialog({
    super.key,
    required this.text,
    required this.onDone,
    this.rowFrom = 400,
    this.icon = Icons.question_mark,
    this.firstOption = const TranslatableText(message: 'Yes'),
    this.secondOption = const TranslatableText(message: 'No'),
  });

  static Future<bool?> showMaterialDialog({
    required BuildContext context,
    required TranslatableText text,
    TranslatableText firstOption = const TranslatableText(message: 'Yes'),
    TranslatableText secondOption = const TranslatableText(message: 'No'),
    IconData icon = Icons.question_mark,
    double rowFrom = 400,
    bool barrierDismissible = true,
  }) async {
    return DialogUtilities.showWidgetAsMaterialDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context, dialogOperator) => QuestionDialog(
        text: text,
        firstOption: firstOption,
        secondOption: secondOption,
        icon: icon,
        rowFrom: rowFrom,
        onDone: (x) => dialogOperator.defineResult(context, x),
      ),
    );
  }

  static Future<bool?> showBottomSheet({
    required BuildContext context,
    required TranslatableText text,
    TranslatableText firstOption = const TranslatableText(message: 'Yes'),
    TranslatableText secondOption = const TranslatableText(message: 'No'),
    IconData icon = Icons.question_mark,
    double rowFrom = 400,
  }) async {
    return DialogUtilities.showWidgetAsBottomSheet(
      context: context,
      builder: (context, dialogOperator) => QuestionDialog(
        text: text,
        firstOption: firstOption,
        secondOption: secondOption,
        icon: icon,
        rowFrom: rowFrom,
        onDone: (x) => dialogOperator.defineResult(context, x),
      ),
    );
  }

  @override
  State<QuestionDialog> createState() => _QuestionDialogState();
}

class _QuestionDialogState extends State<QuestionDialog> {
  @override
  Widget build(BuildContext context) {
    return Flex(
      direction: Axis.vertical,
      mainAxisSize: MainAxisSize.min,
      children: [
        MaxiFlex(
          rowFrom: widget.rowFrom,
          useScreenSize: true,
          children: [
            OnlyIfWidth(
              width: widget.rowFrom,
              largestChild: Icon(widget.icon),
              smallerChild: Center(child: Icon(widget.icon)),
            ),
            const SizedBox(height: 10, width: 10),
            ExpandedOnlyRow(child: MaxiTranslatableText(text: widget.text, selectable: true)),
          ],
        ),
        const SizedBox(height: 10, width: 10),
        MaxiFlex(
          rowFrom: widget.rowFrom,
          useScreenSize: true,
          columnCrossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MaxiTransparentButton(
              text: widget.firstOption,
              onTouch: () {
                widget.onDone(true);
              },
            ),
            const SizedBox(height: 10, width: 10),
            MaxiTransparentButton(
              text: widget.secondOption,
              onTouch: () {
                widget.onDone(false);
              },
            ),
          ],
        )
      ],
    );
  }
}
