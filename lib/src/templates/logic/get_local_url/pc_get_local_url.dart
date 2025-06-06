import 'package:maxi_library/maxi_library.dart';

class GetLocalUrlImpl with IFunctionality<String> {
  final bool localHostIsInsecure;
  final int localHostPort;
  const GetLocalUrlImpl({required this.localHostIsInsecure, required this.localHostPort});

  @override
  String runFunctionality()  {
    return '${localHostIsInsecure ? 'http' : 'https'}://localhost:$localHostPort';
  }
}
