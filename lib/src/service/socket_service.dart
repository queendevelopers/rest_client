import 'package:flutter_rest_client/flutter_rest_client.dart';
import 'package:socket_io_client/socket_io_client.dart';

abstract class ISocketService {
  Future<Socket> createSocketConnection();
}

class SocketService implements ISocketService {
  final IHttpConfig config;

  SocketService(this.config);

  @override
  Future<Socket> createSocketConnection() async {
    final String? token = await config.token;
    Socket socket = io(config.socketUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
      'auth': {
        'token': 'Bearer $token',
      },
    });
    socket.connect();
    socket.onConnect((data) {
      print('Successfully connected to socket!!');
    });
    socket.onConnectError((data) => print('Socket: $data'));
    socket.onConnecting((data) => print('Socket: $data'));
    socket.onDisconnect((data) => print('Socket: $data'));
    socket.onAny((event, data) =>
        print('Socket ${event.toString()} ${data.toString()}'));
    socket.emit("addUser");
    socket.on("getUsersOnline", (user) => {print(user)});
    socket.on('fromServer', (data) => print(data));
    return socket;
  }
}
