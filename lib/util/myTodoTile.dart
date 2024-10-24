import 'package:TodoListo/util/myButton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

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
  final FocusNode _focusNode = FocusNode(); // FocusNode hinzufügen

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.taskName);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose(); // FocusNode freigeben
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
                      _showEditDialog(context);
                    },
                    child: Text(
                      widget.taskName,
                      style: TextStyle(
                        fontSize: 18,
                        color: widget.taskCompleted ? Colors.grey : Colors.white,
                        decoration: widget.taskCompleted
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                      maxLines: 2,
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

  void _showEditDialog(BuildContext context) {
    SmartDialog.show(
      alignment: Alignment.center,
      useAnimation: false,
      builder: (context) {
        // Verzögerung, um sicherzustellen, dass das Textfeld den Fokus erhält
        Future.delayed(Duration.zero, () {
          _focusNode.requestFocus(); // Fokus setzen
        });
        return Container(
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Theme.of(context).colorScheme.secondary,
              width: 2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Edit Todo",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _controller,
                focusNode: _focusNode, // FocusNode zuweisen
                autofocus: true,
                cursorColor: Theme.of(context).colorScheme.secondary,
                style: TextStyle(
                  decoration: TextDecoration.none,
                  decorationThickness: 0,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  enabledBorder: InputBorder.none,
                  hintText: "Todo...",
                  hintStyle: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    widget.taskName = value;
                  });
                },
                onSubmitted: (value) {
                  widget.updateTaskName(value);
                  SmartDialog.dismiss();
                },
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  MyButton(
                    text: "Back",
                    onPressed: () {
                      SmartDialog.dismiss();
                    },
                    color: Theme.of(context).colorScheme.primary,
                    textColor: Theme.of(context).colorScheme.secondary,
                    borderRadius: 15,
                  ),
                  const SizedBox(width: 70),
                  MyButton(
                    text: "Save",
                    onPressed: () {
                      widget.updateTaskName(_controller.text);
                      SmartDialog.dismiss();
                    },
                    color: Theme.of(context).colorScheme.secondary,
                    textColor: Theme.of(context).colorScheme.primary,
                    borderRadius: 15,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
