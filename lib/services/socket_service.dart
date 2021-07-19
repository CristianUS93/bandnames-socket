import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart';

enum ServerStatus{
  Online,
  Offline,
  Connecting,
}


class SocketServices with ChangeNotifier{

  ServerStatus _serverStatus = ServerStatus.Connecting;
  Socket? _socket;

  ServerStatus get serverStatus => this._serverStatus;
  Socket get socket => this._socket!;

  Function get emit => this._socket!.emit;

  SocketServices(){
    this.initConfig();
  }

  void initConfig(){
    this._socket = io('http://192.168.1.21:3000',
      OptionBuilder()
        .setTransports(['websocket'])
        .enableAutoConnect()
        .build()
    );

    this._socket!.onConnect((_) {
      print('connect');
      this._serverStatus = ServerStatus.Online;
      this.socket.emit('mensaje', 'Cliente conectado desde el movil');
      notifyListeners();
    });
    this._socket!.onDisconnect((_) {
      print('disconnect');
      this._serverStatus = ServerStatus.Offline;
      notifyListeners();
    });

    this.socket.on('emitir-mensaje', (payload) {
      print(payload);
    });

  }

}