import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:async/async.dart';
import 'package:lan_communication/encryptions/caesars_cipher.dart';
import 'package:lan_communication/encryptions/cryptography.dart';
import 'package:lan_communication/enums/messsage_type_enum.dart';
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

    // bool isServer = await Setup.isServer();

    commandSendPort.send([name, cryptography]);

    // commandSendPort.send('name: $name');
    // commandSendPort
    //     .send('crypt: ${Cryptography.stringRepresentation(cryptography)}');
    commandSendPort.send(isServer);
    await _parseInputsInBackground();
    while (true) {
      // print(clients);
      clients = await events.next;
      for (int i = 0; i < clients.length; i++) {
        print('${i + 1}) ${clients[i].name} ${clients[i].ipAddress}');
      }
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
          print('hey');
          socket = ClientSocketClass();
        }
        await socket.start(ipAddress, p);
        print('start');
      } else if (message is List) {
        name = message[0];
        cryptography = message[1];
      } else if (message is String && message != 'exit') {
        Map<String, dynamic> i = Message.decode(message);
        i['destinationIpAddress'] =
            clients[int.parse(i['destinationIpAddress']) - 1].ipAddress;
        socket.sendMessage(await Message.encode(
          encryptionType: i['encryptionType'],
          message: i['message'],
          name: i['sourceName'],
          type: i['type'],
          destinationIpAddress: i['destinationIpAddress'],
        )
            // jsonEncode(i));
            );
        print('Sent');
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
    String? key;
    List<dynamic> e = await _commandReceivePort.first;
    final _commandSendPort = e.first;
    cryptography = e[1];
    encryptionType = e[2];
    name = e[3];

    while (true) {
      print('Type exit to quit');
      if (send == null) {
        do {
          print('Enter number to whom to send to');
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
          print('Enter messsage to be sent');

          message = stdin.readLineSync();
        } while (message == null || message.trim().isEmpty);
        if (message == 'exit') {
          break;
        }

        if (cryptography is CaesarsCipher) {
          do {
            print('Enter key');
            key = stdin.readLineSync();
            if (key != null && key == 'exit') {
              break;
            }
          } while (key == null || int.tryParse(key) == null);
          if (key == 'exit') {
            break;
          }
        }
        String j = await Message.encode(
          message: cryptography.encrypt(message: message, key: key!),
          encryptionType: encryptionType,
          type: MessageTypeEnum.data,
          name: name!,
          destinationIpAddress: send,
        );
        _commandSendPort!.send(j);
        send = null;
        message = null;
      }
    }
    _commandSendPort!.send('exit');
    exit(0);
  }
}
