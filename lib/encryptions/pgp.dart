import 'package:lan_communication/encryptions/cryptography.dart';

class PGP extends Cryptography {
  late String _sessionKey;

  void generateSessionKey() {}

  @override
  String encrypt({required String message, required dynamic key}) {
    return '';
  }

  @override
  String decrypt({required dynamic message}) {
    return '';
  }
}
