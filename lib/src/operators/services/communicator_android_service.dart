import 'dart:async';

import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:maxi_flutter_library/maxi_flutter_library.dart';
import 'package:maxi_flutter_library/src/operators/internal_prefix_movile_server.dart';
import 'package:maxi_flutter_library/src/operators/services/mobile_service_creator.dart';
import 'package:maxi_library/maxi_library.dart';

mixin CommunicatorAndroidService {
  static bool get isActive => _isActive.isInitialized && _isActive.syncValue;
  static Stream<Map<String, dynamic>> get receiver => _receiver.receiver;
  static StreamSink<Map<String, dynamic>> get sender => _sending;
  static Stream<Oration> get serverStatus => _serverStatus.receiver;
  static Stream<int> get changedNumberClient => _numbrerOfClients.receiver;
  static Stream<void> get withoutClients => _withoutClients.receiver;

  static int get numberOfClients => _numbrerOfClients.syncValue;

  static MobileServiceCreator? _clientChannel;

  static Stream<void> get onConnected => _onConnected.receiver;
  static Stream<void> get onDisconnects => _onDisconnects.receiver;

  static final IsolatedValue<bool> _isActive = IsolatedValue<bool>(name: '&MxAndroid.isActive', defaultValue: false);
  static final IsolatedValue<int> _numbrerOfClients = IsolatedValue<int>(name: '&MxAndroid.numbrerOfClient', defaultValue: 0);

  static final IsolatedEvent<void> _withoutClients = IsolatedEvent<void>(name: '&MxAndroid.withoutClients');

  static final IsolatedEvent<Map<String, dynamic>> _receiver = IsolatedEvent<Map<String, dynamic>>(name: '&MxAndroid.receiver');
  static final IsolatedEvent<Map<String, dynamic>> _sending = IsolatedEvent<Map<String, dynamic>>(name: '&MxAndroid.sending');
  static final IsolatedEvent<Oration> _serverStatus = IsolatedEvent<Oration>(name: '&MxAndroid.status');

  static final IsolatedEvent<void> _onConnected = IsolatedEvent<void>(name: '&MxAndroid.onConnected');
  static final IsolatedEvent<void> _onDisconnects = IsolatedEvent<void>(name: '&MxAndroid.onDisconnects');

  static final IsolatedEvent<void> _requestShutdown = IsolatedEvent<void>(name: '&MxAndroid.requestShutdown');
  static final IsolatedEvent<void> _requestReset = IsolatedEvent<void>(name: '&MxAndroid.requestReset');

  static final _clientSynchronizer = Semaphore();
  static final _eventList = <StreamSubscription>[];

  static final _addClient = IsolatedEvent<void>(name: '&MxAndroid.newClient');
  static final _removedClient = IsolatedEvent<void>(name: '&MxAndroid.closeClient');

  static void notifyNewClient() => _addClient.add(null);
  static void notifyRemovedClient() => _removedClient.add(null);

  static void sendData(Map<String, dynamic> data) {
    if (isActive) {
      _sending.addIfActive(data);
    } else {
      throw NegativeResult(identifier: NegativeResultCodes.contextInvalidFunctionality, message: const Oration(message: 'The communicator is closed'));
    }
  }

  static void sendServerStatus(Oration text) {
    _serverStatus.add(text);
  }

  static void requestShutdown() {
    if (isActive) {
      _requestShutdown.add(null);
      
    }
  }

  static void requestReset() {
    if (isActive) {
      _requestReset.add(null);
    }
  }

  static Future<void> initializeEvents() async {
    await _isActive.initialize();
    await _receiver.initialize();
    await _sending.initialize();
    await _onConnected.initialize();
    await _onDisconnects.initialize();
    await _requestShutdown.initialize();
    await _requestReset.initialize();
    await _numbrerOfClients.initialize();
    await _withoutClients.initialize();

    await _addClient.initialize();
    await _removedClient.initialize();
  }
/*
  static StreamStateTextsVoid startServiceAsStream({
    required dynamic Function(ServiceInstance) onForeground,
    required FutureOr<bool> Function(ServiceInstance) onIosBackground,
    bool autoStart = true,
    bool isForegroundMode = true,
    bool autoStartOnBoot = true,
  }) async* {
    await initializeEvents();

    yield* connectItemStream(
      serverStatus.parallelizingStreamWithFuture(
        function: () => startService(
          onForeground: onForeground,
          onIosBackground: onIosBackground,
          autoStart: autoStart,
          autoStartOnBoot: autoStartOnBoot,
          isForegroundMode: isForegroundMode,
        ),
      ),
    );
  }*/

  static Future<void> startService({
    required dynamic Function(ServiceInstance) onForeground,
    required FutureOr<bool> Function(ServiceInstance) onIosBackground,
    bool autoStart = true,
    bool isForegroundMode = true,
    bool autoStartOnBoot = true,
  }) async {
    await initializeEvents();

    return await _clientSynchronizer.execute(function: () async {
      if (_clientChannel != null && _clientChannel!.isActive) {
        return;
      }

      final channel = MobileServiceCreator(
        onForeground: onForeground,
        onIosBackground: onIosBackground,
        autoStart: autoStart,
        autoStartOnBoot: autoStartOnBoot,
        isForegroundMode: isForegroundMode,
      );

      await channel.initialize();

      _eventList.add(channel.receiver.listen((x) {
        _receiver.addIfActive(x);
      }));

      _eventList.add(_sending.receiver.listen((x) {
        channel.addIfActive(x);
      }));

      channel.done.whenComplete(() => _declareClosed());

      _eventList.add(_requestShutdown.receiver.listen((_) {
        channel.closeService();
      }));

      _eventList.add(_requestReset.receiver.listen((_) {
        channel.resetService();
      }));

      _eventList.add(_addClient.receiver.listen((_) {
        channel.notifyNewClient();
      }));

      _eventList.add(_removedClient.receiver.listen((_) {
        channel.notifyRemovedClient();
      }));

      _clientChannel = channel;

      _isActive.changeValue(true);
      _onConnected.add(null);
    });
  }

  static Future<void> _declareClosed() async {
    if (!isActive) {
      return;
    }

    _isActive.changeValue(false);
    _onDisconnects.add(null);

    _eventList.iterar((x) => x.cancel());
    _eventList.clear();

    _clientChannel?.close();
    _clientChannel = null;
  }

  static Future<AndroidServiceApplicationManager> initializeAsService({
    required ServiceInstance service,
    required List<IReflectorAlbum> reflectors,
    required bool defineLanguageOperatorInOtherThread,
    required StreamStateTextsVoid Function(AndroidServiceApplicationManager, IChannel<Map<String, dynamic>, Map<String, dynamic>>) preparatoryFunction,
    bool useWorkingPath = false,
    bool useWorkingPathInDebug = true,
  }) async {
    await initializeEvents();
    final channel = MobileServerChannel(service: service, manualActivation: true);

    _connectServerEvents(channel);

    _requestShutdown.receiver.listen((_) {
      channel.close();
    });

    _requestReset.receiver.listen((_) {
      service.invoke(InternalPrefixMovileServer.resetMessage);
    });

    service.on(InternalPrefixMovileServer.newClient).listen((_) {
      final value = _numbrerOfClients.syncValue;
      _numbrerOfClients.changeValue(value + 1);
    });

    service.on(InternalPrefixMovileServer.clientClose).listen((_) {
      final value = _numbrerOfClients.syncValue - 1;
      _numbrerOfClients.changeValue(value);

      if (value == 0) {
        _withoutClients.add(null);
      }
    });

    final manager = await ApplicationManager.changeInstance(
      newInstance: AndroidServiceApplicationManager(
        reflectors: reflectors,
        defineLanguageOperatorInOtherThread: defineLanguageOperatorInOtherThread,
        //channel: channel,
      ),
      initialize: true,
    );

    await _isActive.changeValue(true);

    try {
      await waitFunctionalStream(
        stream: preparatoryFunction(manager, channel),
        onData: (x) => channel.sendServerStatus(x),
      );
    } catch (ex) {
      final rn = NegativeResult.searchNegativity(item: ex, actionDescription: const Oration(message: 'Starting the Android service'));
      service.invoke(InternalPrefixMovileServer.serviceWasInitialized, rn.serialize());

      scheduleMicrotask(() {
        ThreadManager.killAllThread();

        channel.close();
        service.stopSelf();
      });
      rethrow;
    }

    _onConnected.add(null);

    channel.declareActive();
    return manager;
  }

  static void _connectServerEvents(MobileServerChannel channel) {
    channel.receiver.listen((x) {
      _receiver.addIfActive(x);
    });
    _sending.receiver.listen((x) {
      channel.addIfActive(x);
    });
/*
    channel.done.then((_) {
      if (_serverIsActive) {
        _isActive.changeValue(false);
        _onDisconnects.add(null);
      }
    });*/
  }
}
