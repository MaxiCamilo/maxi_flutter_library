import 'dart:convert';
import 'dart:developer';

import 'dart:typed_data';

import 'package:maxi_library/maxi_library.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesOperator with IFileOperator {
  @override
  bool get isLocal => true;

  @override
  final String route;

  final _prefs = SharedPreferencesAsync();

  SharedPreferencesOperator({required String route}) : route = route.replaceAll('\\', '/').replaceAll('${DirectoryUtilities.prefixRouteLocal}/', '').replaceAll(DirectoryUtilities.prefixRouteLocal, '');

  Future<String?> _getKey() {
    return volatile(detail: tr('An error occurred while reading key %1 in local storage'), function: () => _prefs.getString(route));
  }

  @override
  Future<String> copy({required String destinationFolder, required bool destinationIsLocal}) async {
    destinationFolder = destinationFolder.replaceAll('\\', '/').replaceAll('${DirectoryUtilities.prefixRouteLocal}/', '').replaceAll(DirectoryUtilities.prefixRouteLocal, '');
    final content = await readTextual();
    await _prefs.setString(destinationFolder, content);

    return destinationFolder;
  }

  @override
  Future<void> createAsFile({required bool secured}) async {
    if (!await _prefs.containsKey(route)) {
      await _prefs.setString(route, '');
    }
  }

  @override
  Future<void> createAsFolder({required bool secured}) async {}

  @override
  Future<void> deleteDirectory() async {}

  @override
  Future<void> deleteFile() async {
    await _prefs.remove(route);
  }

  @override
  Future<bool> existsDirectory() async {
    return true;
  }

  @override
  Future<bool> existsFile() async {
    return await _prefs.containsKey(route);
  }

  @override
  Future<int> getFileSize() async {
    final value = await _getKey();
    return value?.length ?? -1;
  }

  @override
  Future<Uint8List> read({int? maxSize}) async {
    final value = await _getKey();
    if (value == null) {
      throw NegativeResult(
        identifier: NegativeResultCodes.nonExistent,
        message: tr('The file located at %1 cannot be read because it does not exist', [route]),
      );
    }

    return volatile(detail: tr('File %1 does not have a valid base64 format'), function: () => base64.decode(value));
  }

  @override
  Future<Uint8List> readFilePartially({required int from, required int amount, bool checkSize = true}) async {
    final result = await read();

    if (result.isEmpty || result.length >= amount) {
      return Uint8List.fromList([]);
    }
    log('MAYVE FAIL');
    return result.sublist(from, from + amount);
  }

  @override
  Future<String> readTextual({Encoding? encoder, int? maxSize}) async {
    final value = await _getKey();
    if (value == null) {
      throw NegativeResult(
        identifier: NegativeResultCodes.nonExistent,
        message: tr('The file located at %1 cannot be read because it does not exist', [route]),
      );
    }
    return value;
  }

  @override
  Future<void> write({required Uint8List content, bool secured = false}) async {
    await _prefs.setString(route, base64.encode(content));
  }

  @override
  Future<void> writeText({required String content, Encoding? encoder, bool secured = false}) async {
    await _prefs.setString(route, content);
  }

  @override
  IFileOperator getContainingFolder() {
    final routeSplit = route.split('/');
    if (routeSplit.length < 2) {
      throw NegativeResult(
        identifier: NegativeResultCodes.contextInvalidFunctionality,
        message: tr('Cannot download more from the folder'),
      );
    }

    routeSplit.removeLast();
    return SharedPreferencesOperator(route: routeSplit.join('/'));
  }
}
