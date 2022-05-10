import 'dart:io';

import 'package:lan_communication/enums/connection_enum.dart';
import 'package:lan_communication/global.dart';

import 'encryptions/caesars_cipher.dart';
import 'encryptions/pgp.dart';
import 'encryptions/public_key.dart';

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

    String? cr;
    do {
      print('1) Caesars Cipher');
      print('2) Public key');
      print('3) PGP');
      cr = stdin.readLineSync();
    } while (cr == null || int.tryParse(cr) == null);

    if (cr == '1') {
      cryptography = CaesarsCipher();
      encryptionType = EncryptionEnum.caesarsCipher;
      cr = null;
      do {
        print('Enter Caesars cipher key');
        cr = stdin.readLineSync();
      } while (cr == null || int.tryParse(cr) == null);
      (cryptography as CaesarsCipher).key = int.tryParse(cr)!;
    } else if (cr == '2') {
      cryptography = PublicKeyCrypt();
      encryptionType = EncryptionEnum.publicKey;
      (cryptography as PublicKeyCrypt).generateKeys();
    } else {
      cryptography = PGP();
      encryptionType = EncryptionEnum.pgp;
      (cryptography as PGP).generateSessionKey();
    }

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
          (element) => element.name == 'wlp1s0' || element.name == 'WiFi',
        )
        .first;
    return ipNet.addresses.first.address;
  }
}
