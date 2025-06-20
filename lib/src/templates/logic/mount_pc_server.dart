import 'dart:async';
import 'dart:io';

import 'package:maxi_library/maxi_library.dart';

class MountPcServer with TextableFunctionalityVoid {
  final String folderAddress;
  final String exeName;

  final String? customExeAddress;

  const MountPcServer({
    required this.exeName,
    this.folderAddress = '${DirectoryUtilities.prefixRouteLocal}/server',
    this.customExeAddress,
  });

  String _getServerAddress() {
    if (ApplicationManager.instance.isLinux) {
      return '$folderAddress/${exeName}_linux';
    }

    if (ApplicationManager.instance.isWindows) {
      return '$folderAddress/${exeName}_windows.exe';
    }

    if (ApplicationManager.instance.isMacOS) {
      return '$folderAddress/${exeName}_macos';
    }

    throw NegativeResult(
      identifier: NegativeResultCodes.implementationFailure,
      message: const Oration(message: 'The operating system cannot execute binary files'),
    );
  }

  @override
  Future<void> runFunctionality({required InteractiveFunctionalityExecutor<Oration, void> manager}) async {
    await manager.sendItemAsync(const Oration(message: 'Setting up local server'));

    final String address = customExeAddress ?? _getServerAddress();

    final operatorAddress = FileOperatorMask(isLocal: false, rawRoute: address);
    final folderOperator = operatorAddress.getContainingFolder();

    await folderOperator.createAsFolder(secured: customExeAddress != null);
    final folderAddress = folderOperator.directAddress;

    if (!await operatorAddress.existsFile()) {
      final fileName = DirectoryUtilities.extractFileName(route: operatorAddress.rawRoute, includeExtension: true);
      throw NegativeResult(
        identifier: NegativeResultCodes.externalFault,
        message: Oration(message: 'The server executable cannot be found in the "server" folder, the executable "%1" was being searched', textParts: [fileName]),
      );
    }

    await manager.sendItemAsync(Oration(
      message: 'Running server from %1, waiting for an answer',
      textParts: [operatorAddress.rawRoute],
    ));

    final exeProcess = await Process.start(operatorAddress.rawRoute, [], workingDirectory: folderAddress);
    final waiting = MaxiCompleter();

    final exitFuture = exeProcess.exitCode;
    exitFuture.then(
      (value) {
        if (value == 0) {
          waiting.completeIfIncomplete();
        } else {
          waiting.completeErrorIfIncomplete(
            NegativeResult(
                identifier: NegativeResultCodes.externalFault,
                message: Oration(
                  message: 'The executable located at %1 was executed, but it returned error code %2',
                  textParts: [operatorAddress.rawRoute, exeProcess.exitCode],
                )),
          );
        }
      },
    ).onError((x, y) {
      waiting.completeErrorIfIncomplete(x!, y);
    }).timeout(
      const Duration(seconds: 1),
      onTimeout: () {
        exitFuture.ignore();
        waiting.completeIfIncomplete();
      },
    );

    await waiting.future;
  }
}
