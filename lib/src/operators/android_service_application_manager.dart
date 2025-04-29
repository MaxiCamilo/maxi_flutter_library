import 'package:maxi_flutter_library/maxi_flutter_library.dart';

class AndroidApplicationManager extends FlutterApplicationManager {
  //final MobileServerChannel channel;

  AndroidApplicationManager({
    /*required this.channel,*/ required super.reflectors,
    required super.defineLanguageOperatorInOtherThread,
    super.androidServiceIsServer = true,
    super.useWorkingPath,
    super.useWorkingPathInDebug,
  });

  @override
  void finishApplication() {
    //channel.close();

    AndroidServiceManager.instance.shutdown();
  }

  @override
  void resetApplication({List<String> arguments = const []}) {
    AndroidServiceManager.instance.reset();
  }
}
