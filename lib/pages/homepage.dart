// File: lib/pages/homepage.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../states/list_state.dart';
import '../states/todo_state.dart';
import '../states/auth_state.dart';
import '../util/MenuItem.dart';
import '../util/addTodo_box.dart';
import '../util/myTodoTile.dart';
import '../util/my_app_bar.dart';
import '../util/popupmenu.dart';
import '../util/sideMenu_bar.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int? editingIndex;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final listState = Provider.of<ListState>(context, listen: false);
      final todoState = Provider.of<TodoState>(context, listen: false);

      try {
        await listState.fetchOrCreateDefaultList();
        if (listState.selectedListId != null) {
          await todoState.fetchTodos(listState.selectedListId!);
        }
      } catch (error) {
        print('Error loading lists: $error');
      }
    });
  }

  void startEditing(int index) {
    setState(() {
      editingIndex = index;
    });
  }

  void stopEditing() {
    setState(() {
      editingIndex = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final todoState = Provider.of<TodoState>(context);
    final authState = Provider.of<AuthState>(context, listen: false);
    final listState = Provider.of<ListState>(context);

    if (listState.isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      );
    }

    void handleSignOut(BuildContext context) {
      authState.signOutUser();
      listState.resetState();
      todoState.resetState();
      Navigator.of(context).pushReplacementNamed('/login');
    }

    final currentList = listState.lists.firstWhere(
          (list) => list['documentId'] == listState.selectedListId,
      orElse: () => {},
    );
    final listColor = currentList.isNotEmpty
        ? Color(currentList['listColor'])
        : Colors.grey;

    Future<void> handleListSelection(String? listId) async {
      if (listId == null) return;
      await listState.setSelectedList(listId);
      await todoState.fetchTodos(listId);
    }

    return GestureDetector(
      onTap: stopEditing,
      behavior: HitTestBehavior.translucent,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        resizeToAvoidBottomInset: false,
        extendBodyBehindAppBar: false,
        endDrawer: SideMenu(
          onSelectedListChanged: handleListSelection,
        ),
        appBar: const MyAppBar(),
        body: Stack(
          children: [
            RefreshIndicator(
              color: Theme.of(context).colorScheme.secondary,
              onRefresh: () async {
                if (todoState.selectedListId != null) {
                  await todoState.fetchTodos(todoState.selectedListId!);
                }
              },
              child: Container(
                color: Theme.of(context).colorScheme.scrim,
                child: todoState.todos.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.tag_faces,
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
                    : ReorderableListView(
                  onReorder: (oldIndex, newIndex) {
                    todoState.reorderTodos(oldIndex, newIndex);
                  },
                  buildDefaultDragHandles: false,
                  padding: const EdgeInsets.only(bottom: 75),
                  children: [
                    for (int index = 0; index < todoState.todos.length; index++)
                      _buildTodoTile(context, index, todoState),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 65,
              left: 0,
              right: 0,
              child: Container(
                height: 12,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context)
                          .colorScheme
                          .surface
                          .withOpacity(0.8),
                      Theme.of(context)
                          .colorScheme
                          .surface
                          .withOpacity(0.0),
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: 65,
                color: Theme.of(context).colorScheme.surface,
              ),
            ),
            Stack(
              children: [
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 25),
                    child: Container(
                      height: 50,
                      width: 140,
                      decoration: BoxDecoration(
                        border: Border.all(color: listColor, width: 2),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: FloatingActionButton.extended(
                        elevation: 0,
                        onPressed: () {
                          _createTodoDialog(context, todoState);
                        },
                        backgroundColor:
                        Theme.of(context).colorScheme.primary,
                        label: Text(
                          "Add Todo",
                          style: TextStyle(
                            color:
                            Theme.of(context).iconTheme.color,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        icon: Icon(
                          Icons.add,
                          color:
                          Theme.of(context).iconTheme.color,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding:
                    const EdgeInsets.only(bottom: 12, right: 15),
                    child: FloatingActionButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                      ),
                      elevation: 0,
                      mini: true,
                      onPressed: todoState.toggleVisibility,
                      child: Icon(
                        todoState.showCompletedTodos
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Theme.of(context).iconTheme.color,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 0,
              left: 0,
              child: Padding(
                padding: const EdgeInsets.only(left: 15, bottom: 12),
                child: MyPopupMenu(
                  onMenuItemSelected: (menuItem) {
                    if (menuItem == MyMenuItem.item1) {
                      todoState.deleteAllTodos();
                    } else if (menuItem == MyMenuItem.item2) {
                      handleSignOut(context);
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodoTile(
      BuildContext context, int index, TodoState todoState) {
    final task = todoState.todos[index];

    return Container(
      key: ValueKey(task['documentId']),
      color: Colors.transparent,
      child: ToDoTile(
        taskName: task['taskName'] as String,
        taskCompleted: task['taskCompleted'] as bool,
        onChanged: (newValue) => todoState
            .updateTaskCompletionStatus(task['documentId'], newValue ?? false),
        deleteFunction: (context) =>
            todoState.deleteTodo(task['documentId']),
        onTaskNameChanged: (newTaskName) =>
            todoState.updateTodoName(task['documentId'], newTaskName),
        isEditing: editingIndex == index,
        onEdit: () => startEditing(index),
        trailing: ReorderableDragStartListener(
          index: index,
          child: Icon(
            Icons.drag_handle,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }

  void _createTodoDialog(BuildContext context, TodoState todoState) {
    final TextEditingController _todoController = TextEditingController();

    DialogBox(
      controller: _todoController,
      onSave: (taskName) {
        if (taskName != null && taskName.trim().isNotEmpty) {
          todoState.addTodo(todoState.selectedListId, taskName.trim());
        }
      },
      onCancel: () {
        _todoController.clear();
      },
      onSubmitted: (taskName) {
        if (taskName != null && taskName.trim().isNotEmpty) {
          todoState.addTodo(todoState.selectedListId, taskName.trim());
        }
      },
    ).show(context);
  }
}
