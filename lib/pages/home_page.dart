import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:provider/provider.dart';

import 'package:flutter_band_app_udemy/models/bands.dart';
import 'package:flutter_band_app_udemy/services/socket_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  List<Band> bands = [];

  @override
  void initState() {
    // TODO: implement initState
    final socketService = Provider.of<SocketServices>(context, listen: false);

    socketService.socket.on('active-bands', _handleActiveBands);

    super.initState();
  }

  _handleActiveBands(dynamic payload){
    this.bands = (payload as List)
        .map((band) => Band.fromMap(band))
        .toList();
    setState(() {});
  }

  @override
  void dispose() {
    // TODO: implement dispose
    final socketService = Provider.of<SocketServices>(context, listen: false);
    socketService.socket.off('active-bands');
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final _socketService = Provider.of<SocketServices>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("BandNames", style: TextStyle(color: Colors.black87),),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          Container(
            padding: EdgeInsets.only(right: 10),
            child: _socketService.serverStatus == ServerStatus.Online
                ? Icon(Icons.check_circle, color: Colors.blue[300],)
                : Icon(Icons.offline_bolt, color: Colors.red,)
          )
        ],
      ),
      body: Column(
        children: [
          _showGraf(),
          Expanded(
            child: ListView.builder(
              itemCount: bands.length,
              itemBuilder: (context, index){
                return bandTile(bands[index]);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        elevation: 1,
        onPressed: addNewBand,
      ),
    );
  }

  addNewBand() {
    final textController = new TextEditingController();

    if (Platform.isAndroid) {
      showDialog(
          context: context,
          builder: (_) {
            return AlertDialog(
              title: Text("New band name"),
              content: TextField(
                textCapitalization: TextCapitalization.words,
                controller: textController,
              ),
              actions: [
                MaterialButton(
                  child: Text("Add"),
                  textColor: Colors.blue,
                  elevation: 1,
                  onPressed: () => addBandToList(textController.text),
                )
              ],
            );
          });
    } else if(Platform.isIOS){
      showCupertinoDialog(
          context: context,
          builder: (_) {
            return CupertinoAlertDialog(
              title: Text("New band Name"),
              content: CupertinoTextField(
                controller: textController,
                textCapitalization: TextCapitalization.words,
              ),
              actions: [
                CupertinoDialogAction(
                  isDefaultAction: true,
                  child: Text("Add"),
                  onPressed: () => addBandToList(textController.text),
                ),
                CupertinoDialogAction(
                  isDestructiveAction: true,
                  child: Text("Dismiss"),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            );
          });
    }
  }


  Widget bandTile(Band band) {
    final _socketService = Provider.of<SocketServices>(context, listen: false);

    return Dismissible(
      key: Key(band.id),
      direction: DismissDirection.startToEnd,
      onDismissed: (_) => _socketService.emit('delete-band', {'id': band.id}),
      background: Container(
        color: Colors.red,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text("Delete Band", style: TextStyle(color: Colors.white),),
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(band.name.substring(0,2)),
          backgroundColor: Colors.blue[100],
        ),
        title: Text(band.name),
        trailing: Text(band.votes.toString()),
        onTap: () => _socketService.emit('vote-band',{'id': band.id}),
      ),
    );
  }


  void addBandToList(String name) {
    final _socketService = Provider.of<SocketServices>(context, listen: false);
    if (name.length > 1) {
      _socketService.emit('add-band', {'name': name});
    }
    Navigator.pop(context);
  }


  //Mostrar Grafica
  _showGraf(){
    Map<String, double> dataMap = {};

    bands.forEach((band) {
      dataMap.putIfAbsent(band.name, () => band.votes.toDouble());
    });

    final List<Color> colorList = [
      Colors.blue,
      Colors.cyan,
      Colors.indigo,
      Colors.purple,
      Colors.redAccent,
      Colors.red,
      Colors.deepOrange,
    ];

    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      height: 200,
      width: double.infinity,
      child: PieChart(
        dataMap: dataMap,
        chartType: ChartType.ring,
        colorList: colorList,
      ),
    );
  }

}
