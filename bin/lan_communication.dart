import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:async/async.dart';

import 'package:lan_communication/parent_socket.dart';
import 'package:lan_communication/server_socket.dart';
import 'package:lan_communication/setup.dart';
import 'package:lan_communication/client_socket.dart';

Future<void> _parseInBackground(bool isServer, Stream<String> commands) async {
  final p = ReceivePort();
  await Isolate.spawn(_startSocket, p.sendPort);
  final events = StreamQueue<dynamic>(p);
  SendPort sendPort = await events.next;
  sendPort.send(isServer);
  commands.listen((event) async {
    sendPort.send(event);
    if (event == 'stop') {
      await events.cancel();
    }
  });
}

void _startSocket(SendPort p) async {
  final rPort2 = ReceivePort();
  p.send(rPort2.sendPort);

  late ParentSocket socket;
  String ipAddress = await Setup.getIpAddress();

  await for (final message in rPort2) {
    if (message is bool) {
      if (message == true) {
        socket = ServerSocketClass();
      } else {
        socket = ClientSocketClass();
      }
      await socket.start(ipAddress);
    } else if (message != 'stop') {
      socket.sendMessage(message);
    } else {
      break;
    }
    Isolate.exit();
  }
}

void main(List<String> arguments) async {
  await Setup.start();

  bool isServer = await Setup.isServer();
  final commandsStreamController = StreamController<String>();
  String ipAddress = await Setup.getIpAddress();
  await _parseInBackground(isServer, commandsStreamController.stream);

  String? input;

  while (true) {
    print('Type exit to quit');
    input = stdin.readLineSync();
    if (input == null || input.trim().isEmpty) continue;
    if (input == 'exit') {
      break;
    }
    input = '$input\nFrom $ipAddress';
    commandsStreamController.sink.add(input);
  }

  commandsStreamController.sink.add('stop');
  // await socket.stop();
  exit(0);
}
