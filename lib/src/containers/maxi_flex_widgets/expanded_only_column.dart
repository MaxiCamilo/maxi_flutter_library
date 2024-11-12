import 'package:flutter/material.dart';

class ExpandedOnlyColumn extends StatelessWidget {
  final Widget child;

  const ExpandedOnlyColumn({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
