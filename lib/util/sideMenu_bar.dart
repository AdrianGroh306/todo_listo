import 'dart:math';
import 'package:flutter/material.dart';
import 'package:todo/util/creatList_box.dart';
import 'package:todo/util/myListTile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import 'editList_box.dart';

class SideMenu extends StatefulWidget {
  String? selectedListId;
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
  final FocusNode _focusNode = FocusNode();
  List<Map<String, dynamic>> listNames = [];
  final List<String> profilPics = [
    'images/profil_pics/yellow_form.png',
    'images/profil_pics/darkblue_form.png',
    'images/profil_pics/pink_form.png',
    'images/profil_pics/pinkwhite_form.png',
    'images/profil_pics/redlong_form.png'
  ];

  String? profilList;

  IconData? selectedIcon; // Hinzugefügtes Feld für das ausgewählte Icon

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController();
    _firestore = FirebaseFirestore.instance;
    fetchListNames();

    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        setState(() {
          _textEditingController.clear();
        });
      }
    });

    final random = Random();
    final randomIndex = random.nextInt(profilPics.length);
    profilList = profilPics[randomIndex];
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  void fetchListNames() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        final querySnapshot = await _firestore
            .collection('lists')
            .where('userId', isEqualTo: userId)
            .get();

        final fetchedListNames = querySnapshot.docs.map((doc) {
          final documentId = doc.id;
          final listId = doc['listId'] as String;
          final listName = doc['listName'] as String;
          final listIcon = doc['listIcon'];

          IconData iconData = Icons.list;
          if (listIcon != null) {
            iconData = IconData(
              listIcon,
              fontFamily: 'MaterialIcons',
            );
          }

          return {
            'documentId': documentId,
            'listId': listId,
            'listName': listName,
            'listIcon': iconData,
          };
        }).toList();

        setState(() {
          listNames = fetchedListNames;

          if (listNames.isEmpty) {
            const homeListName = 'Home';
            saveListInfo(homeListName, Icons.house_rounded);
          }

          if (widget.selectedListId == null && listNames.isNotEmpty) {
            widget.selectedListId = listNames.first['listId'];
          }
        });
      }
    } catch (e) {
      print('Error fetching list names: $e');
    }
  }

  void saveListInfo(String listName, IconData iconData) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        final documentRef = await _firestore.collection('lists').add({
          'userId': userId,
          'listName': listName,
          'listIcon': iconData.codePoint,
          'createdAt': FieldValue.serverTimestamp(),
        });

        final newList = {
          'documentId': documentRef.id,
          'listName': listName,
          'listIcon': iconData,
          'createdAt': FieldValue.serverTimestamp(),
        };

        setState(() {
          listNames.add(newList);
          widget.selectedListId = documentRef.id;
        });

        // Set the newly created list as the selected list for the user
        updateSelectedListForUser(documentRef.id); // Füge diese Zeile hinzu
      }
    } catch (e) {
      print('Error saving list info: $e');
    }
  }


  void deleteList(String documentId) async {
    try {
      // Überprüfen, ob es mindestens zwei Listen gibt, bevor eine gelöscht wird
      if (listNames.length < 2) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0), // Abgerundete Ecken
              ),
              content: Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 5.0), // Vertikaler Abstand
                child: Text(
                  'You cannot delete the last list',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              ),
            );
          },
        );
        return; // Abbrechen, wenn es nur eine Liste gibt
      }

      // Zuerst alle To-Dos der Liste abrufen
      final querySnapshot = await _firestore
          .collection('todos')
          .where('listId', isEqualTo: documentId)
          .get();

      // Alle To-Dos löschen
      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        await doc.reference.delete();
      }

      // Dann die Liste löschen
      await _firestore.collection('lists').doc(documentId).delete();

      setState(() {
        listNames.removeWhere((item) => item['documentId'] == documentId);
        if (widget.selectedListId == documentId) {
          widget.onSelectedListChanged(listNames.first['listId']);
        }
      });
    } catch (e) {
      print('Error deleting list: $e');
    }
  }

  void updateSelectedListForUser(String selectedListDocumentId) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        await FirebaseFirestore.instance.collection('users').doc(userId).set(
            {'selectedListId': selectedListDocumentId},
            SetOptions(merge: true));
      }
    } catch (e) {
      print(
          'Fehler beim Aktualisieren der ausgewählten Liste für den Benutzer: $e');
    }
  }

  void updateListInfo(String listId, String listName, IconData iconData) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        await FirebaseFirestore.instance.collection('lists').doc(listId).update({
          'listName': listName,
          'listIcon': iconData.codePoint,
        });
        print('List info updated successfully: $listName, $iconData');

        // Hier können Sie die Liste in Ihrem State aktualisieren
        setState(() {
          final index = listNames.indexWhere((item) => item['listId'] == listId);
          if (index != -1) {
            listNames[index]['listName'] = listName;
            listNames[index]['listIcon'] = iconData;
          }
        });
      }
    } catch (e) {
      print('Error updating list info: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            bottomLeft: Radius.circular(20),
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
                                backgroundColor:
                                    Theme.of(context).colorScheme.background,
                                backgroundImage: AssetImage(profilList ?? ''),
                                radius: 30,
                              ),
                              const SizedBox(width: 25),
                              Text(
                                FirebaseAuth.instance.currentUser?.email ?? '',
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondary),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: listNames.length,
                    itemBuilder: (context, index) {
                      final item = listNames[index];
                      final documentId = item['documentId'];
                      final listId = item['listId'];
                      final listName = item['listName'];
                      final isSelected = listId == widget.selectedListId;
                      final iconData = item['listIcon'];

                      return MyListTile(
                        listName: listName,
                        isSelected: isSelected,
                        iconData: iconData,
                        onTap: () {
                          setState(() {
                            widget.onSelectedListChanged(listId);
                          });
                          // Call the function to update selected list ID for the user
                          updateSelectedListForUser(documentId);
                        },
                        onDelete: () {
                          deleteList(documentId);
                        },
                        onEdit: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return EditListBox(
                                initialListName: listName,
                                initialIconData: iconData,
                                listId: listId,
                                onListInfoUpdated: (updatedListName, updatedIconData){
                                  updateListInfo(listId, updatedListName, updatedIconData);
                                },
                              );
                            },
                          );
                        },
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
                  showDialog(
                    context: context,
                    builder: (context) {
                      return CreateListBox(
                        onListInfoSaved: (listName, iconData) {
                          saveListInfo(listName, iconData);
                          setState(() {
                            selectedIcon = iconData;
                          });
                        },
                        onIconSelected: (iconData) {
                          setState(() {
                            selectedIcon = iconData;
                          });
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
                    borderRadius: BorderRadius.circular(
                      20,
                    ),
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
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
