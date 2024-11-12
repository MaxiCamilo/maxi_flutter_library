import 'package:flutter/material.dart';

class OnlyIfWidth extends StatelessWidget {
  final double width;
  final bool useScreenSize;
  final Widget largestChild;
  final Widget smallerChild;

  const OnlyIfWidth({
    super.key,
    required this.width,
    this.useScreenSize = true,
    this.largestChild = const SizedBox(),
    this.smallerChild = const SizedBox(),
  });

  @override
  Widget build(BuildContext context) {
    if (useScreenSize) {
      return _createChild(context, MediaQuery.of(context).size.width);
    } else {
      return LayoutBuilder(
        builder: (context, constraints) => _createChild(context, MediaQuery.of(context).size.width),
      );
    }
  }

  Widget _createChild(BuildContext context, double screenWidth) {
    if (screenWidth >= width) {
      return largestChild;
    } else {
      return smallerChild;
    }
  }
}
