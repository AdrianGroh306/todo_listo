import 'package:circle_progress_bar/circle_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../states/todo_state.dart';
import '../states/list_state.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MyAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return Consumer2<ListState, TodoState>(
      builder: (context, listState, todoState, child) {
        final selectedListName = listState.selectedListName;
        final selectedListIcon = listState.selectedListIcon;
        final selectedListColor = listState.selectedListColor;

        if (selectedListName == null ||
            selectedListIcon == null ||
            selectedListColor == null) {
          return AppBar(
            elevation: 0,
            backgroundColor: Theme.of(context).colorScheme.surface,
            title: const Text('TodoListo'),
          );
        }

        final allTodos = todoState.allTodos;
        final totalTodos = allTodos.length;
        final completedTodos =
            allTodos.where((todo) => todo['taskCompleted'] == true).length;
        final progressValue = totalTodos == 0 ? 0.0 : completedTodos / totalTodos;

        return AppBar(
          iconTheme: IconThemeData(color: Theme.of(context).colorScheme.secondary),
          elevation: 0,
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Row(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 45,
                    child: CircleProgressBar(
                      foregroundColor:
                      Theme.of(context).colorScheme.secondary,
                      backgroundColor:
                      Theme.of(context).colorScheme.tertiary,
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
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
