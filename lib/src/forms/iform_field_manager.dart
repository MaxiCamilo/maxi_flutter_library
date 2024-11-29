import 'package:maxi_flutter_library/src/forms/iform_field_operator.dart';
import 'package:maxi_library/maxi_library.dart';

mixin IFormFieldManager {
  bool get isValid;
  List<NegativeResult> get errors;
  List<IFormFieldOperator> get fields;

  Stream<IFormFieldManager> get notifyStatusChange;

  dynamic getValue({required String propertyName});
  NegativeResult? setValue({required String propertyName, required dynamic value});

  void addField({required IFormFieldOperator field});
  void removeField({required IFormFieldOperator field});

  Map<String, dynamic> createMap({required bool onlyIfIsValid});

  void dispose();
}
