import 'package:flutter/widgets.dart';

class OnlyColumn  extends StatelessWidget {
  final Widget child;

  const OnlyColumn({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return child;
  }
}