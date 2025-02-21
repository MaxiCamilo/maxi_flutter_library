import 'package:flutter/material.dart';
import 'package:maxi_flutter_library/maxi_flutter_library.dart';
import 'package:maxi_library/maxi_library.dart';

class ErrorLabelTemplate extends StatelessWidget {
  final Oration message;
  final bool expand;
  final Color iconColor;
  final double iconSize;
  final double? textSize;
  final IconData icon;
  final double rowFrom;
  final List<NegativeResultValue> invalidProperties;

  const ErrorLabelTemplate({
    super.key,
    required this.message,
    this.expand = true,
    this.iconColor = Colors.orange,
    this.iconSize = 42,
    this.icon = Icons.warning,
    this.rowFrom = 400,
    this.invalidProperties = const [],
    this.textSize,
  });

  @override
  Widget build(BuildContext context) {
    return Flex(
      direction: Axis.vertical,
      mainAxisSize: MainAxisSize.min,
      children: [
        MaxiFlex(
          rowFrom: rowFrom,
          useScreenSize: true,
          expandRow: expand,
          rowCrossAxisAlignment: CrossAxisAlignment.center,
          columnCrossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: iconSize),
            const SizedBox(height: 15, width: 15),
            OnlyRow(
              child: expand
                  ? Expanded(
                      child: MaxiTranslatableText(
                      text: message,
                      size: textSize,
                      selectable: true,
                      aling: TextAlign.center,
                    ))
                  : Flexible(
                      child: MaxiTranslatableText(
                        text: message,
                        size: textSize,
                        selectable: true,
                        aling: TextAlign.center,
                      ),
                    ),
            ),
            OnlyColumn(
              child: Flexible(
                child: MaxiTranslatableText(
                  text: message,
                  size: textSize,
                  selectable: true,
                  aling: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
        invalidProperties.isNotEmpty
            ? const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Divider(height: 5),
              )
            : const SizedBox(),
        invalidProperties.isNotEmpty ? _makeInvalidPropertiesList(context) : const SizedBox(),
      ],
    );
  }

  Widget _makeInvalidPropertiesList(BuildContext context) {
    return Flex(
      direction: Axis.vertical,
      mainAxisSize: MainAxisSize.min,
      children: invalidProperties
          .map(
            (item) => MaxiRectangle(
              child: Flex(
                direction: Axis.horizontal,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  const Icon(Icons.arrow_right),
                  Expanded(
                    child: Flex(
                      direction: Axis.vertical,
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        MaxiTranslatableText(text: item.formalName, bold: true, selectable: true),
                        const SizedBox(height: 5),
                        MaxiTranslatableText(text: item.message, selectable: true),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}
