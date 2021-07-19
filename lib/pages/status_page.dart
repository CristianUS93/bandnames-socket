import 'package:flutter/material.dart';
import 'package:flutter_band_app_udemy/services/socket_service.dart';
import 'package:provider/provider.dart';

class StatusPage extends StatelessWidget {

  const StatusPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _socketService = Provider.of<SocketServices>(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Server Status: ${_socketService.serverStatus}"),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.message),
        onPressed: (){
          _socketService.emit('emitir-mensaje', {
            'nombre': 'Flutter',
            'mensaje': 'mensaje enviado desde Flutter'
          });
        },
      ),
    );
  }
}
