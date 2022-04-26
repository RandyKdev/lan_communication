enum MessageTypeEnum { data, handshake, update }

String getMessageString(MessageTypeEnum msg) {
  switch (msg) {
    case MessageTypeEnum.data:
      return 'data';
    case MessageTypeEnum.handshake:
      return 'handshake';
    case MessageTypeEnum.update:
      return 'update';
  }
}

MessageTypeEnum getMessageTypeEnum(String type) {
  switch (type) {
    case 'data':
      return MessageTypeEnum.data;
    case 'handshake':
      return MessageTypeEnum.handshake;
    case 'update':
      return MessageTypeEnum.update;
    default:
      return MessageTypeEnum.data;
  }
}
