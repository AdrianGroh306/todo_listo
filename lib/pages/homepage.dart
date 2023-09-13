import 'dart:async';
import 'package:circle_progress_bar/circle_progress_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:todo/util/dialog_box.dart';
import 'package:todo/util/todo_tile.dart';
import '../util/MenuItem.dart';
import '../util/menu_bar.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    Key? key,
  }) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _controller = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> toDoList = [];
  List<ValueNotifier<bool>> taskCompletionList = [];

  @override // wird bei start einmal ausgeführt
  void initState() {
    super.initState();
    fetchToDoList();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // zieht sich die Liste von der Datenbank
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

  //speichert die den neuen Task auf der Datenbank
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

  // für schickt checkbox tru/false an datenbank
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

  //zurück auf Mainscreen
  void cancelNewTask() {
    Navigator.of(context).pop();
    _controller.clear();
  }

  // Der Task wird erstellt
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

  // Bestehender taskName wird auf Datenbank aktualisiert
  void updateTaskName(String documentId, String newTaskName) async {
    try {
      await _firestore
          .collection('todos')
          .doc(documentId)
          .update({'taskName': newTaskName});

      // Aktualisiere den Task-Namen in der lokalen Liste
      setState(() {
        final index =
            toDoList.indexWhere((task) => task['documentId'] == documentId);
        if (index != -1) {
          toDoList[index]['taskName'] = newTaskName;
        }
      });
    } catch (e) {
      print('Fehler beim Aktualisieren des Task-Namens: $e');
    }
  }

  // Bestehender task wird von Datenbank
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

  void deleteAllTask() async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;

      // Fetch all tasks associated with the user's UID
      QuerySnapshot snapshot = await _firestore
          .collection('todos')
          .where('userId', isEqualTo: userId)
          .get();

      // Delete each task in a loop
      for (QueryDocumentSnapshot doc in snapshot.docs) {
        await doc.reference.delete();
      }

      setState(() {
        toDoList.clear();
        taskCompletionList.clear();
      });
    } catch (e) {
      print('Fehler beim Löschen aller Aufgaben: $e');
    }
  }

  // User wird ausgeloggt
  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: SideMenu(),
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        toolbarHeight: 60.0,
        elevation: 5,
        backgroundColor: Theme.of(context).colorScheme.primary,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Todo'),
                const SizedBox(width: 10),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 40,
                      child: CircleProgressBar(
                        foregroundColor: Theme.of(context).colorScheme.secondary,
                        backgroundColor: Theme.of(context).colorScheme.tertiary,
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
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 10),
                const Text('Listo'),
              ],
            ),
            PopupMenuButton<MenuItem>(
              onSelected: (value) {
                if (value == MenuItem.item1) {
                  deleteAllTask();
                }
                if (value == MenuItem.item2) {
                  signUserOut();
                }
                if(value == MenuItem.item3){

                }

              },
              color: Theme.of(context).colorScheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: MenuItem.item1,
                  child: Row(
                    children: [
                      const Icon(Icons.delete),
                      const SizedBox(
                        width: 10,
                      ),
                      Text("Delete all",
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: MenuItem.item2,
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 5,
                      ),
                      const Icon(Icons.logout),
                      const SizedBox(
                        width: 5,
                      ),
                      Text("Logout",
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: MenuItem.item3,
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 5,
                      ),
                      const Icon(Icons.settings_system_daydream_outlined),
                      const SizedBox(
                        width: 5,
                      ),
                      Text("Theme",
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Icon(
                  Icons.more_vert,
                  color: Theme.of(context).colorScheme.secondary, // Farbe des Icons im Button anpassen
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: createTask,
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: IconTheme(
          data: IconThemeData(size: 30, color: Theme.of(context).colorScheme.secondary),
          child: const Icon(Icons.add_circle_outline),
        ),
      ),
      body: Container(color: Theme.of(context).colorScheme.background,

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
                  onTaskNameChanged: (newTaskName) =>
                      updateTaskName(task['documentId'], newTaskName),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
