import 'dart:async';
import 'dart:convert';

import 'package:maxi_flutter_library/maxi_flutter_library.dart';
import 'package:maxi_flutter_library/src/operators/service/android_service_reserved_commands.dart';
import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library_online/maxi_library_online.dart';

class AndroidServiceHttpConnector with StartableFunctionality, PaternalFunctionality, FunctionalityWithLifeCycle, IHttpRequester implements StreamSink<Map<String, dynamic>> {
  @override
  bool get isActive => isInitialized;

  late MapServerConnector _connector;

  @override
  Future<void> afterInitializingFunctionality() async {
    await AndroidServiceManager.instance.onInitialized;
    await AndroidServiceManager.instance.initialize();

    await AndroidServiceManager.instance.sendAndWaitResponse(
      eventSent: AndroidServiceReservedCommands.clientCheckHttpServerIsActive,
      eventReceived: AndroidServiceReservedCommands.serverResponseHttpIfItsActive,
      timeout: const Duration(seconds: 7),
    );

    _connector = joinObject(
      item: MapServerConnector(
        receiver: AndroidServiceManager.instance.listenToData(eventName: AndroidServiceReservedCommands.serverHttpMessage),
        sender: this,
      ),
    );

    await _connector.initialize();
    _connector.onDispose.whenComplete(() => dispose());
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
    return await _connector.executeRequest<T>(
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
  Future<IChannel> executeWebSocket({
    required String url,
    bool disableIfNoOneListens = true,
    Map<String, String> queryParameters = const {},
    Map<String, String>? headers,
    Encoding? encoding,
    Duration? timeout,
  }) async {
    await initialize();
    return await _connector.executeWebSocket(
      url: url,
      disableIfNoOneListens: disableIfNoOneListens,
      encoding: encoding,
      headers: headers,
      queryParameters: queryParameters,
      timeout: timeout,
    );
  }

  @override
  Future close() async {
    dispose();
  }

  @override
  void add(Map<String, dynamic> event) {
    containErrorAsync(function: () => AndroidServiceManager.instance.sendData(eventName: AndroidServiceReservedCommands.clientHttpMessage, content: event));
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) {
    containErrorAsync(
      function: () => AndroidServiceManager.instance.sendError(
        error: NegativeResult.searchNegativity(
          item: error,
          actionDescription: const Oration(message: 'Send error'),
        ),
      ),
    );
  }

  @override
  Future addStream(Stream<Map<String, dynamic>> stream) async {
    final waiter = MaxiCompleter<void>();

    late final StreamSubscription<Map<String, dynamic>> subscription;
    subscription = stream.listen(
      (x) => add(x),
      onError: (x, y) => addError(x, y),
      onDone: () => waiter.complete(),
    );

    final future = done.whenComplete(() => subscription.cancel());

    await waiter.future;
    future.ignore();
  }
}
