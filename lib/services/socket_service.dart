import 'package:flutter/cupertino.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:socket_io_client/socket_io_client.dart';

enum ServerStatus {
  Online,
  Offline,
  Connecting
}

class SocketService with ChangeNotifier {

  late ServerStatus _serverStatus = ServerStatus.Connecting;
  late IO.Socket _socket;
  
  ServerStatus get serverStatus => _serverStatus;
  
  IO.Socket get socket => _socket;
  Function get emit => _socket.emit;

  SocketService(){
    _initConfig();
  }

  void _initConfig(){

    _socket = IO.io('http://192.168.56.1:3000/',{
      'transports': ['websocket'],
      'autoConnect': true
    });
    _socket.onConnect(( _) {
      _serverStatus = ServerStatus.Online;
      notifyListeners();
    });
    _socket.onDisconnect((_) {
      _serverStatus = ServerStatus.Offline;
      notifyListeners();
    });
    // socket.on('nuevo-mensaje', ( payload ){
    //   print('Nombre' + payload['nombre']);
    //   print('Mensaje' + payload['mensaje']);
    //   print( payload.containsKey('numero') ? payload['numero'] : 'anonimo');
    // });
  }

}