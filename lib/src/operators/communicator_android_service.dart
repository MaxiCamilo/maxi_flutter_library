import 'dart:async';

import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:maxi_flutter_library/maxi_flutter_library.dart';
import 'package:maxi_flutter_library/src/operators/mobile_server_channel.dart';
import 'package:maxi_flutter_library/src/operators/mobile_service_channel.dart';
import 'package:maxi_library/maxi_library.dart';

mixin CommunicatorAndroidService {
  static bool get isActive => _isActive.isInitialized && _isActive.syncValue;
  static Stream<Map<String, dynamic>> get receiver => _receiver.receiver;

  static MobileServiceChannel? _clientChannel;

  static Stream<void> get onConnected => _onConnected.receiver;
  static Stream<void> get onDisconnects => _onDisconnects.receiver;

  static final IsolatedValue<bool> _isActive = IsolatedValue<bool>(name: '&MxAndroid.isActive', defaultValue: false);

  static final IsolatedEvent<Map<String, dynamic>> _receiver = IsolatedEvent<Map<String, dynamic>>(name: '&MxAndroid.receiver');
  static final IsolatedEvent<Map<String, dynamic>> _sending = IsolatedEvent<Map<String, dynamic>>(name: '&MxAndroid.sending');

  static final IsolatedEvent<void> _onConnected = IsolatedEvent<void>(name: '&MxAndroid.onConnected');
  static final IsolatedEvent<void> _onDisconnects = IsolatedEvent<void>(name: '&MxAndroid.onDisconnects');

  static final IsolatedEvent<void> _requestShutdown = IsolatedEvent<void>(name: '&MxAndroid.requestShutdown');
  static final IsolatedEvent<void> _requestReset = IsolatedEvent<void>(name: '&MxAndroid.requestReset');

  static final _clientSynchronizer = Semaphore();
  static final _eventList = <StreamSubscription>[];

  static void sendData(Map<String, dynamic> data) {
    if (isActive) {
      _sending.addIfActive(data);
    } else {
      throw NegativeResult(identifier: NegativeResultCodes.contextInvalidFunctionality, message: const Oration(message: 'The communicator is closed'));
    }
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
  }

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

      final channel = MobileServiceChannel(
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

      channel.done.then((_) {
        _clientChannel = null;
        _isActive.changeValue(false);
        _onDisconnects.add(null);

        _eventList.iterar((x) => x.cancel());
        _eventList.clear();
      });

      _eventList.add(_requestShutdown.receiver.listen((_) {
        channel.closeService();
      }));

      _eventList.add(_requestReset.receiver.listen((_) {
        channel.resetService();
      }));

      _clientChannel = channel;

      _isActive.changeValue(true);
      _onConnected.add(null);
    });
  }

  static Future<AndroidServiceApplicationManager> initializeAsService({
    required ServiceInstance service,
    required List<IReflectorAlbum> reflectors,
    required bool defineLanguageOperatorInOtherThread,
    required Future<void> Function(AndroidServiceApplicationManager, IChannel<Map<String, dynamic>, Map<String, dynamic>>) preparatoryFunction,
    bool useWorkingPath = false,
    bool useWorkingPathInDebug = true,
  }) async {
    await initializeEvents();
    final channel = MobileServerChannel(service: service, manualActivation: true);

    _connectServerEvents(channel);

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
      await preparatoryFunction(manager, channel);
    } catch (_) {
      channel.close();
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
