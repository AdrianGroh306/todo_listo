import 'package:circle_progress_bar/circle_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../states/todo_state.dart';
import '../states/list_state.dart';

class MyAppBar extends StatelessWidget {
  const MyAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final listState = Provider.of<ListState>(context);
    final todoState = Provider.of<TodoState>(context);

    final selectedListName = listState.selectedListName;
    final selectedListIcon = listState.selectedListIcon;
    final selectedListColor = listState.selectedListColor;

    // Ladezustand behandeln
    if (selectedListName == null || selectedListIcon == null || selectedListColor == null) {
      return AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text('Loading...'),
      );
    }

    // Fortschritt basierend auf allen Todos berechnen
    final allTodos = todoState.allTodos;
    final totalTodos = allTodos.length;
    final completedTodos = allTodos.where((todo) => todo['taskCompleted'] == true).length;
    final progressValue = totalTodos == 0 ? 0.0 : completedTodos / totalTodos;

    return AppBar(
      elevation: 0,
      backgroundColor: Theme.of(context).colorScheme.surface,
      title: Row(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 45,
                    child: CircleProgressBar(
                      foregroundColor: Theme.of(context).colorScheme.secondary,
                      backgroundColor: Theme.of(context).colorScheme.tertiary,
                      value: progressValue,
                      animationDuration: const Duration(seconds: 1),
                    ),
                  ),
                  Icon(
                    IconData(selectedListIcon, fontFamily: 'MaterialIcons'),
                    size: 22,
                    color: Color(selectedListColor),
                  ),
                ],
              ),
              const SizedBox(width: 10),
              Text(
                selectedListName,
                style: TextStyle(
                  color: Color(selectedListColor),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


class CircularProgressWidget extends StatelessWidget {
  final List<Map<String, dynamic>> todos;
  const CircularProgressWidget({super.key, required this.todos});

  @override
  Widget build(BuildContext context) {
    final totalTodos = todos.length;
    final completedTodos =
        todos.where((todo) => todo['taskCompleted'] == true).length;
    final progressValue = totalTodos == 0 ? 0.0 : completedTodos / totalTodos;

    return CircleProgressBar(
      foregroundColor: Theme.of(context).colorScheme.secondary,
      backgroundColor: Theme.of(context).colorScheme.tertiary,
      value: progressValue,
      animationDuration: const Duration(seconds: 1),
    );
  }
}
