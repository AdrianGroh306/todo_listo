import 'package:circle_progress_bar/circle_progress_bar.dart';
import 'package:flutter/material.dart';

final ValueNotifier<int> _selectedListIcon = ValueNotifier<int>(0);
final ValueNotifier<double> _circularProgressValue = ValueNotifier<double>(0.0);

class IconWidget extends StatelessWidget {
  const IconWidget({Key? key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: _selectedListIcon,
      builder: (context, iconValue, _) {
        return Icon(
          IconData(iconValue, fontFamily: 'MaterialIcons'),
          size: 20,
        );
      },
    );
  }
}

class CircularProgressWidget extends StatelessWidget {
  final List<Map<String, dynamic>> todos;
  const CircularProgressWidget({Key? key, required this.todos});

  @override
  Widget build(BuildContext context) {
    final totalTodos = todos.length;
    final completedTodos = todos.where((todo) => todo['taskCompleted'] == true).length;
    final progressValue = totalTodos == 0 ? 0.0 : completedTodos / totalTodos;

    // Aktualisieren Sie den Fortschrittswert
    _circularProgressValue.value = progressValue;

    return ValueListenableBuilder<double>(
      valueListenable: _circularProgressValue,
      builder: (context, progressValue, _) {
        return CircleProgressBar(
          foregroundColor: Theme.of(context).colorScheme.secondary,
          backgroundColor: Theme.of(context).colorScheme.tertiary,
          value: progressValue,
          animationDuration: const Duration(seconds: 1),
        );
      },
    );
  }
}

class MyAppBar extends StatefulWidget {
  final List<Map<String, dynamic>> todos;
  final Stream<int> selectedListIconStream;
  final Stream<String?> selectedListNameStream;

  const MyAppBar({
    Key? key,
    required this.selectedListIconStream,
    required this.selectedListNameStream,
    required this.todos,
  }) : super(key: key);

  @override
  _MyAppBarState createState() => _MyAppBarState();
}

class _MyAppBarState extends State<MyAppBar> {
  String? _selectedListName = "Todo Listo"; // Initialize with a default value

  @override
  void initState() {
    super.initState();

    widget.selectedListIconStream.listen((iconValue) {
      // Update the selected list icon
      _selectedListIcon.value = iconValue;
    });

    widget.selectedListNameStream.listen((listName) {
      // Update the selected list name
      setState(() {
        _selectedListName = listName;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Theme.of(context).colorScheme.background,
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
                    child: CircularProgressWidget(
                      todos: widget.todos,
                    ),
                  ),
                  const IconWidget(),
                ],
              ),
              const SizedBox(width: 10),
              Text(
                _selectedListName ?? "Todo Listo",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
