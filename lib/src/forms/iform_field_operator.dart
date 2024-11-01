import 'package:maxi_flutter_library/src/forms/iform_field_manager.dart';
import 'package:maxi_library/maxi_library.dart';

mixin IFormFieldOperator {
  bool get isValid;
  bool get isActive;
  NegativeResult get lastError;

  Stream<IFormFieldOperator> get notifyValueChanged;
  Future<IFormFieldOperator> get discardedField;

  bool listenToThatProperty({required String name});

  bool changeValue({required String propertyName, required dynamic value});
  Map<String, dynamic> getValues();
  NegativeResult? validateValue({required dynamic value});

  void setManager({required IFormFieldManager manager});
  void requestUpdate();
}
