import 'dart:convert';

class Client {
  String name;
  String ipAddress;
  List<dynamic>? publicKey;
  Client({required this.ipAddress, required this.name, this.publicKey});

  static String encode(List<Client> clients) {
    return jsonEncode(clients.map((e) {
      return <String, dynamic>{
        'name': e.name,
        'ipAddress': e.ipAddress,
        'publicKey': e.publicKey,
      };
    }).toList());
  }

  static List<Client> decode(List<dynamic> message) {
    return message.map((e) {
      return Client(
        ipAddress: e['ipAddress']!,
        name: e['name']!,
        publicKey: e['publicKey'],
      );
    }).toList();
  }
}
