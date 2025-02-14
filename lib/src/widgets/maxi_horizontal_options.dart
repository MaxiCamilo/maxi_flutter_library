import 'dart:async';

import 'package:flutter/material.dart';
import 'package:maxi_flutter_library/maxi_flutter_library.dart';
import 'package:maxi_library/maxi_library.dart';

class MaxiHorizontalOptionsItem {
  final IconData? icon;
  final Oration text;
  final Color? color;
  final void Function()? onTouch;
  final bool viewInPopUp;

  const MaxiHorizontalOptionsItem({
    required this.text,
    required this.onTouch,
    this.icon,
    this.color,
    this.viewInPopUp = true,
  });
}

class MaxiHorizontalOptions extends StatefulWidget {
  final List<MaxiHorizontalOptionsItem> options;
  final IconData? iconButton;
  final Oration textButton;
  final Color? colorButton;
  final Widget Function(Widget)? buildAtReducedSize;
  final bool enabledPopUpButton;

  final FutureOr<List<Stream>> Function()? reloaders;

  const MaxiHorizontalOptions({
    super.key,
    required this.options,
    required this.textButton,
    this.enabledPopUpButton = true,
    this.colorButton,
    this.iconButton,
    this.reloaders,
    this.buildAtReducedSize,
  });

  @override
  State<MaxiHorizontalOptions> createState() => _MaxiHorizontalOptionsState();
}

class _MaxiHorizontalOptionsState extends StateWithLifeCycle<MaxiHorizontalOptions> {
  double sizeLimit = -1;

  late List<Widget> buttonList;
  late Widget popUpMenu;

  @override
  void initState() {
    super.initState();

    if (widget.reloaders != null) {
      scheduleMicrotask(() async {
        for (final stream in await widget.reloaders!()) {
          joinEvent(
              event: stream,
              onData: (_) {
                sizeLimit = -1;
                if (mounted) {
                  setState(() {});
                }
              });
        }
      });
    }
  }

  void generateWidgets() {
    sizeLimit = widget.options.map((x) => _calculateButtonWidth(x, context)).reduce((x, y) => x + y);
    buttonList = widget.options
        .map(
          (item) => Padding(
            padding: const EdgeInsets.only(right: 5.0),
            child: MaxiTransparentButton(
              icon: item.icon == null ? null : Icon(item.icon),
              text: item.text,
              onTouch: item.onTouch,
            ),
          ),
        )
        .toList();

    popUpMenu = PopupMenuButton<int>(
      enabled: widget.enabledPopUpButton,
      child: Container(
          decoration: BoxDecoration(border: Border.all(color: widget.colorButton ?? Colors.white), borderRadius: BorderRadius.circular(5.0)),
          padding: const EdgeInsets.all(5.0),
          child: Flex(
            direction: Axis.horizontal,
            mainAxisSize: MainAxisSize.min,
            children: [
              widget.iconButton == null ? const SizedBox() : Icon(widget.iconButton),
              widget.iconButton == null ? const SizedBox() : const SizedBox(width: 5),
              MaxiTranslatableText(text: widget.textButton, color: widget.colorButton ?? Colors.white),
              const Icon(Icons.arrow_drop_down)
            ],
          )),
      onSelected: (value) {
        if (widget.options[value].onTouch != null) {
          widget.options[value].onTouch!();
        }
      },
      itemBuilder: (context) => widget.options
          .where((x) => x.viewInPopUp)
          .mapWithPosition(
            (x, i) => PopupMenuItem(
              value: i,
              child: x.icon == null
                  ? MaxiTranslatableText(text: x.text, color: x.onTouch == null ? Colors.grey : Colors.white)
                  : Flex(
                      direction: Axis.horizontal,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(x.icon, color: x.onTouch == null ? Colors.grey : Colors.white),
                        const SizedBox(width: 5),
                        MaxiTranslatableText(text: x.text, color: x.onTouch == null ? Colors.grey : Colors.white),
                      ],
                    ),
            ),
          )
          .toList(),
    );

    if (widget.buildAtReducedSize != null) {
      popUpMenu = widget.buildAtReducedSize!(popUpMenu);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (sizeLimit == -1) {
          generateWidgets();
        }
        if (constraints.maxWidth > sizeLimit) {
          return Flex(direction: Axis.horizontal, mainAxisSize: MainAxisSize.min, children: buttonList);
        } else {
          return popUpMenu;
        }
      },
    );
  }

  double _calculateButtonWidth(MaxiHorizontalOptionsItem option, BuildContext context) {
    // Medir el ancho del texto.
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: option.text.toString(),
      ),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();

    double textWidth = textPainter.width;
    double iconWidth = option.icon == null ? 0 : IconTheme.of(context).size ?? 24.0;
    double spacing = (option.text.isNotEmpty ? 4.0 : 0.0);
    double padding = 60;

    return textWidth + iconWidth + spacing + padding;
  }
}
