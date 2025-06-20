import 'dart:async';

import 'package:maxi_flutter_library/maxi_flutter_library.dart';
import 'package:maxi_library/maxi_library.dart';

class IsolatedAndroidServiceExecuteWithType<T, F extends TextableFunctionality<T>> with TextableFunctionality<T> {
  final InvocationParameters parameters;

  const IsolatedAndroidServiceExecuteWithType( {required this.parameters});

  @override
  Future<T> runFunctionality({required InteractiveFunctionalityExecutor<Oration, T> manager}) {
    if (ThreadManager.instance.isServer) {
      return AndroidServiceManager.instance.executeInteractiveFunctionality<T, F>(parameters: parameters).joinExecutor(manager);
    } else {
      return inThreadServer().joinExecutor(manager);
    }
  }
}
