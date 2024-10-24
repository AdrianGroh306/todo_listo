import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ListState extends ChangeNotifier {
  List<Map<String, dynamic>> _lists = [];
  String? _selectedListId;
  String? _selectedListName;
  int? _selectedListIcon;
  int? _selectedListColor;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Map<String, dynamic>> get lists => _lists;

  String? get selectedListId => _selectedListId;

  String? get selectedListName => _selectedListName;

  int? get selectedListIcon => _selectedListIcon;

  int? get selectedListColor => _selectedListColor;
  bool isLoading = false;

  Future<void> fetchOrCreateDefaultList() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    isLoading = true;
    notifyListeners();

    try {
      // Fetch the user's document to get the last selectedListId
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final userData = userDoc.data();
      String? storedSelectedListId = userData != null
          ? userData['selectedListId'] as String?
          : null;

      // Fetch all lists belonging to the user
      final listsQuery = await _firestore
          .collection('lists')
          .where('userId', isEqualTo: userId)
          .get();

      if (listsQuery.docs.isEmpty) {
        // No lists present, create a default list
        final docRef = await _firestore.collection('lists').add({
          'userId': userId,
          'listName': 'My Todos',
          'listIcon': Icons.list.codePoint,
          'listColor': Colors.blue.value,
          'createdAt': FieldValue.serverTimestamp(),
        });

        _selectedListId = docRef.id;
        _selectedListName = 'My Todos';
        _selectedListIcon = Icons.list.codePoint;
        _selectedListColor = Colors.blue.value;

        _lists.add({
          'documentId': docRef.id,
          'listName': _selectedListName,
          'listIcon': _selectedListIcon,
          'listColor': _selectedListColor,
        });

        // Update the user's document with the new selectedListId
        await _firestore.collection('users').doc(userId).set({
          'selectedListId': _selectedListId,
        }, SetOptions(merge: true));
      } else {
        // Lists are present
        _lists = listsQuery.docs.map((doc) {
          final data = doc.data();
          return {
            'documentId': doc.id,
            'listName': data['listName'],
            'listIcon': data['listIcon'],
            'listColor': data['listColor'],
          };
        }).toList();

        // Check if storedSelectedListId exists in the fetched lists
        if (storedSelectedListId != null &&
            _lists.any((list) => list['documentId'] == storedSelectedListId)) {
          _selectedListId = storedSelectedListId;
        } else {
          // If not, default to the first list
          final firstList = _lists.first;
          _selectedListId = firstList['documentId'];
        }

        // Load the selected list's information
        await fetchSelectedListInfo();
      }
    } catch (e) {
      print('Error fetching or creating default list: $e');
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> setSelectedList(String listId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    _selectedListId = listId;

    // Update the selected list in Firestore
    await _firestore.collection('users').doc(userId).set({
      'selectedListId': listId,
    }, SetOptions(merge: true));

    // Load the information of the selected list
    await fetchSelectedListInfo();

    notifyListeners(); // Call after data is updated
  }

  // Lade die Infos der ausgewählten Liste (Name, Icon, Farbe)
  Future<void> fetchSelectedListInfo() async {
    if (_selectedListId == null) return;

    try {
      final selectedListDoc =
      await _firestore.collection('lists').doc(_selectedListId).get();
      final selectedListData = selectedListDoc.data();

      if (selectedListData != null) {
        _selectedListName = selectedListData['listName'] as String?;
        _selectedListIcon = selectedListData['listIcon'] as int?;
        _selectedListColor = selectedListData['listColor'] as int?;
      }
    } catch (e) {
      print('[Error] Fetching selected list info: $e');
    }
  }

  Future<String> addList(String listName, int listIcon, int listColor) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception("User not authenticated");

    try {
      final docRef = await _firestore.collection('lists').add({
        'userId': userId,
        'listName': listName,
        'listIcon': listIcon,
        'listColor': listColor,
        'createdAt': FieldValue.serverTimestamp(),
      });

      _lists.add({
        'documentId': docRef.id,
        'listName': listName,
        'listIcon': listIcon,
        'listColor': listColor,
      });

      notifyListeners();

      // Gib die documentId zurück
      return docRef.id;
    } catch (e) {
      print('Error adding list: $e');
      rethrow;
    }
  }


  Future<void> updateList(String listId, String listName, IconData iconData,
      int listColor) async {
    try {
      await _firestore.collection('lists').doc(listId).update({
        'listName': listName,
        'listIcon': iconData.codePoint,
        'listColor': listColor,
      });

      final index = _lists.indexWhere((item) => item['documentId'] == listId);
      if (index != -1) {
        _lists[index] = {
          'documentId': listId,
          'listName': listName,
          'listIcon': iconData.codePoint,
          'listColor': listColor,
        };
        notifyListeners();
      }
    } catch (e) {
      print('Error updating list info: $e');
    }
  }

  Future<void> deleteList(String documentId) async {
    try {
      if (_lists.length <= 1) {
        throw Exception("You cannot delete the last list");
      }

      // Delete the list from the database
      await _firestore.collection('lists').doc(documentId).delete();

      // Remove the list from the local state
      _lists.removeWhere((item) => item['documentId'] == documentId);

      // If the deleted list was the selected list, set another list as the default
      if (_selectedListId == documentId && _lists.isNotEmpty) {
        final newSelectedList = _lists.first;
        await setSelectedList(newSelectedList['documentId']);
      } else if (_lists.isEmpty) {
        // If no lists are left, set all fields to null
        _selectedListId = null;
        _selectedListName = null;
        _selectedListIcon = null;
        _selectedListColor = null;

        // Update the user's document
        final userId = _auth.currentUser?.uid;
        if (userId != null) {
          await _firestore.collection('users').doc(userId).set({
            'selectedListId': null,
          }, SetOptions(merge: true));
        }
      }

      // Update the UI
      notifyListeners();
    } catch (e) {
      print('Error deleting list: $e');
      rethrow;
    }
  }

  void resetState() {
    _lists = [];
    _selectedListId = null;
    _selectedListName = null;
    _selectedListIcon = null;
    _selectedListColor = null;
    isLoading = false;
    notifyListeners();
  }

}
