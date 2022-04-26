import 'dart:io';

class Setup {
  static Future<void> start() async {
    print('Welcome to the LAN Communication Program');
    bool success = false;
    do {
      print('Checking connectivity to a network...');
      List<NetworkInterface> networkInterfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
        includeLinkLocal: true,
      );
      if (networkInterfaces.isNotEmpty) {
        print('Connected to a network');
        success = true;
      } else {
        print('Please connect to a network and try again');
      }
    } while (!success);
  }

  static Future<bool> isServer() async {
    String? input;
    do {
      print('Will this computer be used as the server?');
      print('Yes, Y or No, N');
      input = stdin.readLineSync();
    } while (input == null ||
        !(input.toLowerCase() == 'y' ||
            input.toLowerCase() == 'n' ||
            input.toLowerCase() == 'yes' ||
            input.toLowerCase() == 'no'));

    if (input.toLowerCase().contains('y')) {
      return true;
    } else {
      return false;
    }
  }

  static Future<String> getIpAddress() async {
    List<NetworkInterface> networkInterfaces = await NetworkInterface.list(
      type: InternetAddressType.IPv4,
      includeLinkLocal: true,
    );
    NetworkInterface ipNet = networkInterfaces
        .where(
          (element) => element.name == 'wlp1s0',
        )
        .first;
    return ipNet.addresses.first.address;
  }
}
