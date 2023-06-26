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
  late List<String> listNames;
  String? selectedList;

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController();
    _firestore = FirebaseFirestore.instance;
    listNames = [];
    selectedList = null;
    fetchListNames();
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
          listNames = querySnapshot.docs.map((doc) => doc['listName'] as String).toList();
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
        await _firestore.collection('lists').add({
          'userId': userId,
          'listName': listName,
        });

        setState(() {
          listNames.add(listName);
        });
      }
    } catch (e) {
      print('Fehler beim Speichern des Listennamens: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
            bottomLeft: Radius.circular(20), // Add this line for rounded bottom-left corner
          ),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blueAccent, Colors.tealAccent],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.17, // Adjust the height as desired
                child: Container(
                  alignment: Alignment.center,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 5,

                        ),
                      ],
                    ),
                    child: DrawerHeader(
                      decoration: BoxDecoration(
                        color: Colors.indigo[700],
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                          bottomLeft: Radius.circular(20), // Add this line for rounded bottom-left corner
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const SizedBox(width: 10),
                          const CircleAvatar(
                            backgroundImage: AssetImage('assets/profile_image.jpg'),
                            radius: 30, // Adjust the size of the CircleAvatar as desired
                          ),
                          const SizedBox(width: 25),
                          Text(
                            FirebaseAuth.instance.currentUser?.email ?? '',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: listNames.length,
                itemBuilder: (context, index) {
                  final listName = listNames[index];
                  return MyListTile(
                    listName: listName,
                    isSelected: listName == selectedList,
                    onTap: () {
                      setState(() {
                        selectedList = listName;
                      });
                    },
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: ListTile(
                  title: TextField(
                    controller: _textEditingController,
                    decoration: const InputDecoration(
                      labelStyle: TextStyle(
                        color: Color.fromRGBO(63, 81, 181, 1.0),
                      ),
                      labelText: 'Add List',
                    ),
                    onChanged: (value) {},
                  ),
                  trailing: FloatingActionButton(
                    mini: true, // Make the FloatingActionButton smaller
                    backgroundColor: Colors.indigo[700],
                    onPressed: () {
                      final newListName = _textEditingController.text;
                      if (newListName.isNotEmpty) {
                        saveListName(newListName);
                        _textEditingController.clear();
                      }
                    },
                    child: const Icon(Icons.add_circle_outline),
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
