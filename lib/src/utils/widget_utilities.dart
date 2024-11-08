import 'package:flutter/widgets.dart';

mixin WidgetUtilities {
  static Offset getWidgetPosition(GlobalKey llave) {
    final box = llave.currentContext!.findRenderObject() as RenderBox;
    return box.localToGlobal(Offset.zero);
  }

  static Size getWidgetSize(GlobalKey llave) {
    final box = llave.currentContext!.findRenderObject() as RenderBox;
    return box.size;
  }

  static Size getSizeScreen(BuildContext context) => MediaQuery.of(context).size;

  static T? findAncestorState<T extends State<StatefulWidget>>(BuildContext context) => context.findAncestorStateOfType<T>();

  static T? findAncestorWidget<T extends Widget>(BuildContext context) => context.findAncestorWidgetOfExactType<T>();
}
