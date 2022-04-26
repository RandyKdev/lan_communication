enum EncryptionEnum {
  caesarsCipher,
  publicKey,
  pgp,
}

String getEncryptionString(EncryptionEnum con) {
  switch (con) {
    case EncryptionEnum.caesarsCipher:
      return 'caesars_cipher';
    case EncryptionEnum.pgp:
      return 'pgp';
    case EncryptionEnum.publicKey:
      return 'public_key';
  }
}

EncryptionEnum getEncryptionEnum(String crypt) {
  switch (crypt) {
    case 'caesars_cipher':
      return EncryptionEnum.caesarsCipher;
    case 'public_key':
      return EncryptionEnum.publicKey;
    case 'pgp':
      return EncryptionEnum.pgp;
    default:
      return EncryptionEnum.caesarsCipher;
  }
}
