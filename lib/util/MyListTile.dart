import 'package:flutter/material.dart';

class MyListTile extends StatefulWidget {
  String listName;

  MyListTile({Key? key, required this.listName}) : super(key: key);

  @override
  _MyListTileState createState() => _MyListTileState();
}

class _MyListTileState extends State<MyListTile> {
  late TextEditingController _textEditingController;
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController(text: widget.listName);
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  void _toggleEditing() {
    setState(() {
      isEditing = !isEditing;
      if (!isEditing) {
        widget.listName = _textEditingController.text;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.indigo[700],
        borderRadius: BorderRadius.circular(15),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
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
              title: isEditing
                  ? TextSelectionTheme(
                data: const TextSelectionThemeData(
                  cursorColor: Colors.white,
                ),
                child: TextField(
                  controller: _textEditingController,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  cursorColor: Colors.white,
                  autofocus: true,
                  onEditingComplete: _toggleEditing,
                ),
              )
                  : Text(
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
            onPressed: _toggleEditing,
          ),
        ],
      ),
    );
  }
}
