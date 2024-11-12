import 'dart:async';

import 'package:flutter/material.dart';
import 'package:maxi_flutter_library/maxi_flutter_library.dart';
import 'package:maxi_flutter_library/src/widgets/interfaces/imaxi_scroll_positioner.dart';
import 'package:maxi_flutter_library/src/widgets/models/maxi_scroll_current_state.dart';

class MaxiScroll extends StatefulWidget {
  final Axis orientation;
  final Widget child;
  final IMaxiScrollPositioner positioner;
  final double scrollSize;
  final double runningDistance;

  const MaxiScroll({
    super.key,
    required this.orientation,
    required this.child,
    this.scrollSize = 20,
    this.positioner = const MaxiScrollPositionerStandard(),
    this.runningDistance = 20,
  });

  @override
  State<MaxiScroll> createState() => _MaxiScrollState();
}

class _MaxiScrollState extends StateWithLifeCycle<MaxiScroll> {
  late final StreamController<MaxiScrollCurrentState> stateController;
  late final StreamController<double> changePositionController;
  late final ScrollController scrollController;

  final contentKey = GlobalKey();
  final scrollKey = GlobalKey();

  MaxiScrollCurrentState? currentState;

  @override
  void initState() {
    super.initState();

    scrollController = joinObject(item: ScrollController());
    stateController = createEventController<MaxiScrollCurrentState>(isBroadcast: true);
    changePositionController = createEventController<double>(isBroadcast: true);

    scrollController.addListener(_scrollControllerChange);

    joinEvent(event: changePositionController.stream, onData: _changePosition);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
      scheduleMicrotask(_checkSizeContent);

      if (widget.orientation == Axis.vertical) {
        return Flex(
          direction: Axis.horizontal,
          children: [
            SizedBox(
              width: constraints.maxWidth - widget.scrollSize,
              height: constraints.maxHeight,
              child: SingleChildScrollView(
                key: scrollKey,
                controller: scrollController,
                child: Container(
                  key: contentKey,
                  child: widget.child,
                ),
              ),
            ),
            SizedBox(
              width: widget.scrollSize,
              height: constraints.maxHeight,
              child: widget.positioner.createWidget(
                getPositionerSize: () => widget.scrollSize,
                context: context,
                orientation: widget.orientation,
                getStreamState: () => stateController.stream,
                setterPosition: () => changePositionController,
              ),
            )
          ],
        );
      }

      return const Text('Not implement');
    });
  }

  void _checkSizeContent() {
    if (!mounted) {
      return;
    }

    final actualState = getCurrentState();
    if (actualState != currentState) {
      currentState = actualState;
      stateController.add(actualState);
    }
  }

  MaxiScrollCurrentState getCurrentState() {
    final contentSize = WidgetUtilities.getWidgetSize(contentKey);
    final scrollSize = WidgetUtilities.getWidgetSize(scrollKey);

    return MaxiScrollCurrentState(
      childHeigth: contentSize.height,
      childWidth: contentSize.width,
      containerHeigth: scrollSize.height,
      containerWidth: scrollSize.width,
      orientation: widget.orientation,
      positionerSize: widget.scrollSize,
      scrollPosition: scrollController.offset,
      runningDistance: widget.runningDistance,
    );
  }

  void _changePosition(double newPosition) {
    scrollController.jumpTo(newPosition);
  }

  void _scrollControllerChange() {
    _checkSizeContent();
  }
}
