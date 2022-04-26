import 'dart:io';
import 'dart:isolate';

import 'package:async/async.dart';
import 'package:lan_communication/encryptions/caesars_cipher.dart';
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
    await _parseInputsInBackground();

    // bool isServer = await Setup.isServer();
    commandSendPort.send(isServer);

    await events.next;
    exit(0);
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
        await socket.start(ipAddress);
      } else if (message is String && message != 'exit') {
        socket.sendMessage(message);
      } else {
        print('Exiting...');
        await socket.stop();
        break;
      }
    }
    Isolate.exit(p, 'exit');
  }

  static Future<void> _parseInputsInBackground() async {
    final inputReceivePort = ReceivePort();
    await Isolate.spawn(_inputIsolate, inputReceivePort.sendPort);

    final events = StreamQueue<dynamic>(inputReceivePort);
    final inputSendPort = await events.next;

    inputSendPort.send(commandSendPort);
  }

  static void _inputIsolate(SendPort p) async {
    final _commandReceivePort = ReceivePort();
    p.send(_commandReceivePort.sendPort);

    String? send;
    String? message;
    String? key;

    final _commandSendPort = await _commandReceivePort.first;

    while (true) {
      print('Type exit to quit');
      if (send == null) {
        for (int i = 0; i < clients.length; i++) {
          print('${i + 1}) ${clients[i].name} ${clients[i].ipAddress}');
        }
        do {
          print('Enter number to whom to send to');
          send = stdin.readLineSync();
          if (send != null && send == 'exit') {
            break;
          }
        } while (send == null ||
            int.tryParse(send) == null ||
            !(int.parse(send) <= clients.length && int.parse(send) >= 1));
        if (send == 'exit') {
          break;
        }
      } else {
        do {
          print(
              'Enter messsage to be sent to ${clients[int.parse(send)].name} ${clients[int.parse(send)].ipAddress}');

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
        );
        _commandSendPort.send(j);
        send = null;
        message = null;
      }
    }
    _commandSendPort.send('exit');
    Isolate.exit();
  }
}
