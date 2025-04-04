import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:maxi_flutter_library/src/operators/internal_prefix_movile_server.dart';
import 'package:maxi_library/maxi_library.dart';

class MobileServiceChannel with StartableFunctionality, FunctionalityWithLifeCycle, IChannel<Map<String, dynamic>, Map<String, dynamic>> {
  final bool autoStart;
  final bool isForegroundMode;
  final bool autoStartOnBoot;
  final dynamic Function(ServiceInstance) onForeground;
  final FutureOr<bool> Function(ServiceInstance) onIosBackground;

  FlutterBackgroundService? _serviceInstance;
  Completer? _mountedServiceWaiter;
  Completer? _doneWaiter;

  late StreamController<Map<String, dynamic>> _receiverController;

  MobileServiceChannel({
    required this.onForeground,
    required this.onIosBackground,
    this.autoStart = true,
    this.isForegroundMode = true,
    this.autoStartOnBoot = true,
  });

  @override
  bool get isActive => isInitialized;

  @override
  Stream<Map<String, dynamic>> get receiver => checkActivityBefore(() => _receiverController.stream);

  void closeService() {
    if (!isActive) {
      return;
    }

    _serviceInstance!.invoke(InternalPrefixMovileServer.requestServerClosure);
  }

  Future<void> resetService() async {
    if (isActive) {
      scheduleMicrotask(() => closeService());
      await done;
    }
    await Future.delayed(const Duration(seconds: 1));
    await initialize();
  }

  Future<void> checkServerIsActive({bool initializeIfInactive = true}) async {
    if (initializeIfInactive) {
      await initialize();
    }

    _mountedServiceWaiter ??= Completer();
    _serviceInstance!.invoke(InternalPrefixMovileServer.serverConfirmItsInitialized);

    try {
      await _mountedServiceWaiter!.future;
    } catch (_) {
      containErrorLog(detail: const Oration(message: 'Requesting server conclusion'), function: () => _serviceInstance!.invoke(InternalPrefixMovileServer.requestServerClosure));
      scheduleMicrotask(() => dispose());
      rethrow;
    } finally {
      _mountedServiceWaiter = null;
    }
  }

  @override
  Future<void> afterInitializingFunctionality() async {
    WidgetsFlutterBinding.ensureInitialized();

    _serviceInstance = FlutterBackgroundService();

    await _serviceInstance!.configure(
      iosConfiguration: IosConfiguration(autoStart: true, onForeground: onForeground, onBackground: onIosBackground),
      androidConfiguration: AndroidConfiguration(autoStart: true, onStart: onForeground, isForegroundMode: isForegroundMode, autoStartOnBoot: true),
    );

    _mountedServiceWaiter ??= Completer();

    /*final initializedEvent = */ joinEvent(
      event: _serviceInstance!.on(InternalPrefixMovileServer.serviceWasInitialized),
      onData: (event) {
        _mountedServiceWaiter?.completeIfIncomplete();
      },
    );

    if (!await _serviceInstance!.startService()) {
      //initializedEvent.cancel();
      throw NegativeResult(
        identifier: NegativeResultCodes.externalFault,
        message: const Oration(message: 'The service could not be mounted'),
      );
    }

    _serviceInstance!.invoke(InternalPrefixMovileServer.serverConfirmItsInitialized);

    try {
      await _mountedServiceWaiter!.future;
    } catch (_) {
      containErrorLog(detail: const Oration(message: 'Requesting server conclusion'), function: () => _serviceInstance!.invoke(InternalPrefixMovileServer.requestServerClosure));
      rethrow;
    } finally {
      //initializedEvent.cancel();
      _mountedServiceWaiter = null;
    }

    joinEvent(
      event: _serviceInstance!.on(InternalPrefixMovileServer.serverMessage),
      onData: _onServerMessageReceiver,
    );

    joinEvent(
      event: _serviceInstance!.on(InternalPrefixMovileServer.serverNotifiesClosure),
      onData: _onServerClosed,
    );

    joinEvent(
      event: _serviceInstance!.on(InternalPrefixMovileServer.resetMessage),
      onData: _onResetMessage,
    );

    _receiverController = createEventController<Map<String, dynamic>>(isBroadcast: true);
  }

  @override
  void performObjectDiscard() {
    //close();
    super.performObjectDiscard();

    _doneWaiter?.completeIfIncomplete();
    _doneWaiter = null;

    _mountedServiceWaiter?.completeErrorIfIncomplete(
      NegativeResult(
        identifier: NegativeResultCodes.functionalityCancelled,
        message: const Oration(message: 'The channel is closing'),
      ),
    );

    _mountedServiceWaiter = null;
  }

  @override
  void add(Map<String, dynamic> event) {
    checkInitialize();
    _serviceInstance!.invoke(InternalPrefixMovileServer.clientMessage, event);
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) {
    throw UnimplementedError('Sent error is not implemented');
  }

  @override
  Future close() async {
    dispose();
  }

  @override
  Future get done {
    _doneWaiter ??= Completer();
    return _doneWaiter!.future;
  }

  void _onServerMessageReceiver(Map<String, dynamic>? message) {
    _receiverController.addIfActive(message ?? {});
  }

  void _onServerClosed(Map<String, dynamic>? p1) {
    dispose();
  }

  void _onResetMessage(Map<String, dynamic>? p1) {
    resetService();
  }
}
/*
@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {

  
}*/
