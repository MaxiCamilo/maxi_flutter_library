import 'dart:async';
import 'dart:developer';

import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:maxi_flutter_library/maxi_flutter_library.dart';
import 'package:maxi_flutter_library/src/operators/http_system/android_service_http_connector.dart';
import 'package:maxi_flutter_library/src/operators/http_system/android_service_http_server.dart';
import 'package:maxi_flutter_library/src/operators/service/android_service_channel.dart';
import 'package:maxi_flutter_library/src/operators/service/android_service_connector.dart';
import 'package:maxi_flutter_library/src/operators/service/android_service_engine.dart';
import 'package:maxi_flutter_library/src/operators/service/isolated_android_service.dart';
import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library_online/maxi_library_online.dart';

mixin AndroidServiceManager {
  static IAndroidServiceManager? _instance;
  static bool get isDefinder => _instance != null;
  static Semaphore? _synchronizer;
  static Completer<IAndroidServiceManager>? _defineInstanceWaiter;

  static IAndroidServiceManager get instance {
    if (_instance == null) {
      throw NegativeResult(
        identifier: NegativeResultCodes.implementationFailure,
        message: const Oration(message: 'A background service manager has not been defined'),
      );
    }

    return _instance!;
  }

  static Future<IAndroidServiceManager> createConnector({
    required dynamic Function(ServiceInstance) onForeground,
    required FutureOr<bool> Function(ServiceInstance) onIosBackground,
    required String serverName,
    required Oration initialNotificationContent,
    required Oration initialNotificationTitle,
    bool autoStart = false,
    bool isForegroundMode = true,
    bool autoStartOnBoot = false,
  }) async {
    if (_instance != null && _instance is IsolatedAndroidService) {
      await _instance!.initialize();
      return _instance!;
    }

    return AndroidServiceConnector.createConnector(
      onForeground: onForeground,
      onIosBackground: onIosBackground,
      serverName: serverName,
      autoStart: autoStart,
      autoStartOnBoot: autoStartOnBoot,
      isForegroundMode: isForegroundMode,
      initialNotificationContent: initialNotificationContent,
      initialNotificationTitle: initialNotificationTitle,
    );
  }

  static Future<void> initializeAsService({
    required String serverName,
    required ServiceInstance service,
    required List<IReflectorAlbum> reflectors,
    required bool defineLanguageOperatorInOtherThread,
    required FutureOr<dynamic> Function() preparatoryFunction,
    bool useWorkingPath = false,
    bool useWorkingPathInDebug = true,
  }) async {/*
    final androidApp = AndroidApplicationManager(
      defineLanguageOperatorInOtherThread: defineLanguageOperatorInOtherThread,
      reflectors: reflectors,
      androidServiceIsServer: true,
      useWorkingPath: useWorkingPath,
      useWorkingPathInDebug: useWorkingPathInDebug,
    );

    if (!ApplicationManager.isDefined) {
      await ApplicationManager.changeInstance(newInstance: androidApp, initialize: true);
    }*/

    try {
      final instance = AndroidServiceEngine(
        serverName: serverName,
        reflectors: reflectors,
        service: service,
        defineLanguageOperatorInOtherThread: defineLanguageOperatorInOtherThread,
        preparatoryFunction: preparatoryFunction,
        useWorkingPath: useWorkingPath,
        useWorkingPathInDebug: useWorkingPathInDebug,
      );
      await defineInstance(newInstance: instance, initialize: true);
    } catch (ex, st) {
      log('[X] Server failed: $ex\nOn: $st');
      //service.stopSelf();
    }
  }

  static Future<IHttpServer> createHttpServer({
    required List<FunctionalRoute> routes,
    List<IHttpMiddleware> generalMiddleware = const [],
  }) async {
    final server = AndroidServiceHttpServer(routes: routes, generalMiddleware: generalMiddleware);
    await server.initialize();
    return server;
  }

  static Future<IHttpServer> createHttpServerWithReflection({
    List<IHttpMiddleware> serverMiddleware = const [],
    List<ITypeEntityReflection>? entityList,
  }) async {
    final server = AndroidServiceHttpServer.fromReflection(entityList: entityList, serverMiddleware: serverMiddleware);
    await server.initialize();
    return server;
  }

  static Future<IHttpRequester> createHttpRequester() async {
    final connector = AndroidServiceHttpConnector();
    await connector.initialize();
    return connector;
  }

  static Future<IAndroidServiceManager> get onInstanceDefined async {
    if (_instance == null) {
      _defineInstanceWaiter ??= MaxiCompleter<IAndroidServiceManager>();
      await _defineInstanceWaiter!.future;
    }
    if (!_instance!.isInitialized) {
      await _instance!.onInitialized;
    }
    return _instance!;
  }

  static Future<void> defineInstance({required IAndroidServiceManager newInstance, required bool initialize}) async {
    if (_instance != null && _instance!.isInitialized) {
      if (_instance == newInstance) {
        if (initialize) {
          await _instance!.initialize();
        }
        return;
      } else {
        throw NegativeResult(
          identifier: NegativeResultCodes.implementationFailure,
          message: const Oration(message: 'A background service has already been defined and is active'),
        );
      }
    }

    if (initialize) {
      _synchronizer ??= Semaphore();
      await _synchronizer!.execute(function: () async {
        if (_instance != null) {
          return;
        }

        await newInstance.initialize();
        _instance = newInstance;
        newInstance.onDispose.whenComplete(() => _instance = null);
      });
    } else {
      _instance = newInstance;
    }

    _defineInstanceWaiter?.completeIfIncomplete(_instance);
    _defineInstanceWaiter = null;
    //_instance = null;
  }

  static IChannel<(String, Map<String, dynamic>), (String, Map<String, dynamic>)> createChannel() => AndroidServiceChannel(instance: instance);
}
