import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto_keys/crypto_keys.dart';
import 'package:lan_communication/encryptions/cryptography.dart';

// extension StringParsing on EncryptionResult {
//   String parseString() {
//     var j = {
//       'additionalAuthenticatedData': additionalAuthenticatedData == null
//           ? null
//           : String.fromCharCodes(additionalAuthenticatedData!),
//       'authenticationTag': authenticationTag == null
//           ? null
//           : String.fromCharCodes(authenticationTag!),
//       'data': String.fromCharCodes(data),
//       'initializationVector': initializationVector == null
//           ? null
//           : String.fromCharCodes(initializationVector!),
//     };
//     return jsonEncode(j);
//   }

//   EncryptionResult parseEncryption(String message) {
//     var msg = jsonDecode(message);
//     return EncryptionResult(
//       Uint8List.fromList((msg['data'] as String).codeUnits),
//       additionalAuthenticatedData: msg['additionalAuthenticatedData'] == null
//           ? null
//           : Uint8List.fromList(
//               (msg['additionalAuthenticatedData'] as String).codeUnits),
//       authenticationTag: msg['authenticationTag'] == null
//           ? null
//           : Uint8List.fromList((msg['authenticationTag'] as String).codeUnits),
//       initializationVector: msg['initializationVector'] == null
//           ? null
//           : Uint8List.fromList(
//               (msg['initializationVector'] as String).codeUnits),
//     );
//   }
// }

class PublicKeyCrypt extends Cryptography {
  late int x, y, n, t, i, flag, j;
  // List<int> e;

  List<int> halfPublicKey = [],
      halfPrivateKey = [],
      temp = [],
      encryptedMessage = [];
  String msg = 'Jan';
  String m = '';

  // late PrivateKey _privateKey;
  // late PublicKey _publicKey;

  // PublicKey get publicKey => _publicKey;

  // int gcd(int a, int h) {
  //   int temp;
  //   while (true) {
  //     temp = a % h;
  //     if (temp == 0) return h;
  //     a = h;
  //     h = temp;
  //   }
  // }

  int prime1(int i) {
    if (i >= 7) return 7;
    if (i >= 5) return 5;
    if (i >= 3) return 3;
    return 2;
    // if (i >= 1) return 1;
    // return 1;
  }

  int cd(int a) {
    int k = 1;
    while (true) {
      k = k + t;
      if (k % a == 0) return k ~/ a;
    }
  }

  @override
  dynamic encrypt({required String message, required List<dynamic> key}) {
    temp = [];
    encryptedMessage = [];
    int pt, ct, k, len;
    i = 0;
    len = message.length;
    while (i != len) {
      pt = message.codeUnits[i];
      pt = pt - 60;
      k = 1;
      for (j = 0; j < key[0]; j++) {
        k = k * pt;
        k = k % key[1] as int;
      }
      temp.add(k);
      ct = k + 60;
      encryptedMessage.add(ct);
      i++;
    }
    // encryptedMessage.add(0);
    print("\n\nTHE ENCRYPTED MESSAGE IS\n");
    //for (i = 0; en[i] != -1; i++) {
    print(String.fromCharCodes(encryptedMessage));
    print(String.fromCharCodes(temp));
    return temp;
    //}
  }

  @override
  String decrypt({required dynamic message}) {
    int pt, ct, key = halfPrivateKey[0], k;
    m = '';
    i = 0;
    for (int l = 0; l < message.length; l++) {
      ct = message[i];
      k = 1;
      for (j = 0; j < key; j++) {
        k = k * ct;
        k = k % n;
      }
      pt = k + 60;
      m += String.fromCharCode(pt);
      i++;
    }
    // m.add(-1);
    print("\n\nTHE DECRYPTED MESSAGE IS\n");
    // for (i = 0; i < m.length; i++) {
    print(m);
    // }
    print("\n");
    return m;
  }

  void encryptionKey() {
    int k;
    k = 0;
    for (i = 2; i < t; i++) {
      if (t % i == 0) continue;
      flag = prime(i);
      if (flag == 1 && i != x && i != y) {
        halfPublicKey.add(i);
        flag = cd(halfPublicKey[k]);
        if (flag > 0) {
          halfPrivateKey.add(flag);
          k++;
        }
        if (k == 99) break;
      }
    }
  }

  int prime(int pr) {
    int i;
    j = sqrt(pr).toInt();
    for (i = 2; i <= j; i++) {
      if (pr % i == 0) return 0;
    }
    return 1;
  }

  void generateKeys() {
    int x1 = Random().nextInt(10);
    int y1 = Random().nextInt(10);
    x = prime1(x1);
    y = prime1(y1);
    if (x == y) y = 11;
    prime(y.toInt());
    m = msg;
    //prime(q1).toDouble();
    n = (x * y).toInt();
    t = ((x - 1) * (y - 1)).toInt();

    encryptionKey();
    print(halfPublicKey);
    // print("\nPOSSIBLE VALUES OF e AND d ARE\n");
    // for (i = 0; i < j - 1; i++) print("\n%ld\t%ld", e[i], d[i]);
    // encrypt1();
    // decrypt1();
    // //public key
    //e stands for encrypt
    // double publicKey = 2;

    // //for checking co-prime which satisfies e>1
    // while (publicKey < totient) {
    //   count = gcd(publicKey.toInt(), totient.toInt()).toDouble();
    //   if (count == 1) {
    //     break;
    //   } else {
    //     publicKey++;
    //   }
    // }

    // //private key
    // //d stands for decrypt
    // double privateKey;

    // //k can be any arbitrary value
    // double k = 2;

    // //choosing d such that it satisfies d*e = 1 + k * totient
    // privateKey = (1 + (k * totient)) / publicKey;
    // double msg = 12;
    // double c = pow(msg, publicKey).toDouble();
    // double m = pow(c, privateKey).toDouble();
    // c = c % n;
    // m = m % n;

    // print("Message data = " + msg.toString());
    // print("\np = " + p.toString());
    // print("\nq = " + q.toString());
    // print("\nn = pq = " + n.toString());
    // print("\ntotient = " + totient.toString());
    // print("\ne = " + publicKey.toString());
    // print("\nd = " + privateKey.toString());
    // print("\nEncrypted data = " + c.toString());
    // print("\nOriginal Message Sent = " + m.toString());

    // KeyPair keyPair;
    // do {
    //   keyPair = KeyPair.generateRsa(exponent: BigInt.from(1));
    // } while (keyPair.publicKey == null || keyPair.privateKey == null);
    // _publicKey = keyPair.publicKey!;
    // _privateKey = keyPair.privateKey!;
  }

  // @override
  // String encrypt({required String message, required dynamic key}) {
  //   return (key as PublicKey)
  //       .createEncrypter(algorithms.encryption.rsa.oaep)
  //       .encrypt(Uint8List.fromList(message.codeUnits))
  //       .parseString();
  // }

  // @override
  // String decrypt({required String message}) {
  //   return String.fromCharCodes(_privateKey
  //       .createEncrypter(algorithms.encryption.rsa.oaep)
  //       .decrypt(EncryptionResult(Uint8List.fromList(''.codeUnits))
  //           .parseEncryption(message)));
  // }
}
