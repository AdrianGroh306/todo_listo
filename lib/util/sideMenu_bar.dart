import 'dart:math';
import 'package:TodoListo/util/creatList_box.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import '../states/list_state.dart';
import '../states/todo_state.dart';
import 'editList_box.dart';
import 'myListTile.dart';

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
    // Profilbild nur einmal festlegen und dann beibehalten
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

    return Drawer(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            bottomLeft: Radius.circular(20),
          ),
          color: Theme
              .of(context)
              .colorScheme
              .surface,
        ),
        child: Column(
          children: <Widget>[
            SizedBox(
              height: MediaQuery
                  .of(context)
                  .size
                  .height * 0.17,
              child: Container(
                alignment: Alignment.center,
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
                    children: [
                      const SizedBox(width: 10),
                      CircleAvatar(
                        backgroundImage: AssetImage(profilList),
                        radius: 30,
                      ),
                      const SizedBox(width: 25),
                      Text(
                        FirebaseAuth.instance.currentUser?.email ?? '',
                        style: TextStyle(
                          color: Theme
                              .of(context)
                              .colorScheme
                              .secondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  ListView.builder(
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
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return EditListBox(
                                initialListName: listName,
                                initialIconData: iconData,
                                initialListColor: listColor,
                                listId: documentId,
                                onListInfoUpdated: (updatedListName, updatedIconData,
                                    updatedListColor) {
                                  listState.updateList(documentId, updatedListName,
                                      updatedIconData, updatedListColor);
                                },
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                  // Bottom gradient to indicate more lists
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      height: 20,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.surface.withOpacity(0.0),
                            Theme.of(context).colorScheme.surface,
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Theme
                      .of(context)
                      .colorScheme
                      .secondary,
                  backgroundColor: Theme
                      .of(context)
                      .colorScheme
                      .primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                icon: const Icon(Icons.add),
                label: const Text('Add List'),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return CreateListBox(
                        onListInfoSaved: (listName, iconData, color) {
                          listState.addList(listName, iconData.codePoint, color.value).then((newListId) {
                            listState.setSelectedList(newListId);
                            Provider.of<TodoState>(context, listen: false).fetchTodos(newListId);
                          });

                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
