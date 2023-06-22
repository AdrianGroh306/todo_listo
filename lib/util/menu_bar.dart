import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(20), bottomRight: Radius.circular(20)),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blueAccent, Colors.tealAccent],
          ),
        ),
        child: ListView(
          children: <Widget>[
            Center(
              child: UserAccountsDrawerHeader(
                accountName: null,
                accountEmail:
                    Text(FirebaseAuth.instance.currentUser?.email ?? ''),
                currentAccountPicture: CircleAvatar(
                  backgroundImage: AssetImage('assets/profile_image.jpg'),
                ),
                decoration: BoxDecoration(
                  color: Colors.indigo[700],
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.indigo[700],
                borderRadius: BorderRadius.circular(8),
              ),
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                title: const Text(
                  'List Name 1',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  // Handle list item tap
                },
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.indigo[700],
                borderRadius: BorderRadius.circular(8),
              ),
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                title: const Text(
                  'List Name 2',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  // Handle list item tap
                },
              ),
            ),
            // Add more list tiles for other list names
          ],
        ),
      ),
    );
  }
}
