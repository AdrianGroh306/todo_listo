import 'package:flutter/material.dart';

class MyListTile extends StatelessWidget {
  final String listName;
  const MyListTile({Key? key, required this.listName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.indigo[700],
        borderRadius: BorderRadius.circular(8),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: <Widget>[
          IconButton(
            icon: const Icon(Icons.shopping_bag_outlined),
            color: Colors.white,
            onPressed: () {
              child:
              Table(
                children: [
                  TableRow(children: [
                    IconButton(onPressed: () {}, icon: Icon(Icons.work)),
                    IconButton(
                        onPressed: () {}, icon: Icon(Icons.photo_camera)),
                    IconButton(
                        onPressed: () {}, icon: Icon(Icons.photo_camera)),
                  ]),
                  TableRow(children: [
                    IconButton(onPressed: () {}, icon: Icon(Icons.work)),
                    IconButton(
                        onPressed: () {}, icon: Icon(Icons.photo_camera)),
                    IconButton(
                        onPressed: () {}, icon: Icon(Icons.photo_camera)),
                  ])
                ],
              );
            },
          ),
          Expanded(
            child: ListTile(
              title: Text(
                listName,
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
              onTap: () {
                // Handle list item tap
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_note),
            color: Colors.white,
            onPressed: () {
              // Handle IconButton 2 tap
            },
          ),
        ],
      ),
    );
  }
}
