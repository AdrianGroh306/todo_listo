// ignore_for_file: use_build_context_synchronously

import 'dart:async';

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

class _MyHomePageState extends State<MyHomePage> {
  final _controller = TextEditingController();
  final _themeColor = Colors.indigo[700];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List toDoList = [];
  List<ValueNotifier<bool>> taskCompletionList = [];
  late StreamSubscription<QuerySnapshot> _todoListSubscription;

  @override
  void initState() {
    super.initState();
    subscribeToTodoList();
  }

  @override
  void dispose() {
    _todoListSubscription.cancel();
    super.dispose();
  }

  void subscribeToTodoList() {
    _todoListSubscription = _firestore
        .collection('todos')
        .snapshots()
        .listen((QuerySnapshot snapshot) {
      setState(() {
        toDoList = snapshot.docs.map((doc) => doc.data()).toList();

        // Clear the existing taskCompletionList
        taskCompletionList.clear();

        // Initialize the taskCompletionList with ValueNotifier for each task
        for (int i = 0; i < toDoList.length; i++) {
          taskCompletionList
              .add(ValueNotifier<bool>(toDoList[i]['taskCompleted']));
        }
      });
    });
  }

  void saveNewTask() async {
    try {
      DocumentReference docRef = await _firestore.collection('todos').add({
        'taskName': _controller.text,
        'taskCompleted': false,
      });

      String documentId = docRef.id; // Generiere die Document ID

      setState(() {
        toDoList.add({
          'documentId': documentId, // Speichere die Document ID
          'taskName': _controller.text,
          'taskCompleted': false,
        });
        _controller.clear();
      });

      Navigator.of(context).pop();
    } catch (e) {
      print('Fehler beim Speichern der Aufgabe: $e');
    }
  }

  void checkBoxChanged(bool? value, int index) async {
    if (index < 0 || index >= taskCompletionList.length) {
      print('Fehler beim Aktualisieren der Aufgabe: Ungültiger Index.');
      return;
    }

    Map<String, dynamic> task = toDoList[index];

    if (!task.containsKey('documentId')) {
      print('Fehler beim Aktualisieren der Aufgabe: Document ID not found.');
      return;
    }

    String documentId = task['documentId'] as String;

    // Update the task completion status in Firestore
    await _firestore
        .collection('todos')
        .doc(documentId)
        .update({'taskCompleted': value ?? false});

    // Update the task completion status locally
    taskCompletionList[index].value = value ?? false;

    // Update the task name in Firestore
    await _firestore
        .collection('todos')
        .doc(documentId)
        .update({'taskName': task['taskName']});

    // Update the task name locally
    setState(() {
      toDoList[index]['taskName'] = task['taskName'];
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

  void updateTaskName(String documentId, String newTaskName) async {
    try {
      await _firestore
          .collection('todos')
          .doc(documentId)
          .update({'taskName': newTaskName});
    } catch (e) {
      print('Fehler beim Aktualisieren des Task-Namens: $e');
    }
  }


  void deleteTask(int index) async {
    Map<String, dynamic> task = toDoList[index];

    if (!task.containsKey('documentId')) {
      print('Fehler beim Löschen der Aufgabe: Document ID not found.');
      return;
    }

    String documentId = task['documentId'] as String;

    // Delete the task from Firestore
    await _firestore.collection('todos').doc(documentId).delete();

    setState(() {
      toDoList.removeAt(index);
    });
  }

  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent,
      appBar: AppBar(
        centerTitle: true,
        title: const Text('TODO LISTO'),
        elevation: 0,
        backgroundColor: _themeColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
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
            colors: [Colors.blueAccent, Colors.tealAccent],
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: _firestore.collection('todos').snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text(
                    'Fehler beim Abrufen der Todo-Liste: ${snapshot.error}'),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            toDoList = snapshot.data!.docs.map((doc) {
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
              data['documentId'] =
                  doc.id; // Include the document ID in the task object
              return data;
            }).toList();

            return ListView.builder(
              itemCount: toDoList.length,
              itemBuilder: (context, index) {
                final task = toDoList[index];

                return ValueListenableBuilder<bool>(
                  valueListenable: taskCompletionList[index],
                  builder: (context, value, _) {
                    return ToDoTile(
                      key: ValueKey(task['documentId']),
                      taskName: task['taskName'] as String,
                      taskCompleted: value,
                      onChanged: (newValue) => checkBoxChanged(newValue, index),
                      onTaskNameChanged: (newTaskName) =>
                          updateTaskName(task['documentId'] as String, newTaskName),
                      deleteFunction: (context) => deleteTask(index),
                    );

                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
