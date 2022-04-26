import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:async/async.dart';
import 'package:lan_communication/background.dart';

import 'package:lan_communication/setup.dart';

void main(List<String> arguments) async {
  await Setup.start();

  String? name;
  do {
    print('Enter your name');
    name = stdin.readLineSync();
  } while (name == null && name!.trim().isEmpty);

  await Background.startIsolates();
}
