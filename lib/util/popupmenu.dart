import 'package:flutter/material.dart';

import 'MenuItem.dart';

class MyPopupMenu extends StatelessWidget {
  final Function(MenuItem) onMenuItemSelected;

  MyPopupMenu({required this.onMenuItemSelected});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 20, // Adjust the position as needed
      left: 20, // Adjust the position as needed
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).colorScheme.primary,
        ),
        child: PopupMenuButton<MenuItem>(
          onSelected: onMenuItemSelected,
          color: Theme.of(context).colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: MenuItem.item1,
              child: Row(
                children: [
                  const Icon(Icons.delete),
                  const SizedBox(
                    width: 10,
                  ),
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
              value: MenuItem.item2,
              child: Row(
                children: [
                  const SizedBox(
                    width: 5,
                  ),
                  const Icon(Icons.logout),
                  const SizedBox(
                    width: 5,
                  ),
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
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
            child: Icon(
              Icons.settings,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
        ),
      ),
    );
  }
}
