import 'package:flutter/material.dart';

class DotDivider extends StatefulWidget {
  final Color color;
  final double dotSize;
  final EdgeInsets padding;

  const DotDivider({
    super.key,
    this.color = Colors.black,
    this.dotSize = 4,
    this.padding = const EdgeInsets.symmetric(vertical: 5.0),
  });

  @override
  State<DotDivider> createState() => _DotDividerState();
}

class _DotDividerState extends State<DotDivider> {
  int count = -1;
  double lastWidth = -1;
  double dotSize = -1;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding,
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (count == -1 || constraints.maxWidth != lastWidth || widget.dotSize != dotSize) {
            count = (constraints.maxWidth / (widget.dotSize * 2)).floor();
            lastWidth = constraints.maxWidth;
            dotSize = widget.dotSize;
          }
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(count, (_) {
              return Container(
                width: widget.dotSize,
                height: widget.dotSize,
                decoration: BoxDecoration(
                  color: widget.color,
                  shape: BoxShape.circle,
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
