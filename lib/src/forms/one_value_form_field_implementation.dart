import 'dart:async';
import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:maxi_flutter_library/maxi_flutter_library.dart';

import 'package:maxi_library/maxi_library.dart';

abstract class OneValueFormField<T> extends StatefulWidget {
  final String propertyName;
  final IFormFieldManager? manager;
  final T Function()? getterInitialValue;
  final void Function(T)? onChangeValue;
  final List<ValueValidator> validators;

  const OneValueFormField({
    required this.propertyName,
    super.key,
    this.manager,
    this.getterInitialValue,
    this.onChangeValue,
    this.validators = const [],
  });

  @override
  OneValueFormFieldImplementation<T, OneValueFormField<T>> createState();
}

abstract class OneValueFormFieldImplementation<T, W extends OneValueFormField<T>> extends StateWithLifeCycle<W> with IFormFieldOperator {
  T get getDefaultValue;
  void renderingNewValue(T newValue);
  Widget buildField(BuildContext context);

  IFormFieldManager? manager;
  String get propertyName => widget.propertyName;

  late T _actualValue;

  T get actualValue => _actualValue;

  @override
  late NegativeResult lastError;

  bool _wasRendering = false;

  @override
  bool isValid = true;

  @override
  Stream<IFormFieldOperator> get notifyValueChanged => _notifyValueChanged.stream;

  late final StreamController<OneValueFormFieldImplementation<T, W>> _notifyValueChanged;

  @override
  void initState() {
    super.initState();

    _notifyValueChanged = createEventController<OneValueFormFieldImplementation<T, W>>(isBroadcast: true);

    if (widget.manager != null) {
      setManager(manager: widget.manager!);
    } else {
      if (widget.getterInitialValue == null) {
        _actualValue = getDefaultValue;
      } else {
        _actualValue = widget.getterInitialValue!();
      }
    }

    _internalChangeValue(value: _actualValue);
  }

  @override
  Widget build(BuildContext context) {
    if (!_wasRendering) {
      _wasRendering = true;
      renderingNewValue(_actualValue);
    }

    return buildField(context);
  }

  @override
  Future<IFormFieldOperator> get discardedField => onDispose.then((_) => this);

  @override
  bool listenToThatProperty({required String name}) {
    return propertyName == name;
  }

  @override
  bool changeValue({required String propertyName, required value}) {
    if (!listenToThatProperty(name: propertyName)) {
      log('The ${this.propertyName} field accepts only values that have the same property name (not $propertyName)');
      return false;
    }

    return declareChangedValue(value: value);
  }

  @protected
  bool declareChangedValue({required T value}) {
    if (_actualValue == value) {
      return true;
    }

    final result = _internalChangeValue(value: value);

    if (widget.onChangeValue != null) {
      widget.onChangeValue!(value);
    }
    _notifyValueChanged.add(this);

    return result;
  }

  bool _internalChangeValue({required value}) {
    if (value == _actualValue) {
      return true;
    }

    if (value == null) {
      if (widget.getterInitialValue == null) {
        value = getDefaultValue;
      } else {
        value = widget.getterInitialValue!();
      }
    }

    if (value is! T) {
      log('Field ${this.propertyName} only accepts item of type $T, not type ${value.runtimeType}');
      return false;
    }

    _actualValue = value;
    final error = validateValue(value: value);
    if (error != null) {
      lastError = error;
      isValid = false;
    } else {
      isValid = true;
    }

    if (manager != null) {
      manager!.setValue(propertyName: propertyName, value: value);
    }

    if (mounted) {
      renderingNewValue(value);
      //requestUpdate();
    }

    return isValid;
  }

  @override
  Map<String, dynamic> getValues() {
    return {propertyName: _actualValue};
  }

  @override
  bool get isActive => mounted;

  @override
  void requestUpdate() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void setManager({required IFormFieldManager manager}) {
    if (this.manager == manager) {
      return;
    }

    this.manager = manager;
    manager.addField(field: this);
    bool hasValue = false;

    final managerValue = manager.getValue(propertyName: propertyName);
    if (managerValue == null) {
      if (widget.getterInitialValue == null) {
        _actualValue = getDefaultValue;
      } else {
        _actualValue = widget.getterInitialValue!();
      }
    } else if (managerValue is T) {
      _actualValue = managerValue;
      hasValue = true;
    } else {
      log('Field $propertyName accepts only values of type $T, but a value of ${_actualValue.runtimeType} was returned in the operator');
      if (widget.getterInitialValue == null) {
        _actualValue = getDefaultValue;
      } else {
        _actualValue = widget.getterInitialValue!();
      }
    }

    if (!hasValue) {
      manager.setValue(propertyName: propertyName, value: _actualValue);
    }
  }

  @override
  NegativeResult? validateValue({required value}) {
    for (final valid in widget.validators) {
      final detectedError = valid.performValidation(name: propertyName, item: value, parentEntity: null);
      if (detectedError != null) {
        return detectedError;
      }
    }

    return null;
  }
}