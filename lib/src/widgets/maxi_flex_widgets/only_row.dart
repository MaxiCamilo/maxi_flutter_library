import 'package:flutter/material.dart';

class OnlyRow extends StatelessWidget {
  final Widget child;

  const OnlyRow({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
