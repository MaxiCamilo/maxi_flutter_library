import 'dart:async';

import 'package:maxi_flutter_library/maxi_flutter_library.dart';
import 'package:maxi_library/maxi_library.dart';

class IsolatedAndroidServiceInvokator<T, F extends TextableFunctionality<T>> with InteractableFunctionality<Oration, T> {
  final InvocationParameters parameters;

  IsolatedAndroidServiceInvokator({required this.parameters});

  @override
  Future<T> runFunctionality({required InteractableFunctionalityExecutor<Oration, T> manager}) {
    final newManager = AndroidServiceManager.instance.executeInteractableFunctionality<T, F>(parameters: parameters);

    newManager.onDispose.whenComplete(() => manager.dispose());
    manager.joinDisponsabeObject(item: newManager);

    return newManager.waitResult(onItem: (item) => manager.sendItem(item));
  }
}
