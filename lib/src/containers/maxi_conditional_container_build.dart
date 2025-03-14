import 'package:flutter/material.dart';

class MaxiConditionalContainerBuild extends StatelessWidget {
  final List<(bool Function(BuildContext), Widget Function(BuildContext))> conditions;

  final Widget child;

  const MaxiConditionalContainerBuild({super.key, required this.conditions, required this.child});

  @override
  Widget build(BuildContext context) {
    for (final part in conditions) {
      if (part.$1(context)) {
        return part.$2(context);
      }
    }

    return child;
  }
}
