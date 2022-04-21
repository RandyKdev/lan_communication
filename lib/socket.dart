import 'dart:async';
import 'dart:convert';
import 'dart:io';

class SocketClass {
  late Socket _socket;
  Socket get socket => _socket;

  SocketClass() {
    _start();
  }

  Future<void> _start() async {
    _socket = await Socket.connect(
      '10.2.112.226',
      80,
    );
    print('Connection made');
    _socket.listen((List<int> event) {
      print(utf8.decode(event));
    });

    Future.delayed(Duration(seconds: 2), () {
      _socket.add([0x01, 3, 3, 53, 2, 542, 5]);
      // print('Connection made');
      // _socket.write('hey');
      print('Connection made');
    });
  }

  /// Closes all streams and shuts down the socket servers.
  Future<void> stop() async {
    await _socket.close();
  }
}
