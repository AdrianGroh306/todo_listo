// Dart imports
import 'dart:async';

// Package imports
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Local imports
import 'package:todo/util/addTodo_box.dart';
import 'package:todo/util/sideMenu_bar.dart';
import 'package:todo/util/myTodoTile.dart';
import '../util/MenuItem.dart';
import 'package:circle_progress_bar/circle_progress_bar.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _todoController = TextEditingController();
  final FirebaseFirestore _firestoreDB = FirebaseFirestore.instance;

  List<Map<String, dynamic>> _todos = [];
  List<ValueNotifier<bool>> _taskCompletionNotifiers = [];
  String? _selectedTaskListId;

  @override
  void initState() {
    super.initState();
    _fetchTodos();
  }

  // Fetch tasks associated with the selected list
  void _fetchTodos() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      final selectedListId = await getCurrentSelectedListId();
      if (userId != null && selectedListId != null) {
        final querySnapshot = await _firestoreDB
            .collection('todos')
            .where('userId', isEqualTo: userId)
            .where('listId', isEqualTo: selectedListId)
            .get();

        setState(() {
          _todos = querySnapshot.docs.map((doc) {
            return {
              ...doc.data(),
              'documentId': doc.id,
            };
          }).toList();

          _taskCompletionNotifiers = _todos.map((task) {
            return ValueNotifier<bool>(task['taskCompleted'] ?? false);
          }).toList();
        });
      }
    } catch (e) {
      print('[Error] Fetching Todos for the selected list: $e');
    }
  }

  // Save a new task to Firestore
  void _saveTodos(String? taskName) async {
    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final selectedListId = await getCurrentSelectedListId();

      if (selectedListId != null && taskName != null) {
        DocumentReference docRef = await _firestoreDB.collection('todos').add({
          'userId': userId,
          'listId': selectedListId,
          'taskName': taskName,
          'taskCompleted': false,
        });

        setState(() {
          _todos.add({
            'documentId': docRef.id,
            'taskName': taskName,
            'taskCompleted': false,
          });
          _taskCompletionNotifiers.add(ValueNotifier<bool>(false));
          _todoController.clear();
        });

        Navigator.of(context).pop();
      }
    } catch (e) {
      print('[Error] Saving task: $e');
    }
  }

  // Update task's name in Firestore
  void _updateTodoName(String documentId, String newTaskName) async {
    try {
      await _firestoreDB.collection('todos').doc(documentId).update({
        'taskName': newTaskName,
      });

      setState(() {
        final index =
            _todos.indexWhere((task) => task['documentId'] == documentId);
        if (index != -1) {
          _todos[index]['taskName'] = newTaskName;
        }
      });
    } catch (e) {
      print('[Error] Updating task name: $e');
    }
  }

  // Update task's completion status
  Future<void> _updateTaskCompletionStatus(
      String documentId, bool newCompletionStatus) async {
    try {
      await _firestoreDB.collection('todos').doc(documentId).update({
        'taskCompleted': newCompletionStatus,
      });
    } catch (e) {
      print('[Error] Updating task completion status: $e');
    }
  }

  // Handle check-box change
  void _checkBoxChanged(bool? value, int index) async {
    if (index < 0 || index >= _todos.length) {
      print('[Error] Invalid index while updating task.');
      return;
    }

    final task = _todos[index];
    if (!task.containsKey('documentId')) {
      print('[Error] Document ID not found while updating task.');
      return;
    }

    final documentId = task['documentId'] as String;
    final newValue = value ?? false;
    await _updateTaskCompletionStatus(documentId, newValue);

    if (mounted) {
      setState(() {
        task['taskCompleted'] = newValue;
        _taskCompletionNotifiers[index].value = newValue;
      });
    }
  }

  // Show dialog for creating a task
  void _createTodo() {
    showDialog(
      context: context,
      builder: (context) {
        return DialogBox(
          controller: _todoController,
          onSave: _saveTodos,
          onCancel: () {
            Navigator.of(context).pop();
            _todoController.clear();
          },
          onSubmitted: _saveTodos,
        );
      },
    );
  }

  // Delete a single task
  void _deleteTodo(int index) async {
    final task = _todos[index];
    if (!task.containsKey('documentId')) {
      print('[Error] Document ID not found while deleting task.');
      return;
    }

    final documentId = task['documentId'] as String;
    await _firestoreDB.collection('todos').doc(documentId).delete();

    setState(() {
      _todos.removeAt(index);
      _taskCompletionNotifiers.removeAt(index);
    });
  }

  // Delete all tasks for the selected list
  void _deleteAllListTodos() async {
    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final selectedListId = await getCurrentSelectedListId();
      final snapshot = await _firestoreDB
          .collection('todos')
          .where('userId', isEqualTo: userId)
          .where('listId', isEqualTo: selectedListId)
          .get();

      for (final doc in snapshot.docs) {
        await doc.reference.delete();
      }

      setState(() {
        _todos.clear();
        _taskCompletionNotifiers.clear();
      });
    } catch (e) {
      print('[Error] Deleting all tasks: $e');
    }
  }

  // Logout user
  void _signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  Future<int> _getSelectedListIcon() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      try {
        final selectedListId = await getCurrentSelectedListId();
        if (selectedListId != null) {
          // Dann die ausgewählte Liste anhand der ausgewählten List-Id aus der Sammlung 'lists' abrufen
          final selectedListDoc =
              await _firestoreDB.collection('lists').doc(selectedListId).get();
          final selectedListData = selectedListDoc.data();

          if (selectedListData != null) {
            return selectedListData['listIcon'];
          }
        }
      } catch (e) {
        print('[Error] Getting selected list icon: $e');
      }
    }
    return 0; // Return a default icon code if there's an error or if the data is missing.
  }

  Future<String?> getCurrentSelectedListId() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();
        final userData = userDoc.data();
        if (userData != null) {
          final selectedListId = userData['selectedListId'] as String?;
          return selectedListId;
        } else {
          // Wenn selectedListId in userData null ist, die oberste Liste aus 'lists' abrufen
          final lists = userData?['lists'] as List<dynamic>;
          if (lists.isNotEmpty) {
            final topListId = lists[0]['listId'] as String?;
            return topListId;
          }
        }
      } catch (e) {
        print('[Error] Getting current selectedListId: $e');
      }
    }
    return null; // Rückgabe, wenn keine ausgewählte Liste gefunden wurde oder ein Fehler auftrat
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      endDrawer: SideMenu(
        selectedListId: _selectedTaskListId,
        onSelectedListChanged: (listId) {
          setState(() {
            _selectedTaskListId = listId;
            _fetchTodos();
          });
        },
      ),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        toolbarHeight: 60.0,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        title: Row(

          children: [PopupMenuButton<MenuItem>(
            onSelected: (value) {
              if (value == MenuItem.item1) {
                _deleteAllListTodos();
              }
              if (value == MenuItem.item2) {
                _signUserOut();
              }
              if (value == MenuItem.item3) {}
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
              padding: const EdgeInsets.symmetric(horizontal: 5,vertical: 10),
              child: Icon(
                Icons.settings,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ),
            const SizedBox(width: 70,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Todo',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary)),
                const SizedBox(width: 10),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 45,
                      child: CircleProgressBar(
                        foregroundColor:
                            Theme.of(context).colorScheme.secondary,
                        backgroundColor: Theme.of(context).colorScheme.tertiary,
                        value: _todos.isEmpty
                            ? 0.0
                            : _todos
                                    .where((task) => task['taskCompleted'])
                                    .length /
                                _todos.length,
                        animationDuration: const Duration(seconds: 1),
                      ),
                    ),
                    FutureBuilder<int>(
                      future: _getSelectedListIcon(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        } else if (snapshot.hasData && snapshot.data != null) {
                          return Icon(
                            IconData(snapshot.data!,
                                fontFamily: 'MaterialIcons'),
                            size: 20,
                          );
                        } else {
                          return const Icon(
                            Icons.view_list_rounded,
                            size: 20,
                          );
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(width: 10),
                Text('Listo',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary)),
              ],
            ),

          ],
        ),
      ),
      floatingActionButton: SizedBox(
        height: 60,
        width: 140,
        child: FloatingActionButton.extended(
          elevation: 0,
          onPressed: _createTodo,
          backgroundColor: Theme.of(context).colorScheme.primary,
          shape: StadiumBorder(
              side: BorderSide(
                  color: Theme.of(context).iconTheme.color!, width: 2)),
          label: Text(
            "Add Todo",
            style: TextStyle(
                color: Theme.of(context).iconTheme.color,
                fontWeight: FontWeight.bold,
                fontSize: 16),
          ),
          icon: Icon(Icons.add,
              color: Theme.of(context).iconTheme.color, size: 30),
        ),
      ),
      body: Container(
        color: Theme.of(context).colorScheme.background,
        child: ListView.builder(
          itemCount: _todos.length,
          itemBuilder: (context, index) {
            final task = _todos[index];

            return ValueListenableBuilder<bool>(
              valueListenable: _taskCompletionNotifiers[index],
              builder: (context, value, _) {
                return ToDoTile(
                  key: ValueKey(task['documentId']),
                  taskName: task['taskName'] as String,
                  taskCompleted: value,
                  onChanged: (newValue) => _checkBoxChanged(newValue, index),
                  deleteFunction: (context) => _deleteTodo(index),
                  onTaskNameChanged: (newTaskName) =>
                      _updateTodoName(task['documentId'], newTaskName),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
