import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:maxi_library/maxi_library.dart';

class FileOperatorAsset with IAbstractFileOperator, IReadOnlyFileOperator {
  late final String _serializedAddress;

  @override
  bool get isLocal => true;

  @override
  String get directAddress => _serializedAddress;

  @override
  final String route;

  FileOperatorAsset({required this.route}) {
    _serializedAddress = route.replaceAll('${DirectoryUtilities.prefixRouteLocal}/', '').replaceAll(DirectoryUtilities.prefixRouteLocal, '');
  }

  @override
  Future<Uint8List> read({int? maxSize}) async {
    final data = await rootBundle.load(_serializedAddress);
    return data.buffer.asUint8List();
  }

  @override
  Future<Uint8List> readFilePartially({required int from, required int amount, bool checkSize = true}) async {
    if (checkSize) {
      final size = await getFileSize();
      if (size <= from || size <= (from + amount)) {
        amount = size - from;
      }
      if (amount == 0) {
        return Uint8List.fromList([]);
      }
    }

    final data = await rootBundle.load(_serializedAddress);
    return data.buffer.asUint8List(from, amount);
  }

  @override
  Future<String> readTextual({Encoding? encoder, int? maxSize}) {
    return rootBundle.loadString(_serializedAddress);
  }

  @override
  Future<int> getFileSize() async {
    final data = await rootBundle.load(_serializedAddress);
    return data.lengthInBytes;
  }

  @override
  Future<bool> existsFile() async {
    try {
      await rootBundle.load(_serializedAddress);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> existsDirectory() async {
    return false;
  }

  @override
  IFileOperator getContainingFolder() {
    throw NegativeResult(identifier: NegativeResultCodes.implementationFailure, message: const Oration(message: 'The folder of a file cannot be obtained when it is an asset.'));
  }

  @override
  Future<DateTime> getCreationDate() {
    throw NegativeResult(identifier: NegativeResultCodes.implementationFailure, message: const Oration(message: 'The dates of a file cannot be obtained when it is an asset'));
  }

  @override
  Stream<IFileOperator> getFolderContent() {
    throw NegativeResult(identifier: NegativeResultCodes.implementationFailure, message: const Oration(message: 'The folder of a file cannot be obtained when it is an asset'));
  }

  @override
  Future<DateTime> getLastModificationDate() {
    throw NegativeResult(identifier: NegativeResultCodes.implementationFailure, message: const Oration(message: 'The dates of a file cannot be obtained when it is an asset'));
  }
}
