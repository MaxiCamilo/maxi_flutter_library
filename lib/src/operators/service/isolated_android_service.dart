import 'dart:async';

import 'package:maxi_flutter_library/maxi_flutter_library.dart';
import 'package:maxi_flutter_library/src/operators/service/isolated_android_service_invokator.dart';
import 'package:maxi_library/maxi_library.dart';

class IsolatedAndroidService with StartableFunctionality, RemoteFunctionalitiesExecutor, IAndroidServiceManager, IThreadInitializer {
  static const _sharedNameID = '&#MxIAS&';

  static final sharedReceivedData = IsolatedEvent<(String, Map<String, dynamic>)>(name: '$_sharedNameID.1');
  static final sharedHasClient = IsolatedValue<bool>(name: '$_sharedNameID.2', defaultValue: false);
  static final sharedIsServer = IsolatedValue<bool>(name: '$_sharedNameID.3', defaultValue: false);

  //static final sharedNotifyNewClient = IsolatedEvent<dynamic>(name: '$_sharedNameID.4');
  //static final sharedNotifyCloseClient = IsolatedEvent<dynamic>(name: '$_sharedNameID.5');
  static final sharedNotifyCloseConnection = IsolatedEvent<dynamic>(name: '$_sharedNameID.6');
  static final sharedNotifyOnDone = IsolatedEvent<dynamic>(name: '$_sharedNameID.7');
  static final sharedNotifyError = IsolatedEvent<NegativeResult>(name: '$_sharedNameID.8');

  @override
  Future<void> performInitializationInThread(IThreadManager channel) async {
    AndroidServiceManager.defineInstance(initialize: false, newInstance: this);
  }

  static Future<void> initializeEvents() async {
    await sharedReceivedData.initialize();
    await sharedHasClient.initialize();
    await sharedIsServer.initialize();
    //await sharedNotifyNewClient.initialize();
    //await sharedNotifyCloseClient.initialize();
    await sharedNotifyCloseConnection.initialize();
    await sharedNotifyOnDone.initialize();
    await sharedNotifyError.initialize();
  }

  @override
  Future<void> initializeFunctionality() async {
    await initializeEvents();
  }

  @override
  Future get onInitialized => initialize();

  @override
  bool get hasClient => sharedHasClient.syncValue;

  @override
  bool get isServer => sharedIsServer.syncValue;

  @override
  Stream<(String, Map<String, dynamic>)> get receivedData async* {
    await initialize();
    yield* sharedReceivedData.receiver;
  }

  @override
  Stream<Map<String, dynamic>> listenToData({required String eventName}) async* {
    await initialize();
    yield* sharedReceivedData.receiver.where((x) => x.$1 == eventName).map((x) => x.$2);
  }

  @override
  Stream<void> get nofityCloseClient async* {
    await initialize();
    yield* sharedHasClient.receiver.where((x) => !x);
  }

  @override
  Stream<NegativeResult> get notifyError async* {
    await initialize();
    yield* sharedNotifyError.receiver;
  }

  @override
  Stream<void> get notifyNewClient async* {
    await initialize();
    yield* sharedHasClient.receiver.where((x) => !x);
  }

  @override
  Future<void> get onDone async {
    await initialize();
    await nofityCloseClient.waitSomething();
  }

  @override
  void closeConnection() {
    ThreadManager.instance.callFunctionOnTheServer(function: _closeConnectionOnMainThread);
  }

  static FutureOr<void> _closeConnectionOnMainThread(InvocationContext _) {
    if (AndroidServiceManager.isDefinder) {
      AndroidServiceManager.instance.closeConnection();
    }
  }

  @override
  Future<void> sendData({required String eventName, Map<String, dynamic>? content}) {
    return ThreadManager.instance.callFunctionOnTheServer(function: _sendDataOnMainThread, parameters: InvocationParameters.list([eventName, content ?? {}]));
  }

  static Future<void> _sendDataOnMainThread(InvocationContext context) {
    return AndroidServiceManager.instance.sendData(eventName: context.firts<String>(), content: context.second<Map<String, dynamic>>());
  }

  @override
  Future<void> reset() {
    return ThreadManager.instance.callFunctionOnTheServer(function: _resetOnMainThread);
  }

  static Future<void> _resetOnMainThread(InvocationContext p1) {
    return AndroidServiceManager.instance.reset();
  }

  @override
  Future<void> sendError({required NegativeResult error}) {
    return ThreadManager.instance.callFunctionOnTheServer(function: _sendErrorOnMainThread);
  }

  static Future<void> _sendErrorOnMainThread(InvocationContext context) {
    return AndroidServiceManager.instance.reset();
  }

  @override
  Future<void> shutdown() {
    return ThreadManager.instance.callFunctionOnTheServer(function: _shutdownOnMainThread);
  }

  static FutureOr<void> _shutdownOnMainThread(InvocationContext context) {
    return AndroidServiceManager.instance.shutdown();
  }

  @override
  InteractableFunctionalityOperator<Oration, T> executeInteractableFunctionality<T, F extends TextableFunctionality<T>>({InvocationParameters parameters = InvocationParameters.emptry}) {
    return IsolatedAndroidServiceInvokator<T, F>(parameters: parameters).runInThreadServer();
  }
}
