import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:maxi_flutter_library/maxi_flutter_library.dart';
import 'package:maxi_flutter_library/src/operators/service/android_service_reserved_commands.dart';
import 'package:maxi_flutter_library/src/operators/service/isolated_android_service.dart';
import 'package:maxi_library/export_reflectors.dart';

class AndroidServiceConnector with StartableFunctionality, PaternalFunctionality, FunctionalityWithLifeCycle, RemoteFunctionalitiesExecutor, IAndroidServiceManager {
  final bool autoStart;
  final bool isForegroundMode;
  final bool autoStartOnBoot;
  final dynamic Function(ServiceInstance) onForeground;
  final FutureOr<bool> Function(ServiceInstance) onIosBackground;
  final String serverName;

  final Oration initialNotificationContent;
  final Oration initialNotificationTitle;

  late FlutterBackgroundService _backgroundService;
  late Semaphore _syncronizerShipment;
  late StreamController<NegativeResult> _errorStreamController;

  StreamController<(String, Map<String, dynamic>)>? _receivedData;

  Completer? _awaitingShipmentConfirmation;
  RemoteFunctionalitiesExecutor? _functionInvoker;

  @override
  bool get hasClient => isInitialized;

  @override
  Stream<NegativeResult> get notifyError => _errorStreamController.stream;
  @override
  Stream<(String, Map<String, dynamic>)> get receivedData => checkFirstIfInitialized(() => _receivedData!.stream);

  @override
  bool get isServer => false;

  @override
  Stream<void> get nofityCloseClient async* {
    await IsolatedAndroidService.sharedHasClient.initialize();
    yield* IsolatedAndroidService.sharedHasClient.receiver.where((x) => !x);
  }

  @override
  Stream<void> get notifyNewClient async* {
    await IsolatedAndroidService.sharedHasClient.initialize();
    yield* IsolatedAndroidService.sharedHasClient.receiver.where((x) => x);
  }

  AndroidServiceConnector._({
    required this.autoStart,
    required this.isForegroundMode,
    required this.autoStartOnBoot,
    required this.onForeground,
    required this.onIosBackground,
    required this.serverName,
    required this.initialNotificationContent,
    required this.initialNotificationTitle,
  });

  static Future<AndroidServiceConnector> createConnector({
    required dynamic Function(ServiceInstance) onForeground,
    required FutureOr<bool> Function(ServiceInstance) onIosBackground,
    required String serverName,
    required Oration initialNotificationContent,
    required Oration initialNotificationTitle,
    bool autoStart = false,
    bool isForegroundMode = true,
    bool autoStartOnBoot = false,
  }) async {
    //Only executable on the Flutter thread
    if (!ThreadManager.instance.isServer) {
      throw NegativeResult(
        identifier: NegativeResultCodes.implementationFailure,
        message: const Oration(message: 'Only executable on the Flutter thread'),
      );
    }

    final newInstance = AndroidServiceConnector._(
      autoStart: autoStart,
      autoStartOnBoot: autoStartOnBoot,
      isForegroundMode: isForegroundMode,
      onForeground: onForeground,
      onIosBackground: onIosBackground,
      serverName: serverName,
      initialNotificationContent: initialNotificationContent,
      initialNotificationTitle: initialNotificationTitle,
    );

    //Check if it's already defined
    if (AndroidServiceManager.isDefinder) {
      final actualOperator = AndroidServiceManager.instance;
      if (actualOperator is AndroidServiceConnector) {
        if (actualOperator == newInstance) {
          await actualOperator.initialize();
          return actualOperator;
        } else {
          throw NegativeResult(
            identifier: NegativeResultCodes.implementationFailure,
            message: const Oration(message: 'A background server is already defined, but with differing parameters'),
          );
        }
      } else {
        throw NegativeResult(
          identifier: NegativeResultCodes.implementationFailure,
          message: const Oration(message: 'A background server has already been defined, but of a different type (probably server)'),
        );
      }
    }

    await AndroidServiceManager.defineInstance(newInstance: newInstance, initialize: true);
    return newInstance;
  }

  @override
  bool operator ==(Object other) {
    if (other is AndroidServiceConnector) {
      return other.autoStart == autoStart &&
          other.isForegroundMode == isForegroundMode &&
          other.autoStartOnBoot == autoStartOnBoot &&
          other.onForeground == onForeground &&
          other.onIosBackground == onIosBackground &&
          other.serverName == serverName;
    } else {
      return false;
    }
  }

