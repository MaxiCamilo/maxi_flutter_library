import 'dart:async';

import 'package:maxi_library/maxi_library.dart';

mixin IAndroidServiceManager on StartableFunctionality, IRemoteFunctionalitiesExecutor {
  Stream<(String, Map<String, dynamic>)> get receivedData;
  Stream<void> get notifyNewClient;
  Stream<void> get nofityCloseClient;
  Stream<NegativeResult> get notifyError;

  bool get isServer;
  bool get hasClient;

  
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

    final result = await sendAndWaitForAnswerAsOptional(eventSent: eventSent, eventReceived: eventReceived, content: content, timeout: timeout);
    if (result == null) {
      throw NegativeResult(
        identifier: NegativeResultCodes.timeout,
        message: const Oration(message: 'The server took too long to respond to a request, it\'s probably down or very busy'),
      );
    } else {
      return result;
    }
  }

  Future<Map<String, dynamic>?> sendAndWaitForAnswerAsOptional({
    required String eventSent,
    required String eventReceived,
    Map<String, dynamic>? content,
    Duration timeout = const Duration(seconds: 7),
  }) async {
    checkInitialize();
    var waiter = MaxiCompleter<Map<String, dynamic>?>();

    final subscription = listenToData(eventName: eventReceived).listen((x) {
      waiter.completeIfIncomplete((x));
    });

    for (int i = 0; i <= timeout.inSeconds * 4; i++) {
      try {
        waiter = MaxiCompleter<Map<String, dynamic>?>();
        sendData(eventName: eventSent, content: content);
        final result = await waiter.future.timeout(const Duration(milliseconds: 250), onTimeout: () => null);
        if (result != null) {
          subscription.cancel();
          return result;
        }
      } finally {
        waiter.completeIfIncomplete();
      }
    }

    subscription.cancel();

    return null;
  }
}
