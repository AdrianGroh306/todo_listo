import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:todo/util/MyListTile.dart';

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
    "images/profil_pics/redlong_form.png"
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

        setState(() {
          listNames = querySnapshot.docs.map((doc) {
            final documentId = doc.id; // Store the document ID
            final listName = doc['listName'] as String;
            return {'documentId': documentId, 'listName': listName};
          }).toList();
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
        final documentRef = await _firestore.collection('lists').add({
          'userId': userId,
          'listName': listName,
        });

        final newList = {
          'documentId': documentRef.id,
          'listName': listName,
        };

        setState(() {
          listNames.add(newList);
          selectedList = documentRef.id; // Select the newly added list
        });
      }
    } catch (e) {
      print('Fehler beim Speichern des Listennamens: $e');
    }
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
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.background, // Hintergrundfarbe des DrawerHeaders anpassen
            ),
            child: Column(
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      width: 2,
                      color: Theme.of(context).colorScheme.secondary,
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
                  style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                ),
              ],
            ),
          ),
          Column(
            children: listNames.map((item) {
              final documentId = item['documentId'];
              final listName = item['listName'];
              return MyListTile(
                listName: listName,
                isSelected: listName == selectedList,
                onTap: () {
                  setState(() {
                    selectedList = listName;
                  });
                },
                onDelete: () {
                  deleteList(documentId);
                },
              );
            }).toList(),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: ListTile(
              title: TextField(
                controller: _textEditingController,
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
                decoration: InputDecoration(
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: Theme.of(context).colorScheme.primary,
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
                mini: true,
                backgroundColor: Theme.of(context).colorScheme.primary,
                onPressed: () {
                  final newListName = _textEditingController.text;
                  if (newListName.isNotEmpty) {
                    saveListName(newListName);
                    _textEditingController.clear();
                  }
                },
                child: Icon(Icons.add_circle_outline,
                    color: Theme.of(context).colorScheme.secondary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
