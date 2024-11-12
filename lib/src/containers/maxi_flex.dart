import 'package:flutter/widgets.dart';
import 'package:maxi_flutter_library/src/containers/maxi_flex_widgets/expanded_only_column.dart';
import 'package:maxi_flutter_library/src/containers/maxi_flex_widgets/expanded_only_row.dart';
import 'package:maxi_flutter_library/src/containers/maxi_flex_widgets/flex_child.dart';
import 'package:maxi_flutter_library/src/containers/maxi_flex_widgets/flexible_only_column.dart';
import 'package:maxi_flutter_library/src/containers/maxi_flex_widgets/flexible_only_row.dart';
import 'package:maxi_flutter_library/src/containers/maxi_flex_widgets/only_column.dart';
import 'package:maxi_flutter_library/src/containers/maxi_flex_widgets/only_row.dart';

class MaxiFlex extends StatelessWidget {
  final List<Widget> children;
  final double rowFrom;

  final CrossAxisAlignment rowCrossAxisAlignment;
  final MainAxisAlignment rowMainAxisAlignment;

  final CrossAxisAlignment columnCrossAxisAlignment;
  final MainAxisAlignment columnMainAxisAlignment;

  final bool reverseRow;
  final bool reverseColumn;

  final bool useScreenSize;

  final bool expandColumn;
  final bool expandRow;

  final bool removeExpandedInColumn;
  final bool removeExpandedInRow;

  final bool expandedChildInColumn;
  final bool expandedChildInRow;

  final bool removeFlexiblesInColumn;
  final bool removeFlexiblesInRow;

  final bool flexibleInColumn;
  final bool flexibleInRow;

  const MaxiFlex({
    super.key,
    required this.children,
    required this.rowFrom,
    required this.useScreenSize,
    this.expandColumn = false,
    this.expandRow = false,
    this.rowCrossAxisAlignment = CrossAxisAlignment.start,
    this.rowMainAxisAlignment = MainAxisAlignment.start,
    this.columnCrossAxisAlignment = CrossAxisAlignment.start,
    this.columnMainAxisAlignment = MainAxisAlignment.start,
    this.reverseRow = false,
    this.reverseColumn = false,
    this.removeExpandedInColumn = false,
    this.removeExpandedInRow = false,
    this.removeFlexiblesInColumn = false,
    this.removeFlexiblesInRow = false,
    this.expandedChildInColumn = false,
    this.expandedChildInRow = false,
    this.flexibleInColumn = false,
    this.flexibleInRow = false,
  });

  @override
  Widget build(BuildContext context) {
    if (useScreenSize) {
      return _createFlex(context, MediaQuery.of(context).size.width);
    } else {
      return LayoutBuilder(
        builder: (context, constraints) => _createFlex(context, MediaQuery.of(context).size.width),
      );
    }
  }

  Widget _createFlex(BuildContext context, double width) {
    if (width >= rowFrom) {
      return _createRow(context);
    } else {
      return _createColumn(context);
    }
  }

  Widget _createRow(BuildContext context) {
    final rowList = _getRowChildren(context);

    return Flex(
      direction: Axis.horizontal,
      mainAxisAlignment: rowMainAxisAlignment,
      crossAxisAlignment: rowCrossAxisAlignment,
      mainAxisSize: expandRow ? MainAxisSize.max : MainAxisSize.min,
      children: rowList,
    );
  }

  Widget _createColumn(BuildContext context) {
    final columnList = _getColumnChildren(context);

    return Flex(
      direction: Axis.vertical,
      mainAxisAlignment: columnMainAxisAlignment,
      crossAxisAlignment: columnCrossAxisAlignment,
      mainAxisSize: expandColumn ? MainAxisSize.max : MainAxisSize.min,
      children: columnList,
    );
  }

  List<Widget> _getRowChildren(BuildContext context) {
    final list = <Widget>[];

    for (final realChild in children) {
      Widget child = realChild;

      if (child is OnlyColumn) {
        continue;
      }

      if (child is OnlyRow) {
        child = child.child;
      }

      if (child is FlexChild) {
        child = child.rowChild;
      }

      if (removeExpandedInRow && child is Expanded) {
        child = child.child;
      }

      if (removeFlexiblesInRow && child is Flexible) {
        child = child.child;
      }

      if (child is FlexibleOnlyRow) {
        if (child.child is Flexible) {
          child = child.child;
        } else {
          child = Flexible(child: child.child);
        }
      }

      if (child is FlexibleOnlyColumn) {
        child = child.child;
      }

      if (child is ExpandedOnlyRow) {
        if (child.child is Expanded) {
          child = child.child;
        } else {
          child = Expanded(child: child.child);
        }
      }

      if (child is ExpandedOnlyColumn) {
        child = child.child;
      }

      if (flexibleInRow && child is! Flexible) {
        child = Flexible(child: child);
      }

      if (expandedChildInRow && child is! Expanded) {
        child = Expanded(child: child);
      }

      list.add(child);
    }

    return reverseRow ? list.reversed.toList() : list;
  }

  List<Widget> _getColumnChildren(BuildContext context) {
    final list = <Widget>[];

    for (final realChild in children) {
      Widget child = realChild;

      if (child is OnlyRow) {
        continue;
      }

      if (child is OnlyColumn) {
        child = child.child;
      }

      if (child is FlexChild) {
        child = child.columnChild;
      }

      if (removeExpandedInColumn && child is Expanded) {
        child = child.child;
      }

      if (removeFlexiblesInColumn && child is Flexible) {
        child = child.child;
      }

      if (child is FlexibleOnlyColumn) {
        if (child.child is Flexible) {
          child = child.child;
        } else {
          child = Flexible(child: child.child);
        }
      }

      if (child is FlexibleOnlyRow) {
        child = child.child;
      }

      if (child is ExpandedOnlyColumn) {
        if (child.child is Expanded) {
          child = child.child;
        } else {
          child = Expanded(child: child.child);
        }
      }

      if (child is ExpandedOnlyRow) {
        child = child.child;
      }

      if (flexibleInColumn && child is! Flexible) {
        child = Flexible(child: child);
      }

      if (expandedChildInColumn && child is! Expanded) {
        child = Expanded(child: child);
      }

      list.add(child);
    }

    return reverseColumn ? list.reversed.toList() : list;
  }
}