  @override
  int get hashCode => Object.hashAll([
        autoStart,
        isForegroundMode,
        autoStartOnBoot,
        onForeground,
        onIosBackground,
        serverName,
      ]);

  @override
  Future<void> afterInitializingFunctionality() async {
    WidgetsFlutterBinding.ensureInitialized();

    await IsolatedAndroidService.initializeEvents();
    await IsolatedAndroidService.sharedIsServer.changeValue(false);

    _syncronizerShipment = Semaphore();
    _backgroundService = FlutterBackgroundService();

    _receivedData = createEventController<(String, Map<String, dynamic>)>(isBroadcast: true);

    await _backgroundService.configure(
      iosConfiguration: IosConfiguration(autoStart: autoStart, onForeground: onForeground, onBackground: onIosBackground),
      androidConfiguration: AndroidConfiguration(
        autoStart: autoStart,
        onStart: onForeground,
        isForegroundMode: isForegroundMode,
        autoStartOnBoot: autoStartOnBoot,
        initialNotificationContent: initialNotificationContent.toString(),
        initialNotificationTitle: initialNotificationTitle.toString(),
      ),
    );

    if (!await _backgroundService.startService()) {
      //initializedEvent.cancel();
      throw NegativeResult(
        identifier: NegativeResultCodes.externalFault,
        message: const Oration(message: 'The service could not be mounted'),
      );
    }
/*
    if (await _checkServerName(timeout: const Duration(seconds: 1))) {
      _connectEvents();
      return;
      final waiter = MaxiCompleter<void>();

    //Events
    final events = <StreamSubscription>[];
    }*/

    /*
    joinEvent(
      event: _backgroundService.on(AndroidServiceReservedCommands.serverSendsInitializationStatus),
      onSubscriptionCreated: (x) => events.add(x),
      onData: (x) {
        x ??= {};
        final text = Oration.interpret(map: x);
        waiterController.addIfActive(streamTextStatus(text));
      },
    );
   

    joinEvent(
      event: _backgroundService.on(AndroidServiceReservedCommands.serverSendsItsName),
      onSubscriptionCreated: (x) => events.add(x),
      onData: (x) {
        waiter.completeIfIncomplete();
      },
    );
     */

    if (!await _checkServerName(timeout: const Duration(seconds: 7))) {
      throw NegativeResult(
        identifier: NegativeResultCodes.externalFault,
        message: const Oration(message: 'The service reports that it started, but did not return its name'),
      );
    }

    _connectEvents();
  }

