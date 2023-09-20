import 'dart:math';

import 'package:flutter/material.dart';
import 'package:todo/util/creatList_box.dart';
import 'package:todo/util/myListTile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

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
  FocusNode _focusNode = FocusNode();
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
          return {
            'documentId': documentId,
            'listId': listId,
            'listName': listName
          };
        }).toList();

        setState(() {
          listNames = fetchedListNames;

          if (listNames.isEmpty) {
            final homeListName = 'Home';
            saveListInfo(homeListName, Icons.list);
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
        final listId = _generateUniqueListId();
        final documentRef = await _firestore.collection('lists').add({
          'userId': userId,
          'listId': listId,
          'listName': listName,
          'listIcon': iconData.codePoint,
        });

        final newList = {
          'documentId': documentRef.id,
          'listId': listId,
          'listName': listName,
          'listIcon': iconData.codePoint,
        };

        setState(() {
          listNames.add(newList);
          widget.selectedListId = documentRef.id;
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

      setState(() {
        listNames.removeWhere((item) => item['documentId'] == documentId);
        if (widget.selectedListId == documentId) {
          widget.selectedListId = null;
        }
      });
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
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    width: 2,
                                    color:
                                    Theme.of(context).colorScheme.secondary,
                                  ),
                                ),
                                child: CircleAvatar(
                                  backgroundImage: AssetImage(profilList ?? ''),
                                  radius: 30,
                                ),
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
                      // Use ?? to provide a default IconData if item['listIcon'] is null
                      final iconData = item['listIcon'] != null
                          ? IconData(
                        item['listIcon'],
                        fontFamily: 'MaterialIcons',
                      )
                          : Icons.list; // Replace 'defaultIcon' with your desired default icon

                      return MyListTile(
                        listName: listName,
                        isSelected: isSelected,
                        iconData: iconData,
                        onTap: () {
                          setState(() {
                            widget.onSelectedListChanged(listId);
                          });
                        },
                        onDelete: () {
                          deleteList(documentId);
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
                  final newListName = _textEditingController.text;
                  if (newListName.isNotEmpty) {
                    // Hier kannst du das Standard-Icon für neue Listen anpassen
                    saveListInfo(newListName, Icons.list);
                    _textEditingController.clear();
                  }
                  showDialog(
                    context: context,
                    builder: (context) {
                      return CreateListBox(
                        // Callback-Funktion übergeben
                        onListInfoSaved: (listName, iconData) {
                          // Hier kannst du die Daten speichern und fetchen
                          // Speichere in der Datenbank und aktualisiere die Liste
                          saveListInfo(listName, iconData);
                          // Aktualisiere das ausgewählte Icon im State
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
                        20), // Hier kannst du die gewünschte Form anpassen
                  ),
                ),
                child: const Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Text(
                    "Create List",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18, // Hier kannst du die Schriftgröße anpassen
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
