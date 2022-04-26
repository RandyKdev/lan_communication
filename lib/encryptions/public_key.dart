import 'package:lan_communication/encryptions/cryptography.dart';

class PublicKey extends Cryptography {
  late String _privateKey;
  late String _publicKey;

  String get publicKey => _publicKey;

  void generateKeys() {}

  @override
  String encrypt({required String message, required String key}) {
    return '';
  }

  @override
  String decrypt({required String message}) {
    return '';
  }
}
