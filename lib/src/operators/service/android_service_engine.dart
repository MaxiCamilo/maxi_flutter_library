import 'dart:async';
import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:maxi_flutter_library/maxi_flutter_library.dart';
import 'package:maxi_flutter_library/src/operators/service/android_service_reserved_commands.dart';
import 'package:maxi_library/maxi_library.dart';

class AndroidServiceEngine with StartableFunctionality, FunctionalityWithLifeCycle, FunctionalityWithLifeCycleAsStream, IAndroidServiceManager {
  final String serverName;
  final ServiceInstance service;
  final List<IReflectorAlbum> reflectors;
  final bool defineLanguageOperatorInOtherThread;
  final StreamStateTextsVoid Function() preparatoryFunction;
  final bool useWorkingPath;
  final bool useWorkingPathInDebug;

  late Semaphore _syncronizerShipment;
  Completer? _awaitingShipmentConfirmation;
  Completer? _awaitingDone;

  StreamController<(String, Map<String, dynamic>)>? _receivedData;

  late StreamController _newClientController;
  late StreamController _closeClientController;
  late StreamController<NegativeResult> _errorStreamController;

  AndroidServiceEngine({
    required this.serverName,
    required this.service,
    required this.reflectors,
    required this.defineLanguageOperatorInOtherThread,
    required this.preparatoryFunction,
    required this.useWorkingPath,
    required this.useWorkingPathInDebug,
  });

  @override
  bool get isServer => true;

  @override
  bool hasClient = false;

  @override
  Stream<void> get nofityCloseClient => checkFirstIfInitialized(() => _closeClientController.stream);

  @override
  Stream<void> get notifyNewClient => checkFirstIfInitialized(() => _newClientController.stream);

  @override
  Stream<NegativeResult> get notifyError => checkFirstIfInitialized(() => _errorStreamController.stream);

  @override
  Stream<(String, Map<String, dynamic>)> get receivedData => checkFirstIfInitialized(() => _receivedData!.stream);

  @override
  StreamStateTextsVoid afterInitializingFunctionalityAsStream() async* {
    yield* connectOptionalFunctionalStream(
      _afterInitializingFunctionalityAsStreamAsegurated(),
      onData: (x) {
        service.invoke(AndroidServiceReservedCommands.serverSendsInitializationStatus, x.serialize());
      },
      onResult: (x) {
        service.invoke(AndroidServiceReservedCommands.correctInitializedConfirmedServer);
      },
      onError: (x, y) {
        service.invoke(AndroidServiceReservedCommands.serverInitializationError, NegativeResult.searchNegativity(item: x, actionDescription: const Oration(message: 'Starting service')).serialize());
        Future.delayed(const Duration(milliseconds: 20)).whenComplete(() => _closeService());
      },
    );
  }

  StreamStateTextsVoid _afterInitializingFunctionalityAsStreamAsegurated() async* {
    _newClientController = createEventController(isBroadcast: true);
    _closeClientController = createEventController(isBroadcast: true);
    _receivedData = createEventController<(String, Map<String, dynamic>)>(isBroadcast: true);
    _errorStreamController = createEventController<NegativeResult>(isBroadcast: true);

    _syncronizerShipment = joinObject(item: Semaphore());
    //_awaitingDone = joinObject(item: Completer());

    yield streamTextStatus(const Oration(message: 'Setting up background service'));
    AndroidServiceManager.defineInstance(newInstance: this, initialize: false);

    await ApplicationManager.changeInstance(
      initialize: true,
      newInstance: AndroidApplicationManager(
        reflectors: reflectors,
        defineLanguageOperatorInOtherThread: defineLanguageOperatorInOtherThread,
        useWorkingPath: useWorkingPath,
        useWorkingPathInDebug: useWorkingPathInDebug,
        androidServiceIsServer: true,
      ),
    );

    yield* preparatoryFunction();

    joinEvent(
      event: service.on(AndroidServiceReservedCommands.notifyNewClient),
      onData: _reactNewClient,
    );

    joinEvent(
      event: service.on(AndroidServiceReservedCommands.notifyCloseClient),
      onData: _reactCloseClient,
    );

    joinEvent(
      event: service.on(AndroidServiceReservedCommands.clientRequiresServerName),
      onData: _clientRequiresServerName,
    );

    joinEvent(
      event: service.on(AndroidServiceReservedCommands.clientReceivedMessage),
      onData: _reactConfirmReceived,
    );

    joinEvent(
      event: service.on(AndroidServiceReservedCommands.clientSendMessage),
      onData: _reactClientSendMessage,
    );

    joinEvent(
      event: service.on(AndroidServiceReservedCommands.clientSendAppStatus),
      onData: _reactClientSendAppStatus,
    );

    joinEvent(
      event: listenToData(eventName: AndroidServiceReservedCommands.serverSendError),
      onData: (x) {
        final error = NegativeResult.interpret(values: x, checkTypeFlag: true);
        _errorStreamController.addIfActive(error);
      },
    );

    hasClient = true;
  }

