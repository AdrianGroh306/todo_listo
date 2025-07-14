import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../states/list_state.dart';
import '../states/todo_state.dart';
import '../util/my_todo_tile.dart';
import '../util/smart_add_dialog.dart';
import '../util/my_app_bar.dart';
import '../util/side_menu_bar.dart';
import 'completed_todos_page.dart';

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
      
      if (listState.selectedListId == null) {
        await listState.fetchOrCreateDefaultList();
        // After creating/fetching default list, load todos
        if (listState.selectedListId != null) {
          todoState.fetchTodos(listState.selectedListId!);
        }
      } else {
        // Load todos for the already selected list
        todoState.fetchTodos(listState.selectedListId!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      endDrawer: SideMenu(
        onSelectedListChanged: (listId) {
          if (listId != null) {
            final todoState = Provider.of<TodoState>(context, listen: false);
            todoState.fetchTodos(listId);
          }
        },
      ),
      appBar: const MyAppBar(),
      body: Consumer2<ListState, TodoState>(
        builder: (context, listState, todoState, child) {
          final incompleteTodos = todoState.incompleteTodos;
          
          if (listState.selectedListId == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final listColor = Color(listState.selectedListColor ?? Colors.blue.value);
          final completedTodos = todoState.completedTodos;

          return Stack(
            children: [
              // Todo Liste nimmt den ganzen Platz ein
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 100), // Platz für die Buttons
                  child: incompleteTodos.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.checklist,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'List is empty',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tap "Add Item" to get started',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: incompleteTodos.length,
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ), // Immer scrollbar für bessere UX
                          itemBuilder: (context, index) {
                            final todo = incompleteTodos[index];
                            return ToDoTile(
                              taskName: todo['taskName'],
                              taskCompleted: todo['taskCompleted'],
                              isEditing: editingIndex == index,
                              onEdit: () {
                                setState(() {
                                  editingIndex = editingIndex == index ? null : index;
                                });
                              },
                              onChanged: (value) {
                                todoState.toggleTodoCompletion(todo['documentId']);
                              },
                              deleteFunction: (context) {
                                todoState.deleteTodo(todo['documentId']);
                                setState(() {
                                  editingIndex = null;
                                });
                              },
                              onTaskNameChanged: (newName) {
                                todoState.updateTodo(todo['documentId'], newName);
                                setState(() {
                                  editingIndex = null;
                                });
                              },
                            );
                          },
                        ),
                ),
              ),
              
              // Floating Action Buttons am unteren Rand - 25px über dem Boden
              Positioned(
                bottom: 25,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // View Completed Button (links, kleiner, rund)
                      if (completedTodos.isNotEmpty)
                        SizedBox(
                          width: 48,
                          height: 48,
                          child: FloatingActionButton(
                            heroTag: "viewCompletedButton",
                            elevation: 0,
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const CompletedTodosPage(),
                                ),
                              );
                            },
                            backgroundColor: Theme.of(context).colorScheme.surface,
                            foregroundColor: Colors.grey[600],
                            shape: CircleBorder(
                              side: BorderSide(color: Colors.grey[400]!, width: 1),
                            ),
                            child: Icon(Icons.visibility, size: 20, color: Colors.grey[600]),
                          ),
                        ),
                      // Spacer zwischen den Buttons
                      if (completedTodos.isNotEmpty) const SizedBox(width: 16),
                      // Add Item Button (rechts, größer)
                      SizedBox(
                        width: 140,
                        height: 48,
                        child: FloatingActionButton.extended(
                          heroTag: "addButton",
                          elevation: 0,
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (context) {
                                return Padding(
                                  padding: MediaQuery.of(context).viewInsets,
                                  child: SmartAddBottomSheet(
                                    onSave: (taskName) {
                                      if (taskName.isNotEmpty) {
                                        todoState.addTodo(taskName, listState.selectedListId!);
                                      }
                                      Navigator.of(context).pop();
                                    },
                                    onCancel: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                );
                              },
                            );
                          },
                          backgroundColor: Theme.of(context).colorScheme.surface,
                          foregroundColor: listColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                            side: BorderSide(color: listColor, width: 2),
                          ),
                          icon: Icon(Icons.add, color: listColor),
                          label: Text(
                            'Add Item',
                            style: TextStyle(
                              color: listColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
