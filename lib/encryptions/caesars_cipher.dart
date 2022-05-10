import 'package:lan_communication/encryptions/cryptography.dart';

class CaesarsCipher extends Cryptography {
  late int _key;

  set key(int k) => _key = k;

  @override
  String encrypt({required String message, required dynamic key}) {
    return message
        .split('')
        .map((e) => String.fromCharCode(e.codeUnits.first + int.parse(key)))
        .toList()
        .reduce((value, element) => value + element);
  }

  @override
  String decrypt({required dynamic message}) {
    return message
        .split('')
        .map((e) => String.fromCharCode(e.codeUnits.first - _key))
        .toList()
        .reduce((value, element) => value + element);
  }
}
