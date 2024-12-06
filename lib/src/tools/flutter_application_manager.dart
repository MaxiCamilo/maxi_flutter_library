import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:maxi_flutter_library/maxi_flutter_library.dart';
import 'package:maxi_library/maxi_library.dart';
import 'package:path_provider/path_provider.dart';

class FlutterApplicationManager with StartableFunctionality, IThreadInitializer, IApplicationManager, WidgetsBindingObserver {
  final bool useWorkingPath;
  final bool useWorkingPathInDebug;

  final _appLifecycleStateController = StreamController<AppLifecycleState>.broadcast();

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

  Stream<AppLifecycleState> get appLifeCycleStateStream => _appLifecycleStateController.stream;

  String? _currentDirectory;
  bool _wasBinding = false;

  FlutterApplicationManager({
    this.useWorkingPath = false,
    this.useWorkingPathInDebug = true,
    required this.reflectors,
    required this.defineLanguageOperatorInOtherThread,
  });

  void initObserver() {
    if (!_wasBinding) {
      WidgetsBinding.instance.addObserver(this);
      _wasBinding = true;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _appLifecycleStateController.add(state);

    if (state == AppLifecycleState.detached) {
      _declareClosed();
    }
  }

  void _declareClosed() async {
    killAllThread();
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
      _currentDirectory = isDebug ? '${Directory.current.path}/debug' : Directory.current.path;
      if (isDebug && !await Directory(_currentDirectory!).exists()) {
        await Directory(_currentDirectory!).create();
      }
    } else {
      _currentDirectory = DirectoryUtilities.extractFileLocation(fileDirection: Platform.resolvedExecutable, checkPrefix: false);
    }

    return _currentDirectory!;
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

  void killAllThread() {
    if (ThreadManager.instance is IThreadManagerServer) {
      (ThreadManager.instance as IThreadManagerServer).killAllThread();
    } else {
      ThreadManager.instance.callFunctionOnTheServer(function: (x) => (ThreadManager.instance as IThreadManagerServer).killAllThread());
    }
  }
}
