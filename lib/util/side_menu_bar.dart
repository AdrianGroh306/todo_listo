import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
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
  File? _selectedImage;
  Uint8List? _webImage;
  String? _profileImageBase64;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final listState = Provider.of<ListState>(context, listen: false);
    if (listState.selectedListId == null) {
      listState.fetchOrCreateDefaultList();
    }
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (doc.exists && doc.data()?['profileImageBase64'] != null) {
          setState(() {
            _profileImageBase64 = doc.data()!['profileImageBase64'];
          });
        }
      } catch (e) {
        debugPrint('Error loading profile image: $e');
      }
    }
  }

  Future<void> _saveProfileImage() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      String? base64String;
      
      if (kIsWeb && _webImage != null) {
        base64String = base64Encode(_webImage!);
      } else if (!kIsWeb && _selectedImage != null) {
        final bytes = await _selectedImage!.readAsBytes();
        base64String = base64Encode(bytes);
      } else {
        return;
      }

      // Save Base64 string to Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({
        'profileImageBase64': base64String,
        'email': user.email,
      }, SetOptions(merge: true));

      setState(() {
        _profileImageBase64 = base64String;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profilbild erfolgreich gespeichert!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error saving profile image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fehler beim Speichern des Profilbildes'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 300,
        maxHeight: 300,
        imageQuality: 80,
      );
      
      if (image != null) {
        if (kIsWeb) {
          final bytes = await image.readAsBytes();
          setState(() {
            _webImage = bytes;
            _selectedImage = null;
          });
        } else {
          setState(() {
            _selectedImage = File(image.path);
            _webImage = null;
          });
        }
        await _saveProfileImage();
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fehler beim Auswählen des Bildes'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  ImageProvider? _getProfileImage() {
    if (kIsWeb && _webImage != null) {
      return MemoryImage(_webImage!);
    } else if (!kIsWeb && _selectedImage != null) {
      return FileImage(_selectedImage!);
    } else if (_profileImageBase64 != null) {
      try {
        final bytes = base64Decode(_profileImageBase64!);
        return MemoryImage(bytes);
      } catch (e) {
        debugPrint('Error decoding profile image: $e');
        return null;
      }
    }
    return null;
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Ausloggen'),
          content: const Text('Möchten Sie sich wirklich ausloggen?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Abbrechen'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                final authState = Provider.of<AuthState>(context, listen: false);
                final listState = Provider.of<ListState>(context, listen: false);
                authState.signOutUser();
                listState.resetState();
                Provider.of<TodoState>(context, listen: false).resetState();
                if (mounted) {
                  Navigator.of(context).pushReplacementNamed('/login');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Colors.white,
              ),
              child: const Text('Ausloggen'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final listState = Provider.of<ListState>(context);

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
            // Profile area positioned higher
            Container(
              height: MediaQuery.of(context).size.height * 0.10,
              alignment: Alignment.center,
              padding: const EdgeInsets.only(left: 16, right: 8, top: 20),
              child: Row(
                children: [
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: _pickImage,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          backgroundImage: _getProfileImage(),
                          child: _getProfileImage() == null 
                              ? Icon(
                                  Icons.person,
                                  size: 30,
                                  color: Theme.of(context).colorScheme.primary,
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Theme.of(context).colorScheme.surface,
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              Icons.camera_alt,
                              size: 12,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Text(
                      FirebaseAuth.instance.currentUser?.email ?? '',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  // Logout Button integriert in die Profil-Reihe, aber klein
                  SizedBox(
                    width: 32,
                    height: 32,
                    child: IconButton(
                      onPressed: _showLogoutDialog,
                      style: IconButton.styleFrom(
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .errorContainer
                            .withOpacity(0.1),
                        foregroundColor: Theme.of(context).colorScheme.error,
                        padding: EdgeInsets.zero,
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.logout, size: 14),
                    ),
                  ),
                  const SizedBox(width: 8),
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
                        if (!mounted) return;
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
                      if (!mounted) return;
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
            Positioned(
              bottom: 25,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 25, left: 16, right: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 140,
                      height: 48,
                      child: FloatingActionButton.extended(
                        heroTag: "addListButton",
                        elevation: 0,
                        backgroundColor: Theme.of(context).colorScheme.surface,
                        foregroundColor: Theme.of(context).colorScheme.secondary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.secondary,
                            width: 2,
                          ),
                        ),
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) {
                              return Padding(
                                padding: MediaQuery.of(context).viewInsets,
                                child: CreateListBottomSheet(
                                  onListInfoSaved: (listName, iconData, color) async {
                                    final listState = Provider.of<ListState>(context, listen: false);
                                    final newListId = await listState
                                        .addList(listName, iconData.codePoint,
                                            color.value);
                                    if (mounted) {
                                      listState.setSelectedList(newListId);
                                      Provider.of<TodoState>(context,
                                              listen: false)
                                          .fetchTodos(newListId);
                                      Navigator.of(context).pop();
                                    }
                                  },
                                ),
                              );
                            },
                          );
                        },
                        icon: Icon(
                          Icons.add,
                          color: Theme.of(context).colorScheme.secondary,
                          size: 20,
                        ),
                        label: Text(
                          'Add List',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
