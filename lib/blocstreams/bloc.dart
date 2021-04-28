import 'dart:async';

class Bloc {
  StreamController codeController = StreamController.broadcast();
  Stream get codeStream => codeController.stream;

  StreamController<bool> joinController = StreamController.broadcast();

  Stream<bool> get joinStream => joinController.stream;

  StreamController newCodeController = StreamController.broadcast();
  Stream get newCodeStream => newCodeController.stream;

  StreamController playerInfoController = StreamController.broadcast();
  Stream get playerInfoStream => playerInfoController.stream;
}
