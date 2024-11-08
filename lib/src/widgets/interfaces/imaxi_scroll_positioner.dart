import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:maxi_flutter_library/src/widgets/models/maxi_scroll_current_state.dart';

mixin IMaxiScrollPositioner {
  Widget createWidget({
    required double Function() getPositionerSize,
    required BuildContext context,
    required Axis orientation,
    required Stream<MaxiScrollCurrentState> Function() getStreamState,
    required StreamSink<double> Function() setterPosition,
  });
}
