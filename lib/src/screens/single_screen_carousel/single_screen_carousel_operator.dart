import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:maxi_flutter_library/maxi_flutter_library.dart';

class SingleScreenCarouselOperator {
  late final StackedCanvasOperator canvasOperator;

  final _previousWidgets = <StackedCanvasWidget>[];

  StackedCanvasWidget? _actualWidget;

  SingleScreenCarouselOperator({StackedCanvasOperator? canvasOperator}) {
    this.canvasOperator = canvasOperator ?? StackedCanvasOperator();
  }

  StackedCanvasWidget createScreen({
    required Widget child,
    required Duration animationDuration,
    required bool goLeftPrevious,
    bool showScreen = false,
  }) {
    late final StackedCanvasWidget newScreen;

    if (canvasOperator.currentSize == null) {
      newScreen = canvasOperator.createCanvas(
        child: child,
        animationDuration: animationDuration,
        top: 0,
        bottom: 0,
        left: 0,
        right: 0,
      );
    } else if (goLeftPrevious) {
      newScreen = canvasOperator.createCanvas(
        child: child,
        animationDuration: animationDuration,
        left: canvasOperator.currentSize!.maxWidth * -1,
        right: canvasOperator.currentSize!.maxWidth,
        top: 0,
        bottom: 0,
      );
    } else {
      newScreen = canvasOperator.createCanvas(
        child: child,
        animationDuration: animationDuration,
        left: canvasOperator.currentSize!.maxWidth,
        right: canvasOperator.currentSize!.maxWidth * -1,
        top: 0,
        bottom: 0,
      );
    }
    _previousWidgets.add(newScreen);

    if (showScreen) {
      Future.delayed(const Duration(milliseconds: 20)).whenComplete(() => this.showScreen(
            goLeftPrevious: !goLeftPrevious,
            screen: newScreen,
            animationDuration: animationDuration,
          ));
    }

    return newScreen;
  }

  void showScreen({
    required StackedCanvasWidget screen,
    required bool goLeftPrevious,
    Duration? animationDuration,
    Curve? curve,
  }) {
    if (_actualWidget == screen) {
      return;
    }

    _movePrevious(goLeftPrevious: goLeftPrevious, animationDuration: animationDuration, curve: curve);

    _previousWidgets.remove(screen);
    _actualWidget = screen;

    screen.changePosition(left: 0, right: 0, duration: animationDuration, curve: curve);
  }

  void _movePrevious({
    required bool goLeftPrevious,
    Duration? animationDuration,
    Curve? curve,
  }) {
    if (_actualWidget == null) {
      return;
    }

    if (canvasOperator.currentSize == null) {
      log('[SingleScreenCarouselOperator] Cannot get current size from canvas operator!');
      return;
    }

    final currentSize = canvasOperator.currentSize!;

    if (goLeftPrevious) {
      _actualWidget!.changePosition(
        duration: animationDuration,
        left: currentSize.maxWidth * -1,
        right: currentSize.maxWidth,
        curve: curve,
      );
    } else {
      _actualWidget!.changePosition(
        duration: animationDuration,
        left: currentSize.maxWidth,
        right: currentSize.maxWidth * -1,
        curve: curve,
      );
    }
    _previousWidgets.add(_actualWidget!);

    _actualWidget = null;
  }

  void deleteScreen({
    required StackedCanvasWidget screen,
    required bool goLeftPrevious,
    Duration? animationDuration,
    Curve? curve,
  }) {
    if (_actualWidget == screen) {
      if (_previousWidgets.isEmpty) {
        screen.autoRemove();
      } else {
        final lastWidget = _previousWidgets.last;
        showScreen(screen: lastWidget, goLeftPrevious: goLeftPrevious, animationDuration: animationDuration, curve: curve);
        Future.delayed(animationDuration ?? lastWidget.duration).whenComplete(() => screen.autoRemove());
      }
    } else {
      screen.autoRemove();
    }
  }
}
