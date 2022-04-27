import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto_keys/crypto_keys.dart';
import 'package:lan_communication/encryptions/cryptography.dart';

extension StringParsing on EncryptionResult {
  String parseString() {
    var j = {
      'additionalAuthenticatedData': additionalAuthenticatedData == null
          ? null
          : String.fromCharCodes(additionalAuthenticatedData!),
      'authenticationTag': authenticationTag == null
          ? null
          : String.fromCharCodes(authenticationTag!),
      'data': String.fromCharCodes(data),
      'initializationVector': initializationVector == null
          ? null
          : String.fromCharCodes(initializationVector!),
    };
    return jsonEncode(j);
  }

  EncryptionResult parseEncryption(String message) {
    var msg = jsonDecode(message);
    return EncryptionResult(
      Uint8List.fromList((msg['data'] as String).codeUnits),
      additionalAuthenticatedData: msg['additionalAuthenticatedData'] == null
          ? null
          : Uint8List.fromList(
              (msg['additionalAuthenticatedData'] as String).codeUnits),
      authenticationTag: msg['authenticationTag'] == null
          ? null
          : Uint8List.fromList((msg['authenticationTag'] as String).codeUnits),
      initializationVector: msg['initializationVector'] == null
          ? null
          : Uint8List.fromList(
              (msg['initializationVector'] as String).codeUnits),
    );
  }
}

class PublicKeyCrypt extends Cryptography {
  late PrivateKey _privateKey;
  late PublicKey _publicKey;

  PublicKey get publicKey => _publicKey;

  void generateKeys() {
    KeyPair keyPair;
    do {
      keyPair = KeyPair.generateRsa(exponent: BigInt.from(1), bitStrength: 12);
    } while (keyPair.publicKey == null || keyPair.privateKey == null);
    _publicKey = keyPair.publicKey!;
    _privateKey = keyPair.privateKey!;
  }

  @override
  String encrypt({required String message, required dynamic key}) {
    return (key as PublicKey)
        .createEncrypter(algorithms.encryption.rsa.pkcs1)
        .encrypt(Uint8List.fromList(message.codeUnits))
        .parseString();
  }

  @override
  String decrypt({required String message}) {
    return String.fromCharCodes(_privateKey
        .createEncrypter(algorithms.encryption.rsa.pkcs1)
        .decrypt(EncryptionResult(Uint8List.fromList(''.codeUnits))
            .parseEncryption(message)));
  }
}
