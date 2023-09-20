import 'dart:async';
import 'package:circle_progress_bar/circle_progress_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:todo/util/addTodo_box.dart';
import 'package:todo/util/sideMenu_bar.dart';
import 'package:todo/util/todo_tile.dart';
import '../util/MenuItem.dart';

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
  String? selectedList;

  @override
  void initState() {
    super.initState();
    fetchTodosForSelectedList();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void fetchTodosForSelectedList() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        final querySnapshot = await _firestore
            .collection('todos')
            .where('userId', isEqualTo: userId)
            .where('listId', isEqualTo: selectedList)
            .get();

        setState(() {
          toDoList = querySnapshot.docs.map((doc) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            data['documentId'] = doc.id;
            return data;
          }).toList();

          taskCompletionList = toDoList.map((task) {
            return ValueNotifier<bool>(task['taskCompleted'] ?? false);
          }).toList();
        });
      }
    } catch (e) {
      print('Error fetching Todos for the selected list: $e');
    }
  }

  void saveNewTask(String? taskName) async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;

      if (selectedList != null) {
        DocumentReference docRef = await _firestore.collection('todos').add({
          'userId': userId,
          'listId': selectedList,
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
      }
    } catch (e) {
      print('Error saving task: $e');
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
      print('Error updating task completion status: $e');
      rethrow;
    }
  }

  void checkBoxChanged(bool? value, int index) async {
    if (index < 0 || index >= toDoList.length) {
      print('Error updating task: Invalid index.');
      return;
    }

    final task = toDoList[index];

    if (!task.containsKey('documentId')) {
      print('Error updating task: Document ID not found.');
      return;
    }

    final documentId = task['documentId'] as String;

    try {
      await _firestore.collection('todos').doc(documentId).update({
        'taskCompleted': value ?? false,
        'taskName': task['taskName'],
      });

      if (mounted) {
        setState(() {
          task['taskCompleted'] = value ?? false;
          taskCompletionList[index].value = value ?? false;
        });
      }
    } catch (e) {
      print('Error updating task: $e');
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

      setState(() {
        final index =
            toDoList.indexWhere((task) => task['documentId'] == documentId);
        if (index != -1) {
          toDoList[index]['taskName'] = newTaskName;
        }
      });
    } catch (e) {
      print('Error updating task name: $e');
    }
  }

  void deleteTask(int index) async {
    Map<String, dynamic> task = toDoList[index];

    if (!task.containsKey('documentId')) {
      print('Error deleting task: Document ID not found.');
      return;
    }

    String documentId = task['documentId'] as String;

    await _firestore.collection('todos').doc(documentId).delete();

    setState(() {
      toDoList.removeAt(index);
      taskCompletionList.removeAt(index);
    });
  }

  void deleteAllTask() async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;

      QuerySnapshot snapshot = await _firestore
          .collection('todos')
          .where('userId', isEqualTo: userId)
          .get();

      for (QueryDocumentSnapshot doc in snapshot.docs) {
        await doc.reference.delete();
      }

      setState(() {
        toDoList.clear();
        taskCompletionList.clear();
      });
    } catch (e) {
      print('Error deleting all tasks: $e');
    }
  }

  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      drawer: SideMenu(
        selectedListId: selectedList,
        onSelectedListChanged: (listId) {
          setState(() {
            selectedList = listId;
            fetchTodosForSelectedList();
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(),
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
                        value: toDoList.isEmpty
                            ? 0.0
                            : toDoList
                                    .where((task) => task['taskCompleted'])
                                    .length /
                                toDoList.length,
                        animationDuration: const Duration(seconds: 1),
                      ),
                    ),
                    const Icon(
                      Icons.view_list_rounded,
                      size: 20,
                    ),
                  ],
                ),
                const SizedBox(width: 10),
                Text('Listo',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary)),
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
                padding: const EdgeInsets.all(10),
                child: Icon(
                  Icons.more_vert,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: SizedBox(
        height: 60,
        width: 140,
        child: FloatingActionButton.extended(
          elevation: 0,
          onPressed: createTask,
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
