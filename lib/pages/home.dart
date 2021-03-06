import 'dart:io';

import 'package:band_names/models/band.dart';
import 'package:band_names/services/socket_service.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  List<Band>  bands = [];
  @override
  void initState() {
    final socketService = Provider.of<SocketService>( context, listen: false );
    socketService.socket.on('active-bands', _handleActiveBands );
    super.initState();
  }

  _handleActiveBands( dynamic  payload ){
    this.bands = ( payload as List).map( (band) => Band.fromMap(band) ).toList();
    setState(() {});
  }

  @override
  void dispose() {
    final socketService = Provider.of<SocketService>( context, listen: false );
    socketService.socket.off('active-bands');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);
    return Scaffold(
      body: Scaffold(
        appBar: AppBar(
          title: const Text('Band Names', style: TextStyle(color: Colors.black87)),
          backgroundColor: Colors.white,
          elevation: 1,
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 10),
              child: socketService.serverStatus == ServerStatus.Online
                ?const Icon(Icons.check_circle,color: Colors.greenAccent,)
                :const Icon(Icons.offline_bolt, color: Colors.red)
            )
          ],
        ),
        body: 
        Column(
          children: [
            _showGraph(),
            Expanded(
              child: ListView.builder(
                itemCount: bands.length,
                itemBuilder: (context, i) => _bandTile(bands[i])
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: addNewBand,
        ),
      )
    );
  }

  Widget _bandTile(Band band) {

    final socketService = Provider.of<SocketService>( context);
    return Dismissible(
      key: Key(band.id),
      direction:  DismissDirection.startToEnd,
      onDismissed: ( _ ) => socketService.emit('delete-band',{ 'id': band.id }),
      background: Container(
        padding: EdgeInsets.only(left: 8), 
        color: Colors.red,
        child: const Align(
          alignment: Alignment.centerLeft,
          child: Text('Delete', style: TextStyle(color: Colors.white ) )
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          child: Text( band.name.substring(0,2) ),
          backgroundColor: Colors.blue[100],
        ),
        title: Text(band.name),
        trailing: Text('${band.votes}', style: const TextStyle(fontSize: 20 )),
        onTap: () => socketService.socket.emit('vote-band', { 'id': band.id }),
      ),
    );
  }

  addNewBand(){
    final textController = TextEditingController();
    //# Android
    if( Platform.isAndroid ){
      return showDialog(
        context: context, 
        builder: ( _ ) =>  AlertDialog(
            title: Text('New band name:'),
            content: TextField(
              controller:  textController,
            ),
            actions: [
              MaterialButton(
                child: Text('Add'),
                elevation: 5,
                textColor: Colors.blue, 
                onPressed: () => addBandToList( textController.text )
              )
            ]
          ),
      );
    }else {
      showCupertinoDialog(
      context: context, 
      builder: ( _ ) => CupertinoAlertDialog(
        title:  Text('New band name'),
        content: CupertinoTextField(
          controller: textController,
        ),
        actions: <Widget> [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text('Add'),
            onPressed: () => addBandToList( textController.text )
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Dismiss'),
            onPressed: () => Navigator.pop(context)
          )
        ]
      ));
    }
  }
  void addBandToList(String name){
    if ( name.length > 1 ){
      final socketService = Provider.of<SocketService>( context, listen: false );
      socketService.emit('add-band',{ 'name': name });
    }
    Navigator.pop(context);
  }
  Widget _showGraph (){
    Map<String, double> dataMap = {};
    bands.forEach((band){
      dataMap.putIfAbsent(band.name, () => band.votes.toDouble());
    });
    final List<Color> colorList = [
      Colors.redAccent,
      Colors.blueAccent,
      Colors.greenAccent,
      Colors.yellowAccent,
      Colors.purpleAccent,
      Colors.cyanAccent,
      Colors.orangeAccent,
      Colors.deepOrangeAccent,
      Colors.deepPurpleAccent,
    ];
    return Container(
      height: MediaQuery.of(context).size.height * 0.25,
      child: PieChart( 
        dataMap: dataMap,
        animationDuration: Duration(milliseconds: 800),
        chartLegendSpacing: 32,
        chartRadius: MediaQuery.of(context).size.width / 3.2,
        colorList: colorList,
        initialAngleInDegree: 0,
        chartType: ChartType.ring,
        ringStrokeWidth: 32,
        centerText: "HYBRID",
        legendOptions: const LegendOptions(
          showLegendsInRow: false,
          legendPosition: LegendPosition.right,
          showLegends: true,
          // legendShape: _BoxShape.circle,
          legendTextStyle: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        chartValuesOptions: const ChartValuesOptions(
          showChartValueBackground: true,
          showChartValues: true,
          showChartValuesInPercentage: true,
          showChartValuesOutside: false,
          decimalPlaces: 1,
        ),
      ),
    );
  }
}