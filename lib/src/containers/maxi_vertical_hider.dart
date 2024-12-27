import 'package:flutter/material.dart';
import 'package:maxi_flutter_library/maxi_flutter_library.dart';

class MaxiVerticalHider extends StatefulWidget {
  final bool startHide;
  final Widget title;
  final Widget child;
  final double padding;

  final Duration duration;
  final Curve curve;

  const MaxiVerticalHider({
    super.key,
    required this.startHide,
    required this.title,
    required this.child,
    this.padding = 5.0,
    this.curve = Curves.easeInOut,
    this.duration = const Duration(milliseconds: 300),
  });

  @override
  State<MaxiVerticalHider> createState() => _MaxiVerticalHiderState();
}

class _MaxiVerticalHiderState extends StateWithLifeCycle<MaxiVerticalHider> {
  late bool hided;
  late IMaxiVerticalCollapsorOperator collapsorOperator;

  @override
  void initState() {
    super.initState();

    hided = widget.startHide;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.startHide != hided) {
      hided = !widget.startHide;
      collapsorOperator.changeState(!hided);
    }

    return Flex(
      direction: Axis.vertical,
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTouchButton,
            child: Flex(
              direction: Axis.horizontal,
              mainAxisSize: MainAxisSize.max,
              children: [
                TextButton(onPressed: onTouchButton, child: Icon(hided ? Icons.add_circle_outline : Icons.remove_circle_outline)),
                const SizedBox(width: 2),
                Expanded(child: widget.title),
              ],
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Divider(height: 5),
        ),
        MaxiVerticalCollapsor(
          makeChild: (x) => Padding(
            padding: EdgeInsets.all(widget.padding),
            child: widget.child,
          ),
          startsOpen: !hided,
          onCreatedOperator: (x) => collapsorOperator = x,
          curve: widget.curve,
          duration: widget.duration,
        ),
      ],
    );
  }

  void onTouchButton() {
    hided = !hided;
    collapsorOperator.changeState(!hided);
    setState(() {});
  }
}
