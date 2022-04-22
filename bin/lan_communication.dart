import 'dart:io';
import 'dart:isolate';

import 'package:lan_communication/parent_socket.dart';
import 'package:lan_communication/server_socket.dart';
import 'package:lan_communication/setup.dart';
import 'package:lan_communication/client_socket.dart';

Future<void> _parseInBackground(bool isServer) async {
  final p = ReceivePort();
  if (isServer) {
    await Isolate.spawn(_startServer, p.sendPort);
  } else {
    await Isolate.spawn(_startClient, p.sendPort);
  }
}

void _startClient(SendPort p) async {
  late ParentSocket socket;
  String ipAddress = await Setup.getIpAddress();
  socket = ClientSocketClass();
  await socket.start(ipAddress);
}

void _startServer(SendPort p) async {
  late ParentSocket socket;
  String ipAddress = await Setup.getIpAddress();
  socket = ServerSocketClass();
  await socket.start(ipAddress);
}

void main(List<String> arguments) async {
  await Setup.start();

  late ParentSocket socket;
  String ipAddress = await Setup.getIpAddress();

  bool isServer = await Setup.isServer();
  if (isServer) {
    socket = ServerSocketClass();
  } else {
    socket = ClientSocketClass();
  }

  await socket.start(ipAddress);

  await _parseInBackground(isServer);

  String? input;

  while (true) {
    print('Type exit to quit');
    input = stdin.readLineSync();
    if (input == null || input.trim().isEmpty) continue;
    if (input == 'exit') {
      break;
    }
    input = '$input\nFrom $ipAddress';
    socket.sendMessage(input);
  }

  await socket.stop();
  exit(0);
}