  void _connectEvents() {
    joinEvent(
      event: _backgroundService.on(AndroidServiceReservedCommands.serverFinishesItsExecution),
      onData: _reactServerClosed,
    );

    joinEvent(
      event: _backgroundService.on(AndroidServiceReservedCommands.serverReceivedMessage),
      onData: _reactConfirmReceived,
    );

    joinEvent(
      event: _backgroundService.on(AndroidServiceReservedCommands.serverSendMessage),
      onData: _reactReceivedMessage,
    );

    joinEvent(
      event: _backgroundService.on(AndroidServiceReservedCommands.serverRequiredReset),
      onData: (_) => reset(),
    );

    joinEvent(
      event: FlutterApplicationManager.changedApplicationStatus.receiver,
      onData: (x) => _backgroundService.invoke(AndroidServiceReservedCommands.clientSendAppStatus, {'content': x.index}),
    );

    _backgroundService.invoke(AndroidServiceReservedCommands.notifyNewClient);

    if (FlutterApplicationManager.changedApplicationStatus.isInitialized) {
      maxiScheduleMicrotask(() async {
        _backgroundService.invoke(AndroidServiceReservedCommands.clientSendAppStatus, {'content': (await FlutterApplicationManager.changedApplicationStatus.asyncValue).index});
      });
    }

    _errorStreamController = createEventController<NegativeResult>(isBroadcast: true);
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

  Future<String?> _getServerName({Duration? timeout}) async {
    final waiter = MaxiCompleter<String?>();
    final subscription = joinEvent(
      event: _backgroundService.on(AndroidServiceReservedCommands.serverSendsItsName),
      onData: (x) {
        waiter.completeIfIncomplete(volatile(detail: const Oration(message: 'The server did not return its name'), function: () => x!['name'].toString()));
      },
    );

    final initError = joinEvent(
      event: _backgroundService.on(AndroidServiceReservedCommands.serverInitializationError),
      onData: (x) {
        try {
          final error = NegativeResult.interpret(values: x ?? {}, checkTypeFlag: true);
          waiter.completeErrorIfIncomplete(error);
        } catch (ex, st) {
          waiter.completeErrorIfIncomplete(ex, st);
        }
      },
    );

    Timer? timer;

    if (timeout != null) {
      timer = Timer(timeout, () {
        timer?.cancel();
        subscription.cancel();
        initError.cancel();
        waiter.completeIfIncomplete();
      });
    }

    try {
      _backgroundService.invoke(AndroidServiceReservedCommands.clientRequiresServerName);
      return await waiter.future;
    } finally {
      timer?.cancel();
      subscription.cancel();
      initError.cancel();
    }
  }

  Future<bool> _checkServerName({required Duration timeout}) async {
    for (int i = 0; i < timeout.inSeconds * 4; i++) {
      final serverName = await _getServerName(timeout: const Duration(milliseconds: 250));
      if (serverName != null) {
        if (serverName != this.serverName) {
          throw NegativeResult(
            identifier: NegativeResultCodes.externalFault,
            message: Oration(
              message: 'The server is named %1, but a server called %2 was expected',
              textParts: [this.serverName, serverName],
            ),
          );
        }
        return true;
      }
    }

    return false;
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
  Future<void> sendData({required String eventName, Map<String, dynamic>? content}) {
    checkFirstIfInitialized(() {});
    return _syncronizerShipment.execute(function: () async {
      _awaitingShipmentConfirmation = joinWaiter();
      _backgroundService.invoke(
        AndroidServiceReservedCommands.clientSendMessage,
        {'name': eventName, 'content': content ?? {}},
      );
      await _awaitingShipmentConfirmation!.future.timeout(
        const Duration(seconds: 7),
        onTimeout: () {
          throw NegativeResult(identifier: NegativeResultCodes.timeout, message: const Oration(message: 'The server took too long to confirm receipt of the sent package'));
        },
      );
    });
  }

  @override
  Future<void> reset() async {
    await shutdown();
    await Future.delayed(const Duration(seconds: 1));
    await initialize();
  }

  @override
  Future<void> shutdown() async {
    if (!isInitialized) {
      return;
    }

    _backgroundService.invoke(AndroidServiceReservedCommands.clientRequestsServiceTermination);
    await onDispose;
  }

  @override
  void dispose() {
    super.dispose();
    _receivedData?.close();
    _receivedData = null;
  }

  void _reactServerClosed(Map<String, dynamic>? p1) {
    dispose();
  }

  void _reactConfirmReceived(Map<String, dynamic>? p1) {
    _awaitingShipmentConfirmation?.completeIfIncomplete();
    _awaitingShipmentConfirmation = null;
  }

  void _reactReceivedMessage(Map<String, dynamic>? rawContext) {
    _backgroundService.invoke(AndroidServiceReservedCommands.clientReceivedMessage);

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
  void closeConnection() {
    if (isInitialized) {
      _backgroundService.invoke(AndroidServiceReservedCommands.notifyCloseClient);
      maxiScheduleMicrotask(() async {
        await continueOtherFutures();
        dispose();
      });
    }
  }

  @override
  void performObjectDiscard() {
    super.performObjectDiscard();

    IsolatedAndroidService.sharedHasClient.changeValue(false);
    IsolatedAndroidService.sharedNotifyCloseConnection.add(null);
    IsolatedAndroidService.sharedNotifyOnDone.add(null);
  }

  @override
  Future<void> get onDone => onDispose;

  @override
  Future<void> sendError({required NegativeResult error}) {
    return sendData(eventName: AndroidServiceReservedCommands.clientSendError, content: error.serialize());
  }

  void _makeInvoker() {
    if (_functionInvoker == null) {
      _functionInvoker = RemoteFunctionalitiesExecutor.fromStream(
        input: listenToData(eventName: AndroidServiceReservedCommands.serverInvokeRemoteObject),
        output: CustomStreamSink(
          onNewItem: (x) => sendData(eventName: AndroidServiceReservedCommands.clientInvokeRemoteObject, content: x),
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
