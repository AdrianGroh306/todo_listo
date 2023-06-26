import 'package:flutter/material.dart';

class MyListTile extends StatefulWidget {
  final String listName;
  final bool isSelected;
  final VoidCallback onTap;

  MyListTile({
    Key? key,
    required this.listName,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

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
        // Update the text value instead of the listName
        _textEditingController.text = widget.listName;
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
            onPressed: widget.onTap,
          ),
          Expanded(
            child: ListTile(
              title: isEditing
                  ? TextField(
                controller: _textEditingController,
                style: const TextStyle(color: Colors.white, fontSize: 18),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                cursorColor: Colors.white,
                autofocus: true,
                onEditingComplete: _toggleEditing,
              )
                  : Text(
                _textEditingController.text,
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
              onTap: widget.onTap,
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
