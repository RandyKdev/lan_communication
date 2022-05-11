import 'dart:isolate';

import 'package:lan_communication/encryptions/cryptography.dart';
import 'package:lan_communication/enums/connection_enum.dart';
import 'package:lan_communication/client.dart';

int networkingPort = 2001;
String serverAddress = '192.168.43.191';

late ReceivePort commandReceivePort;
late SendPort commandSendPort;

late String? name;
late EncryptionEnum encryptionType;
late Cryptography cryptography;
List<Client> clients = [];
