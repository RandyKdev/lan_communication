import 'package:lan_communication/encryptions/caesars_cipher.dart';
import 'package:lan_communication/encryptions/pgp.dart';
import 'package:lan_communication/encryptions/public_key.dart';

class Cryptography {
  String encrypt({required String message, required String key}) {
    return '';
  }

  String decrypt({required String message}) {
    return '';
  }

  // static String stringRepresentation(Cryptography c) {
  //   if (c is CaesarsCipher) return 'caesarsCipher';
  //   if (c is PublicKey) return 'publicKey';
  //   return 'pgp';
  // }

  // static Cryptography cryptRepresentation(String c) {
  //   if (c == 'caesarsCipher') return CaesarsCipher();
  //   if (c == 'publicKey') return PublicKey();
  //   return PGP();
  // }
}
