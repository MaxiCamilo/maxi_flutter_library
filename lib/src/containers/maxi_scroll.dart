import 'package:flutter/material.dart';

class MaxiScroll extends StatefulWidget {
  final Axis scrollDirection;
  final Widget child;
  final double scrollSpace;

  final double? thickness;
  final Radius? radius;

  final void Function(ScrollController)? onScrollCreated;

  const MaxiScroll({
    super.key,
    required this.child,
    this.scrollDirection = Axis.vertical,
    this.scrollSpace = 0,
    this.onScrollCreated,
    this.thickness,
    this.radius,
  });

  @override
  State<MaxiScroll> createState() => _MaxiScrollState();
}

class _MaxiScrollState extends State<MaxiScroll> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    if (widget.onScrollCreated != null) {
      widget.onScrollCreated!(_scrollController);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: _scrollController,
      thumbVisibility: true,
      thickness: widget.thickness,
      radius: widget.radius,
      child: SingleChildScrollView(
        scrollDirection: widget.scrollDirection,
        controller: _scrollController,
        child: widget.child,
      ),
    );
  }
}
