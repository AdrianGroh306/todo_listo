import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'myButton.dart';

// ignore: must_be_immutable
class ToDoTile extends StatefulWidget {
  String taskName;
  final bool taskCompleted;
  Function(bool?)? onChanged;
  Function(BuildContext)? deleteFunction;
  final ValueChanged<String>? onTaskNameChanged;
  final Widget? trailing;

  ToDoTile({
    super.key,
    required this.taskName,
    required this.taskCompleted,
    required this.onChanged,
    required this.deleteFunction,
    this.onTaskNameChanged,
    this.trailing,
  });

  void updateTaskName(String newTaskName) {
    if (onTaskNameChanged != null) {
      onTaskNameChanged!(newTaskName);
    }
  }

  @override
  State<ToDoTile> createState() => _ToDoTileState();
}

class _ToDoTileState extends State<ToDoTile> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.taskName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 15, top: 5),
      child: Slidable(
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          children: [
            SlidableAction(
              onPressed: widget.deleteFunction,
              icon: Icons.delete,
              backgroundColor: Theme.of(context).colorScheme.error,
              borderRadius: BorderRadius.circular(15),
            )
          ],
        ),
        child: SizedBox(
          height: 50,
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                Transform.scale(
                  scale: 1.2,
                  child: Checkbox(
                    value: widget.taskCompleted,
                    onChanged: widget.onChanged,
                    activeColor: Theme.of(context).colorScheme.tertiary,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(5),
                        bottomRight: Radius.circular(5),
                        topLeft: Radius.circular(5),
                        topRight: Radius.circular(5),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          String newTaskName = widget.taskName;
                          return AlertDialog(
                            backgroundColor: Theme.of(context).colorScheme.surface,
                            contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            title: Center(
                              child: Text(
                                "Edit Todo",
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            content: TextField(
                              style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.secondary),
                              controller: _controller,
                              autofocus: true,
                              cursorColor:
                                  Theme.of(context).colorScheme.secondary,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide(
                                      color: Theme.of(context).colorScheme.primary,
                                      width: 2),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      width: 2),
                                ),
                                hintText: "Todo...",
                              ),
                              onChanged: (value) {
                                newTaskName = value;
                              },
                            ),
                            actionsPadding:
                                const EdgeInsets.symmetric(horizontal: 20),
                            actions: <Widget>[
                              const SizedBox(
                                height: 20,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  MyButton(
                                    text: "Back",
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    textColor:
                                        Theme.of(context).colorScheme.secondary,
                                    borderRadius: 15,
                                  ),
                                  MyButton(
                                    text: "Save",
                                    onPressed: () {
                                      setState(() {
                                        widget.taskName = newTaskName;
                                      });

                                      widget.updateTaskName(newTaskName);

                                      Navigator.of(context).pop();
                                    },
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                    textColor:
                                        Theme.of(context).colorScheme.primary,
                                    borderRadius: 15,
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: Text(
                      widget.taskName,
                      style: TextStyle(
                        fontSize: 18,
                        color:
                            widget.taskCompleted ? Colors.grey : Colors.white,
                        decoration: widget.taskCompleted
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                      maxLines: 2,
                      // minFontSize: 15,
                    ),
                  ),
                ),
                if (widget.trailing != null) widget.trailing!,
                const SizedBox(
                  width: 10,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
