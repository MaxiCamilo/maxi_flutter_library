import 'package:flutter/widgets.dart';

class FlexChild extends StatelessWidget {
  final Widget rowChild;
  final Widget columnChild;

  const FlexChild({super.key, required this.rowChild, required this.columnChild});

  @override
  Widget build(BuildContext context) {
    return rowChild;
  }
}
