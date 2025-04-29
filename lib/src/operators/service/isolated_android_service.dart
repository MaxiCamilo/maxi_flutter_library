import 'dart:async';

import 'package:maxi_flutter_library/maxi_flutter_library.dart';
import 'package:maxi_library/maxi_library.dart';

class IsolatedAndroidService with StartableFunctionality, FunctionalityWithLifeCycle, IAndroidServiceManager, IThreadInitializer {
  @override
  final bool isServer;

  late StreamController _nofityCloseClientController;
  late StreamController _notifyNewClientController;
  late StreamController<NegativeResult> _notifyError;
  late StreamController<(String, Map<String, dynamic>)> _receiverController;

  @override
  bool hasClient = false;

  IsolatedAndroidService({required this.isServer});

  @override
  Stream<void> get nofityCloseClient async* {
    await initialize();
    yield* _nofityCloseClientController.stream;
  }

  @override
  Stream<void> get notifyNewClient async* {
    await initialize();
    yield* _notifyNewClientController.stream;
  }

  @override
  Stream<(String, Map<String, dynamic>)> get receivedData async* {
    await initialize();
    yield* _receiverController.stream;
  }

  @override
  Stream<NegativeResult> get notifyError async* {
    await initialize();
    yield* _notifyError.stream;
  }

  @override
  Future<void> performInitializationInThread(IThreadManager channel) async {
    AndroidServiceManager.defineInstance(initialize: false, newInstance: this);
  }

  @override
  Future<void> afterInitializingFunctionality() async {
    if (ThreadManager.instance.isServer) {
      throw NegativeResult(
        identifier: NegativeResultCodes.implementationFailure,
        message: const Oration(message: 'The thread where this operator is executed should not be the main thread'),
      );
    }

    await ThreadManager.instance.callFunctionOnTheServer(function: _onInitializedOnMainThread);
    joinFuture(
      ThreadManager.instance.callFunctionOnTheServer(function: _awaitCompletionOperator),
      whenCompleted: () {
        dispose();
      },
    );
    await _updateHasClient();

    _nofityCloseClientController = createEventController(isBroadcast: true);
    _notifyNewClientController = createEventController(isBroadcast: true);
    _receiverController = createEventController<(String, Map<String, dynamic>)>(isBroadcast: true);
    _notifyError = createEventController<NegativeResult>(isBroadcast: true);

    joinSubscription(await ThreadManager.callStreamOnTheServerDirectly(
      parameters: InvocationParameters.emptry,
      function: (_) => ThreadManager.instance.callFunctionOnTheServer(function: _receivedDataOnMainThread),
      onListen: (x) async {
        _receiverController.addIfActive(x);
      },
      onError: (error, [stackTrace]) => _receiverController.addErrorIfActive(error, stackTrace),
    ));

    joinSubscription(await ThreadManager.callStreamOnTheServerDirectly(
      parameters: InvocationParameters.emptry,
      function: (_) => ThreadManager.instance.callFunctionOnTheServer(function: _notifyNewClientOnMainThread),
      onListen: (_) async {
        await _updateHasClient();
        _notifyNewClientController.addIfActive(null);
      },
    ));

    joinSubscription(await ThreadManager.callStreamOnTheServerDirectly(
      parameters: InvocationParameters.emptry,
      function: (_) => ThreadManager.instance.callFunctionOnTheServer(function: _nofityCloseClientOnMainThread),
      onListen: (_) async {
        await _updateHasClient();
        _nofityCloseClientController.addIfActive(null);
      },
    ));

    joinSubscription(await ThreadManager.callStreamOnTheServerDirectly(
      parameters: InvocationParameters.emptry,
      function: (_) => ThreadManager.instance.callFunctionOnTheServer(function: _nofityErrorOnMainThread),
      onListen: (x) {
        _notifyError.addIfActive(x);
      },
    ));
  }

  static Stream<(String, Map<String, dynamic>)> _receivedDataOnMainThread(InvocationContext context) {
    return AndroidServiceManager.instance.receivedData;
  }

