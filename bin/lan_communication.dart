import 'dart:io';

import 'package:lan_communication/background.dart';
import 'package:lan_communication/global.dart';

import 'package:lan_communication/setup.dart';

void main(List<String> arguments) async {
  await Setup.start();

  do {
    print('Enter your name');
    name = stdin.readLineSync();
  } while (name == null && name!.trim().isEmpty);
  // Setup.isServer();

  await Background.startIsolates();
}
