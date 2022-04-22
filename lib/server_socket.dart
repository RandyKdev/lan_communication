import 'dart:async';
import 'dart:io';

import 'dart:typed_data';

import 'package:lan_communication/const.dart';
import 'package:lan_communication/parent_socket.dart';

class ServerSocketClass extends ParentSocket {
  List<Socket> get sockets => _sockets;
  final List<Socket> _sockets = [];
  late ServerSocket _serverSocket;

  void _handleIncomingMessage(Socket socket, Uint8List event) {
    String message = String.fromCharCodes(event);
    print('\n\nMessage\n$message\n');
    // message = message + '\n' + 'From ${socket.remoteAddress.toString()}';
    sendMessage(message);
  }

  void _handleCloseSocket(Socket socket, dynamic event) {
    _sockets.removeWhere(
        (element) => element.remoteAddress == socket.remoteAddress);
  }

  void _handleIncomingSocket(Socket socket) {
    _sockets.add(socket);
    socket.listen((Uint8List event) => _handleIncomingMessage(socket, event));
    socket.done.asStream().listen(
          (dynamic event) => _handleCloseSocket(socket, event),
        );
    socket.write("200");
  }

  void _handleError(Object error, StackTrace stackTrace) {
    print('Error: ${error.toString()}\nStacktrace: ${stackTrace.toString()}');
  }

  @override
  Future<void> start(String ipAddress) async {
    _serverSocket = await ServerSocket.bind(
      ipAddress,
      networkingPort,
      shared: true,
    );
    _serverSocket.listen(_handleIncomingSocket);
    _serverSocket.handleError(_handleError);
    print('Connection made');
  }

  void _sendMessageToSocket(Socket socket, String message) {
    socket.write(message);
  }

  @override
  void sendMessage(String message) {
    for (final Socket socket in _sockets) {
      _sendMessageToSocket(socket, message);
    }
  }

  Future<void> _stopSocket(Socket socket) async {
    await socket.flush();
    await socket.close();
    socket.destroy();
  }

  /// Closes all streams and shuts down the socket servers.
  @override
  Future<void> stop() async {
    for (final Socket socket in _sockets) {
      await _stopSocket(socket);
    }
    await _serverSocket.close();
  }
}
