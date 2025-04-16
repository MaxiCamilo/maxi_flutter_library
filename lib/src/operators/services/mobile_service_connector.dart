import 'dart:convert';

import 'package:maxi_flutter_library/maxi_flutter_library.dart';
import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library_online/maxi_library_online.dart';

class MobileServiceConnector with IHttpRequester, StartableFunctionality, FunctionalityWithLifeCycle {
  late MapServerConnector _connector;

  MobileServiceConnector();

  @override
  bool get isActive => CommunicatorAndroidService.isActive;

  @override
  Future<void> afterInitializingFunctionality() async {
    _connector = MapServerConnector(
      receiver: CommunicatorAndroidService.receiver,
      sender: CommunicatorAndroidService.sender,
      receiverServerStatus: CommunicatorAndroidService.serverStatus,
    );

    await _connector.initialize();

    _connector.done.whenComplete(() => dispose());
    joinEvent(
        event: CommunicatorAndroidService.onDisconnects,
        onData: (_) {
          dispose();
        });

    CommunicatorAndroidService.notifyNewClient();
  }

  @override
  void performObjectDiscard() {
    super.performObjectDiscard();

    CommunicatorAndroidService.notifyRemovedClient();
    _connector.close();
  }

  @override
  Future<ResponseHttpRequest<T>> executeRequest<T>({
    required HttpMethodType type,
    required String url,
    bool badStatusCodeIsNegativeResult = true,
    Duration? timeout,
    Object? content,
    Map<String, String>? headers,
    Encoding? encoding,
    int? maxSize,
  }) async {
    await initialize();

    return _connector.executeRequest<T>(
      type: type,
      url: url,
      badStatusCodeIsNegativeResult: badStatusCodeIsNegativeResult,
      content: content,
      encoding: encoding,
      headers: headers,
      maxSize: maxSize,
      timeout: timeout,
    );
  }

  @override
  Future<IChannel> executeWebSocket({required String url, bool disableIfNoOneListens = true, Map<String, String>? headers, Encoding? encoding, Duration? timeout}) async {
    await initialize();

    return _connector.executeWebSocket(
      url: url,
      encoding: encoding,
      headers: headers,
      timeout: timeout,
      disableIfNoOneListens: disableIfNoOneListens,
    );
  }

  @override
  void close() {
    dispose();
  }
}
