import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TodoState extends ChangeNotifier {
  List<Map<String, dynamic>> _todos = [];
  String? selectedListId;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> get todos => _todos;
  List<Map<String, dynamic>> get allTodos => _todos;
  List<Map<String, dynamic>> get completedTodos =>
      _todos.where((todo) => todo['taskCompleted'] == true).toList();
  List<Map<String, dynamic>> get incompleteTodos =>
      _todos.where((todo) => todo['taskCompleted'] == false).toList();

  Future<void> fetchTodos(String listId) async {
    try {
      selectedListId = listId;
      
      final query = _firestore
          .collection('todos')
          .where('listId', isEqualTo: listId)
          .orderBy('order', descending: false);
      final snapshot = await query.get();
      
      _todos = snapshot.docs.map((doc) {
        final data = doc.data();
        data['documentId'] = doc.id;
        return data;
      }).toList();
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching todos: $e');
    }
  }

  Future<void> addTodo(String taskName, String listId) async {
    if (taskName.trim().isEmpty) return;

    try {
      final todoData = {
        'taskName': taskName.trim(),
        'taskCompleted': false,
        'listId': listId,
        'order': _todos.length,
        'createdAt': Timestamp.now(),
      };

      final docRef = await _firestore.collection('todos').add(todoData);
      
      final newTodo = {...todoData, 'documentId': docRef.id};
      _todos.add(newTodo);
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding todo: $e');
    }
  }

  Future<void> updateTodo(String documentId, String newTaskName) async {
    if (newTaskName.trim().isEmpty) return;

    try {
      await _firestore.collection('todos').doc(documentId).update({
        'taskName': newTaskName.trim(),
      });

      final index = _todos.indexWhere((todo) => todo['documentId'] == documentId);
      if (index != -1) {
        _todos[index]['taskName'] = newTaskName.trim();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating todo: $e');
    }
  }

  Future<void> toggleTodoCompletion(String documentId) async {
    final index = _todos.indexWhere((todo) => todo['documentId'] == documentId);
    if (index == -1) return;

    final wasCompleted = _todos[index]['taskCompleted'] as bool;
    final newStatus = !wasCompleted;

    // Update UI immediately
    _todos[index]['taskCompleted'] = newStatus;
    notifyListeners();

    try {
      await _firestore.collection('todos').doc(documentId).update({
        'taskCompleted': newStatus,
      });
    } catch (e) {
      debugPrint('Error toggling todo completion: $e');
      // Revert on error
      _todos[index]['taskCompleted'] = wasCompleted;
      notifyListeners();
    }
  }

  Future<void> deleteTodo(String documentId) async {
    try {
      _todos.removeWhere((todo) => todo['documentId'] == documentId);
      notifyListeners();
      
      await _firestore.collection('todos').doc(documentId).delete();
    } catch (e) {
      debugPrint('Error deleting todo: $e');
    }
  }

  Future<void> deleteCompletedTodos() async {
    final completedTodos = _todos.where((todo) => todo['taskCompleted'] == true).toList();
    if (completedTodos.isEmpty) return;

    final documentsToDelete = completedTodos.map((todo) => todo['documentId'] as String).toList();
    
    _todos.removeWhere((todo) => todo['taskCompleted'] == true);
    notifyListeners();

    try {
      final batch = _firestore.batch();
      for (final docId in documentsToDelete) {
        batch.delete(_firestore.collection('todos').doc(docId));
      }
      await batch.commit();
    } catch (e) {
      debugPrint('Error deleting completed todos: $e');
    }
  }

  Future<void> reorderTodos(int oldIndex, int newIndex) async {
    if (oldIndex == newIndex) return;
    
    final incompleteTodos = this.incompleteTodos;
    if (oldIndex >= incompleteTodos.length || newIndex >= incompleteTodos.length) return;

    // Adjust newIndex if moving down
    if (newIndex > oldIndex) {
      newIndex--;
    }

    // Update local state immediately for smooth UI
    final movedTodo = incompleteTodos.removeAt(oldIndex);
    incompleteTodos.insert(newIndex, movedTodo);

    // Update order values
    for (int i = 0; i < incompleteTodos.length; i++) {
      incompleteTodos[i]['order'] = i;
    }

    // Update the main _todos list
    final completedTodos = this.completedTodos;
    _todos = [...incompleteTodos, ...completedTodos];
    
    notifyListeners();

    // Batch update Firestore
    try {
      final batch = _firestore.batch();
      for (int i = 0; i < incompleteTodos.length; i++) {
        final todo = incompleteTodos[i];
        final docRef = _firestore.collection('todos').doc(todo['documentId']);
        batch.update(docRef, {'order': i});
      }
      await batch.commit();
    } catch (e) {
      debugPrint('Error reordering todos: $e');
      // Revert on error
      fetchTodos(selectedListId!);
    }
  }

  void resetState() {
    _todos.clear();
    selectedListId = null;
    notifyListeners();
  }
}