import 'dart:async';

import 'package:flutter/material.dart';
import 'package:maxi_flutter_library/maxi_flutter_library.dart';
import 'package:maxi_flutter_library/src/widgets/interfaces/imaxi_scroll_positioner.dart';
import 'package:maxi_flutter_library/src/widgets/models/maxi_scroll_current_state.dart';

class MaxiScrollPositionerStandard with IMaxiScrollPositioner {
  const MaxiScrollPositionerStandard();

  @override
  Widget createWidget({
    required BuildContext context,
    required double Function() getPositionerSize,
    required Stream<MaxiScrollCurrentState> Function() getStreamState,
    required StreamSink<double> Function() setterPosition,
    required Axis orientation,
  }) {
    return _MaxiScrollPositionerStandardWidget(getStreamState: getStreamState, setterPosition: setterPosition, orientation: orientation, getPositionerSize: getPositionerSize);
  }
}

class _MaxiScrollPositionerStandardWidget extends StatefulWidget {
  final Stream<MaxiScrollCurrentState> Function() getStreamState;
  final StreamSink<double> Function() setterPosition;
  final double Function() getPositionerSize;
  final Axis orientation;

  const _MaxiScrollPositionerStandardWidget({required this.getStreamState, required this.setterPosition, required this.orientation, required this.getPositionerSize});

  @override
  State<_MaxiScrollPositionerStandardWidget> createState() => _MaxiScrollPositionerStandardState();
}

class _MaxiScrollPositionerStandardState extends StateWithLifeCycle<_MaxiScrollPositionerStandardWidget> {
  late final StreamSubscription<MaxiScrollCurrentState> subscription;
  late final StreamSink<double> setterPosition;
  late final double positionerSize;

  bool isTouchUp = false;
  bool isTouchDown = false;

  bool get canGoFurtherUp => currentState != null && currentState!.scrollPosition > 0;
  bool get canGoFurtherDown => currentState != null && currentState!.scrollPosition < currentState!.missingSize;

  MaxiScrollCurrentState? currentState;

  @override
  void initState() {
    super.initState();

    subscription = joinEvent(event: widget.getStreamState(), onData: _changeState);
    setterPosition = widget.setterPosition();
    positionerSize = widget.getPositionerSize();
  }

  @override
  Widget build(BuildContext context) {
    if (currentState == null) {
      return const SizedBox();
    }

    if (widget.orientation == Axis.vertical) {
      return Flex(
        direction: Axis.vertical,
        mainAxisSize: MainAxisSize.max,
        children: [
          _createUpButtom(),
          Expanded(child: _createTouchPositioner()),
          _createDownButtom(),
        ],
      );
    } else {
      return const Text('Not implement');
    }
  }

  Widget _createTouchPositioner() {
    if (currentState == null || currentState!.missingSize <= 0) {
      return const SizedBox();
    }

    double scrollIndicatorSize = (currentState!.orientation == Axis.vertical ? currentState!.containerHeigth : currentState!.childWidth) - currentState!.missingSize - 40;
    if (scrollIndicatorSize < 10) scrollIndicatorSize = 10;

    return GestureDetector(
      onPanUpdate: (x) {
        _touchPosition(x.localPosition.dy);
      },
      onPanStart: (x) {
        _touchPosition(x.localPosition.dy);
      },
      child: Stack(
        children: [
          Container(
            height: currentState!.orientation == Axis.horizontal ? currentState!.positionerSize : currentState!.containerHeigth - 40,
            width: currentState!.orientation == Axis.vertical ? currentState!.positionerSize : currentState!.containerHeigth - 40,
            color: Colors.transparent,
          ),
          const Center(
            child: VerticalDivider(
              color: Colors.black45,
            ),
          ),
          Center(
            child: RotatedBox(
              quarterTurns: 1,
              child: MaxiText(
                text: '${currentState!.missingSizePercentage.toInt()}%',
                size: 12,
                bold: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _createUpButtom() {
    if (currentState == null || currentState!.missingSize <= 0) {
      return const SizedBox();
    }

    return Material(
      child: InkWell(
        onTapDown: (_) {
          if (isTouchUp) {
            return;
          }
          isTouchUp = true;
          _onUp();
        },
        onTapUp: (_) {
          isTouchUp = false;
        },
        child: const Icon(Icons.keyboard_double_arrow_up, size: 20, color: Colors.green),
      ),
    );
  }

  Widget _createDownButtom() {
    if (currentState == null || currentState!.missingSize <= 0) {
      return const SizedBox();
    }

    return Material(
      child: InkWell(
        onTapDown: (_) {
          if (isTouchDown) {
            return;
          }
          isTouchDown = true;
          _onDown();
        },
        onTapUp: (_) {
          isTouchDown = false;
        },
        child: const Icon(Icons.keyboard_double_arrow_down, size: 20, color: Colors.green),
      ),
    );
  }

  void _changeState(MaxiScrollCurrentState state) {
    if (currentState == state) {
      return;
    }

    currentState = state;
    //log(state.missingSize.toString());
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _onUp() async {
    while (mounted && isTouchUp && canGoFurtherUp) {
      setterPosition.add(currentState!.scrollPosition - (currentState!.runningDistance));
      await Future.delayed(const Duration(milliseconds: 100));
    }
    isTouchUp = false;
  }

  Future<void> _onDown() async {
    while (mounted && isTouchDown && canGoFurtherDown) {
      setterPosition.add(currentState!.scrollPosition + (currentState!.runningDistance));
      await Future.delayed(const Duration(milliseconds: 100));
    }
    isTouchDown = false;
  }

  void _touchPosition(double dy) {
    final complete = currentState!.orientation == Axis.vertical ? currentState!.containerHeigth - 40 : currentState!.containerWidth - 40;
    final percentage = (dy / complete) * 100;
    if (percentage > 100 || percentage < 0) {
      return;
    }

    final newPosition = (percentage / 100) * currentState!.missingSize;
    setterPosition.add(newPosition);
  }
}
