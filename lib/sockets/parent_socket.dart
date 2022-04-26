import 'dart:isolate';

class ParentSocket {
  void sendMessage(String message) {}
  Future<void> stop() async {}
  Future<void> start(String ipAddress, SendPort p) async {}
}
