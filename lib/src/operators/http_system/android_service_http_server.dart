import 'dart:async';

import 'package:maxi_flutter_library/src/operators/service/android_service_reserved_commands.dart';
import 'package:maxi_flutter_library/src/operators/service/isolated_android_service.dart';
import 'package:maxi_flutter_library/src/singletons.dart';
import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library_online/maxi_library_online.dart';

class AndroidServiceHttpServer with StartableFunctionality, PaternalFunctionality, FunctionalityWithLifeCycle, IHttpServer implements StreamSink<Map<String, dynamic>> {
  final List<FunctionalRoute> routes;
  final List<IHttpMiddleware> generalMiddleware;

  static final instantialServerFlag = IsolatedValue<bool>(name: '&MxAs&.http_server_ok', defaultValue: false);

  late MapServerInstance _server;

  @override
  bool get isActive => isInitialized;

  @override
  Future<void> startServer() => initialize();

  @override
  Future<void> closeServer({bool forced = false}) async {
    dispose();
  }

  @override
  Future<void> waitFinish() => onDispose;

  AndroidServiceHttpServer({required this.routes, required this.generalMiddleware});

  factory AndroidServiceHttpServer.fromReflection({
    List<IHttpMiddleware> serverMiddleware = const [],
    List<ITypeEntityReflection>? entityList,
  }) {
    final routes = IHttpServer.getAllRouteByReflection(serverMiddleware: serverMiddleware, entityList: entityList);
    return AndroidServiceHttpServer(
      routes: routes,
      generalMiddleware: serverMiddleware,
    );
  }

  @override
  Future<void> afterInitializingFunctionality() async {
    await instantialServerFlag.initialize();
    if (await instantialServerFlag.asyncValue) {
      throw NegativeResult(
        identifier: NegativeResultCodes.contextInvalidFunctionality,
        message: const Oration(message: 'An http server communicating on the services channel is already initialized'),
      );
    }

    if (AndroidServiceManager.instance is IsolatedAndroidService) {
      await AndroidServiceManager.instance.initialize();
    }

    AndroidServiceManager.instance.checkInitialize(); //<-- If is null, thrown negative result

    if (!AndroidServiceManager.instance.isServer) {
      throw NegativeResult(
        identifier: NegativeResultCodes.contextInvalidFunctionality,
        message: const Oration(message: 'Can only create an HTTP server from the Android service'),
      );
    }

    _server = joinObject(
      item: MapServerInstance(
        routes: routes,
        generalMiddleware: generalMiddleware,
        receiver: AndroidServiceManager.instance.listenToData(eventName: AndroidServiceReservedCommands.clientHttpMessage),
        sender: this,
      ),
    );

    await _server.initialize();
    _server.onDispose.whenComplete(() => dispose());

    joinEvent(event: AndroidServiceManager.instance.nofityCloseClient, onData: _reactWhenThereIsNoClient);

    joinEvent(
      event: AndroidServiceManager.instance.listenToData(eventName: AndroidServiceReservedCommands.clientCheckHttpServerIsActive),
      onData: (x) {
        AndroidServiceManager.instance.sendData(eventName: AndroidServiceReservedCommands.serverResponseHttpIfItsActive, content: {'ok': 'ok'});
      },
    );

    await instantialServerFlag.changeValue(true);
  }

  @override
  void add(Map<String, dynamic> event) {
    if (isInitialized) {
      containErrorAsync(function: () => AndroidServiceManager.instance.sendData(eventName: AndroidServiceReservedCommands.serverHttpMessage, content: event));
    }
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) {
    if (isInitialized) {
      containErrorAsync(
        function: () => AndroidServiceManager.instance.sendError(
          error: NegativeResult.searchNegativity(
            item: error,
            actionDescription: const Oration(message: 'Send error'),
          ),
        ),
      );
    }
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

  @override
  Future close() async {
    dispose();
  }

  @override
  Future get done => onDispose;

  @override
  void afterDiscard() {
    super.afterDiscard();
    instantialServerFlag.changeValue(false);
  }

  @override
  Future<void> closeAllWebSockets() async {
    if (isInitialized) {
      return await _server.closeAllWebSockets();
    }
  }

  void _reactWhenThereIsNoClient(_) {
    if (isInitialized) {
      _server.closeAllWebSockets();
    }
  }
}
