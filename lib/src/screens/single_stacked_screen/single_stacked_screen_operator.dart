import 'package:flutter/widgets.dart';
import 'package:maxi_flutter_library/maxi_flutter_library.dart';
import 'package:maxi_flutter_library/src/screens/iwidget_has_screen_operator.dart';
import 'package:maxi_library/maxi_library.dart';

class SingleStackedScreenOperator with IStackedScreenOperator {
  final _carouselOperator = SingleScreenCarouselOperator();

  final _previousScreens = <StackedCanvasWidget>[];
  StackedCanvasWidget? _actualScreen;

  Duration animationDuration = const Duration(seconds: 1);
  Curve curve = Curves.linear;

  SingleStackedScreenOperator();

  Widget generateWidget() {
    return _SingleStackedScreenStateContainer(
      stackedScreenOperator: this,
      child: _carouselOperator.generateWidget(),
    );
  }

  @override
  void goBack() {
    if (_previousScreens.isEmpty) {
      return;
    }

    final screenToChange = _previousScreens.removeLast();
    _carouselOperator.showScreen(
      screen: screenToChange,
      goLeftPrevious: false,
      animationDuration: animationDuration,
      curve: curve,
    );

    if (_actualScreen != null) {
      final previousScreen = _actualScreen!;
      Future.delayed(animationDuration).whenComplete(() => _carouselOperator.deleteScreen(screen: previousScreen, goLeftPrevious: true));
    }

    _actualScreen = screenToChange;
  }

  @override
  void pushScreen({required Widget newWidget}) {
    if (_actualScreen != null) {
      _previousScreens.add(_actualScreen!);
    }

    _actualScreen = _carouselOperator.createScreen(
      child: newWidget,
      animationDuration: animationDuration,
      goLeftPrevious: false,
      showScreen: true,
      curve: curve,
    );
  }

  @override
  void resetScreen({required Widget newWidget}) {
    if (_actualScreen != null && _previousScreens.isEmpty) {
      pushScreen(newWidget: newWidget);
      return;
    }

    pushScreen(newWidget: newWidget);
    final previousScreens = _previousScreens.toList(growable: false);
    _previousScreens.clear();
    Future.delayed(animationDuration).whenComplete(() {
      previousScreens.iterar((x) => _carouselOperator.deleteScreen(screen: x, goLeftPrevious: false));
    });
  }
}

class _SingleStackedScreenStateContainer extends StatelessWidget with IWidgetHasScreenOperator {
  @override
  final IStackedScreenOperator stackedScreenOperator;
  final Widget child;

  const _SingleStackedScreenStateContainer({required this.stackedScreenOperator, required this.child});

  @override
  Widget build(BuildContext context) => child;
}
