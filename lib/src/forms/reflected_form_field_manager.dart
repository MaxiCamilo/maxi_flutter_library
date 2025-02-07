import 'dart:async';

import 'package:maxi_flutter_library/maxi_flutter_library.dart';
import 'package:maxi_library/maxi_library.dart';

class ReflectedFormFieldManager<T> with IFormFieldManager {
  late final ITypeEntityReflection reflector;

  late final FormFieldManager _formOperator;

  final _notifyStatusChange = StreamController<IFormFieldManager>.broadcast();

  late Map<String, NegativeResult> _hideErrors;

  @override
  List<NegativeResult> get errors => [..._hideErrors.values, ..._formOperator.errors];

  @override
  Stream<IFormFieldOperator> get fieldChangeValue => _formOperator.fieldChangeValue;

  @override
  List<IFormFieldOperator> get fields => _formOperator.fields;

  @override
  Stream<IFormFieldOperator> get newField => _formOperator.newField;

  @override
  Stream<IFormFieldManager> get notifyStatusChange => _notifyStatusChange.stream;

  @override
  Stream<IFormFieldOperator> get retiredField => _formOperator.retiredField;

  @override
  Stream<IFormFieldManager> get notifyErrorListChange => _formOperator.notifyErrorListChange;

  @override
  bool get isValid => _formOperator.isValid && _hideErrors.isEmpty;

  late bool beforeValid;

  ReflectedFormFieldManager({T? item}) {
    reflector = ReflectionManager.getReflectionEntity(T);

    late final Map<String, dynamic> values;

    if (item != null) {
      values = reflector.serializeToMap(item);
      _hideErrors = reflector.listErrors(value: item, parentEntity: null).map((x) => MapEntry<String, NegativeResult>(x.name, x)).toMap();
    } else {
      item = reflector.buildEntity();
      values = reflector.serializeToMap(item);
      _hideErrors = reflector.listErrors(value: item, parentEntity: null).map((x) => MapEntry<String, NegativeResult>(x.name, x)).toMap();
    }

    _formOperator = FormFieldManager(values: values);
    beforeValid = isValid;

    _formOperator.retiredField.listen(_reactRetiredField);
    _formOperator.notifyStatusChange.listen(_reactOperatorStatusChange);
  }

  @override
  void addField({required IFormFieldOperator field}) {
    field.fixedPropertiesListened.iterar((x) => _hideErrors.remove(x));
    _formOperator.addField(field: field);
  }

  @override
  Map<String, dynamic> createMap({required bool onlyIfIsValid}) {
    return _formOperator.createMap(onlyIfIsValid: onlyIfIsValid);
  }

  T createEntity() {
    return reflector.interpret(value: createMap(onlyIfIsValid: true), tryToCorrectNames: false);
  }

  @override
  void dispose() {
    _formOperator.dispose();
    _notifyStatusChange.close();
  }

  @override
  getValue({required String propertyName}) {
    return _formOperator.getValue(propertyName: propertyName);
  }

  @override
  void refreshStatus({required IFormFieldOperator field}) {
    _formOperator.refreshStatus(field: field);
  }

  @override
  void removeField({required IFormFieldOperator field}) {
    _formOperator.removeField(field: field);
  }

  @override
  NegativeResult? setValue({required String propertyName, required value}) {
    return _formOperator.setValue(propertyName: propertyName, value: value);
  }

  @override
  Map<String, NegativeResult> setSeveralValues(Map<String, dynamic> values) {
    return _formOperator.setSeveralValues(values);
  }

  @override
  void removeValue({required String propertyName}) {
    _formOperator.removeValue(propertyName: propertyName);
  }

  @override
  bool hasProperty({required String propertyName}) {
    return _formOperator.hasProperty(propertyName: propertyName);
  }

  void _reactRetiredField(IFormFieldOperator field) {
    if (!field.isValid) {
      for (final proName in field.fixedPropertiesListened) {
        _hideErrors[proName] = field.lastError;
      }
    }
  }

  void _reactOperatorStatusChange(IFormFieldManager event) {
    if (beforeValid != isValid) {
      beforeValid = isValid;
      _notifyStatusChange.add(this);
    }
  }
}
