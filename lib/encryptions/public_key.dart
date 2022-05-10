import 'dart:math';
import 'package:lan_communication/encryptions/cryptography.dart';

class PublicKeyCrypt extends Cryptography {
  late int x, y, n, t, i, flag, j;
  late int index;

  List<int> halfPublicKey = [], halfPrivateKey = [], encryptedMessage = [];

  int cd(int a) {
    int k = 1;
    while (true) {
      k = k + t;
      if (k % a == 0) return k ~/ a;
    }
  }

  @override
  dynamic encrypt({required String message, required dynamic key}) {
    encryptedMessage = [];
    int pt, k, len;
    i = 0;
    len = message.length;
    while (i != len) {
      pt = message.runes.elementAt(i);
      pt = pt - 31;
      k = 1;
      for (j = 0; j < key[0]; j++) {
        k = k * pt;
        k = k % key[1] as int;
      }
      encryptedMessage.add(k);
      i++;
    }
    print('Encrypted Message: ' +
        String.fromCharCodes(encryptedMessage.map((e) => e + 31).toList()));
    return encryptedMessage;
  }

  @override
  String decrypt({required dynamic message}) {
    int pt, ct, key = halfPrivateKey[index], k;
    String m = '';
    i = 0;
    for (int l = 0; l < message.length; l++) {
      ct = message[i];
      k = 1;
      for (j = 0; j < key; j++) {
        k = k * ct;
        k = k % n;
      }
      pt = k + 31;
      m += String.fromCharCode(pt);
      i++;
    }
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
    x = 7;
    y = 13;
    prime(y.toInt());
    n = (x * y).toInt();
    t = ((x - 1) * (y - 1)).toInt();

    encryptionKey();
    index = Random().nextInt(15);
  }
}
