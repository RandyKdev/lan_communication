class CaesarsCipher {
  static String encrypt({required String message, required int key}) {
    String encryptedMessage = '';
    for (var i = 0; i < message.length; i++) {
      //Using unicodes.
      encryptedMessage += String.fromCharCode(message.codeUnits[i] + key);
    }
    return encryptedMessage;
  }

  static String decrypt({required String message, required int key}) {
    String decryptedMessage = '';
    for (var i = 0; i < message.length; i++) {
      decryptedMessage += String.fromCharCode(message.codeUnits[i] - key);
    }
    return decryptedMessage;
  }
}
