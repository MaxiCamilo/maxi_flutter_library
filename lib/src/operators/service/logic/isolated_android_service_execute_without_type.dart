import 'dart:async';

import 'package:maxi_flutter_library/maxi_flutter_library.dart';
import 'package:maxi_library/maxi_library.dart';

class IsolatedAndroidServiceExecuteWithoutType<T> with TextableFunctionality<T> {
  final String functionalityType;
  final InvocationParameters parameters;

  const IsolatedAndroidServiceExecuteWithoutType({required this.functionalityType, required this.parameters});

  @override
  Future<T> runFunctionality({required InteractiveFunctionalityExecutor<Oration, T> manager}) {
    if (ThreadManager.instance.isServer) {
      return AndroidServiceManager.instance.executeInteractiveFunctionalityViaName<T>(functionalityName: functionalityName, parameters: parameters).joinExecutor(manager);
    } else {
      return inThreadServer().joinExecutor(manager);
    }
  }
}
