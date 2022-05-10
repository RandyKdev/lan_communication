import 'dart:io';
import 'dart:isolate';

import 'package:async/async.dart';
import 'package:lan_communication/encryptions/caesars_cipher.dart';
import 'package:lan_communication/encryptions/pgp.dart';
import 'package:lan_communication/encryptions/public_key.dart';
import 'package:lan_communication/enums/message_type_enum.dart';
import 'package:lan_communication/message.dart';
import 'package:lan_communication/sockets/client_socket.dart';
import 'package:lan_communication/global.dart';
import 'package:lan_communication/sockets/parent_socket.dart';
import 'package:lan_communication/sockets/server_socket.dart';
import 'package:lan_communication/setup.dart';

class Background {
  static Future<void> startIsolates() async {
    bool isServer = await Setup.isServer();
    commandReceivePort = ReceivePort();
    await Isolate.spawn(_commandIsolate, commandReceivePort.sendPort);

    final events = StreamQueue<dynamic>(commandReceivePort);
    commandSendPort = await events.next;

    commandSendPort.send([name, cryptography, encryptionType]);

    commandSendPort.send(isServer);
    await _parseInputsInBackground();
    while (true) {
      clients = await events.next;
      print("\nList of connected peers");
      for (int i = 0; i < clients.length; i++) {
        if (clients[i].ipAddress == await Setup.getIpAddress()) {
          continue;
        }
        print(
            'Id: ${i + 1}, Name: ${clients[i].name}, Ip address: ${clients[i].ipAddress}, Public key: ${clients[i].publicKey?[0] ?? ''}');
      }
      print('\n');
    }
  }

  static void _commandIsolate(SendPort p) async {
    final _commandReceivePort = ReceivePort();
    p.send(_commandReceivePort.sendPort);

    late ParentSocket socket;
    String ipAddress = await Setup.getIpAddress();

    await for (final message in _commandReceivePort) {
      if (message is bool) {
        if (message == true) {
          socket = ServerSocketClass();
        } else {
          socket = ClientSocketClass();
        }
        await socket.start(ipAddress, p);
      } else if (message is List) {
        name = message[0];
        cryptography = message[1];
        encryptionType = message[2];
      } else if (message is String && message != 'exit') {
        Map<String, dynamic> i = Message.decode(message);
        i['destinationIpAddress'] =
            clients[int.parse(i['destinationIpAddress']) - 1].ipAddress;

        if (cryptography is CaesarsCipher) {
          socket.sendMessage(await Message.encode(
            encryptionType: i['encryptionType'],
            message: i['message'],
            name: i['sourceName'],
            type: i['type'],
            destinationIpAddress: i['destinationIpAddress'],
          )
              // jsonEncode(i));
              );
        } else if (cryptography is PublicKeyCrypt) {
          socket.sendMessage(await Message.encode(
            encryptionType: i['encryptionType'],
            message: cryptography.encrypt(
              message: i['message'],
              key: clients
                      .lastWhere((element) =>
                          element.ipAddress == i['destinationIpAddress'])
                      .publicKey ??
                  [],
            ),
            name: i['sourceName'],
            type: i['type'],
            destinationIpAddress: i['destinationIpAddress'],
          )
              // jsonEncode(i));
              );
        } else {
          socket.sendMessage(await Message.encode(
            encryptionType: i['encryptionType'],
            message: cryptography.encrypt(
              message: i['message'],
              key: [...clients
                      .lastWhere((element) =>
                          element.ipAddress == i['destinationIpAddress'])
                      .publicKey as List<dynamic>, i['sessionKey']],
            ),
            name: i['sourceName'],
            type: i['type'],
            destinationIpAddress: i['destinationIpAddress'],
            sessionKey: (cryptography as PGP).encryptedSessionKey,
          )
              // jsonEncode(i));
              );
        }
      } else {
        print('Exiting...');
        await socket.stop();
        break;
      }
    }
    Isolate.exit(p, 'exit');
  }

  static Future<void> _parseInputsInBackground() async {
    // _inputIsolate();
    final inputReceivePort = ReceivePort();
    await Isolate.spawn(_inputIsolate, inputReceivePort.sendPort);

    final events = StreamQueue<dynamic>(inputReceivePort);
    final inputSendPort = await events.next;

    inputSendPort.send([commandSendPort, cryptography, encryptionType, name]);
    // inputSendPort.send(cryptography);
  }

  static void _inputIsolate(SendPort p) async {
    final _commandReceivePort = ReceivePort();
    p.send(_commandReceivePort.sendPort);

    String? send;
    String? message;
    dynamic key;
    String? j;
    List<dynamic> e = await _commandReceivePort.first;
    final _commandSendPort = e.first;
    cryptography = e[1];
    encryptionType = e[2];
    name = e[3];

    while (true) {
      print('\nType exit to quit\n');
      if (send == null) {
        do {
          print('\nEnter number to whom to send to');
          send = stdin.readLineSync();
          if (send != null && send == 'exit') {
            break;
          }
        } while (send == null || int.tryParse(send) == null);
        if (send == 'exit') {
          break;
        }
      } else {
        do {
          print('\nEnter message to be sent');

          message = stdin.readLineSync();
        } while (message == null || message.trim().isEmpty);
        if (message == 'exit') {
          break;
        }

        if (cryptography is CaesarsCipher) {
          do {
            print('\nEnter key');
            key = stdin.readLineSync();
            if (key != null && key == 'exit') {
              break;
            }
          } while (key == null || int.tryParse(key) == null);
          if (key == 'exit') {
            break;
          }
          j = await Message.encode(
            message: cryptography.encrypt(message: message, key: key!),
            encryptionType: encryptionType,
            type: MessageTypeEnum.data,
            name: name!,
            destinationIpAddress: send,
          );
        } else if (cryptography is PublicKeyCrypt) {
          j = await Message.encode(
            message: message,
            encryptionType: encryptionType,
            type: MessageTypeEnum.data,
            name: name!,
            destinationIpAddress: send,
            
          );
        } else {
          do {
            print('\nEnter key');
            key = stdin.readLineSync();
            if (key != null && key == 'exit') {
              break;
            }
          } while (key == null || int.tryParse(key) == null);
          if (key == 'exit') {
            break;
          }
          j = await Message.encode(
            message: message,
            encryptionType: encryptionType,
            type: MessageTypeEnum.data,
            name: name!,
            destinationIpAddress: send,
            sessionKey: key!,
          );
        }

        _commandSendPort!.send(j);
        send = null;
        message = null;
      }
    }
    _commandSendPort!.send('exit');
    exit(0);
  }
}
