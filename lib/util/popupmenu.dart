import 'package:flutter/material.dart';
import 'MenuItem.dart';

class MyPopupMenu extends StatelessWidget {
  final Function(MyMenuItem) onMenuItemSelected;

  const MyPopupMenu({super.key, required this.onMenuItemSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).colorScheme.primary,
      ),
      child: PopupMenuButton<MyMenuItem>(
        onSelected: onMenuItemSelected,
        color: Theme.of(context).colorScheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(
              color: Theme.of(context).colorScheme.secondary, width: 2),
        ),
        itemBuilder: (context) => [
          PopupMenuItem(
            value: MyMenuItem.item1,
            child: Row(
              children: [
                const Icon(Icons.delete),
                const SizedBox(width: 10),
                Text(
                  "Delete all",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuItem(
            value: MyMenuItem.item2,
            child: Row(
              children: [
                const SizedBox(width: 5),
                const Icon(Icons.logout),
                const SizedBox(width: 5),
                Text(
                  "Logout",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Icon(
            Icons.settings,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
      ),
    );
  }
}
