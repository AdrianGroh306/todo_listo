import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class ToDoTile extends StatefulWidget {
  final String taskName;
  final bool taskCompleted;
  final Function(bool?) onChanged;
  final Function(BuildContext) deleteFunction;
  final Function(String) onTaskNameChanged;
  final Widget? trailing;
  final bool isEditing;
  final VoidCallback onEdit;

  const ToDoTile({
    super.key,
    required this.taskName,
    required this.taskCompleted,
    required this.onChanged,
    required this.deleteFunction,
    required this.onTaskNameChanged,
    required this.isEditing,
    required this.onEdit,
    this.trailing,
  });

  @override
  _ToDoTileState createState() => _ToDoTileState();
}

class _ToDoTileState extends State<ToDoTile> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.taskName);
    _focusNode = FocusNode();

    if (widget.isEditing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNode.requestFocus();
      });
    }
  }

  @override
  void didUpdateWidget(ToDoTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isEditing && !oldWidget.isEditing) {
      _focusNode.requestFocus();
    } else if (!widget.isEditing && oldWidget.isEditing) {
      _focusNode.unfocus();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _saveTaskName() {
    String newTaskName = _controller.text.trim();
    if (newTaskName.isNotEmpty) {
      widget.onTaskNameChanged(newTaskName);
    } else {
      widget.deleteFunction(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: widget.onEdit,
      child: Slidable(
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          children: [
            SlidableAction(
              onPressed: widget.deleteFunction,
              icon: Icons.delete,
              backgroundColor: theme.colorScheme.error,
              borderRadius: BorderRadius.circular(15),
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.only(left: 15, right: 25),
            leading: Transform.scale(
              scale: 1.3,
              child: Checkbox(
                value: widget.taskCompleted,
                onChanged: widget.onChanged,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                side: BorderSide(
                  color: widget.taskCompleted
                      ? colorScheme.secondary
                      : colorScheme.secondary,
                  width: 2,
                ),
                checkColor: colorScheme.surface,
                fillColor: WidgetStateProperty.resolveWith<Color?>(
                      (Set<WidgetState> states) {
                    if (states.contains(WidgetState.selected)) {
                      return colorScheme.primary;
                    }
                    return Colors.transparent;
                  },
                ),
              ),
            ),
            title: widget.isEditing
                ? TextField(
              controller: _controller,
              focusNode: _focusNode,
              autofocus: true,
              onSubmitted: (value) {
                _saveTaskName();
              },
              decoration: InputDecoration(
                hintText: 'Enter todo',
                hintStyle: TextStyle(
                  color: colorScheme.onSurface,
                ),
                border: const UnderlineInputBorder(),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: colorScheme.secondary),
                ),
              ),
            )
                : Text(
              widget.taskName,
              style: TextStyle(
                decoration: widget.taskCompleted
                    ? TextDecoration.lineThrough
                    : null,
                color: widget.taskCompleted
                    ? colorScheme.onSurface
                    : colorScheme.secondary,
              ),
            ),
            trailing: widget.trailing ?? Container(width: 0),
          ),
        ),
      ),
    );
  }
}
