import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:auto_size_text/auto_size_text.dart';

import 'my_button.dart';

class ToDoTile extends StatefulWidget {
  String taskName;
  final bool taskCompleted;
  Function(bool?)? onChanged;
  Function(BuildContext)? deleteFunction;
  final ValueChanged<String>? onTaskNameChanged;

  ToDoTile({
    super.key,
    required this.taskName,
    required this.taskCompleted,
    required this.onChanged,
    required this.deleteFunction,
    this.onTaskNameChanged,
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
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            title: const Text("EDIT TASK",
                                style: TextStyle(color: Color(0xFF3F51B5))),
                            content: TextField(
                              controller: _controller,
                              autofocus: true,
                              cursorColor: Theme.of(context).colorScheme.primary,
                              decoration: InputDecoration(
                                hintText: newTaskName,
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                                ),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                                ),
                              ),
                              onChanged: (value) {
                                newTaskName = value;
                              },
                            ),
                            actions: <Widget>[
                              Row(
                                children: [
                                  MyButton(
                                    text: "Back",
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    color: Colors.white,
                                    textColor: Colors.indigo[700],
                                    borderRadius: 15,
                                  ),
                                  const SizedBox(width: 75),
                                  MyButton(
                                    text: "Save",
                                    onPressed: () {
                                      setState(() {
                                        widget.taskName = newTaskName;
                                      });

                                      widget.updateTaskName(newTaskName);

                                      Navigator.of(context).pop();
                                    },
                                    color: Colors.indigo[700],
                                    textColor: Colors.white,
                                    borderRadius: 15,
                                  ),
                                ],
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
                const Icon(
                  Icons.linear_scale_sharp,
                  color: Colors.white,
                ),
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
