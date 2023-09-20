import 'dart:math';

import 'package:flutter/material.dart';
import 'package:todo/util/creatList_box.dart';
import 'package:todo/util/myListTile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class SideMenu extends StatefulWidget {
  final String? selectedListId;
  final Function(String?) onSelectedListChanged;

  SideMenu({
    Key? key,
    required this.selectedListId,
    required this.onSelectedListChanged,
  }) : super(key: key);

  @override
  _SideMenuState createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  late TextEditingController _textEditingController;
  late FirebaseFirestore _firestore;
  FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController();
    _firestore = FirebaseFirestore.instance;

    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        setState(() {
          _textEditingController.clear();
        });
      }
    });
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  void saveListInfo(String listName, IconData iconData) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        final listId = _generateUniqueListId();
        await _firestore.collection('lists').add({
          'userId': userId,
          'listId': listId,
          'listName': listName,
          'listIcon': iconData.codePoint,
        });
      }
    } catch (e) {
      print('Error saving list info: $e');
    }
  }

  String _generateUniqueListId() {
    final uuid = Uuid();
    return uuid.v4();
  }

  void deleteList(String documentId) async {
    try {
      await _firestore.collection('lists').doc(documentId).delete();
    } catch (e) {
      print('Error deleting list: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          color: Theme.of(context).colorScheme.background,
        ),
        child: Stack(
          children: <Widget>[
            SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.17,
                    child: Container(
                      alignment: Alignment.center,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.transparent,
                        ),
                        child: DrawerHeader(
                          decoration: const BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(20),
                              bottomRight: Radius.circular(20),
                              bottomLeft: Radius.circular(20),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const SizedBox(width: 10),
                              CircleAvatar(
                                backgroundImage:
                                AssetImage('images/profil_pics/yellow_form.png'), // Hier kannst du das Standard-Profilbild festlegen
                                radius: 30,
                              ),
                              const SizedBox(width: 25),
                              Text(
                                FirebaseAuth.instance.currentUser?.email ?? '',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.secondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('lists')
                        .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }

                      if (!snapshot.hasData) {
                        return CircularProgressIndicator(); // Ladeanzeige, während Daten geladen werden
                      }

                      final listDocs = snapshot.data!.docs;

                      return Column(
                        children: listDocs.map((doc) {
                          final documentId = doc.id;
                          final listId = doc['listId'] as String;
                          final listName = doc['listName'] as String;
                          final isSelected = listId == widget.selectedListId;
                          final iconData = doc['listIcon'] != null
                              ? IconData(
                            doc['listIcon'],
                            fontFamily: 'MaterialIcons',
                          )
                              : Icons.list; // Standard-Icon

                          return MyListTile(
                            listName: listName,
                            isSelected: isSelected,
                            iconData: iconData,
                            onTap: () {
                              widget.onSelectedListChanged(listId);
                            },
                            onDelete: () {
                              deleteList(documentId);
                            },
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 20,
              right: 20,
              child: ElevatedButton(
                onPressed: () {
                  final newListName = _textEditingController.text;
                  if (newListName.isNotEmpty) {
                    saveListInfo(newListName, Icons.list); // Standard-Icon für neue Listen
                    _textEditingController.clear();
                  }
                  showDialog(
                    context: context,
                    builder: (context) {
                      return CreateListBox(
                        onListInfoSaved: (listName, iconData) {
                          saveListInfo(listName, iconData);
                        },
                      );
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.secondary,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Text(
                    "Create List",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
