import 'dart:io';

import 'package:lan_communication/parent_socket.dart';
import 'package:lan_communication/server_socket.dart';
import 'package:lan_communication/setup.dart';
import 'package:lan_communication/client_socket.dart';

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
}
