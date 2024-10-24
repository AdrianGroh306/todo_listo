import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TodoState extends ChangeNotifier {
  List<Map<String, dynamic>> _todos = [];
  String? selectedListId;
  String? _selectedListName;
  int? _selectedListIcon;
  int? _selectedListColor;
  bool _showCompletedTodos = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> get todos => _showCompletedTodos
      ? _todos.where((todo) => todo['taskCompleted'] == true).toList()
      : _todos.where((todo) => todo['taskCompleted'] == false).toList();
  List<Map<String, dynamic>> get allTodos => _todos;
  String? get selectedListName => _selectedListName;
  int? get selectedListIcon => _selectedListIcon;
  int? get selectedListColor => _selectedListColor;
  bool get showCompletedTodos => _showCompletedTodos;

  // Methode zum Umschalten der Sichtbarkeit
  void toggleVisibility() {
    _showCompletedTodos = !_showCompletedTodos;
    notifyListeners();
  }

  /// Lädt die Informationen zur aktuell ausgewählten Liste.
  Future<void> fetchSelectedListInfo() async {
    if (selectedListId == null) return;

    try {
      final selectedListDoc =
      await _firestore.collection('lists').doc(selectedListId).get();
      final selectedListData = selectedListDoc.data();

      if (selectedListData != null) {
        _selectedListName = selectedListData['listName'] as String?;
        _selectedListIcon = selectedListData['listIcon'] as int?;
        _selectedListColor = selectedListData['listColor'] as int?;
        notifyListeners(); // UI aktualisieren
      }
    } catch (e) {
      print('[Error] Fetching selected list info: $e');
    }
  }

  /// Lädt die Todos für eine bestimmte `listId`.
  Future<void> fetchTodos(String listId) async {
    try {
      selectedListId = listId;

      // Fetch todos for the selected list
      final querySnapshot = await _firestore
          .collection('todos')
          .where('listId', isEqualTo: listId)
          .orderBy('order')
          .get();

      // Load todos into the local list
      _todos = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'documentId': doc.id,
          'taskName': data['taskName'],
          'taskCompleted': data['taskCompleted'],
          'order': data['order'],
        };
      }).toList();

      notifyListeners();
    } catch (e) {
      print('Error fetching todos: $e');
    }
  }


  /// Fügt ein neues Todo zur Liste hinzu.
  Future<void> addTodo(String? listId, String taskName) async {
    if (listId == null) {
      print('Error: listId is null');
      return;
    }

    try {
      int order = _todos.length;

      // Todo zur Datenbank hinzufügen
      final docRef = await _firestore.collection('todos').add({
        'listId': listId,
        'taskName': taskName,
        'taskCompleted': false,
        'order': order,
      });

      // Füge das Todo zur lokalen Liste hinzu
      _todos.add({
        'documentId': docRef.id,
        'taskName': taskName,
        'taskCompleted': false,
        'order': order,
      });

      notifyListeners();
      print('Todo erfolgreich zu Firestore hinzugefügt: ${docRef.id}');
    } catch (e) {
      print('Error adding todo to Firestore: $e');
    }
  }

  /// Aktualisiert den Namen eines spezifischen Todos.
  Future<void> updateTodoName(String documentId, String newTaskName) async {
    try {
      await _firestore.collection('todos').doc(documentId).update({
        'taskName': newTaskName,
      });

      // Aktualisiere das Todo in der lokalen Liste
      final index = _todos.indexWhere((todo) => todo['documentId'] == documentId);
      if (index != -1) {
        _todos[index]['taskName'] = newTaskName;
        notifyListeners();
      }
    } catch (e) {
      print('Error updating todo name: $e');
    }
  }

  /// Aktualisiert den Status eines Todos (abgeschlossen/nicht abgeschlossen).
  Future<void> updateTaskCompletionStatus(String documentId, bool isCompleted) async {
    try {
      await _firestore.collection('todos').doc(documentId).update({
        'taskCompleted': isCompleted,
      });

      // Aktualisiere den Status in der lokalen Liste
      final index = _todos.indexWhere((todo) => todo['documentId'] == documentId);
      if (index != -1) {
        _todos[index]['taskCompleted'] = isCompleted;
        notifyListeners();
      }
    } catch (e) {
      print('Error updating todo completion status: $e');
    }
  }

  /// Löscht ein spezifisches Todo.
  Future<void> deleteTodo(String documentId) async {
    try {
      await _firestore.collection('todos').doc(documentId).delete();

      // Lösche das Todo aus der lokalen Liste
      _todos.removeWhere((todo) => todo['documentId'] == documentId);
      notifyListeners();
    } catch (e) {
      print('Error deleting todo: $e');
    }
  }

  /// Aktualisiert die Reihenfolge der Todos.
  Future<void> reorderTodos(int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    // Todo lokal verschieben
    final movedTodo = _todos.removeAt(oldIndex);
    _todos.insert(newIndex, movedTodo);

    notifyListeners();

    // Reihenfolge in Firestore aktualisieren
    WriteBatch batch = _firestore.batch();
    for (int i = 0; i < _todos.length; i++) {
      final todo = _todos[i];
      final docRef = _firestore.collection('todos').doc(todo['documentId']);
      batch.update(docRef, {'order': i});
      todo['order'] = i;
    }
    await batch.commit();
  }

  /// Löscht alle Todos in der ausgewählten Liste.
  Future<void> deleteAllTodos() async {
    if (selectedListId != null) {
      try {
        final querySnapshot = await _firestore
            .collection('todos')
            .where('listId', isEqualTo: selectedListId)
            .get();

        WriteBatch batch = _firestore.batch();
        for (final doc in querySnapshot.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();

        _todos.clear();
        notifyListeners();
      } catch (e) {
        print('[Error] Deleting all todos: $e');
      }
    }
  }

  void resetState() {
    _todos = [];
    selectedListId = null;
    _selectedListName = null;
    _selectedListIcon = null;
    _selectedListColor = null;
    _showCompletedTodos = false;
    notifyListeners();
  }
}
