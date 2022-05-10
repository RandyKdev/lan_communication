import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'dart:typed_data';

import 'package:lan_communication/client.dart';
import 'package:lan_communication/encryptions/pgp.dart';
import 'package:lan_communication/encryptions/public_key.dart';
import 'package:lan_communication/enums/connection_enum.dart';
import 'package:lan_communication/enums/message_type_enum.dart';
import 'package:lan_communication/global.dart';
import 'package:lan_communication/message.dart';
import 'package:lan_communication/sockets/parent_socket.dart';
import 'package:lan_communication/setup.dart';

class ClientSocketClass extends ParentSocket {
  late Socket _clientSocket;
  late SendPort _p;

  Future<void> _handleMessage(Uint8List data) async {
    String message = String.fromCharCodes(data);
    Map<String, dynamic> msg = Message.decode(message);
    if (msg['type'] == MessageTypeEnum.handshake) {
      print('Connection established');
      switch (encryptionType) {
        case EncryptionEnum.caesarsCipher:
          String msg1 = await Message.encode(
            type: MessageTypeEnum.handshake,
            encryptionType: encryptionType,
            message: Client.encode(
                [Client(ipAddress: await Setup.getIpAddress(), name: name!)]),
            name: name!,
          );
          sendMessage(msg1);
          break;
        case EncryptionEnum.pgp:
          break;
        case EncryptionEnum.publicKey:
          String msg1 = await Message.encode(
            type: MessageTypeEnum.handshake,
            encryptionType: encryptionType,
            message: Client.encode([
              Client(
                  ipAddress: await Setup.getIpAddress(),
                  publicKey: [
                    (cryptography as PublicKeyCrypt)
                        .halfPublicKey[(cryptography as PublicKeyCrypt).index],
                    (cryptography as PublicKeyCrypt).n
                  ],
                  name: name!)
            ]),
            name: name!,
          );
          sendMessage(msg1);
          break;
      }
      return;
    } else if (msg['type'] == MessageTypeEnum.update) {
      clients = Client.decode(jsonDecode(msg['message']));
      _p.send(clients);
    } else {
      print('\nMessage');
      if (cryptography is PublicKeyCrypt) {
        print('Encrypted Message: ' +
            String.fromCharCodes((msg['message'] as List<dynamic>)
                .map((e) => (e as int) + 36)
                .toList()));
      } else {
        print('Encrypted Message: ' + msg['message']);
      }
      if (cryptography is PGP) {
        (cryptography as PGP).encryptedSessionKey = msg['sessionKey'];
      }
      print('Decrypted Message: ' +
          cryptography.decrypt(message: msg['message']));
      print('From ${msg['sourceName']} ${msg['sourceIp']}\n');
    }
  }

  void _handleError(Object error, StackTrace stackTrace) {
    print('Error: ${error.toString()}\nStacktrace: ${stackTrace.toString()}');
  }

  void _handleCloseSocket(dynamic event) {
    print('Connection closed');
    exit(1);
  }

  @override
  Future<void> start(String ipAddress, SendPort p) async {
    _clientSocket = await Socket.connect(
      serverAddress,
      networkingPort,
      sourceAddress: ipAddress,
      sourcePort: networkingPort,
    );
    _clientSocket.listen(_handleMessage);
    _clientSocket.handleError(_handleError);
    _clientSocket.done.asStream().listen(_handleCloseSocket);
    _p = p;
  }

  @override
  void sendMessage(String message) async {
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
