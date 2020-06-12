import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:async';


void main(){
  runApp(MaterialApp(
    home: HOME(),

  ));
}

class HOME extends StatefulWidget {
  @override
  _HOMEState createState() => _HOMEState();
}

class _HOMEState extends State<HOME> {

   final _toDocontroller = TextEditingController();

  List _toDoList = [];

  Map<String, dynamic> _lastRemoved;
  int _lastRemovedPos;


  Future<Null> _refresh() async{
    await Future.delayed(Duration(seconds: 1));

    setState(() {
      _toDoList.sort((a, b){
        if(a["ok"] && !b["ok"]) return 1;
      else if(!a["ok"] && b["ok"]) return -1;
      else return 0;

      });
      _saveData();
    });
    return null;
  }

  @override
  void initState(){
    super.initState();
    _readData().then((data){
      setState(() {
        _toDoList = json.decode(data);
      });

    });

  }
 

  void _addToDo(){
    Map<String, dynamic> newToDo = Map();
   setState(() {
      newToDo["title"] = _toDocontroller.text;
    _toDocontroller.text = "";
    newToDo["ok"] = false;
    _toDoList.add(newToDo);
    _saveData();
   });
    

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lista de Tarefas"),
        centerTitle: true,
        backgroundColor: Colors.indigo,
      ),

      body:Column(
        children: <Widget>[
        Container(
        padding: EdgeInsets.fromLTRB(17.0, 1.0, 7.0, 1.0),
        child: Row(
          children: <Widget>[
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  labelText: "Nova Tarefa",
                  labelStyle: TextStyle(color: Colors.indigo)
                ),
                controller: _toDocontroller,
            ),
            ),

            RaisedButton(
              onPressed: _addToDo,
              child: Text("ADD"),
              textColor: Colors.white,
              color: Colors.indigo,
            )

        ],),

      ),
      Expanded(
        child: RefreshIndicator(  onRefresh: _refresh,
        child: ListView.builder(
          padding: EdgeInsets.only(top: 10.0),
          itemCount: _toDoList.length,
          
          itemBuilder: buildItem),
        
        ),
         ),



      ],)
      
      
    );
  }

  Widget buildItem (BuildContext context, int index){
            return Dismissible(
              key: Key(DateTime.now().millisecondsSinceEpoch.toString()),

              background: Container(
                color: Colors.red,
                child: Align(
                  alignment: Alignment(-0.9, 0.0),
                  child: Icon(Icons.delete, color: Colors.white,),
                  ),
              ),
              direction: DismissDirection.startToEnd,
              child:  CheckboxListTile(
              title: Text(_toDoList[index]["title"]),
              value: _toDoList[index]["ok"],
              secondary: CircleAvatar(
                child: Icon(_toDoList[index]["ok"] ?
                Icons.check :Icons.error
                ),
              ),
              onChanged: (c){
                setState(() {
                  _toDoList[index]["ok"] = c;
                  _saveData();
                });
              },
            ),

            onDismissed: (direction){
              setState(() {
                _lastRemoved = Map.from(_toDoList [index]);
                _lastRemovedPos = index;
                _toDoList.removeAt(index);
                _saveData();

                final snack = SnackBar(
                  content: Text("Tarefa \"${_lastRemoved["title"]}\" removida"),
                  action: SnackBarAction( label: "Desfazer",
                  onPressed: (){
                    setState(() {
                      _toDoList.insert(_lastRemovedPos, _lastRemoved);
                      _saveData();
                    });
                  },
                       
                  ),
                  duration: Duration(seconds: 3),
                );
                Scaffold.of(context).removeCurrentSnackBar();
                Scaffold.of(context).showSnackBar(snack);
              });
            }

            );
          }
  




Future<File> _getFile() async{
  
  final directory = await getApplicationSupportDirectory();
  return File("${directory.path}/data.json");

}

Future<File> _saveData() async{
  String data = json.encode(_toDoList);
  final file = await _getFile();
  return file.writeAsString(data);

}

Future<String> _readData() async{
  try{
    final file = await _getFile();
    return file.readAsString();

  }catch (e){
    return null;

  }

}


}