  static Stream<void> _notifyNewClientOnMainThread(InvocationContext context) {
    return AndroidServiceManager.instance.notifyNewClient;
  }

  static Stream<void> _nofityCloseClientOnMainThread(InvocationContext context) {
    return AndroidServiceManager.instance.nofityCloseClient;
  }

  static Stream<NegativeResult> _nofityErrorOnMainThread(InvocationContext context) {
    return AndroidServiceManager.instance.notifyError;
  }

  Future<void> _updateHasClient() async {
    hasClient = await ThreadManager.instance.callFunctionOnTheServer(
      function: (_) => AndroidServiceManager.instance.hasClient,
    );
  }

  static Future<void> _awaitCompletionOperator(InvocationContext context) async {
    await AndroidServiceManager.instance.onDispose;
  }
/*
  static Future<void> _checkIfServerIsActive(InvocationContext context) async {
    AndroidServiceManager.instance.checkFirstIfInitialized(() {});
  }*/

  /*--------------------------------------------------------------------------------------------------------- */

  @override
  Stream<Map<String, dynamic>> listenToData({required String eventName}) async* {
    await initialize();

    yield* _receiverController.stream.where((x) => x.$1 == eventName).map((x) => x.$2);
  }

  @override
  Future<void> sendData({required String eventName, Map<String, dynamic>? content}) async {
    await initialize();
    return await ThreadManager.instance.callFunctionOnTheServer(parameters: InvocationParameters.list([eventName, content]), function: _sendDataOnMainThread);
  }

  static Future<void> _sendDataOnMainThread(InvocationContext context) {
    final name = context.firts<String>();
    final content = context.second<Map<String, dynamic>?>();

    return AndroidServiceManager.instance.sendData(eventName: name, content: content);
  }

  @override
  Future<void> reset() async {
    await initialize();

    await ThreadManager.instance.callFunctionOnTheServer(function: _resetOnMainThread);
  }

  static Future<void> _resetOnMainThread(InvocationContext context) {
    return AndroidServiceManager.instance.reset();
  }

  @override
  Future<void> shutdown() async {
    await initialize();
    await ThreadManager.instance.callFunctionOnTheServer(function: _shutdownOnMainThread);
  }

  static Future<void> _shutdownOnMainThread(InvocationContext context) {
    return AndroidServiceManager.instance.shutdown();
  }

  @override
  void closeConnection() async {
    if (!isInitialized) {
      return;
    }
    await ThreadManager.instance.callFunctionOnTheServer(function: _declareClosedOnMainThread);
    dispose();
  }

  static void _declareClosedOnMainThread(InvocationContext context) {
    AndroidServiceManager.instance.closeConnection();
  }

  @override
  Future<void> get onDone => ThreadManager.instance.callFunctionOnTheServer(function: _onDoneMainThread);

  static Future<void> _onDoneMainThread(InvocationContext context) {
    return AndroidServiceManager.instance.onDone;
  }

  @override
  Future<void> sendError({required NegativeResult error}) {
    return ThreadManager.instance.callFunctionOnTheServer(function: _sendErrorOnMainThread, parameters: InvocationParameters.only(error));
  }

  static void _sendErrorOnMainThread(InvocationContext context) {
    AndroidServiceManager.instance.sendError(error: context.firts<NegativeResult>());
  }

  @override
  Future<dynamic> get onDispose async {
    await initialize();
    return await ThreadManager.instance.callFunctionOnTheServer(function: _onDisposeOnMainThread);
  }

  static Future<void> _onDisposeOnMainThread(InvocationContext context) {
    return AndroidServiceManager.instance.onDispose;
  }

  @override
  Future<dynamic> get onInitialized async {
    await initialize();
    return this;
  }

  static Future<void> _onInitializedOnMainThread(InvocationContext context) async {
    await AndroidServiceManager.instance.onInitialized;
  }
}
