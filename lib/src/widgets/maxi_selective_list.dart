import 'package:flutter/material.dart';
import 'package:maxi_flutter_library/maxi_flutter_library.dart';

class MaxiSelectiveList<T> extends StatefulWidget {
  final Future<List<T>> Function() getterValue;
  final Widget Function(BuildContext context, T item) builder;
  final void Function(T)? onSelect;
  final void Function(T)? onLongSelect;
  final void Function(T)? onSecondarySelect;
  final Widget waitingWidget;
  final Future<List<Stream>> Function()? updateStreamList;
  final Widget? whenListIsEmpty;
  final bool canRetry;
  final double iconSize;
  final double textSize;
  final Duration duration;
  final Duration hoverDuration;
  final Curve curve;
  final double? rowFrom;
  final Axis listDirection;

  final Color backgroundColor;
  final Color backgroundColorOnMouseover;
  final Color backgroundColorOnTouch;

  final MainAxisAlignment mainAxisAlignmentColumn;
  final MainAxisSize mainAxisSizeColumn;
  final CrossAxisAlignment crossAxisAlignmentColumn;
  final VerticalDirection verticalDirectionColumn;

  final MainAxisAlignment mainAxisAlignmentRow;
  final MainAxisSize mainAxisSizeRow;
  final CrossAxisAlignment crossAxisAlignmentRow;
  final VerticalDirection verticalDirectionRow;

  const MaxiSelectiveList({
    super.key,
    required this.getterValue,
    required this.builder,
    this.onSelect,
    this.waitingWidget = const CircularProgressIndicator(),
    this.canRetry = true,
    this.iconSize = 42,
    this.textSize = 12,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.linear,
    this.listDirection = Axis.vertical,
    this.mainAxisAlignmentColumn = MainAxisAlignment.start,
    this.mainAxisSizeColumn = MainAxisSize.min,
    this.crossAxisAlignmentColumn = CrossAxisAlignment.center,
    this.verticalDirectionColumn = VerticalDirection.down,
    this.mainAxisAlignmentRow = MainAxisAlignment.start,
    this.mainAxisSizeRow = MainAxisSize.max,
    this.crossAxisAlignmentRow = CrossAxisAlignment.start,
    this.verticalDirectionRow = VerticalDirection.down,
    this.backgroundColor = Colors.transparent,
    this.backgroundColorOnMouseover = const Color.fromARGB(88, 158, 158, 158),
    this.backgroundColorOnTouch = const Color.fromARGB(137, 56, 56, 56),
    this.hoverDuration = const Duration(milliseconds: 200),
    this.updateStreamList,
    this.whenListIsEmpty,
    this.rowFrom,
    this.onLongSelect,
    this.onSecondarySelect,
  });

  @override
  State<MaxiSelectiveList<T>> createState() => _MaxiSelectiveListState<T>();
}

class _MaxiSelectiveListState<T> extends StateWithLifeCycle<MaxiSelectiveList<T>> {
  @override
  Widget build(BuildContext context) {
    return LoadingScreen<List<T>>(
      builder: _buildList,
      getterValue: widget.getterValue,
      canRetry: widget.canRetry,
      curve: widget.curve,
      duration: widget.duration,
      iconSize: widget.iconSize,
      textSize: widget.textSize,
      updateStreamList: widget.updateStreamList,
      waitingWidget: widget.waitingWidget,
    );
  }

  Widget _buildList(BuildContext context, List<T> list) {
    if (list.isEmpty) {
      return widget.whenListIsEmpty ?? const SizedBox();
    }

    if (widget.rowFrom == null) {
      return Flex(
        direction: widget.listDirection,
        crossAxisAlignment: widget.listDirection == Axis.horizontal ? widget.crossAxisAlignmentRow : widget.crossAxisAlignmentColumn,
        mainAxisAlignment: widget.listDirection == Axis.horizontal ? widget.mainAxisAlignmentRow : widget.mainAxisAlignmentColumn,
        mainAxisSize: widget.listDirection == Axis.horizontal ? widget.mainAxisSizeRow : widget.mainAxisSizeColumn,
        verticalDirection: widget.listDirection == Axis.horizontal ? widget.verticalDirectionRow : widget.verticalDirectionColumn,
        children: list.map((x) => _createChildren(context, x)).toList(growable: false),
      );
    } else {
      final width = MediaQuery.of(context).size.width;
      return Flex(
        direction: widget.listDirection,
        crossAxisAlignment: width >= widget.rowFrom! ? widget.crossAxisAlignmentRow : widget.crossAxisAlignmentColumn,
        mainAxisAlignment: width >= widget.rowFrom! ? widget.mainAxisAlignmentRow : widget.mainAxisAlignmentColumn,
        mainAxisSize: width >= widget.rowFrom! ? widget.mainAxisSizeRow : widget.mainAxisSizeColumn,
        verticalDirection: width >= widget.rowFrom! ? widget.verticalDirectionRow : widget.verticalDirectionColumn,
        children: list.map((x) => _createChildren(context, x)).toList(growable: false),
      );
    }
  }

  Widget _createChildren(BuildContext context, T item) {
    final itemWidget = widget.builder(context, item);
    return _MaxiSelectiveListItem<T>(
      backgroundColor: widget.backgroundColor,
      backgroundColorOnMouseover: widget.backgroundColorOnMouseover,
      backgroundColorOnTouch: widget.backgroundColorOnTouch,
      value: item,
      onSelect: widget.onSelect,
      curve: widget.curve,
      duration: widget.duration,
      hoverDuration: widget.hoverDuration,
      onLongSelect: widget.onLongSelect,
      onSecondarySelect: widget.onSecondarySelect,
      child: itemWidget,
    );
  }
}

class _MaxiSelectiveListItem<T> extends StatefulWidget {
  final Color backgroundColor;
  final Color backgroundColorOnMouseover;
  final Color backgroundColorOnTouch;
  final void Function(T)? onSelect;
  final void Function(T)? onLongSelect;
  final void Function(T)? onSecondarySelect;
  final Duration duration;
  final Duration hoverDuration;
  final Curve curve;
  final T value;
  final Widget child;

  const _MaxiSelectiveListItem({
    super.key,
    required this.backgroundColor,
    required this.backgroundColorOnMouseover,
    required this.backgroundColorOnTouch,
    required this.onLongSelect,
    required this.onSecondarySelect,
    required this.child,
    required this.value,
    required this.onSelect,
    required this.duration,
    required this.curve,
    required this.hoverDuration,
  });

  @override
  State<_MaxiSelectiveListItem<T>> createState() => _MaxiSelectiveListItemState<T>();
}

class _MaxiSelectiveListItemState<T> extends State<_MaxiSelectiveListItem<T>> {
  late Color backgroundColor;

  @override
  void initState() {
    super.initState();
    backgroundColor = widget.backgroundColor;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: widget.duration,
      curve: widget.curve,
      color: backgroundColor,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (widget.onSelect != null) {
              widget.onSelect!(widget.value);
            }
          },
          onLongPress: () {
            if (widget.onLongSelect != null) {
              widget.onLongSelect!(widget.value);
            }
          },
          onSecondaryTap: () {
            if (widget.onSecondarySelect != null) {
              widget.onSecondarySelect!(widget.value);
            }
          },
          splashColor: widget.backgroundColorOnTouch,
          hoverColor: widget.backgroundColorOnMouseover,
          focusColor: widget.backgroundColorOnMouseover,
          hoverDuration: widget.hoverDuration,
          child: widget.child,
        ),
      ),
    );
  }
}
