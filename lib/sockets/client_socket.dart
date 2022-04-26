import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'dart:typed_data';

import 'package:lan_communication/client.dart';
import 'package:lan_communication/encryptions/caesars_cipher.dart';
import 'package:lan_communication/encryptions/pgp.dart';
import 'package:lan_communication/encryptions/public_key.dart';
import 'package:lan_communication/enums/connection_enum.dart';
import 'package:lan_communication/enums/messsage_type_enum.dart';
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
      encryptionType = msg['encryption'] as EncryptionEnum;
      switch (encryptionType) {
        case EncryptionEnum.caesarsCipher:
          cryptography = CaesarsCipher();
          String? input;
          int? key;
          do {
            print('Enter your caesars cipher key');
            input = stdin.readLineSync();
            key = int.tryParse(input!);
          } while (key == null || key == 0);
          (cryptography as CaesarsCipher).key = key;
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
          cryptography = PGP();
          (cryptography as PGP).generateSessionKey();
          break;
        case EncryptionEnum.publicKey:
          cryptography = PublicKey();
          (cryptography as PublicKey).generateKeys();
          String msg1 = await Message.encode(
            type: MessageTypeEnum.handshake,
            encryptionType: encryptionType,
            message: Client.encode([
              Client(
                  ipAddress: await Setup.getIpAddress(),
                  publicKey: (cryptography as PublicKey).publicKey,
                  name: name!)
            ]),
            name: name!,
          );
          sendMessage(msg1);
          break;
      }
      return;
    } else if (msg['type'] == MessageTypeEnum.update) {
      clients = Client.decode(msg['message']);
      _p.send(clients);
    } else {
      print('\nMessage');
      print(cryptography.decrypt(message: msg['messsage']));
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
    _clientSocket.write(jsonEncode(message));
  }

  /// Closes all streams and shuts down the socket servers.
  @override
  Future<void> stop() async {
    await _clientSocket.flush();
    await _clientSocket.close();
    _clientSocket.destroy();
  }
}
