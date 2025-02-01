import 'package:flutter/material.dart';

class FlexibleOnlyRow extends StatelessWidget {
  final Widget child;
  final int flex;
  final FlexFit fit;

  const FlexibleOnlyRow({
    super.key,
    required this.child,
    this.flex = 1,
    this.fit = FlexFit.loose,
  });

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
