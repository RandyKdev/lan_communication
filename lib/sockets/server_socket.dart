import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'dart:typed_data';

import 'package:lan_communication/client.dart';
import 'package:lan_communication/encryptions/public_key.dart';
import 'package:lan_communication/enums/message_type_enum.dart';
import 'package:lan_communication/global.dart';
import 'package:lan_communication/message.dart';
import 'package:lan_communication/sockets/parent_socket.dart';

class ServerSocketClass extends ParentSocket {
  List<Socket> get sockets => _sockets;
  final List<Socket> _sockets = [];
  late ServerSocket _serverSocket;
  late SendPort _p;

  Future<void> _handleIncomingMessage(Socket socket, Uint8List event) async {
    String message = String.fromCharCodes(event);
    Map<String, dynamic> msg = Message.decode(message);
    if (msg['type'] == MessageTypeEnum.handshake) {
      clients.add(Client.decode(jsonDecode(msg['message'])).first);
      for (final Socket _socket in _sockets) {
        _sendMessageToSocket(
            _socket,
            await Message.encode(
              message: Client.encode(clients),
              encryptionType: encryptionType,
              type: MessageTypeEnum.update,
              destinationIpAddress: _socket.remoteAddress.address,
              name: 'Server',
            ));
      }
      _p.send(clients);
      return;
    }
    if (msg['destinationIpAddress'] == clients.first.ipAddress) {
      print('\nMessage');
      if (cryptography is PublicKeyCrypt) {
        print('Encrypted Message: ' +
            String.fromCharCodes((msg['message'] as List<dynamic>)
                .map((e) => (e as int) + 31)
                .toList()));
      } else {
        print('Encrypted Message: ' + msg['message']);
      }
      print('Decrypted Message: ' +
          cryptography.decrypt(message: msg['message']));
      print('From ${msg['sourceName']} ${msg['sourceIp']}\n');
      return;
    }
    Socket dest = _sockets.lastWhere(
        (e) => e.remoteAddress.address == msg['destinationIpAddress']);
    _sendMessageToSocket(dest, message);
  }

  Future<void> _handleCloseSocket(Socket socket, dynamic event) async {
    clients.removeWhere(
        (element) => element.ipAddress == socket.remoteAddress.address);
    _sockets.removeWhere(
        (element) => element.remoteAddress == socket.remoteAddress);
    _p.send(clients);
    for (final Socket socket in _sockets) {
      _sendMessageToSocket(
          socket,
          await Message.encode(
            message: Client.encode(clients),
            encryptionType: encryptionType,
            type: MessageTypeEnum.update,
            name: 'Server',
          ));
    }
  }

  void _handleIncomingSocket(Socket socket) async {
    _sockets.add(socket);
    socket.listen((Uint8List event) => _handleIncomingMessage(socket, event));
    socket.done.asStream().listen(
          (dynamic event) => _handleCloseSocket(socket, event),
        );
    String msg = await Message.encode(
      message: '200',
      encryptionType: encryptionType,
      type: MessageTypeEnum.handshake,
      name: 'Server',
    );
    socket.write(msg);
  }

  void _handleError(Object error, StackTrace stackTrace) {
    print('Error: ${error.toString()}\nStacktrace: ${stackTrace.toString()}');
  }

  @override
  Future<void> start(String ipAddress, SendPort p) async {
    _serverSocket = await ServerSocket.bind(
      ipAddress,
      networkingPort,
      shared: true,
    );
    _serverSocket.listen(_handleIncomingSocket);
    _serverSocket.handleError(_handleError);

    clients = [
      Client(
          name: name!,
          ipAddress: ipAddress,
          publicKey: cryptography.runtimeType == PublicKeyCrypt
              ? [
                  (cryptography as PublicKeyCrypt)
                      .halfPublicKey[(cryptography as PublicKeyCrypt).index],
                  (cryptography as PublicKeyCrypt).n
                ]
              : null)
    ];
    _p = p;
    p.send(clients);
    print('Connection made');
  }

  void _sendMessageToSocket(Socket socket, String message) {
    socket.write(message);
  }

  @override
  void sendMessage(String message) {
    for (final Socket socket in _sockets) {
      if (socket.remoteAddress.address ==
          (jsonDecode(message)
              as Map<String, dynamic>)['destinationIpAddress']) {
        _sendMessageToSocket(socket, message);
        break;
      }
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
    final s = [..._sockets];
    for (final Socket socket in s) {
      await _stopSocket(socket);
    }
    await _serverSocket.close();
  }
}
