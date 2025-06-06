import 'package:maxi_library/maxi_library.dart';
import 'get_local_url/pc_get_local_url.dart' if (dart.library.html) 'get_local_url/web_get_local_url.dart' as impl;

class GetLocalUrl with IFunctionality<String> {
  final bool localHostIsInsecure;
  final int localHostPort;

  const GetLocalUrl({required this.localHostIsInsecure, required this.localHostPort});

  @override
  String runFunctionality() => impl.GetLocalUrlImpl(localHostIsInsecure: localHostIsInsecure, localHostPort: localHostPort).runFunctionality();
}
