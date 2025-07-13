import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:todo_listo/util/creat_list_box.dart';

import '../states/list_state.dart';
import '../states/todo_state.dart';
import '../states/auth_state.dart';
import 'edit_list_box.dart';
import 'my_list_tile.dart';

class SideMenu extends StatefulWidget {
  final Function(String?) onSelectedListChanged;

  const SideMenu({
    super.key,
    required this.onSelectedListChanged,
  });

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  late String profilList;

  @override
  void initState() {
    super.initState();
    final profilePics = [
      'images/profil_pics/yellow_form.png',
      'images/profil_pics/darkblue_form.png',
      'images/profil_pics/pink_form.png',
      'images/profil_pics/pinkwhite_form.png',
      'images/profil_pics/redlong_form.png'
    ];
    profilList = profilePics[Random().nextInt(profilePics.length)];
    final listState = Provider.of<ListState>(context, listen: false);
    if (listState.selectedListId == null) {
      listState.fetchOrCreateDefaultList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final listState = Provider.of<ListState>(context);
    final authState = Provider.of<AuthState>(context, listen: false);

    return Drawer(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          color: Theme.of(context).colorScheme.surface,
        ),
        child: Column(
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height * 0.17,
              alignment: Alignment.center,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const SizedBox(width: 10),
                  CircleAvatar(
                    backgroundImage: AssetImage(profilList),
                    radius: 30,
                  ),
                  const SizedBox(width: 25),
                  Expanded(
                    child: Text(
                      FirebaseAuth.instance.currentUser?.email ?? '',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: listState.lists.length,
                itemBuilder: (context, index) {
                  final item = listState.lists[index];
                  final documentId = item['documentId'];
                  final listName = item['listName'];
                  final iconData =
                      IconData(item['listIcon'], fontFamily: 'MaterialIcons');
                  final listColor = Color(item['listColor']);
                  final isSelected = documentId == listState.selectedListId;

                  return MyListTile(
                    listName: listName,
                    listColor: listColor,
                    isSelected: isSelected,
                    iconData: iconData,
                    onTap: () {
                      listState.setSelectedList(documentId);
                      widget.onSelectedListChanged(documentId);
                      Navigator.of(context).pop();
                    },
                    onDelete: () async {
                      try {
                        await listState.deleteList(documentId);
                      } catch (e) {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return const AlertDialog(
                                content: SizedBox(
                                  height: 100,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "- You cannot delete the last list - ",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            });
                      }
                    },
                    onEdit: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) {
                          return Padding(
                            padding: MediaQuery.of(context).viewInsets,
                            child: EditListBottomSheet(
                              initialListName: listName,
                              initialIconData: iconData,
                              initialListColor: listColor,
                              listId: documentId,
                              onListInfoUpdated: (updatedListName,
                                  updatedIconData, updatedListColor) {
                                listState.updateList(
                                    documentId,
                                    updatedListName,
                                    updatedIconData,
                                    updatedListColor);
                                Navigator.of(context).pop();
                              },
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
            Container(
              height: 80,
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 120,
                    height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        foregroundColor: Theme.of(context).colorScheme.primary,
                        backgroundColor: Colors.white,
                        side: BorderSide(
                          color: Theme.of(context)
                              .colorScheme
                              .outline
                              .withOpacity(0.2),
                          width: 1,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: Icon(Icons.add, size: 20),
                      label: Text('Add List',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600)),
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) {
                            return Padding(
                              padding: MediaQuery.of(context).viewInsets,
                              child: CreateListBottomSheet(
                                onListInfoSaved: (listName, iconData, color) {
                                  listState
                                      .addList(listName, iconData.codePoint,
                                          color.value)
                                      .then((newListId) {
                                    listState.setSelectedList(newListId);
                                    Provider.of<TodoState>(context,
                                            listen: false)
                                        .fetchTodos(newListId);
                                  });
                                  Navigator.of(context).pop();
                                },
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  IconButton(
                    style: IconButton.styleFrom(
                      backgroundColor: Theme.of(context)
                          .colorScheme
                          .secondary
                          .withOpacity(0.1),
                      foregroundColor: Theme.of(context).colorScheme.secondary,
                      padding: const EdgeInsets.all(12),
                    ),
                    onPressed: () {
                      authState.signOutUser();
                      listState.resetState();
                      Provider.of<TodoState>(context, listen: false)
                          .resetState();
                      Navigator.of(context).pushReplacementNamed('/login');
                    },
                    icon: const Icon(Icons.logout),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
