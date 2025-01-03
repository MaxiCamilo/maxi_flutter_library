import 'package:flutter/material.dart';
import 'package:maxi_flutter_library/maxi_flutter_library.dart';
import 'package:maxi_library/maxi_library.dart';

class FormTextListEditor extends OneValueFormField<List<String>> {
  final bool useListView;
  final int? maximumLength;
  final int? minimumLength;
  final List<ValueValidator> itemsValidators;
  final TranslatableText? title;
  final Color firstBackgroudColor;
  final Color secondBackgroundColor;

  const FormTextListEditor({
    required super.propertyName,
    required this.useListView,
    this.firstBackgroudColor = const Color.fromARGB(55, 71, 71, 71),
    this.secondBackgroundColor = const Color.fromARGB(120, 71, 71, 71),
    this.title,
    this.minimumLength,
    this.maximumLength,
    this.itemsValidators = const [],
    super.formalName = TranslatableText.empty,
    super.key,
    super.manager,
    super.validators,
    super.onChangeValue,
    super.getterInitialValue,
  });

  @override
  OneValueFormFieldImplementation<List<String>, OneValueFormField<List<String>>> createState() => _FormTextListEditorState();
}

class _FormTextListEditorState extends OneValueFormFieldImplementation<List<String>, FormTextListEditor> {
  int? minimum;
  int? maximum;

  CheckList? listValidator;

  int actualKey = 0;

  late List<ValueValidator> itemValidators;

  @override
  List<String> get getDefaultValue => <String>[];

  @override
  void initState() {
    minimum = widget.minimumLength;
    maximum = widget.maximumLength;

    listValidator = widget.validators.selectByType<CheckList>();
    if (listValidator != null && minimum == null) {
      minimum = listValidator!.minimumLength;
    }

    if (listValidator != null && maximum == null) {
      maximum = listValidator!.maximumLength;
    }

    itemValidators = [...widget.itemsValidators, ...(listValidator?.validatos ?? <ValueValidator>[])];

    super.initState();
  }

  @override
  NegativeResult? validateValue({required value}) {
    final list = value as Iterable;

    if (minimum != null && list.length < minimum!) {
      return NegativeResultValue(
        message: tr('The list of property %1 has %2 items, but at least %3 items are required', [widget.formalName, list.length, minimum!]),
        formalName: widget.formalName,
        name: widget.propertyName,
        value: value,
      );
    }

    if (maximum != null && list.length > maximum!) {
      return NegativeResultValue(
        message: tr('The list of property %1 has %2 items, but a maximum of %3 items is accepted', [widget.formalName, list.length, maximum!]),
        formalName: widget.formalName,
        name: widget.propertyName,
        value: value,
      );
    }

    if (widget.itemsValidators.isNotEmpty && list.isNotEmpty) {
      int i = 1;
      for (final item in list) {
        for (final val in widget.itemsValidators) {
          final error = val.performValidation(name: '${widget.formalName.toString()}: Item $i', formalName: widget.formalName, item: item, parentEntity: null);
          return error;
        }
      }
      i += 1;
    }

    return super.validateValue(value: value);
  }

  @override
  void renderingNewValue(List<String> newValue) {
    setState(() {});
  }

  @override
  Widget buildField(BuildContext context) {
    return Flex(
      direction: Axis.vertical,
      mainAxisSize: widget.useListView ? MainAxisSize.max : MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MaxiTranslatableText(text: widget.title ?? widget.formalName, bold: true, size: 20, aling: TextAlign.left, color: isValid ? null : Colors.redAccent),
        MaxiRectangle(
          borderColor: isValid ? const Color.fromARGB(104, 255, 255, 255) : const Color.fromARGB(193, 244, 67, 54),
          borderRadious: 5.0,
          //padding: const EdgeInsets.all(5.0),
          borderWidth: 1,
          child: _buildList(context),
        ),
      ],
    );
  }

  Widget _buildList(BuildContext context) {
    if (widget.useListView) {
      return _buildListWithListView(context);
    } else {
      return _buildListWithFlex(context);
    }
  }

  Widget _buildListWithListView(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        itemCount: actualValue.length + 1,
        itemBuilder: (_, i) => _makeItems(position: i),
      ),
    );
  }

  Widget _buildListWithFlex(BuildContext context) {
    return Flex(
      direction: Axis.vertical,
      mainAxisSize: MainAxisSize.min,
      children: List<int>.generate(actualValue.length + 1, (index) => index, growable: false).map((x) => _makeItems(position: x)).toList(),
    );
  }

  Widget _makeItems({required int position}) {
    if (position >= actualValue.length) {
      return _makeAddButton();
    }

    final backgroundColor = position % 2 == 0 ? widget.firstBackgroudColor : widget.secondBackgroundColor;

    return MaxiRectangle(
      key: ValueKey('$actualKey-$position'),
      backgroundColor: backgroundColor,
      padding: const EdgeInsets.all(8.0),
      child: Flex(
        direction: Axis.horizontal,
        mainAxisSize: MainAxisSize.max,
        children: [
          MaxiText(
            text: '${position + 1}°'.toString(),
            bold: true,
            color: Colors.cyan,
            size: 21,
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: SizedBox(height: 40, child: VerticalDivider(width: 1)),
          ),
          Expanded(
            child: FormText(
              propertyName: propertyName,
              title: TranslatableText.empty,
              getterInitialValue: () => actualValue[position],
              validators: itemValidators,
              onChangeValue: (text, _) => onChangueValue(position: position, text: text),
              //onIsInvalid: (_) => reactInvalidForm(position),
              // onIsValid: (_) => reactValidForm(position),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: SizedBox(height: 40, child: VerticalDivider(width: 1)),
          ),
          TextButton.icon(onPressed: () => onPressRemoveItem(position), label: const Icon(Icons.remove, color: Colors.red)),
        ],
      ),
    );
  }

  Widget _makeAddButton() {
    if (maximum != null && maximum! <= actualValue.length) {
      return const SizedBox();
    }
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: MaxiTransparentButton(
          icon: const Icon(Icons.add),
          onTouch: touchAddText,
        ),
      ),
    );
  }

  void touchAddText() {
    actualKey += 1;
    changeValue(propertyName: propertyName, value: actualValue.toList()..add(''));
  }

  void onPressRemoveItem(int position) {
    actualKey += 1;
    changeValue(propertyName: propertyName, value: actualValue.toList()..removeAt(position));
  }

  void onChangueValue({required int position, required String text}) {
    //actualKey += 1;
    changeValue(propertyName: propertyName, value: actualValue.toList()..[position] = text);
  }
/*
  void reactInvalidForm(int position) {
    print('OH NO $position');
  }

  reactValidForm(int position) {
    print('yey $position');
  }
  */
}
