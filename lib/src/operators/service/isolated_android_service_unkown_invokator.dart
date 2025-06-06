import 'dart:async';

import 'package:maxi_flutter_library/maxi_flutter_library.dart';
import 'package:maxi_library/maxi_library.dart';

class IsolatedAndroidServiceUnkownInvokator<T> with InteractableFunctionality<Oration, T> {
  final InvocationParameters parameters;
  final String funcName;

  const IsolatedAndroidServiceUnkownInvokator({required this.parameters, required this.funcName});

  @override
  FutureOr<T> runFunctionality({required InteractableFunctionalityExecutor<Oration, T> manager}) {
    final newManager = AndroidServiceManager.instance.executeInteractableFunctionalityViaName<T>(parameters: parameters, functionalityName: funcName);

    newManager.onDispose.whenComplete(() => manager.dispose());
    manager.joinDisponsabeObject(item: newManager);

    return newManager.waitResult(onItem: (item) => manager.sendItem(item));
  }
}
