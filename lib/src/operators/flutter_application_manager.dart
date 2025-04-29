import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:maxi_flutter_library/maxi_flutter_library.dart';
import 'package:maxi_flutter_library/src/operators/service/isolated_android_service.dart';
import 'package:maxi_library/maxi_library.dart';
import 'package:path_provider/path_provider.dart';

class FlutterApplicationManager with StartableFunctionality, IThreadInitializer, IApplicationManager, WidgetsBindingObserver {
  final bool useWorkingPath;
  final bool useWorkingPathInDebug;

  //final _appLifecycleStateController = StreamController<AppLifecycleState>.broadcast();

  static final changedApplicationStatus = IsolatedValue<AppLifecycleState>(name: '%MxCaS%', defaultValue: AppLifecycleState.resumed);

  @override
  final List<IReflectorAlbum> reflectors;
  @override
  final bool defineLanguageOperatorInOtherThread;

  @override
  bool get canHandleFiles => !isWeb;

  @override
  bool get isAndroid => !kIsWeb && Platform.isAndroid;

  @override
  bool get isDebug => kDebugMode;

  @override
  bool get isFuchsia => !kIsWeb && Platform.isFuchsia;

  @override
  bool get isIOS => !kIsWeb && Platform.isIOS;

  @override
  bool get isLinux => !kIsWeb && Platform.isLinux;

  @override
  bool get isMacOS => !kIsWeb && Platform.isMacOS;

  @override
  bool get isWeb => kIsWeb;

  @override
  bool get isWindows => !kIsWeb && Platform.isWindows;

  @override
  bool get isFlutter => true;

  //Stream<AppLifecycleState> get appLifeCycleStateStream => _appLifecycleStateController.stream;

  String? _currentDirectory;
  bool _wasBinding = false;

  FlutterApplicationManager({
    this.useWorkingPath = false,
    this.useWorkingPathInDebug = true,
    bool androidServiceIsServer = false,
    required this.reflectors,
    required this.defineLanguageOperatorInOtherThread,
  }) {
    ThreadManager.addThreadInitializer(initializer: IsolatedAndroidService(isServer: androidServiceIsServer));
  }

  @override
  Future<void> initializeFunctionality() async {
    await super.initializeFunctionality();
    await changedApplicationStatus.initialize();
  }

  void initObserver() {
    if (!_wasBinding) {
      WidgetsBinding.instance.addObserver(this);
      changedApplicationStatus.initialize();
      _wasBinding = true;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.detached) {
      if (AndroidServiceManager.isDefinder) {
        AndroidServiceManager.instance.closeConnection();
      }
      _declareClosed();
    } else {
      changedApplicationStatus.changeValue(state);
    }
  }

  void _declareClosed() {
    ThreadManager.killAllThread();
  }

  @override
  Future<String> getCurrentDirectory() async {
    if (_currentDirectory != null) {
      return _currentDirectory!;
    }

    if (isWeb) {
      _currentDirectory = '';
    } else if (isAndroid || isIOS) {
      WidgetsFlutterBinding.ensureInitialized();
      _currentDirectory = (await getApplicationDocumentsDirectory()).path;
    } else if (useWorkingPath || (useWorkingPathInDebug && isDebug)) {
      final newRoute = isDebug ? '${Directory.current.path}/debug' : Directory.current.path;
      await continueOtherFutures();
      final isExists = Directory(newRoute).existsSync();
      if (isDebug && !isExists) {
        await Directory(newRoute).create();
      }

      _currentDirectory = newRoute;
    } else {
      _currentDirectory = DirectoryUtilities.extractFileLocation(fileDirection: Platform.resolvedExecutable, checkPrefix: false);
    }

    return _currentDirectory!;
  }

  @override
  void changeLocalAddress(String address) {
    _currentDirectory = address;
  }

  @override
  IOperatorLanguage get languagesOperator => LanguageOperatorBasic();

  @override
  IFileOperator makeFileOperator({required String address, required bool isLocal}) {
    if (isWeb) {
      return SharedPreferencesOperator(route: address);
    } else {
      return FileOperatorNative(isLocal: isLocal, rawRoute: address);
    }
  }

  @override
  IThreadManagersFactory get serverThreadsFactory {
    if (isWeb) {
      return const FakeThreadFactory();
    } else {
      return const IsolatedThreadFactory();
    }
  }

  @override
  void closeAllThreads() {
    if (ThreadManager.instance is IThreadManagerServer) {
      (ThreadManager.instance as IThreadManagerServer).closeAllThread();
    } else {
      ThreadManager.instance.callFunctionOnTheServer(function: (x) => (ThreadManager.instance as IThreadManagerServer).closeAllThread());
    }
  }

  @override
  void finishApplication() {
    Future.delayed(const Duration(milliseconds: 100)).then((value) async {
      exit(0);
    });
  }

  @override
  void resetApplication({List<String> arguments = const []}) {
    Process.run(Platform.resolvedExecutable, arguments);
    finishApplication();
  }
}
