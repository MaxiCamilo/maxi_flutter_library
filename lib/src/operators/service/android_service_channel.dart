import 'package:maxi_flutter_library/maxi_flutter_library.dart';
import 'package:maxi_library/maxi_library.dart';

class AndroidServiceChannel with IChannel<(String, Map<String, dynamic>), (String, Map<String, dynamic>)> {
  final IAndroidServiceManager instance;

  const AndroidServiceChannel({required this.instance});

  @override
  bool get isActive => instance.isInitialized;

  @override
  Stream<(String, Map<String, dynamic>)> get receiver => instance.receivedData;

  @override
  Future close() {
    return instance.shutdown();
  }

  @override
  Future get done => instance.onDone;

  @override
  void add((String, Map<String, dynamic>) event) {
    instance.sendData(eventName: event.$1, content: event.$2);
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) {
    instance.sendError(error: NegativeResult.searchNegativity(item: error, actionDescription: const Oration(message: 'Error Channel'), stackTrace: stackTrace));
  }
}
