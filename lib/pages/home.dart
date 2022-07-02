import 'dart:io';

import 'package:band_names/models/band.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  List<Band>  bands = [
    Band( id: '1', name: 'Metalica', votes: 2),
    Band( id: '2', name: 'Ramsstein', votes: 7),
    Band( id: '3', name: 'Mother Mother', votes: 5),
    Band( id: '4', name: 'Queen', votes: 4),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Scaffold(
        appBar: AppBar(
          title: const Text('Band Names', style: TextStyle(color: Colors.black87)),
          backgroundColor: Colors.white,
          elevation: 1,
        ),
        body: ListView.builder(
          itemCount: bands.length,
          itemBuilder: (context, i) => _bandTile(bands[i])
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: addNewBand,
        ),
      )
    );
  }

  ListTile _bandTile(Band band) {
    return ListTile(
      leading: CircleAvatar(
        child: Text( band.name.substring(0,2) ),
        backgroundColor: Colors.blue[100],
      ),
      title: Text(band.name),
      trailing: Text('${band.votes}', style: const TextStyle(fontSize: 20 )),
      onTap: (){
        print(band.name);
      },
    );
  }

  addNewBand(){
    final textController = TextEditingController();
    //# Android
    if( Platform.isAndroid ){
      return showDialog(
        context: context, 
        builder: ( context ){
          return AlertDialog(
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
          );
        }
      );
    }else {
      showCupertinoDialog(
      context: context, 
      builder: ( _ ) {
        return CupertinoAlertDialog(
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
          ); 
        }
      );
    }
    
  }

  void addBandToList(String name){
    if ( name.length > 1 ){

    }
    Navigator.pop(context);
  }
}