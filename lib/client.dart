class Client {
  String name;
  String ipAddress;
  String? publicKey;
  Client({required this.ipAddress, required this.name, this.publicKey});

  static List<Map<String, String?>> encode(List<Client> clients) {
    return clients.map((e) {
      return {
        'name': e.name,
        'ipAddress': e.ipAddress,
        'publicKey': e.publicKey,
      };
    }).toList();
  }

  static List<Client> decode(List<Map<String, String?>> message) {
    return message.map((e) {
      return Client(
          ipAddress: e['ipAddress']!,
          name: e['name']!,
          publicKey: e['publicKey']);
    }).toList();
  }
}
