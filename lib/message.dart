import 'dart:convert';

import 'package:lan_communication/enums/connection_enum.dart';
import 'package:lan_communication/enums/messsage_type_enum.dart';
import 'package:lan_communication/setup.dart';

class Message {
  static Future<String> encode({
    required dynamic message,
    required EncryptionEnum encryptionType,
    required MessageTypeEnum type,
    required String name,
    String? destinationIpAddress,
    String? publicKey,
    String? sessionKey,
  }) async {
    final msg = <String, String?>{
      'type': getMessageString(type),
      'publicKey': publicKey,
      'sessionKey': sessionKey,
      'encryptionType': getEncryptionString(encryptionType),
      'message': message,
      'sourceIp': await Setup.getIpAddress(),
      'destinationIpAddress': destinationIpAddress,
      'sourceName': name,
    };

    return jsonEncode(msg);
  }

  static Map<String, dynamic> decode(String message) {
    final msg = jsonDecode(message) as Map<String, dynamic>;
    msg['encryptionType'] = getEncryptionEnum(msg['encryptionType']);
    msg['type'] = getMessageTypeEnum(msg['type']);
    return msg;
  }
}
