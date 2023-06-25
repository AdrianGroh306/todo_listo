import 'package:flutter/material.dart';

class MyListTile extends StatefulWidget {
  String listName;

  MyListTile({Key? key, required this.listName}) : super(key: key);

  @override
  _MyListTileState createState() => _MyListTileState();
}

class _MyListTileState extends State<MyListTile> {
  late TextEditingController _textEditingController;
  late String _updatedListName;

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController(text: widget.listName);
    _updatedListName = widget.listName;
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  void _handleEditTap() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(

          content: TextField(
            controller: _textEditingController,
            onChanged: (value) {
              setState(() {
                _updatedListName = value;
              });
            },
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, _updatedListName);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    ).then((value) {
      if (value != null) {
        setState(() {
          widget.listName = value;
        });
      }
    });
  }

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
              // Handle IconButton 1 tap
            },
          ),
          Expanded(
            child: ListTile(
              title: Text(
                widget.listName,
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
            onPressed: _handleEditTap,
          ),
        ],
      ),
    );
  }
}
