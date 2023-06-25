import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:todo/util/MyListTile.dart';

class SideMenu extends StatefulWidget {
  SideMenu({Key? key}) : super(key: key);

  @override
  _SideMenuState createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  List<String> listNames = ['Liste 1'];

  late TextEditingController _textEditingController;

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(20), bottomRight: Radius.circular(20)),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blueAccent, Colors.tealAccent],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              UserAccountsDrawerHeader(
                accountName: Text(FirebaseAuth.instance.currentUser?.email ?? ''),
                accountEmail: null,
                currentAccountPicture: const CircleAvatar(
                  backgroundImage: AssetImage('assets/profile_image.jpg'),
                ),
                decoration: BoxDecoration(
                  color: Colors.indigo[700],
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: listNames.length,
                itemBuilder: (context, index) {
                  final listName = listNames[index];
                  return MyListTile(listName: listName);
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
                        setState(() {
                          listNames.add(newListName);
                        });
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

