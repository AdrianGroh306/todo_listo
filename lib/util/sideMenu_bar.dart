import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:todo/util/myListTile.dart';
import 'package:uuid/uuid.dart';

class SideMenu extends StatefulWidget {
  SideMenu({Key? key}) : super(key: key);

  @override
  _SideMenuState createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  late TextEditingController _textEditingController;
  late FirebaseFirestore _firestore;

  late List<Map<String, dynamic>> listNames = [];

  final List<String> profilPics = [
    'images/profil_pics/yellow_form.png',
    'images/profil_pics/darkblue_form.png',
    'images/profil_pics/pink_form.png',
    'images/profil_pics/pinkwhite_form.png',
    'images/profil_pics/redlong_form.png'
  ];

  String? selectedList;
  String? profilList;

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController();
    _firestore = FirebaseFirestore.instance;
    fetchListNames();

    // Generate a random index to select a profile picture
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
          final documentId = doc.id; // Store the document ID
          final listId = doc['listId'] as String; // Get the listId from the document
          final listName = doc['listName'] as String;
          return {
            'documentId': documentId,
            'listId': listId,
            'listName': listName
          };
        }).toList();

        setState(() {
          listNames = fetchedListNames;

          // Überprüfen Sie, ob mindestens eine Liste vorhanden ist.
          if (listNames.isEmpty) {
            // Wenn keine Listen vorhanden sind, erstellen Sie eine "Home"-Liste.
            final homeListName = 'Home';
            saveListName(homeListName);
          }

          // Wenn die Liste nicht leer ist, wählen Sie die erste Liste aus.
          if (selectedList == null && listNames.isNotEmpty) {
            selectedList = listNames.first['listName'];
          }
        });
      }
    } catch (e) {
      print('Fehler beim Abrufen der Listennamen: $e');
    }
  }

  Future<void> saveListName(String listName) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        // Generiere eine eindeutige listId
        final listId = _generateUniqueListId();

        final documentRef = await _firestore.collection('lists').add({
          'userId': userId,
          'listId': listId, // Speichern Sie die listId in der Datenbank
          'listName': listName,
        });

        final newList = {
          'documentId': documentRef.id,
          'listId': listId, // Fügen Sie die listId dem newList hinzu
          'listName': listName,
        };

        setState(() {
          listNames.add(newList);
          selectedList =
              documentRef.id; // Wählen Sie die neu hinzugefügte Liste aus
        });
      }
    } catch (e) {
      print('Fehler beim Speichern des Listennamens: $e');
    }
  }

  String _generateUniqueListId() {
    final uuid = Uuid();
    return uuid.v4(); // Generiert eine Version 4 UUID (eine zufällige UUID).
  }

  void deleteList(String documentId) async {
    try {
      await _firestore.collection('lists').doc(documentId).delete();

      setState(() {
        listNames.removeWhere((item) => item['documentId'] == documentId);
        if (selectedList == documentId) {
          selectedList = null;
        }
      });
    } catch (e) {
      print('Fehler beim Löschen der Liste: $e');
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
        child: SingleChildScrollView(
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
                                color: Theme.of(context)
                                    .colorScheme
                                    .secondary, // Adjust the width of the outline as desired
                              ),
                            ),
                            child: CircleAvatar(
                              backgroundImage: AssetImage(profilList ?? ''),
                              radius:
                                  30, // Adjust the size of the CircleAvatar as desired
                            ),
                          ),
                          const SizedBox(width: 25),
                          Text(
                            FirebaseAuth.instance.currentUser?.email ?? '',
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary),
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
                  final listName = item['listName'];
                  final isSelected = listName == selectedList;
                  return MyListTile(
                    listName: listName,
                    isSelected: isSelected,
                    onTap: () {
                      setState(() {
                        selectedList = listName; // Update selectedList with the tapped listName
                      });
                    },
                    onDelete: () {
                      deleteList(documentId);
                    },
                  );
                },
              ),
              //Add List Zeile
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: ListTile(
                  title: TextField(
                    maxLength: 15,
                    controller: _textEditingController,
                    style: TextStyle(fontSize: 18,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    decoration: InputDecoration(
                      labelStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      labelText: 'Add List',
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          width: 2,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    cursorColor: Theme.of(context).colorScheme.primary,
                    onChanged: (value) {},
                  ),
                  trailing: FloatingActionButton(
                    elevation: 0,
                    mini: true, // Make the FloatingActionButton smaller
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    onPressed: () {
                      final newListName = _textEditingController.text;
                      if (newListName.isNotEmpty) {
                        saveListName(newListName);
                        _textEditingController.clear();
                      }
                    },
                    child: Icon(
                      Icons.add_circle_outline,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
