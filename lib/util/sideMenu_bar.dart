import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'editList_box.dart';
import 'myListTile.dart';

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

  IconData? selectedIcon;

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
    _focusNode.dispose();
    super.dispose();
  }

  void fetchListNames() {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        _firestore
            .collection('lists')
            .where('userId', isEqualTo: userId)
            .get()
            .then((querySnapshot) {
          final fetchedListNames = querySnapshot.docs.map((doc) {
            final documentId = doc.id;
            final listName = doc['listName'] as String;
            final listIcon = doc['listIcon'] as int?;
            final listColor = doc['listColor'] as int?;

            IconData iconData = Icons.list;
            Color color = Theme.of(context)
                .colorScheme
                .secondary; // Fallback-Farbe, wenn keine Farbe in der Datenbank gespeichert ist

            if (listIcon != null) {
              iconData = IconData(
                listIcon,
                fontFamily: 'MaterialIcons',
              );
            }

            if (listColor != null) {
              color = Color(listColor);
            }

            return {
              'documentId': documentId,
              'listName': listName,
              'listIcon': iconData,
              'listColor': color,
            };
          }).toList();

          setState(() {
            listNames = fetchedListNames;
          });
        });
      }
    } catch (e) {
      print('Error fetching list names: $e');
    }
  }

  void saveListInfo(String listName, IconData iconData, Color color) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        final documentRef = await _firestore.collection('lists').add({
          'userId': userId,
          'listName': listName,
          'listIcon': iconData.codePoint,
          'listColor': color.value, // Farbwert in der Datenbank speichern
          'createdAt': FieldValue.serverTimestamp(),
        });

        final newList = {
          'documentId': documentRef.id,
          'listName': listName,
          'listIcon': iconData,
          'listColor': color, // Farbobjekt in die Liste aufnehmen
          'createdAt': FieldValue.serverTimestamp(),
        };

        setState(() {
          listNames.add(newList);
          widget.selectedListId = documentRef.id;
        });

        // Setze die neu erstellte Liste als ausgewählte Liste für den Benutzer
        updateSelectedListForUser(documentRef.id);
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
              backgroundColor: Theme.of(context).colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0), // Abgerundete Ecken
              ),
              content: Padding(
                padding:
                const EdgeInsets.symmetric(vertical: 5.0), // Vertikaler Abstand
                child: Text(
                  'You cannot delete the last list',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
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
          widget.onSelectedListChanged(listNames.first['documentId']);
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
            {'selectedListId': selectedListDocumentId}, SetOptions(merge: true));
      }
    } catch (e) {
      print(
          'Fehler beim Aktualisieren der ausgewählten Liste für den Benutzer: $e');
    }
  }

  Stream<String?> getCurrentSelectedListId() async* {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      try {
        await for (final userSnapshot in FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .snapshots()) {
          final userData = userSnapshot.data();
          if (userData != null) {
            final selectedListId = userData['selectedListId'] as String?;
            yield selectedListId;
          } else {
            yield null;
          }
        }
      } catch (e) {
        print('[Error] Getting current selectedListId: $e');
        yield null;
      }
    } else {
      yield null;
    }
  }

  void updateListInfo(String listId, String listName, IconData iconData,
      Color listColor) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        await FirebaseFirestore.instance
            .collection('lists')
            .doc(listId)
            .update({
          'listName': listName,
          'listIcon': iconData.codePoint,
          'listColor': listColor.value,
        });
        print('List info updated successfully: $listName, $iconData');

        // Aktualisieren der Liste im State
        setState(() {
          final index =
          listNames.indexWhere((item) => item['documentId'] == listId);
          if (index != -1) {
            listNames[index]['listName'] = listName;
            listNames[index]['listIcon'] = iconData;
            listNames[index]['listColor'] = listColor;
          }
        });
      }
    } catch (e) {
      print('Error updating list info: $e');
    }
  }
  void _showAddListDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditListBox(
          initialListName: '',
          initialIconData: Icons.list,
          initialListColor: Theme.of(context).colorScheme.primary,
          onListInfoUpdated: (listName, iconData, listColor) {
            saveListInfo(listName, iconData, listColor);
          }, listId: '',
        );
      },
    );
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
          color: Theme.of(context).colorScheme.surface,
        ),
        child: StreamBuilder<String?>(
          stream: getCurrentSelectedListId(),
          builder: (context, snapshot) {
            final currentSelectedListId = snapshot.data;
            return Column(
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
                              Theme.of(context).colorScheme.surface,
                              backgroundImage: AssetImage(profilList ?? ''),
                              radius: 30,
                            ),
                            const SizedBox(width: 25),
                            Text(
                              FirebaseAuth.instance.currentUser?.email ?? '',
                              style: TextStyle(
                                  color:
                                  Theme.of(context).colorScheme.secondary),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // Expanded Widget hinzugefügt
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: listNames.length,
                    itemBuilder: (context, index) {
                      final item = listNames[index];
                      final documentId = item['documentId'];
                      final listName = item['listName'];
                      final iconData = item['listIcon'];
                      final listColor = item['listColor'];
                      final isSelected = documentId == currentSelectedListId;

                      return MyListTile(
                        listName: listName,
                        listColor: listColor,
                        isSelected: isSelected,
                        iconData: iconData,
                        onTap: () {
                          updateSelectedListForUser(documentId);
                          widget.onSelectedListChanged(documentId);
                          Navigator.of(context).pop();
                        },
                        onDelete: () {
                          deleteList(documentId);
                        },
                        onEdit: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return EditListBox(
                                initialListName: listName ?? 'Default Name',
                                initialIconData: iconData ?? Icons.list,
                                initialListColor: listColor,
                                listId: documentId ?? '',
                                onListInfoUpdated: (updatedListName,
                                    updatedIconData, updatedListColor) {
                                  updateListInfo(documentId, updatedListName,
                                      updatedIconData, updatedListColor);
                                },
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
                // Button zum Hinzufügen neuer Listen
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.secondary, backgroundColor: Theme.of(context).colorScheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    icon: const Icon(Icons.add),
                    label: Text(
                      'Add List',
                      style: TextStyle(fontSize: 16,color: Theme.of(context).colorScheme.secondary,),
                    ),
                    onPressed: () {
                      // Aktion beim Drücken des Buttons
                      _showAddListDialog();
                    },
                  ),
                ),
                const SizedBox(height: 20),
              ],
            );
          },
        ),
      ),
    );
  }
}
