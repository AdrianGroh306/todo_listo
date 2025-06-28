import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TodoState extends ChangeNotifier {
  List<Map<String, dynamic>> _todos = [];
  String? selectedListId;
  
  // Cache computed lists for better performance
  List<Map<String, dynamic>>? _cachedCompletedTodos;
  List<Map<String, dynamic>>? _cachedIncompleteTodos;
  bool _cacheValid = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> get todos => _todos;
  List<Map<String, dynamic>> get allTodos => _todos;
  
  List<Map<String, dynamic>> get completedTodos {
    if (!_cacheValid || _cachedCompletedTodos == null) {
      _cachedCompletedTodos = _todos.where((todo) => todo['taskCompleted'] == true).toList();
    }
    return _cachedCompletedTodos!;
  }
  
  List<Map<String, dynamic>> get incompleteTodos {
    if (!_cacheValid || _cachedIncompleteTodos == null) {
      _cachedIncompleteTodos = _todos.where((todo) => todo['taskCompleted'] == false).toList();
    }
    return _cachedIncompleteTodos!;
  }

  void _invalidateCache() {
    _cacheValid = false;
    _cachedCompletedTodos = null;
    _cachedIncompleteTodos = null;
  }

  @override
  void notifyListeners() {
    _invalidateCache();
    _cacheValid = true; // Mark as valid after recomputing
    super.notifyListeners();
  }

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

  // Get unique task names for autocomplete suggestions
  List<String> getUniqueTaskNames() {
    return _todos
        .map((todo) => todo['taskName'] as String)
        .where((name) => name.isNotEmpty)
        .toSet()
        .toList();
  }

  // Get frequency map for smart learning (tracks how often items are used)
  Map<String, int> getItemFrequency() {
    final frequencyMap = <String, int>{};
    
    for (final todo in _todos) {
      final taskName = (todo['taskName'] as String).toLowerCase().trim();
      if (taskName.isNotEmpty) {
        frequencyMap[taskName] = (frequencyMap[taskName] ?? 0) + 1;
      }
    }
    
    return frequencyMap;
  }

  // Get most frequently used items (for quick suggestions)
  List<String> getMostFrequentItems({int limit = 10}) {
    final frequencyMap = getItemFrequency();
    
    // Convert to list and sort by frequency
    final sortedItems = frequencyMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sortedItems
        .take(limit)
        .map((entry) => entry.key)
        .toList();
  }

  void resetState() {
    _todos.clear();
    selectedListId = null;
    notifyListeners();
  }
}