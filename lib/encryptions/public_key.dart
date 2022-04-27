import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto_keys/crypto_keys.dart';
import 'package:lan_communication/encryptions/cryptography.dart';

extension StringParsing on EncryptionResult {
  String parseString() {
    var j = {
      'additionalAuthenticatedData': additionalAuthenticatedData?.toList(),
      'authenticationTag': authenticationTag?.toList(),
      'data': data.toList(),
      'initializationVector': initializationVector?.toList(),
    };
    return jsonEncode(j);
  }

  EncryptionResult parseEncryption(String message) {
    var msg = jsonDecode(message);
    return EncryptionResult(
      Uint8List.fromList((msg['data'] as List<int>)),
      additionalAuthenticatedData: msg['additionalAuthenticatedData'] == null
          ? null
          : Uint8List.fromList(
              (msg['additionalAuthenticatedData'] as List<int>)),
      authenticationTag: msg['authenticationTag'] == null
          ? null
          : Uint8List.fromList((msg['authenticationTag'] as List<int>)),
      initializationVector: msg['initializationVector'] == null
          ? null
          : Uint8List.fromList((msg['initializationVector'] as List<int>)),
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
      keyPair = KeyPair.generateRsa(exponent: BigInt.from(1));
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
