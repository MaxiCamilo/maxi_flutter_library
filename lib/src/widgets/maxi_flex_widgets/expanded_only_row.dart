import 'package:flutter/material.dart';

class ExpandedOnlyRow extends StatelessWidget {
  final Widget child;

  const ExpandedOnlyRow({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
