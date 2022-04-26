import 'package:lan_communication/encryptions/cryptography.dart';

class CaesarsCipher extends Cryptography {
  late int _key;

  set key(int k) => _key = k;

  @override
  String encrypt({required String message}) {
    return message
        .split('')
        .map((e) => String.fromCharCode(e.codeUnits.first + _key))
        .toList()
        .reduce((value, element) => value + element);
  }

  @override
  String decrypt({required String message}) {
    return message
        .split('')
        .map((e) => String.fromCharCode(e.codeUnits.first - _key))
        .toList()
        .reduce((value, element) => value + element);
  }
}
