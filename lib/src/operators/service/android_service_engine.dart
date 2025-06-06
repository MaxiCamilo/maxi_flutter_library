import 'dart:async';
import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:maxi_flutter_library/maxi_flutter_library.dart';
import 'package:maxi_flutter_library/src/operators/service/android_service_reserved_commands.dart';
import 'package:maxi_flutter_library/src/operators/service/isolated_android_service.dart';
import 'package:maxi_library/maxi_library.dart';

class AndroidServiceEngine with StartableFunctionality, PaternalFunctionality, FunctionalityWithLifeCycle, RemoteFunctionalitiesExecutor, IAndroidServiceManager {
  final String serverName;
  final ServiceInstance service;
  final List<IReflectorAlbum> reflectors;
  final bool defineLanguageOperatorInOtherThread;
  final FutureOr Function() preparatoryFunction;

  final bool useWorkingPath;
  final bool useWorkingPathInDebug;

  late Semaphore _syncronizerShipment;

  Completer? _awaitingShipmentConfirmation;
  Completer? _awaitingDone;
  RemoteFunctionalitiesExecutor? _functionInvoker;

  StreamController<(String, Map<String, dynamic>)>? _receivedData;

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
  bool get hasClient => IsolatedAndroidService.sharedHasClient.syncValue;

  @override
  Stream<void> get nofityCloseClient => checkFirstIfInitialized(() => IsolatedAndroidService.sharedHasClient.receiver.where((x) => !x));

  @override
  Stream<void> get notifyNewClient => checkFirstIfInitialized(() => IsolatedAndroidService.sharedHasClient.receiver.where((x) => x));

  @override
  Stream<NegativeResult> get notifyError => checkFirstIfInitialized(() => _errorStreamController.stream);

  @override
  Stream<(String, Map<String, dynamic>)> get receivedData => checkFirstIfInitialized(() => _receivedData!.stream);

  @override
  Future<void> afterInitializingFunctionality() async {
    try {
      await _afterInitializingFunctionalityAsStreamAsegurated();
    } catch (ex, st) {
      containErrorLog(
        detail: const Oration(message: 'Starting service'),
        function: () =>
            service.invoke(AndroidServiceReservedCommands.serverInitializationError, NegativeResult.searchNegativity(item: ex, stackTrace: st, actionDescription: const Oration(message: 'Starting service')).serialize()),
      );
      Future.delayed(const Duration(milliseconds: 20)).whenComplete(() => _closeService());
    }
  }

  Future<void> _afterInitializingFunctionalityAsStreamAsegurated() async {
    await IsolatedAndroidService.initializeEvents();
    await IsolatedAndroidService.sharedIsServer.changeValue(true);

    _receivedData = createEventController<(String, Map<String, dynamic>)>(isBroadcast: true);
    _errorStreamController = createEventController<NegativeResult>(isBroadcast: true);

    _syncronizerShipment = joinObject(item: Semaphore());
    //_awaitingDone = joinObject(item: Completer());

    //AndroidServiceManager.defineInstance(newInstance: this, initialize: false);

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

    await preparatoryFunction();

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
      event: service.on(AndroidServiceReservedCommands.clientRequestsServiceTermination),
      onData: (_) => shutdown(),
    );

    joinEvent(
      event: listenToData(eventName: AndroidServiceReservedCommands.serverSendError),
      onData: (x) {
        final error = NegativeResult.interpret(values: x, checkTypeFlag: true);

        _errorStreamController.addIfActive(error);
        IsolatedAndroidService.sharedNotifyError.add(error);
      },
    );

    IsolatedAndroidService.sharedHasClient.changeValue(true);
    _makeInvoker();
  }

  @override
  void reactWhenInitializedFinishes() {
    super.reactWhenInitializedFinishes();
    _clientRequiresServerName();
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
  Future<void> shutdown() async {
    service.invoke(AndroidServiceReservedCommands.serverFinishesItsExecution);
    dispose();
    await continueOtherFutures();
    ThreadManager.killAllThread();
    await continueOtherFutures();
    await _closeService();
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
    if (_awaitingDone != null) {
      _awaitingDone?.completeIfIncomplete();
      _awaitingDone = null;
      await continueOtherFutures();
    }

    await service.stopSelf();
  }

  void _clientRequiresServerName([_]) {
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

    IsolatedAndroidService.sharedReceivedData.add((name, content));
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
    IsolatedAndroidService.sharedHasClient.changeValue(true);
  }

  void _reactCloseClient(Map<String, dynamic>? p1) {
    FlutterApplicationManager.changedApplicationStatus.add(AppLifecycleState.detached);
    IsolatedAndroidService.sharedHasClient.changeValue(false);
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

  void _makeInvoker() {
    if (_functionInvoker == null) {
      _functionInvoker = RemoteFunctionalitiesExecutor.fromStream(
        input: listenToData(eventName: AndroidServiceReservedCommands.clientInvokeRemoteObject),
        output: CustomStreamSink(
          onNewItem: (x) => sendData(eventName: AndroidServiceReservedCommands.serverInvokeRemoteObject, content: x),
          waitDone: onDispose,
        ),
      );
      _functionInvoker!.onDispose.whenComplete(() => _functionInvoker = null);
      joinDisponsabeObject<RemoteFunctionalitiesExecutor>(item: _functionInvoker!);
    }
  }

  @override
  InteractableFunctionalityOperator<Oration, T> executeInteractableFunctionality<T, F extends TextableFunctionality<T>>({InvocationParameters parameters = InvocationParameters.emptry}) {
    checkInitialize();
    _makeInvoker();

    return _functionInvoker!.executeInteractableFunctionality<T, F>(parameters: parameters);
  }

  @override
  InteractableFunctionalityOperator<Oration, T> executeInteractableFunctionalityViaName<T>({required String functionalityName, InvocationParameters parameters = InvocationParameters.emptry}) {
    checkInitialize();
    _makeInvoker();

    return _functionInvoker!.executeInteractableFunctionalityViaName<T>(parameters: parameters, functionalityName: functionalityName);
  }
}
