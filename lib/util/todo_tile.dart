import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:auto_size_text/auto_size_text.dart';

class ToDoTile extends StatefulWidget {
  String taskName;
  final bool taskCompleted;
  Function(bool?)? onChanged;
  Function(BuildContext)? deleteFunction;

  ToDoTile({
    super.key,
    required this.taskName,
    required this.taskCompleted,
    required this.onChanged,
    required this.deleteFunction,
  });

  @override
  State<ToDoTile> createState() => _ToDoTileState();
}

class _ToDoTileState extends State<ToDoTile> {
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(left: 15, right: 15, top: 10),
        child: Slidable(
          endActionPane: ActionPane(
            motion: const DrawerMotion(),
            children: [
              SlidableAction(
                onPressed: widget.deleteFunction,
                icon: Icons.delete,
                backgroundColor: Colors.red,
                borderRadius: BorderRadius.circular(15),
              )
            ],
          ),
          child: Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.indigo[700],
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                Transform.scale(
                  scale: 1.2,
                  child: Checkbox(
                    value: widget.taskCompleted,
                    onChanged: widget.onChanged,
                    activeColor: Colors.black54,

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
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        String newTaskName = widget.taskName;
                        return AlertDialog(
                          title: const Text("Edit task name"),
                          content: TextField(
                            autofocus: true,
                            decoration: InputDecoration(
                              labelText: "Task name",
                              hintText: newTaskName,
                            ),
                            onChanged: (value) {
                              newTaskName = value;
                            },
                          ),
                          actions: <Widget>[
                            TextButton(
                              child: const Text("CANCEL"),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            TextButton(
                              child: const Text("SAVE"),
                              onPressed: () {
                                setState(() {
                                  widget.taskName = newTaskName;
                                });
                                Navigator.of(context).pop();
                              },

                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Flexible(
                    child: AutoSizeText(
                      widget.taskName,
                      style: TextStyle(
                        fontSize: 22,
                        color:  widget.taskCompleted ? Colors.grey : Colors.white,
                        decoration: widget.taskCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                      ),
                      maxLines: 2,
                      minFontSize: 15,
                    ),
                  ),
                )
              ],
            ),
          ),
        ));
  }
}
