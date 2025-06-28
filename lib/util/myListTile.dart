import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class MyListTile extends StatelessWidget {
  final String listName;
  final Color listColor;
  final bool isSelected;
  final IconData iconData;
  final VoidCallback onTap;
  final Function onDelete;
  final VoidCallback onEdit;

  const MyListTile({
    super.key,
    required this.listName,
    required this.listColor,
    required this.isSelected,
    required this.iconData,
    required this.onTap,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
      child: Slidable(
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          children: [
            SlidableAction(
              onPressed: (context) {
                deleteList();
              },
              icon: Icons.delete,
              backgroundColor: Theme.of(context).colorScheme.error,
              borderRadius: BorderRadius.circular(15),
            )
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected
                  ? Theme.of(context).colorScheme.secondary
                  : Colors.transparent,
              width: 2,
            ),
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              const SizedBox(width: 10),
              Icon(
                iconData,
                size: 25,
                color: listColor,
              ),
              Expanded(
                child: ListTile(
                  title: Text(
                    listName,
                    style: TextStyle(
                      color: listColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: onTap,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_note),
                color: Theme.of(context).colorScheme.secondary,
                onPressed: onEdit,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void deleteList() {
    onDelete();
  }
}
