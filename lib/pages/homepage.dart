import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:todo/util/dialog_box.dart';
import 'package:todo/util/todo_tile.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    Key? key,
  }) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

//homepage class
class _MyHomePageState extends State<MyHomePage> {
  //text controller
  final _controller = TextEditingController();
  final _themeColor = Colors.indigo[700];

  // referenz auf Datenbank
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //list of todo tasks
  List toDoList = [];



  // get todo-data
  void fetchToDoList() async {
    try {
      QuerySnapshot querySnapshot =
      await _firestore.collection('todos').get();

      setState(() {
        toDoList = querySnapshot.docs.map((doc) => doc.data()).toList();
      });
    } catch (e) {
      print('Fehler beim Abrufen der Todo-Liste: $e');
    }
  }
  // speichere todos auf datenbank
  void saveNewTask() async {
    try {
      await _firestore.collection('todos').add({
        'taskName': _controller.text,
        'taskCompleted': false,
      });

      setState(() {
        toDoList.add([_controller.text, false]);
        _controller.clear();
      });

      Navigator.of(context).pop();
    } catch (e) {
      print('Fehler beim Speichern der Aufgabe: $e');
    }
  }

  void checkBoxChanged(bool? value, index) {
    setState(() {
      toDoList[index][1] = !toDoList[index][1];
    });
  }



  void cancelNewTask() {
    Navigator.of(context).pop();
    _controller.clear();
  }

  void createTask() {
    showDialog(
      context: context,
      builder: (context) {

        return DialogBox(
            controller: _controller,
            onSave: saveNewTask,
            onCancel: cancelNewTask,
          );

      },
    );
  }

  // delete task
  void deleteTask(int index) {
    setState(() {
      toDoList.removeAt(index);
    });
  }

  // sign User out
  void signUserOut(){
    FirebaseAuth.instance.signOut();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent,
      appBar: AppBar(

        centerTitle: true,
        title: const Text(
          'TODO LISTO',
        ),
        elevation: 0,
        backgroundColor: _themeColor,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        )),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              icon: const Icon(Icons.logout),
              onPressed: signUserOut,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: createTask,
        backgroundColor: Colors.indigo[500],
        child: const Icon(Icons.add_circle_outline),
      ),
      body: Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.blueAccent, Colors.tealAccent])),
        child: ListView.builder(
          itemCount: toDoList.length,
          itemBuilder: (context, index) {
            return ToDoTile(
              taskName: toDoList[index][0],
              taskCompleted: toDoList[index][1],
              onChanged: (value) => checkBoxChanged(value, index),
              deleteFunction: (context) => deleteTask(index),
            );
          },
        ),
      ),
    );
  }
}
