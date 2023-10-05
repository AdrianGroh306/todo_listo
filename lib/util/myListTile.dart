import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class MyListTile extends StatefulWidget {
  final String listName;
  final bool isSelected;
  final IconData iconData; // Das hinzugefügte Icon-Datum
  final VoidCallback onTap;
  final Function onDelete;

  const MyListTile({
    Key? key,
    required this.listName,
    required this.isSelected,
    required this.iconData, // Hinzugefügtes Icon-Datum
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
        // Aktualisieren Sie den Textwert anstelle von listName
        _textEditingController.text = widget.listName;
        updateListName(_textEditingController.text);
      }
    });
  }

  void updateListName(String listName) async {
    try {
      // Greifen Sie auf die Firestore-Instanz zu
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Pfad zur gewünschten Sammlung und zum Dokument
      String collectionPath = 'lists'; // Pfad zur Sammlung
      String documentId = 'your_document_id'; // Dokument-ID

      // Aktualisieren Sie den Listenname im Dokument
      await firestore.collection(collectionPath).doc(documentId).update({
        'listName': listName,
      });

      print('Listenname erfolgreich aktualisiert!');
    } catch (e) {
      print('Fehler beim Aktualisieren des Listen namens: $e');
    }
  }

  void deleteList() async {
    try {
      // Greifen Sie auf die Firestore-Instanz zu
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Holen Sie die Dokument-ID aus den Widget-Eigenschaften
      String documentId = widget.listName; // Verwenden Sie beispielsweise den Listen-Namen als Dokument-ID

      // Pfad zur gewünschten Sammlung
      String collectionPath = 'lists'; // Pfad zur Sammlung

      print('Lösche Liste mit Dokument-ID: $documentId');

      // Löschen Sie das Dokument
      await firestore.collection(collectionPath).doc(documentId).delete();

      // Benachrichtigen Sie das übergeordnete Widget über die Löschung
      widget.onDelete();

      print('Liste erfolgreich gelöscht!');
    } catch (e) {
      print('Fehler beim Löschen der Liste: $e');
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
                // Löschen Sie die Liste
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
                color: widget.isSelected
                    ? Theme.of(context).colorScheme.secondary
                    : Colors.transparent,
                width: 2),
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[SizedBox(width: 10,),
              Icon(
                widget.iconData, // Verwenden Sie das übergebene Icon-Datum
                size: 25,
                color: Theme.of(context).colorScheme.secondary,
              ),
              Expanded(
                child: ListTile(
                  title: isEditing
                      ? TextField(
                    maxLength: 15,
                    controller: _textEditingController,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontSize: 18),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    cursorColor: Theme.of(context).colorScheme.secondary,
                    autofocus: true,
                    onEditingComplete: _toggleEditing,
                  )
                      : Text(
                    _textEditingController.text,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontSize: 18),
                  ),
                  onTap: widget.onTap,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_note),
                color: Theme.of(context).colorScheme.secondary,
                onPressed: _toggleEditing,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
