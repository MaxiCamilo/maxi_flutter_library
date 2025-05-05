import 'dart:async';

import 'package:maxi_library/maxi_library.dart';

mixin IAndroidServiceManager on StartableFunctionality, IRemoteFunctionalitiesExecutor {
  Stream<(String, Map<String, dynamic>)> get receivedData;
  Stream<void> get notifyNewClient;
  Stream<void> get nofityCloseClient;
  Stream<NegativeResult> get notifyError;

  bool get isServer;
  bool get hasClient;

  @override
  bool get isActive => isInitialized;

  Future<void> get onDone;

  Stream<Map<String, dynamic>> listenToData({required String eventName});
  Future<void> sendData({required String eventName, Map<String, dynamic>? content});
  Future<void> shutdown();
  Future<void> reset();
  Future<void> sendError({required NegativeResult error});

  void closeConnection();

  Future<Map<String, dynamic>> sendAndWaitResponse({
    required String eventSent,
    required String eventReceived,
    Map<String, dynamic>? content,
    Duration timeout = const Duration(seconds: 7),
  }) async {
    checkInitialize();

    await sendData(eventName: eventSent, content: content);

    return await listenToData(eventName: eventReceived).waitItem(
        timeout: timeout,
        onTimeout: () {
          throw NegativeResult(
            identifier: NegativeResultCodes.timeout,
            message: const Oration(message: 'The server took too long to respond to a request, it\'s probably down or very busy'),
          );
        });
  }
}
