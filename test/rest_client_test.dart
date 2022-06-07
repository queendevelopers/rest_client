// import 'package:socket_io_client/socket_io_client.dart';
//
// void main() async {
//   SocketService socketService = SocketService();
//   socketService.createSocketConnection();
//   socketService.emitAny(key: 'addUser');
//   socketService.getMessage();
//   socketService.sendMessage();
//   socketService.getMessageResponse();
// }
//
// abstract class ISocketService {
//   Socket createSocketConnection();
//   Future<void> emitAny({required String key});
//   Future<dynamic> onAny({required String key, required dynamic data});
//   Future<void> sendMessage();
//   Stream<void> getOnlineUsers();
//   Stream<String> getMessage();
//   Stream<void> getMessageResponse();
// }
//
// class SocketService extends ISocketService {
//   late Socket socket;
//
//   @override
//   Socket createSocketConnection() {
//     final String? token =
//         'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjYyNzU1MmU0Y2I0OTJhMzg3OGZhOTcxYSIsImlhdCI6MTY1MzI5MjE3OCwiZXhwIjoxNjUzMzc4NTc4LCJpc3MiOiJpc3N1ZXJfbmFtZSJ9.J8pxztluo1C5UpcCgqnT9BnUEZr9Os3b0SnjdCcwexU';
//     socket = io('https://stem.goswivt.com', <String, dynamic>{
//       'transports': ['websocket'],
//       'autoConnect': true,
//       'auth': {
//         'token': 'Bearer $token',
//       },
//     });
//     socket.connect();
//     socket.onConnect((data) {
//       print('Successfully connected to socket!!');
//     });
//     socket.onConnectError((data) => print('Socket: $data'));
//     socket.onConnecting((data) => print('Socket: $data'));
//     socket.onDisconnect((data) => print('Socket: $data'));
//     socket.onAny((event, data) =>
//         print('Socket ${event.toString()} ${data.toString()}'));
//     // socket.emit("addUser");
//     // socket.on("getUsersOnline", (user) => {print(user)});
//     socket.on('fromServer', (data) => print(data));
//     return socket;
//   }
//
//   @override
//   Future<void> emitAny({required String key}) async {
//     socket.emit(key);
//   }
//
//   @override
//   Future onAny({required String key, required data}) {
//     // TODO: implement onAny
//     throw UnimplementedError();
//   }
//
//   @override
//   Future<void> sendMessage() async {
//     var data = {
//       "sender": {"_id": "627552e4cb492a3878fa971a"},
//       "receiver": {"_id": "62710d58be21b5216c800ea5"},
//       "msg": "Hello Upendra brother.!! NIce to meet you!!"
//     };
//     print(data.toString());
//     socket.emit(
//       'sendMessage',
//       data,
//     );
//   }
//
//   @override
//   Stream<String> getMessage() async* {
//     socket.on('getMessage', (data) async* {
//       print(data.toString());
//       yield '';
//     });
//   }
//
//   @override
//   Stream<void> getMessageResponse() async* {
//     socket.on('messageResponse', (data) {
//       print(data.toString());
//     });
//   }
//
//   @override
//   Stream<void> getOnlineUsers() async* {
//     socket.on('getUsersOnline', (data) {
//       print(data.toString());
//     });
//   }
// }
