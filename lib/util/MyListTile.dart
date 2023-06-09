import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class MyListTile extends StatefulWidget {
  final String listName;
  final bool isSelected;
  final VoidCallback onTap;
  final Function onDelete;

  MyListTile({
    Key? key,
    required this.listName,
    required this.isSelected,
    required this.onTap,
    required this.onDelete,
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
        updateListName(_textEditingController.text);
      }
    });
  }

  void updateListName(String listName) async {
    try {
      // Access the Firestore instance
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Path to the desired collection and document
      String collectionPath = 'lists'; // Path to the collection
      String documentId = 'your_document_id'; // Document ID

      // Update the list name in the document
      await firestore.collection(collectionPath).doc(documentId).update({
        'listName': listName,
      });

      print('List name updated successfully!');
    } catch (e) {
      print('Error updating list name: $e');
    }
  }

  void deleteList() async {
    try {
      // Access the Firestore instance
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Path to the desired collection and document
      String collectionPath = 'lists'; // Path to the collection
      String documentId = 'your_document_id'; // Document ID

      // Delete the document
      await firestore.collection(collectionPath).doc(documentId).delete();

      // Notify the parent widget about the deletion
      widget.onDelete();

      print('List deleted successfully!');
    } catch (e) {
      print('Error deleting list: $e');
    }
  }

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
                // Delete the list
                deleteList();
              },
              icon: Icons.delete,
              backgroundColor: Colors.red,
              borderRadius: BorderRadius.circular(15),
            )
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.indigo[700],
            borderRadius: BorderRadius.circular(15),
          ),
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
                    style: const TextStyle(
                        color: Colors.white, fontSize: 18),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    cursorColor: Colors.white,
                    autofocus: true,
                    onEditingComplete: _toggleEditing,
                  )
                      : Text(
                    _textEditingController.text,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 18),
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
        ),
      ),
    );
  }
}
