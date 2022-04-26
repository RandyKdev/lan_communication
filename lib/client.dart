import 'dart:convert';

import 'package:crypto_keys/crypto_keys.dart';

class Client {
  String name;
  String ipAddress;
  PublicKey? publicKey;
  Client({required this.ipAddress, required this.name, this.publicKey});

  static String encode(List<Client> clients) {
    return jsonEncode(clients.map((e) {
      return <String, dynamic>{
        'name': e.name,
        'ipAddress': e.ipAddress,
        'publicKey': {
          "exponent": (e.publicKey as RsaPublicKey).exponent.toString(),
          "modulus": (e.publicKey as RsaPublicKey).modulus.toString(),
        },
      };
    }).toList());
  }

  static List<Client> decode(List<dynamic> message) {
    return message.map((e) {
      return Client(
          ipAddress: e['ipAddress']!,
          name: e['name']!,
          publicKey: RsaPublicKey(
            exponent: BigInt.parse(e['publicKey']['exponent']),
            modulus: BigInt.parse(e['publicKey']['modulus']),
          ));
    }).toList();
  }
}
