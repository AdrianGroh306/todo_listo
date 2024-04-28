// Dart imports
import 'dart:async';

// Package imports
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Local imports

import '../util/MenuItem.dart';
import '../util/addTodo_box.dart';
import '../util/myTodoTile.dart';
import '../util/my_app_bar.dart';
import '../util/popupmenu.dart';
import '../util/sideMenu_bar.dart';

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
  StreamSubscription<String?>? _currentSelectedListIdSubscription;



  @override
  void initState() {
    super.initState();
    _fetchDefaultListIfNeeded();
    _currentSelectedListIdSubscription = getCurrentSelectedListId().listen((selectedListId) {
      _selectedTaskListId = selectedListId;
      if (selectedListId != null) {
        _fetchTodos(_selectedTaskListId!);
      }
    });
  }

  @override
  void dispose() {
    _currentSelectedListIdSubscription?.cancel();
    _todoController.dispose();
    super.dispose();
  }
        void _fetchTodos(String listId) async {
        final userId = FirebaseAuth.instance.currentUser?.uid;
        if (userId != null) {
          try {
            final querySnapshot = await _firestoreDB
                .collection('todos')
                .where('userId', isEqualTo: userId)
                .where('listId', isEqualTo: listId)
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
          } catch (e) {
            print('[Error] Fetching Todos: $e');
          }
        }
      }

  // Save a new task to Firestore
  void _saveTodos(String? taskName) async {
    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;

      await for (final selectedListId in getCurrentSelectedListId()) {
        print(selectedListId);
        if (selectedListId != null && taskName != null) {
          DocumentReference docRef =
              await _firestoreDB.collection('todos').add({
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
          break; // Dies beendet die Schleife nach dem ersten erfolgreichen Speichern
        }
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
        return SingleChildScrollView(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: DialogBox(
            controller: _todoController,
            onSave: _saveTodos,
            onCancel: () {
              Navigator.of(context).pop();
              _todoController.clear();
            },
            onSubmitted: _saveTodos,
          ),
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
      final selectedListId = await getCurrentSelectedListId().first;
      final snapshot = await _firestoreDB
          .collection('todos')
          .where('userId', isEqualTo: userId)
          .where('listId', isEqualTo: selectedListId)
          .get();

      await Future.wait(snapshot.docs.map((doc) => doc.reference.delete()));

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

  Stream<int> getSelectedListIcon() async* {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      try {
        final selectedListIdStream = getCurrentSelectedListId();
        await for (final selectedListId in selectedListIdStream) {
          if (selectedListId != null) {
            final selectedListDoc = await FirebaseFirestore.instance
                .collection('lists')
                .doc(selectedListId)
                .get();
            final selectedListData = selectedListDoc.data();
            if (selectedListData != null) {
              // Ensure that the yielded value is an int.
              int? listIcon = selectedListData['listIcon'] as int?;
              yield listIcon ?? 0;
            } else {
              yield 0;
            }
          } else {
            yield 0;
          }
        }
      } catch (e) {
        print('[Error] Getting selected list icon: $e');
        yield 0;
      }
    }
  }

  Stream<String?> getSelectedListName() async* {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      try {
        final selectedListIdStream = getCurrentSelectedListId();
        await for (final selectedListId in selectedListIdStream) {
          if (selectedListId != null) {
            final selectedListDoc = await FirebaseFirestore.instance
                .collection('lists')
                .doc(selectedListId)
                .get();
            final selectedListData = selectedListDoc.data();
            if (selectedListData != null) {
              // Ensure that the yielded value is an int.
              String? listName = selectedListData['listName'] as String?;
              yield listName;
            } else {
              yield "";
            }
          } else {
            yield "";
          }
        }
      } catch (e) {
        print('[Error] Getting selected list icon: $e');
        yield "";
      }
    }
  }

  Stream<String?> getCurrentSelectedListId() async* {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      try {
        await for (final userSnapshot in FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .snapshots()) {
          final userData = userSnapshot.data();
          if (userData != null) {
            final selectedListId = userData['selectedListId'] as String?;
            yield selectedListId;
          } else {
            final lists = userData?['lists'] as List<dynamic>;
            if (lists.isNotEmpty) {
              final topListId = lists[0]['listId'] as String?;
              yield topListId;
            } else {
              yield null;
            }
          }
        }
      } catch (e) {
        print('[Error] Getting current selectedListId: $e');
        yield null;
      }
    } else {
      yield null;
    }
  }

  Stream<int?> selectedListColorStream() async* {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    try {
      final selectedListIdStream = getCurrentSelectedListId();
      await for (final selectedListId in selectedListIdStream) {
        if (selectedListId != null) {
          final selectedListDoc = await FirebaseFirestore.instance
              .collection('lists')
              .doc(selectedListId)
              .get();
          final selectedListData = selectedListDoc.data();
          if (selectedListData != null) {
            int? listColor = selectedListData['listColor'] as int?;
            yield listColor;
          } else {
            yield null;
          }
        } else {
          yield null;
        }
      }
    } catch (e) {
      print('[Error] Getting selected list color: $e');
      yield null;
    }
  }

  void _fetchDefaultListIfNeeded() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      final querySnapshot = await _firestoreDB
          .collection('lists')
          .where('userId', isEqualTo: userId)
          .get();

      if (querySnapshot.docs.isEmpty) {
        // Create the default list "TodoListo" with blue color, timestamp, and icon.
        final docRef = await _firestoreDB.collection('lists').add({
          'createdAt': Timestamp.now(),
          'userId': userId,
          'listName': 'TodoListo',
          'listIcon': Icons.check.codePoint, // Icon code for check
          'listColor': Colors.blue.value, // Blue color value
        });

        // Set the newly created list as the selected list for the user.
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .set({'selectedListId': docRef.id}, SetOptions(merge: true));

        // Update the _selectedTaskListId variable with the new list ID.
        setState(() {
          _selectedTaskListId = docRef.id;
        });

        // Fetch the list of todos for the new selected list.
        _fetchTodos(_selectedTaskListId!);
      }
    }
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
            _fetchTodos(_selectedTaskListId!);
          });
        },
      ),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: MyAppBar(
          todos: _todos,
          selectedListColorStream: selectedListColorStream(),
          selectedListIconStream:
              getSelectedListIcon(), // Pass the selected list's icon
          selectedListNameStream:
              getSelectedListName(), // Pass the selected list's name
        ),
      ),
      floatingActionButton: SizedBox(
        height: 50,
        width: 140,
        child: FloatingActionButton.extended(
          elevation: 0,
          onPressed: _createTodo,
          backgroundColor: Theme.of(context).colorScheme.primary,
          label: Text(
            "Add Todo",
            style: TextStyle(
              color: Theme.of(context).iconTheme.color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          icon: Icon(
            Icons.add,
            color: Theme.of(context).iconTheme.color,
            size: 28,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20), // Anpassen des Radius nach Bedarf
          ),
        ),
      ),

      body: Stack(
        children: [
          RefreshIndicator(
            color: Theme.of(context).colorScheme.secondary,
            onRefresh: () async {
              _fetchTodos(_selectedTaskListId!);
            },
            child: Container(
              color: Theme.of(context).colorScheme.background,
              child: _todos.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons
                                .tag_faces, // Ändern Sie dies auf das gewünschte Icon
                            size: 50,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(height: 15),
                          Text(
                            "Add a Todo +",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Padding(
                    padding: const EdgeInsets.only(bottom: 75),

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
                                onChanged: (newValue) =>
                                    _checkBoxChanged(newValue, index),
                                deleteFunction: (context) => _deleteTodo(index),
                                onTaskNameChanged: (newTaskName) =>
                                    _updateTodoName(
                                        task['documentId'], newTaskName),
                              );
                            },
                          );
                        },
                      ),
                  ),

            ),
          ),

          MyPopupMenu(
            onMenuItemSelected: (menuItem) {
              if (menuItem == MenuItem.item1) {
                _deleteAllListTodos();
              } else if (menuItem == MenuItem.item2) {
                _signUserOut();
              }
            },
          ),
        ],
      ),
    );
  }
}
