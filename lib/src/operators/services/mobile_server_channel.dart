import 'dart:async';

import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:maxi_flutter_library/src/operators/internal_prefix_movile_server.dart';
import 'package:maxi_library/maxi_library.dart';

class MobileServerChannel with IChannel<Map<String, dynamic>, Map<String, dynamic>> {
  final ServiceInstance service;
  final Future Function()? onClose;
  final bool manualActivation;

  final _doneWaiter = Completer();

  late StreamController<Map<String, dynamic>> _receiverController;

  late bool _isActive;

  @override
  Stream<Map<String, dynamic>> get receiver => _receiverController.stream;

  @override
  bool get isActive => _isActive;

  MobileServerChannel({
    required this.service,
    required this.manualActivation,
    this.onClose,
  }) {
    _isActive = !manualActivation;

    _receiverController = StreamController.broadcast();

    service.on(InternalPrefixMovileServer.clientMessage).listen((x) {
      _receiverController.addIfActive(x ?? {});
    });

    service.on(InternalPrefixMovileServer.requestServerClosure).listen((x) {
      close();
    });

    if (!manualActivation) {
      declareActive();
    }
  }

  void declareActive() {
    _isActive = true;
    service.on(InternalPrefixMovileServer.serverConfirmItsInitialized).listen((_) {
      service.invoke(InternalPrefixMovileServer.serviceWasInitialized);
    });

    service.invoke(InternalPrefixMovileServer.serviceWasInitialized);
  }

  void sendServerStatus(Oration text) {
    service.invoke(InternalPrefixMovileServer.serverTextStatus, text.serialize());
  }

  @override
  void add(Map<String, dynamic> event) {
    checkProgrammingFailure(thatChecks: const Oration(message: 'The Channel is active'), result: () => isActive);
    service.invoke(InternalPrefixMovileServer.serverMessage, event);
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) {
    throw UnimplementedError('Sent error is not implemented');
  }

  void requestReboot() {
    if (isActive) {
      service.invoke(InternalPrefixMovileServer.resetMessage);
    }
  }

  @override
  Future close() async {
    if (!isActive) {
      return;
    }

    _isActive = false;
    containErrorLog(
      detail: const Oration(message: 'Send "Server Notifies Closure" to client'),
      function: () => service.invoke(InternalPrefixMovileServer.serverNotifiesClosure),
    );

    _receiverController.close();

    if (onClose != null) {
      await onClose!();
    }

    ThreadManager.killAllThread();

    service.stopSelf();
    _doneWaiter.completeIfIncomplete();

    //Isolate.exit();
  }

  @override
  Future get done => _doneWaiter.future;
}
