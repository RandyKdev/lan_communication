import 'dart:io';
import 'dart:isolate';

import 'package:async/async.dart';
import 'package:lan_communication/sockets/client_socket.dart';
import 'package:lan_communication/global.dart';
import 'package:lan_communication/sockets/parent_socket.dart';
import 'package:lan_communication/sockets/server_socket.dart';
import 'package:lan_communication/setup.dart';

class Background {
  static Future<void> startIsolates() async {
    commandReceivePort = ReceivePort();
    await Isolate.spawn(_commandIsolate, commandReceivePort.sendPort);

    final events = StreamQueue<dynamic>(commandReceivePort);
    commandSendPort = await events.next;
    await _parseInputsInBackground();

    bool isServer = await Setup.isServer();
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

    String? input;

    final _commandSendPort = await _commandReceivePort.first;

    while (true) {
      print('Type exit to quit');
      input = stdin.readLineSync();
      if (input == null || input.trim().isEmpty) {
        continue;
      } else if (input == 'exit') {
        break;
      } else {
        // input = '$input\nFrom $ipAddress';
        _commandSendPort.send(input);
      }
    }
    _commandSendPort.send('exit');
    Isolate.exit();
  }
}
