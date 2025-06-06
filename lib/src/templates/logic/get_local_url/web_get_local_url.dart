import 'package:maxi_library/maxi_library.dart';
import 'package:web/web.dart' as web;

class GetLocalUrlImpl with IFunctionality<String> {
  final bool localHostIsInsecure;
   final int localHostPort;
  const GetLocalUrlImpl({required this.localHostIsInsecure, required this.localHostPort});

  @override
  String runFunctionality() {   

    final host = web.window.location.host.split(':').first;
    return '${web.window.location.protocol}//$host:$localHostPort';
  }
}
