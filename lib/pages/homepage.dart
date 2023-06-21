import 'dart:async';
import 'package:circle_progress_bar/circle_progress_bar.dart';
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
  List<Map<String, dynamic>> toDoList = [];
  List<ValueNotifier<bool>> taskCompletionList = [];

  @override
  void initState() {
    super.initState();
    fetchToDoList();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void fetchToDoList() async {
    try {
      String userId =
          FirebaseAuth.instance.currentUser!.uid; // Get the current user's UID

      QuerySnapshot snapshot = await _firestore
          .collection('todos')
          .where('userId',
              isEqualTo: userId) // Fetch tasks associated with the user's UID
          .get();

      setState(() {
        toDoList = snapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          data['documentId'] = doc.id;
          return data;
        }).toList();

        taskCompletionList = toDoList.map((task) {
          return ValueNotifier<bool>(task['taskCompleted'] ?? false);
        }).toList();
      });
    } catch (e) {
      print('Fehler beim Abrufen der Todo-Liste: $e');
    }
  }

  void saveNewTask(String? taskName) async {
    try {
      String userId =
          FirebaseAuth.instance.currentUser!.uid; // Get the current user's UID

      DocumentReference docRef = await _firestore.collection('todos').add({
        'userId': userId, // Associate the task with the user's UID
        'taskName': taskName,
        'taskCompleted': false,
      });

      String documentId = docRef.id;

      setState(() {
        toDoList.add({
          'documentId': documentId,
          'taskName': taskName,
          'taskCompleted': false,
        });
        taskCompletionList.add(ValueNotifier<bool>(false));
        _controller.clear();
      });

      Navigator.of(context).pop();
    } catch (e) {
      print('Fehler beim Speichern der Aufgabe: $e');
    }
  }

  Future<void> updateTaskCompletionStatus(
      String documentId, bool newCompletionStatus) async {
    try {
      await _firestore
          .collection('todos')
          .doc(documentId)
          .update({'taskCompleted': newCompletionStatus});
    } catch (e) {
      print('Fehler beim Aktualisieren des Aufgabenstatus: $e');
      rethrow; // Throw the exception to indicate the error
    }
  }

  void checkBoxChanged(bool? value, int index) async {
    if (index < 0 || index >= toDoList.length) {
      print('Fehler beim Aktualisieren der Aufgabe: Ungültiger Index.');
      return;
    }

    final task = toDoList[index];

    if (!task.containsKey('documentId')) {
      print('Fehler beim Aktualisieren der Aufgabe: Document ID not found.');
      return;
    }

    final documentId = task['documentId'] as String;

    try {
      await _firestore.collection('todos').doc(documentId).update({
        'taskCompleted': value ?? false,
        'taskName': task['taskName'], // Retain the existing task name
      });

      if (mounted) {
        setState(() {
          task['taskCompleted'] = value ?? false;
          taskCompletionList[index].value = value ?? false;
        });
      }
    } catch (e) {
      print('Fehler beim Aktualisieren der Aufgabe: $e');
      // Handle the error here
    }
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
          onSubmitted: saveNewTask,
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
      taskCompletionList.removeAt(index);
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
        toolbarHeight: 60.0,
        elevation: 5,
        backgroundColor: _themeColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(width: 50),
                  const Text('TODO'),
                  const SizedBox(width: 10),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 40,
                        child: CircleProgressBar(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.black12,
                          value: toDoList.isEmpty
                              ? 0.0
                              : toDoList
                                      .where((task) => task['taskCompleted'])
                                      .length /
                                  toDoList.length,
                          animationDuration: const Duration(seconds: 1),
                        ),
                      ),
                      Text(
                        '${toDoList.where((task) => task['taskCompleted']).length}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 10),
                  const Text('LISTO'),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: signUserOut,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: createTask,
        backgroundColor: Colors.indigo[700],
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
        child: ListView.builder(
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
                  deleteFunction: (context) => deleteTask(index),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
