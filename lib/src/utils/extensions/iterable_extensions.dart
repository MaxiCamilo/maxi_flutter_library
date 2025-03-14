import 'package:flutter/widgets.dart';
import 'package:maxi_flutter_library/maxi_flutter_library.dart';

extension FlutterIterableExtension<T> on Iterable<T> {
  List<T> reverseIfWidthIsSmall({required BuildContext context, required double width}) {
    if (context.screenWidth >= width) {
      if (this is List<T>) {
        return this as List<T>;
      } else {
        return toList(growable: false);
      }
    } else {
      return toList(growable: false).reversed.toList(growable: false);
    }
  }
}
