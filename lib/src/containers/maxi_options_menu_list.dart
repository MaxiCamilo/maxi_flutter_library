import 'package:flutter/material.dart';
import 'package:maxi_flutter_library/maxi_flutter_library.dart';
import 'package:maxi_flutter_library/src/widgets/maxi_translatable_text.dart';
import 'package:maxi_library/export_reflectors.dart';

class MaxiOptionsMenuListItem {
  final Widget icon;
  final Oration text;
  final Oration? subText;

  final void Function() onTouch;

  const MaxiOptionsMenuListItem({
    required this.icon,
    required this.text,
    required this.onTouch,
    this.subText,
  });
}

class MaxiOptionsMenuList extends StatefulWidget {
  final List<MaxiOptionsMenuListItem> options;
  final void Function(MaxiOptionsMenuListItem)? onSelectItem;

  const MaxiOptionsMenuList({
    super.key,
    this.onSelectItem,
    required this.options,
  });

  static Future<MaxiOptionsMenuListItem?> showDialog({
    required BuildContext context,
    required Oration title,
    required List<MaxiOptionsMenuListItem> options,
    double minWidth = 0.0
  }) {
    return DialogUtilities.showWidgetAsMaterialDialog(
      context: context,
      builder: (context, dialogOperator) => MaxiRectangle(
        constraints: BoxConstraints(minWidth: minWidth),
        child: Flex(
          direction: Axis.vertical,
          mainAxisSize: MainAxisSize.min,
          children: [
            Flex(
              direction: Axis.horizontal,
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(child: MaxiTranslatableText(text: title, bold: true, size: 25)),
                const SizedBox(width: 7),
                MaxiTransparentButton(
                  icon: const Icon(Icons.close),
                  onTouch: () => dialogOperator.defineResult(context),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Divider(height: 5),
            ),
            Flexible(
              child: MaxiScroll(
                child: MaxiOptionsMenuList(
                  options: options,
                  onSelectItem: (x) => dialogOperator.defineResult(context, x),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  State<MaxiOptionsMenuList> createState() => _MaxiOptionsMenuListState();
}

class _MaxiOptionsMenuListState extends State<MaxiOptionsMenuList> {
  late final List<Widget> generatedList;

  @override
  void initState() {
    super.initState();

    generatedList = widget.options.map(_makeItem).toList(growable: false);
  }

  Widget _makeItem(MaxiOptionsMenuListItem item) {
    return ListTile(
      leading: item.icon,
      title: MaxiTranslatableText(text: item.text),
      subtitle: item.subText == null ? null : MaxiTranslatableText(text: item.subText!),
      onTap: () {
        if (widget.onSelectItem != null) {
          widget.onSelectItem!(item);
        }

        item.onTouch();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Flex(
      direction: Axis.vertical,
      mainAxisSize: MainAxisSize.min,
      children: generatedList,
    );
  }
}
