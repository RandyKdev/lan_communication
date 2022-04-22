import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:async/async.dart';

import 'package:lan_communication/parent_socket.dart';
import 'package:lan_communication/server_socket.dart';
import 'package:lan_communication/setup.dart';
import 'package:lan_communication/client_socket.dart';

// late ReceivePort inputReceivePort;
late ReceivePort commandReceivePort;
// late SendPort inputSendPort;
late SendPort commandSendPort;

Future<void> _parseInputInBackground() async {
  final inputReceivePort = ReceivePort();
  await Isolate.spawn(_startInputSocket, inputReceivePort.sendPort);

  final events = StreamQueue<dynamic>(inputReceivePort);
  final inputSendPort = await events.next;

  inputSendPort.send(commandSendPort);
}

void _startInputSocket(SendPort p) async {
  final _commandReceivePort = ReceivePort();
  p.send(_commandReceivePort.sendPort);
  String ipAddress = await Setup.getIpAddress();

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
      input = '$input\nFrom $ipAddress';
      print(input);
      _commandSendPort.send(input);
    }
  }
  _commandSendPort.send('stop');
  Isolate.exit();
}

Future<void> _parseCommandInBackground(bool isServer) async {
  commandReceivePort = ReceivePort();
  // print(commands.hashCode);
  await Isolate.spawn(_startCommandSocket, commandReceivePort.sendPort);
  // print(commands);
  final events = StreamQueue<dynamic>(commandReceivePort);
  commandSendPort = await events.next;
  print(commandSendPort);
  await _parseInputInBackground();
  commandSendPort.send(isServer);
  // sendPort.send(commands);
  // String m = await events.next;
  // if (m == 'stop') {
  // events.cancel();
  // }
  print('hey');
  await events.next;
  exit(0);
  // commands.stream.listen((event) async {
  //   print('stream');
  //   sendPort.send(event);
  //   if (event == 'stop') {
  //     await events.cancel();
  //   }
  // });
}

void _startCommandSocket(SendPort p) async {
  final _commandReceivePort = ReceivePort();
  p.send(_commandReceivePort.sendPort);

  late ParentSocket socket;
  String ipAddress = await Setup.getIpAddress();

  await for (final message in _commandReceivePort) {
    if (message is bool) {
      print(message);
      if (message == true) {
        socket = ServerSocketClass();
      } else {
        socket = ClientSocketClass();
      }
      await socket.start(ipAddress);
    } else if (message is String && message != 'stop') {
      print(message + 'Message');
      await socket.stop();
    } else {
      print('hstopping');
      break;
    }
  }
  // p.send('stop');
  Isolate.exit(p, 'stop');
}

void main(List<String> arguments) async {
  await Setup.start();

  bool isServer = await Setup.isServer();
  await _parseCommandInBackground(isServer);
  // await _parseInputInBackground();
  // exit(0);
}
