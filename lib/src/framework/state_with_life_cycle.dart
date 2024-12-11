import 'dart:async';
import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:maxi_library/maxi_library.dart';

abstract class StateWithLifeCycle<T extends StatefulWidget> extends State<T> {
  final _eventsList = <StreamSubscription>[];
  final _controllersList = <StreamController>[];
  final _otherActiveList = <Object>[];

  bool _isDispose = false;

  Completer<StateWithLifeCycle<T>>? _waitingDiscarded;

  bool get isDispose => _isDispose;

  Future<StateWithLifeCycle<T>> get onDispose {
    _waitingDiscarded ??= Completer<StateWithLifeCycle<T>>();
    return _waitingDiscarded!.future;
  }

  StreamController<R> createEventController<R>({required bool isBroadcast}) {
    late final StreamController<R> newController;

    if (isBroadcast) {
      newController = StreamController<R>.broadcast();
    } else {
      newController = StreamController<R>();
    }

    _controllersList.add(newController);
    newController.done.whenComplete(() => _controllersList.remove(newController));

    return newController;
  }

  StreamSubscription<R> joinEvent<R>({
    required Stream<R> event,
    required void Function(R) onData,
    void Function(dynamic)? onError,
    void Function()? onDone,
  }) {
    late final StreamSubscription<R> subscription;
    subscription = event.listen(
      onData,
      onError: onError,
      onDone: () {
        _eventsList.remove(subscription);
        if (onDone != null) {
          onDone();
        }
      },
    );
    _eventsList.add(subscription);
    return subscription;
  }

  R joinObject<R extends Object>({required R item}) {
    _otherActiveList.add(item);
    return item;
  }

  Future<void> callEntityStreamDirectly<S extends Object, R>({
    InvocationParameters parameters = InvocationParameters.emptry,
    required FutureOr<Stream<R>> Function(S serv, InvocationParameters para) function,
    bool cancelOnError = false,
    void Function(R)? onListen,
    void Function()? onDone,
    void Function(Object error, [StackTrace? stackTrace])? onError,
  }) async {
    final subscription = await ThreadManager.callEntityStreamDirectly(
      function: function,
      cancelOnError: cancelOnError,
      onDone: onDone,
      onError: onError,
      onListen: onListen,
      parameters: parameters,
    );

    if (isDispose) {
      subscription.cancel();
    } else {
      _eventsList.add(subscription);
    }
  }

  @override
  void dispose() {
    super.dispose();

    _isDispose = true;

    _eventsList.iterar((x) => x.cancel());

    _controllersList.iterar((x) => x.close());

    _otherActiveList.iterar((x) {
      try {
        (x as dynamic).dispose();
      } catch (ex) {
        log('[Error en descartar objeto] $ex');
      }
    });

    _eventsList.clear();
    _controllersList.clear();
    _otherActiveList.clear();

    _waitingDiscarded?.complete(this);
    _waitingDiscarded = null;
  }
}
