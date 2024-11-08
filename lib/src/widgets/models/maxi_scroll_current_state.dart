import 'package:flutter/widgets.dart';

class MaxiScrollCurrentState {
  final double containerWidth;
  final double containerHeigth;

  final double childWidth;
  final double childHeigth;
  final double scrollPosition;

  final double positionerSize;
  final Axis orientation;
  final double runningDistance;

  double get missingSize => orientation == Axis.vertical ? (childHeigth - containerHeigth) : (childWidth - containerWidth);
  double get missingSizePercentage => missingSize == 0 ? 0 : (scrollPosition / missingSize) * 100;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! MaxiScrollCurrentState) return false;

    return containerWidth == other.containerWidth &&
        containerHeigth == other.containerHeigth &&
        childWidth == other.childWidth &&
        childHeigth == other.childHeigth &&
        scrollPosition == other.scrollPosition &&
        positionerSize == other.positionerSize &&
        orientation == other.orientation &&
        runningDistance == other.runningDistance;
  }

  @override
  int get hashCode => Object.hash(containerWidth, containerHeigth, childWidth, childHeigth, scrollPosition, positionerSize, orientation, runningDistance);

  const MaxiScrollCurrentState({
    required this.orientation,
    required this.containerWidth,
    required this.containerHeigth,
    required this.childWidth,
    required this.childHeigth,
    required this.positionerSize,
    required this.scrollPosition,
    required this.runningDistance,
  });
}
