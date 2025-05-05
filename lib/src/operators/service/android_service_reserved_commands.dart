mixin AndroidServiceReservedCommands {
  static const String initialPrefix = '&MxAs&';

  //static const String correctInitializedConfirmedServer = '$initialPrefix.1';
  static const String serverInitializationError = '$initialPrefix.2';
  //static const String serverSendsInitializationStatus = '$initialPrefix.3';
  static const String serverSendsItsName = '$initialPrefix.4';

  static const String clientRequiresServerName = '$initialPrefix.5';
  static const String clientRequestsServiceTermination = '$initialPrefix.6';
  static const String clientSendMessage = '$initialPrefix.7';
  static const String clientReceivedMessage = '$initialPrefix.8';
  static const String clientSendAppStatus = '$initialPrefix.9';

  static const String serverFinishesItsExecution = '$initialPrefix.10';
  static const String serverReceivedMessage = '$initialPrefix.11';
  static const String serverSendMessage = '$initialPrefix.12';
  static const String serverRequiredReset = '$initialPrefix.13';

  static const String notifyNewClient = '$initialPrefix.14';
  static const String notifyCloseClient = '$initialPrefix.15';

  static const String clientSendError = '$initialPrefix.15';
  static const String serverSendError = '$initialPrefix.16';

  static const String serverHttpMessage = '$initialPrefix.17';
  static const String clientHttpMessage = '$initialPrefix.18';
  static const String clientCheckHttpServerIsActive = '$initialPrefix.19';
  static const String serverResponseHttpIfItsActive = '$initialPrefix.20';

  static const String serverInvokeRemoteObject = '$initialPrefix.21';
  static const String clientInvokeRemoteObject = '$initialPrefix.22';
}
