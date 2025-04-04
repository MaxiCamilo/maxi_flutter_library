import 'package:maxi_flutter_library/maxi_flutter_library.dart';

class AndroidServiceApplicationManager extends FlutterApplicationManager {
  //final MobileServerChannel channel;

  AndroidServiceApplicationManager({/*required this.channel,*/ required super.reflectors, required super.defineLanguageOperatorInOtherThread});

  @override
  void finishApplication() {
    //channel.close();

    CommunicatorAndroidService.requestShutdown();
  }

  @override
  void resetApplication({List<String> arguments = const []}) {
    CommunicatorAndroidService.requestReset();
  }
}
