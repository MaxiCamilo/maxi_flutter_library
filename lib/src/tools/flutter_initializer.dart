import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:maxi_library/maxi_library.dart';
import 'package:path_provider/path_provider.dart';

class FlutterInitializer with StartableFunctionality, IThreadInitializer {
  static bool get isWeb => kIsWeb;

  late final String appRoute;

  @override
  Future<void> initializeFunctionality() async {
    appRoute = await _changeAppRoute();

    ThreadManager.addThreadInitializer(initializer: this);
  }

  static Future<String> _changeAppRoute() async {
    if (!isWeb && (Platform.isAndroid || Platform.isIOS)) {
      WidgetsFlutterBinding.ensureInitialized();
      final route = (await getApplicationDocumentsDirectory()).path;
      return DirectoryUtilities.changeFixedRoute(route);
    } else if (Platform.environment['PUB_ENVIRONMENT'] == 'vscode.dart-code') {
      return DirectoryUtilities.useDebugPath();
    } else {
      return DirectoryUtilities.currentPath;
    }
  }

  @override
  Future<void> performInitializationInThread(IThreadManager channel) async {
    DirectoryUtilities.changeFixedRoute(appRoute);
  }
}
