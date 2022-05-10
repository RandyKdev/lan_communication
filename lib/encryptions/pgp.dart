import 'package:lan_communication/encryptions/caesars_cipher.dart';
import 'package:lan_communication/encryptions/cryptography.dart';
import 'package:lan_communication/encryptions/public_key.dart';

class PGP extends Cryptography {
  PublicKeyCrypt publicKeyClass = PublicKeyCrypt();
  CaesarsCipher caesarsCipherClass = CaesarsCipher();
  String sessionKey = '';
  List<int> encryptedSessionKey = [];

  void generateSessionKey() {
    publicKeyClass.generateKeys();
  }

  @override
  String encrypt({required String message, required dynamic key}) {
    encryptedSessionKey = publicKeyClass.encrypt(message: key[2], key: key);
    return caesarsCipherClass.encrypt(message: message, key: key[2]);
  }

  @override
  String decrypt({required dynamic message}) {
    sessionKey = publicKeyClass.decrypt(message: encryptedSessionKey);
    caesarsCipherClass.key = int.tryParse(sessionKey) ?? 1;
    return caesarsCipherClass.decrypt(message: message);
  }
}
