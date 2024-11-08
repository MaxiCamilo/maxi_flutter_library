import 'package:flutter/widgets.dart';
import 'package:maxi_flutter_library/maxi_flutter_library.dart';
import 'package:maxi_library/maxi_library.dart';

mixin WidgetAnimator {
  Widget build({required BuildContext context, required Widget child});

  static T? getAnimatorByAncestorOptional<T extends State<StatefulWidget>>(BuildContext context) {
    return WidgetUtilities.findAncestorState<T>(context);
  }

  static T getAnimatorByAncestor<T extends State<StatefulWidget>>(BuildContext context) {
    final result = getAnimatorByAncestorOptional<T>(context);

    if (result == null) {
      throw NegativeResult(
        identifier: NegativeResultCodes.contextInvalidFunctionality,
        message: tr('The widget is not encapsulated in a flag named %1', [T]),
      );
    }

    return result;
  }
}
