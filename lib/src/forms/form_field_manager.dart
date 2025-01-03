import 'dart:async';

import 'package:maxi_flutter_library/maxi_flutter_library.dart';
import 'package:maxi_library/maxi_library.dart';

class FormFieldManager with IFormFieldManager {
  late Map<String, dynamic> _values;
  final _mapErrors = <IFormFieldOperator, NegativeResult>{};
  final _mapSubscriptions = <IFormFieldOperator, StreamSubscription>{};

  final _notifyStatusChange = StreamController<IFormFieldManager>.broadcast();
  final _notifyErrorListChange = StreamController<IFormFieldManager>.broadcast();
  final _fieldChangeValue = StreamController<IFormFieldOperator>.broadcast();
  final _newField = StreamController<IFormFieldOperator>.broadcast();
  final _retiredField = StreamController<IFormFieldOperator>.broadcast();

  @override
  final fields = <IFormFieldOperator>[];

  @override
  List<NegativeResult> get errors => _mapErrors.values.toList(growable: true);

  @override
  Stream<IFormFieldManager> get notifyStatusChange => _notifyStatusChange.stream;

  @override
  bool get isValid => _mapErrors.isEmpty;

  @override
  Stream<IFormFieldOperator> get fieldChangeValue => _fieldChangeValue.stream;

  @override
  Stream<IFormFieldOperator> get newField => _newField.stream;

  @override
  Stream<IFormFieldOperator> get retiredField => _retiredField.stream;

  @override
  Stream<IFormFieldManager> get notifyErrorListChange => _notifyErrorListChange.stream;

  FormFieldManager({Map<String, dynamic>? values}) {
    if (values != null) {
      _values = values;
    } else {
      _values = <String, dynamic>{};
    }
  }

  @override
  bool hasProperty({required String propertyName}) => _values.containsKey(propertyName);

  @override
  void addField({required IFormFieldOperator field}) {
    checkProgrammingFailure(thatChecks: tr('Field %1 is active'), result: () => field.isActive);

    if (fields.contains(field)) {
      return;
    }

    field.discardedField.then((x) => removeField(field: x));
    final subscription = field.notifyValueChanged.listen(_reactFieldChanged);

    _mapSubscriptions[field] = subscription;
    fields.add(field);

    _newField.add(field);
  }

  @override
  Map<String, dynamic> createMap({required bool onlyIfIsValid}) {
    if (onlyIfIsValid && !isValid) {
      throw NegativeResult(
        identifier: NegativeResultCodes.invalidValue,
        message: tr('The form has invalid values'),
      );
    }

    return _values;
  }

  @override
  getValue({required String propertyName}) {
    return _values[propertyName];
  }

  @override
  NegativeResult? setValue({required String propertyName, required value}) {
    final errorLength = _mapErrors.length;
    final lastStatus = isValid;
    _values[propertyName] = value;

    NegativeResult? result;

    for (final field in fields) {
      if (field.listenToThatProperty(name: propertyName)) {
        field.changeValue(propertyName: propertyName, value: value);
        if (field.isValid) {
          _mapErrors.remove(field);
        } else {
          result = field.lastError;
          if (!_mapErrors.containsKey(field)) {
            _mapErrors[field] = field.lastError;
          }
        }

        if (lastStatus != isValid) {
          _notifyStatusChange.add(this);
        }
      }
    }

    if (errorLength != _mapErrors.length) {
      _notifyErrorListChange.add(this);
    }

    return result;
  }

  @override
  void removeField({required IFormFieldOperator field}) {
    final lastStatus = isValid;
    final errorLength = _mapErrors.length;
    final subscription = _mapSubscriptions.remove(field);
    if (subscription != null) {
      subscription.cancel();
    }

    _mapErrors.remove(field);
    fields.remove(field);

    _retiredField.addIfActive(field);

    if (lastStatus != isValid) {
      _notifyStatusChange.addIfActive(this);
    }

    if (errorLength != _mapErrors.length) {
      _notifyErrorListChange.addIfActive(this);
    }
  }

  void _reactFieldChanged(IFormFieldOperator field) {
    final lastStatus = isValid;
    if (field.isValid) {
      _mapErrors.remove(field);
    } else {
      _mapErrors[field] = field.lastError;
    }

    if (lastStatus != isValid) {
      _notifyStatusChange.add(this);
    }

    _fieldChangeValue.add(field);
  }

  @override
  void dispose() {
    _mapSubscriptions.values.iterar((x) => x.cancel());
    _mapSubscriptions.clear();
    _mapErrors.clear();
    _notifyStatusChange.close();
    _fieldChangeValue.close();
    _newField.close();
    _retiredField.close();
    _notifyErrorListChange.close();
  }

  @override
  void refreshStatus({required IFormFieldOperator field}) {
    if (!fields.contains(field)) {
      addField(field: field);
      return;
    }

    _reactFieldChanged(field);
  }

  @override
  void removeValue({required String propertyName}) {
    if (!_values.containsKey(propertyName)) {
      return;
    }

    if (fields.any((x) => x.listenToThatProperty(name: propertyName))) {
      throw NegativeResult(identifier: NegativeResultCodes.contextInvalidFunctionality, message: tr('property %1 is being used by another field', [propertyName]));
    }

    _values.remove(propertyName);
  }
}
