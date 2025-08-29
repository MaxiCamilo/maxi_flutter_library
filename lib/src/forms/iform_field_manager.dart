import 'package:maxi_flutter_library/src/forms/iform_field_operator.dart';
import 'package:maxi_library/maxi_library.dart';

mixin IFormFieldManager on IDisposable{
  bool get isValid;
  List<NegativeResult> get errors;
  List<IFormFieldOperator> get fields;

  Stream<IFormFieldManager> get notifyStatusChange;
  Stream<IFormFieldOperator> get newField;
  Stream<IFormFieldOperator> get retiredField;
  Stream<IFormFieldOperator> get fieldChangeValue;
  Stream<IFormFieldManager> get notifyErrorListChange;

  dynamic getValue({required String propertyName});

  NegativeResult? setValue({required String propertyName, required dynamic value});
  Map<String, NegativeResult> setSeveralValues(Map<String, dynamic> values);

  void removeValue({required String propertyName});

  bool hasProperty({required String propertyName});

  void addField({required IFormFieldOperator field});
  void removeField({required IFormFieldOperator field});

  void refreshStatus({required IFormFieldOperator field});

  Map<String, dynamic> createMap({required bool onlyIfIsValid});
  


  Map<String, NegativeResult> setReflectionValues(Object item) => setSeveralValues(ReflectionManager.getReflectionEntity(item.runtimeType).serializeToMap(item));

  T createEntityObject<T extends Object>() {
    final map = createMap(onlyIfIsValid: true);
    return ReflectionManager.getReflectionEntity(T).interpret(value: map, tryToCorrectNames: false) as T;
  }
}
