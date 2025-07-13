import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class FirestoreService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  // Save list information to Firestore
  static Future<void> saveListInfo(String listName, IconData iconData) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    try {
      await _firestore.collection('lists').add({
        'userId': userId,
        'listName': listName,
        'listIcon': iconData.codePoint,
        'createdAt': Timestamp.now(),
      });

      // Your implementation here...
    } catch (e) {
      print('Error saving list info: $e');
    }
  }

  // Delete a list from Firestore
  static Future<void> deleteList(String documentId) async {
    try {
      // Your implementation here...
    } catch (e) {
      print('Error deleting list: $e');
    }
  }

  // Fetch list names from Firestore
  static Future<List<Map<String, dynamic>>> fetchListNames(
      String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('lists')
          .where('userId', isEqualTo: userId)
          .get();

      return querySnapshot.docs.map((doc) {
        final documentId = doc.id;
        final listId = doc['listId'] as String;
        final listName = doc['listName'] as String;
        final listIcon = doc['listIcon'];

        IconData iconData = Icons.list;
        if (listIcon != null) {
          iconData = IconData(
            listIcon,
            fontFamily: 'MaterialIcons',
          );
        }

        return {
          'documentId': documentId,
          'listId': listId,
          'listName': listName,
          'listIcon': iconData,
        };
      }).toList();
    } catch (e) {
      print('Error fetching list names: $e');
      return [];
    }
  }

// Add more Firestore-related methods as needed...
}
