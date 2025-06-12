import 'package:flutter/material.dart';
import 'package:maxi_flutter_library/maxi_flutter_library.dart';
import 'package:maxi_library/export_reflectors.dart';

class EditionOptionsMenu<T> extends StatefulWidget {
  final T item;

  final void Function(T)? onEdit;
  final void Function(T)? onClone;
  final void Function(T)? onDelete;

  final bool askIfWantToDelete;
  final Oration eliminationConfirmationText;
  final IDialogWindow<void>? dialogOperator;

  const EditionOptionsMenu({
    super.key,
    required this.item,
    this.askIfWantToDelete = true,
    this.eliminationConfirmationText = const Oration(message: 'Are you sure you wish to delete it?'),
    this.onEdit,
    this.onClone,
    this.onDelete,
    this.dialogOperator,
  });

  static Future<void> showMaterialDialog<T>({
    required BuildContext context,
    required T item,
    Oration title = Oration.empty,
    bool askIfWantToDelete = true,
    bool barrierDismissible = true,
    Oration eliminationConfirmationText = const Oration(message: 'Are you sure you wish to delete it?'),
    void Function(T)? onEdit,
    void Function(T)? onClone,
    void Function(T)? onDelete,
  }) {
    return DialogUtilities.showWidgetAsMaterialDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context, dialogOperator) => Flex(
        direction: Axis.vertical,
        children: [
          Flex(
            direction: Axis.horizontal,
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(child: MaxiTranslatableText(text: title)),
              MaxiTransparentButton(icon: const Icon(Icons.close), onTouch: () => dialogOperator.defineResult(context)),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Divider(height: 5),
          ),
          Flexible(
            child: EditionOptionsMenu<T>(
              dialogOperator: dialogOperator,
              item: item,
              askIfWantToDelete: askIfWantToDelete,
              eliminationConfirmationText: eliminationConfirmationText,
              onClone: onClone,
              onDelete: onDelete,
              onEdit: onEdit,
            ),
          ),
        ],
      ),
    );
  }

  static Future<void> showBottomSheet<T>({
    required BuildContext context,
    required T item,
    bool askIfWantToDelete = true,
    bool barrierDismissible = true,
    Oration eliminationConfirmationText = const Oration(message: 'Are you sure you wish to delete it?'),
    void Function(T)? onEdit,
    void Function(T)? onClone,
    void Function(T)? onDelete,
  }) {
    return DialogUtilities.showWidgetAsBottomSheet(
      context: context,
      builder: (context, dialogOperator) => Padding(
        padding: const EdgeInsetsGeometry.all(8.0),
        child: EditionOptionsMenu<T>(
          dialogOperator: dialogOperator,
          item: item,
          askIfWantToDelete: askIfWantToDelete,
          eliminationConfirmationText: eliminationConfirmationText,
          onClone: onClone,
          onDelete: onDelete,
          onEdit: onEdit,
        ),
      ),
    );
  }

  @override
  State<EditionOptionsMenu<T>> createState() => _EditionOptionsMenuState<T>();
}

class _EditionOptionsMenuState<T> extends State<EditionOptionsMenu<T>> {
  late ISingleStackScreenOperator screenOperator;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      curve: Curves.decelerate,
      duration: const Duration(milliseconds: 200),
      child: SingleStackScreen(
        onCreatedOperator: (x) => screenOperator = x,
        initialChildBuild: _buildList,
        curve: Curves.decelerate,
        duration: const Duration(milliseconds: 250),
      ),
    );
  }

  Widget _buildList(BuildContext context) {
    final options = <Widget>[];

    if (widget.onEdit != null) {
      options.add(ListTile(
        leading: const Icon(Icons.edit),
        title: const MaxiTranslatableText(text: Oration(message: 'Edit')),
        onTap: () {
          if (widget.dialogOperator != null) {
            widget.dialogOperator!.defineResult(context);
          }
          widget.onEdit!(widget.item);
        },
      ));
    }

    if (widget.onClone != null) {
      options.add(ListTile(
        leading: const Icon(Icons.content_copy),
        title: const MaxiTranslatableText(text: Oration(message: 'Clone')),
        onTap: () {
          if (widget.dialogOperator != null) {
            widget.dialogOperator!.defineResult(context);
          }
          widget.onClone!(widget.item);
        },
      ));
    }

    if (widget.onDelete != null) {
      options.add(ListTile(
        leading: const Icon(Icons.delete),
        title: const MaxiTranslatableText(text: Oration(message: 'Delete')),
        onTap: () => _selectDelete(),
      ));
    }

    return Flex(
      direction: Axis.vertical,
      mainAxisSize: MainAxisSize.min,
      children: options,
    );
  }

  void _selectDelete() {
    if (widget.askIfWantToDelete) {
      _buildMessageWindow();
    } else {
      if (widget.dialogOperator != null) {
        widget.dialogOperator!.defineResult(context);
      }
      widget.onDelete!(widget.item);
    }
  }

  void _buildMessageWindow() {
    screenOperator.changeScreen(
        newChild: Flex(
      direction: Axis.vertical,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MaxiFlex(
          rowFrom: 500,
          expandRow: true,
          rowMainAxisAlignment: MainAxisAlignment.center,
          rowCrossAxisAlignment: CrossAxisAlignment.center,
          columnCrossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.warning, color: Colors.amber, size: 42),
            const SizedBox(width: 5),
            MaxiTranslatableText(text: widget.eliminationConfirmationText, aling: TextAlign.center),
          ],
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Divider(height: 5),
        ),
        MaxiFlex(
          rowFrom: 500,
          expandRow: true,
          reverseColumn: true,
          rowMainAxisAlignment: MainAxisAlignment.spaceBetween,
          columnCrossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MaxiTransparentButton(
              icon: const Icon(Icons.close),
              text: const Oration(message: 'No'),
              onTouch: () => screenOperator.changeScreen(newChild: _buildList(context)),
            ),
            const SizedBox(height: 7),
            MaxiTransparentButton(
              icon: const Icon(Icons.delete),
              text: const Oration(message: 'Yes'),
              textColor: Colors.deepOrange,
              onTouch: () {
                if (widget.dialogOperator != null) {
                  widget.dialogOperator!.defineResult(context);
                }
                widget.onDelete!(widget.item);
              },
            ),
          ],
        ),
      ],
    ));
  }
}