  @override
  void reactWhenInitializedFinishes() {
    super.reactWhenInitializedFinishes();
    service.invoke(AndroidServiceReservedCommands.correctInitializedConfirmedServer);
  }

  @override
  void reactWhenItFails(error, StackTrace trace) {
    super.reactWhenItFails(error, trace);
    service.invoke(
      AndroidServiceReservedCommands.serverInitializationError,
      NegativeResult.searchNegativity(
        item: error,
        actionDescription: const Oration(message: 'Initializing server'),
        stackTrace: trace,
      ).serialize(),
    );
  }

  @override
  Stream<Map<String, dynamic>> listenToData({required String eventName}) {
    if (_receivedData == null) {
      checkInitialize();
    }
    return _receivedData!.stream.where((x) => x.$1 == eventName).map((x) => x.$2);
    //return checkFirstIfInitialized(() => _backgroundService.on(eventName).map((x) => x ?? {}));
  }

  @override
  Future<void> reset() async {
    service.invoke(AndroidServiceReservedCommands.serverRequiredReset);
  }

  @override
  Future<void> shutdown() {
    service.invoke(AndroidServiceReservedCommands.serverFinishesItsExecution);
    return _closeService();
  }

  @override
  void dispose() {
    _awaitingDone?.completeIfIncomplete();
    _awaitingDone = null;

    super.dispose();
    _receivedData?.close();
    _receivedData = null;
  }

  Future<void> _closeService() async {
    ThreadManager.killAllThread();

    if (_awaitingDone != null) {
      _awaitingDone?.completeIfIncomplete();
      _awaitingDone = null;
      await continueOtherFutures();
    }

    await service.stopSelf();
  }

  void _clientRequiresServerName(Map<String, dynamic>? p1) {
    service.invoke(AndroidServiceReservedCommands.serverSendsItsName, {'name': serverName});
  }

  void _reactClientSendMessage(Map<String, dynamic>? rawContext) {
    service.invoke(AndroidServiceReservedCommands.serverReceivedMessage);

    final context = rawContext ?? {};

    final name = context['name'] as String;
    late final Map<String, dynamic> content;
    if (context.containsKey('content')) {
      content = context['content'] as Map<String, dynamic>;
    } else {
      content = {};
    }

    _receivedData!.addIfActive((name, content));
  }

  @override
  Future<void> sendData({required String eventName, Map<String, dynamic>? content}) {
    checkFirstIfInitialized(() {});
    return _syncronizerShipment.execute(function: () async {
      _awaitingShipmentConfirmation = joinWaiter();
      service.invoke(
        AndroidServiceReservedCommands.serverSendMessage,
        {'name': eventName, 'content': content ?? {}},
      );
      await _awaitingShipmentConfirmation!.future.timeout(
        const Duration(seconds: 7),
        onTimeout: () {
          throw NegativeResult(identifier: NegativeResultCodes.timeout, message: const Oration(message: 'The client took too long to confirm receipt of the sent package'));
        },
      );
    });
  }

  void _reactConfirmReceived(Map<String, dynamic>? p1) {
    _awaitingShipmentConfirmation?.completeIfIncomplete();
    _awaitingShipmentConfirmation = null;
  }

  void _reactNewClient(Map<String, dynamic>? p1) {
    hasClient = true;
    _newClientController.addIfActive(null);
  }

  void _reactCloseClient(Map<String, dynamic>? p1) {
    hasClient = false;
    _closeClientController.addIfActive(null);
    FlutterApplicationManager.changedApplicationStatus.add(AppLifecycleState.detached);
  }

  void _reactClientSendAppStatus(Map<String, dynamic>? rawContext) {
    final context = rawContext ?? {};

    final content = context.getRequiredValueWithSpecificType<int>('content');
    final status = AppLifecycleState.values[content];
    FlutterApplicationManager.changedApplicationStatus.add(status);

    log(status.name);
  }

  @override
  void closeConnection() {
    log('[AndroidServiceEngine] WARNING! The server cannot be defined as closed');
    dispose();
  }

  @override
  Future<void> get onDone {
    _awaitingDone ??= joinWaiter();

    return _awaitingDone!.future;
  }

  @override
  Future<void> sendError({required NegativeResult error}) {
    return sendData(
      eventName: AndroidServiceReservedCommands.serverSendError,
      content: error.serialize(),
    );
  }
}
