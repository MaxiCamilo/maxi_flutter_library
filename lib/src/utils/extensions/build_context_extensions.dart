import 'package:flutter/widgets.dart';

extension BuildContextExtensions on BuildContext {
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeigth => MediaQuery.of(this).size.height;
}
