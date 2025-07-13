import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../states/todo_state.dart';
import '../util/my_todo_tile.dart';

class CompletedTodosPage extends StatelessWidget {
  const CompletedTodosPage({super.key});

  void _showDeleteCompletedDialog(BuildContext context, TodoState todoState) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          'Delete all completed items?',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'This will permanently delete all completed items.',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await todoState.deleteCompletedTodos();
              HapticFeedback.mediumImpact();
              // Go back to main page if no completed todos left
              if (todoState.completedTodos.isEmpty) {
                Navigator.of(context).pop();
              }
            },
            child: Text(
              'Delete All',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Consumer<TodoState>(
          builder: (context, todoState, child) {
            final completedCount = todoState.completedTodos.length;
            return Text(
              'Completed $completedCount',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            );
          },
        ),
        actions: [
          Consumer<TodoState>(
            builder: (context, todoState, child) {
              final completedTodos = todoState.completedTodos;
              if (completedTodos.isEmpty) return const SizedBox.shrink();
              
              return IconButton(
                onPressed: () => _showDeleteCompletedDialog(context, todoState),
                icon: const Icon(Icons.delete_sweep),
                tooltip: 'Delete all completed',
                color: Colors.red[400],
              );
            },
          ),
        ],
      ),
      body: Consumer<TodoState>(
        builder: (context, todoState, child) {
          final completedTodos = todoState.completedTodos;

          if (completedTodos.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No completed items',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Completed todos will appear here',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: completedTodos.length,
            itemBuilder: (context, index) {
              final todo = completedTodos[index];
              return ToDoTile(
                key: ValueKey(todo['documentId']),
                taskName: todo['taskName'],
                taskCompleted: true,
                quickToggle: true,
                isEditing: false,
                onEdit: null,
                onChanged: (value) {
                  todoState.toggleTodoCompletion(todo['documentId']);
                },
                deleteFunction: (context) {
                  todoState.deleteTodo(todo['documentId']);
                },
                onTaskNameChanged: null,
              );
            },
          );
        },
      ),
    );
  }
}
