import 'dart:async';
import 'dart:io';

import 'dart:typed_data';

import 'package:lan_communication/const.dart';
import 'package:lan_communication/parent_socket.dart';

class ClientSocketClass extends ParentSocket {
  late Socket _clientSocket;

  void _handleSocket(Uint8List data) {
    String message = String.fromCharCodes(data);
    if (message == '200') {
      print('Connection made');
    } else {
      print('\n\nMessage\n$message\n');
    }
  }

  void _handleError(Object error, StackTrace stackTrace) {
    print('Error: ${error.toString()}\nStacktrace: ${stackTrace.toString()}');
  }

  void _handleCloseSocket(dynamic event) {
    print('Connection closed');
    exit(0);
  }

  @override
  Future<void> start(String ipAddress) async {
    _clientSocket = await Socket.connect(
      serverAddress,
      networkingPort,
      sourceAddress: ipAddress,
      sourcePort: networkingPort,
    );
    _clientSocket.listen(_handleSocket);
    _clientSocket.handleError(_handleError);
    _clientSocket.done.asStream().listen(_handleCloseSocket);
  }

  @override
  void sendMessage(String message) {
    _clientSocket.write(message);
  }

  /// Closes all streams and shuts down the socket servers.
  @override
  Future<void> stop() async {
    await _clientSocket.flush();
    await _clientSocket.close();
    _clientSocket.destroy();
  }
}
