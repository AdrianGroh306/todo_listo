import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../states/todo_state.dart';

class SmartAddBottomSheet extends StatefulWidget {
  final Function(String) onSave;
  final VoidCallback onCancel;

  const SmartAddBottomSheet({
    super.key,
    required this.onSave,
    required this.onCancel,
  });

  @override
  State<SmartAddBottomSheet> createState() => _SmartAddBottomSheetState();
}

class _SmartAddBottomSheetState extends State<SmartAddBottomSheet> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<String> _suggestions = [];
  List<String> _userSuggestions = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  static const List<String> _commonSuggestions = [
    // Lebensmittel & Grundnahrungsmittel
    'Milch',
    'Brot',
    'Eier',
    'Käse',
    'Butter',
    'Äpfel',
    'Bananen',
    'Tomaten',
    'Kartoffeln',
    'Zwiebeln',
    'Hähnchen',
    'Hackfleisch',
    'Reis',
    'Nudeln',
    'Joghurt',
    'Orangensaft',
    'Kaffee',
    'Tee',
    'Zucker',
    'Salz',
    'Mehl',
    'Öl',
    'Essig',
    // Haushaltsartikel
    'Toilettenpapier',
    'Shampoo',
    'Seife',
    'Zahnpasta',
    'Putzmittel',
    'Waschmittel',
    'Spülmittel',
    'Küchenrollen',
    'Müllbeutel',
    // Drogerie
    'Vitamine',
    'Aspirin',
    'Pflaster',
    'Creme',
    // Sonstiges
    'Batterien',
    'Glühbirnen',
    'Hundefutter',
    'Katzenfutter',
  ];

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
    _loadUserSuggestions(); // Lade gespeicherte Vorschläge von Firebase
    
    // Einfachere Fokus-Behandlung da Padding extern gehandhabt wird
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showInitialSuggestions(); // Zeige häufige Items beim Start
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadUserSuggestions() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;
      
      final doc = await _firestore
          .collection('user_suggestions')
          .doc(userId)
          .get();
      
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final suggestions = List<String>.from(data['suggestions'] ?? []);
        setState(() {
          _userSuggestions = suggestions;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Fehler beim Laden der Vorschläge: $e');
      }
    }
  }

  Future<void> _saveUserSuggestion(String suggestion) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;
      
      final trimmed = suggestion.trim();
      if (trimmed.isEmpty) return;
      
      final existingIndex = _userSuggestions.indexWhere(
        (item) => item.toLowerCase() == trimmed.toLowerCase()
      );
      
      if (existingIndex != -1) {
        _userSuggestions.removeAt(existingIndex);
      }
      
      _userSuggestions.insert(0, trimmed);
      
      if (_userSuggestions.length > 50) {
        _userSuggestions = _userSuggestions.take(50).toList();
      }
      
      final userDoc = await _firestore
          .collection('user_suggestions')
          .doc(userId)
          .get();
      
      Map<String, int> frequencyMap = {};
      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        frequencyMap = Map<String, int>.from(data['frequency'] ?? {});
      }
      
      final lowerCaseItem = trimmed.toLowerCase();
      frequencyMap[lowerCaseItem] = (frequencyMap[lowerCaseItem] ?? 0) + 1;
      
      await _firestore
          .collection('user_suggestions')
          .doc(userId)
          .set({
        'suggestions': _userSuggestions,
        'frequency': frequencyMap,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      
    } catch (e) {
      if (kDebugMode) {
        print('Fehler beim Speichern der Vorschläge: $e');
      }
    }
  }

  void _showInitialSuggestions() async {
    final todoState = Provider.of<TodoState>(context, listen: false);
    final frequentItems = todoState.getMostFrequentItems(limit: 3);
    
    final userId = FirebaseAuth.instance.currentUser?.uid;
    Map<String, int> frequencyMap = {};
    
    if (userId != null) {
      try {
        final userDoc = await _firestore
            .collection('user_suggestions')
            .doc(userId)
            .get();
        
        if (userDoc.exists) {
          final data = userDoc.data() as Map<String, dynamic>;
          frequencyMap = Map<String, int>.from(data['frequency'] ?? {});
        }
      } catch (e) {
        if (kDebugMode) {
          print('Fehler beim Laden der Häufigkeits-Daten: $e');
        }
      }
    }
    
    // Sortiere Benutzereingaben nach Häufigkeit + Aktualität
    final sortedUserSuggestions = List<String>.from(_userSuggestions);
    sortedUserSuggestions.sort((a, b) {
      final freqA = frequencyMap[a.toLowerCase()] ?? 0;
      final freqB = frequencyMap[b.toLowerCase()] ?? 0;
      
      // Erst nach Häufigkeit, dann nach Position in der Liste (Aktualität)
      if (freqA != freqB) {
        return freqB.compareTo(freqA);
      }
      return _userSuggestions.indexOf(a).compareTo(_userSuggestions.indexOf(b));
    });
    
    final recentUserItems = sortedUserSuggestions.take(3).toList();
    
    final initialSuggestions = <String>[
      ...recentUserItems,
      ...frequentItems.where((item) => 
        !recentUserItems.any((recent) => recent.toLowerCase() == item.toLowerCase())
      ),
    ].take(3).toList();
    
    setState(() {
      _suggestions = initialSuggestions;
    });
  }

  void _onTextChanged() async {
    final text = _controller.text.toLowerCase().trim();
    final todoState = Provider.of<TodoState>(context, listen: false);
    
    if (text.isEmpty) {
      _showInitialSuggestions();
      return;
    }
    
    final userId = FirebaseAuth.instance.currentUser?.uid;
    Map<String, int> userFrequencyMap = {};
    
    if (userId != null) {
      try {
        final userDoc = await _firestore
            .collection('user_suggestions')
            .doc(userId)
            .get();
        
        if (userDoc.exists) {
          final data = userDoc.data() as Map<String, dynamic>;
          userFrequencyMap = Map<String, int>.from(data['frequency'] ?? {});
        }
      } catch (e) {
        if (kDebugMode) {
          print('Fehler beim Laden der Häufigkeits-Daten: $e');
        }
      }
    }
    
    final userMatches = _userSuggestions
        .where((suggestion) => suggestion.toLowerCase().contains(text))
        .toList();
    
    userMatches.sort((a, b) {
      final freqA = userFrequencyMap[a.toLowerCase()] ?? 0;
      final freqB = userFrequencyMap[b.toLowerCase()] ?? 0;
      if (freqA != freqB) {
        return freqB.compareTo(freqA);
      }
      return _userSuggestions.indexOf(a).compareTo(_userSuggestions.indexOf(b));
    });
    
    final todoFrequencyMap = todoState.getItemFrequency();
    
    final existingTodos = todoState.getUniqueTaskNames()
        .where((name) => name.toLowerCase().contains(text))
        .toList();
    
    existingTodos.sort((a, b) {
      final freqA = todoFrequencyMap[a.toLowerCase()] ?? 0;
      final freqB = todoFrequencyMap[b.toLowerCase()] ?? 0;
      return freqB.compareTo(freqA);
    });

    final commonMatches = _commonSuggestions
        .where((suggestion) => suggestion.toLowerCase().contains(text))
        .toList();
    
    commonMatches.sort((a, b) {
      final freqA = userFrequencyMap[a.toLowerCase()] ?? 0;
      final freqB = userFrequencyMap[b.toLowerCase()] ?? 0;
      return freqB.compareTo(freqA);
    });

    // Kombiniere mit verbesserter Priorität: 
    // 1. Häufigste Benutzereingaben
    // 2. Häufigste bestehende Todos  
    // 3. Standard-Vorschläge (sortiert nach User-Häufigkeit)
    final allSuggestions = <String>[
      ...userMatches.take(2), // Top 2 Benutzereingaben
      ...existingTodos.take(1).where((item) => 
        !userMatches.any((user) => user.toLowerCase() == item.toLowerCase())
      ),
      ...commonMatches.take(1).where((item) => 
        !userMatches.any((user) => user.toLowerCase() == item.toLowerCase()) &&
        !existingTodos.any((existing) => existing.toLowerCase() == item.toLowerCase())
      ),
    ].take(3).toList();

    setState(() {
      _suggestions = allSuggestions;
    });
  }

  void _handleSave() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      _saveUserSuggestion(text);
      widget.onSave(text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.onSurface.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: Row(
                children: [
                  Text(
                    'Add New Item',
                    style: TextStyle(
                      color: colorScheme.secondary,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: widget.onCancel,
                    icon: Icon(
                      Icons.close,
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      autofocus: false,
                      decoration: InputDecoration(
                        hintText: "What do you need?",
                        hintStyle: TextStyle(
                          color: colorScheme.onSurface.withOpacity(0.6),
                        ),
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: colorScheme.primary, width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                      ),
                      style: TextStyle(
                        color: colorScheme.secondary,
                        fontSize: 18,
                      ),
                      onSubmitted: (_) => _handleSave(),
                    ),
                    if (_suggestions.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      Text(
                        'Suggestions',
                        style: TextStyle(
                          color: colorScheme.onSurface.withOpacity(0.8),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _suggestions.take(6).map((suggestion) {
                          Color chipColor;
                          IconData? chipIcon;
                          
                          if (_userSuggestions.any((user) => 
                              user.toLowerCase() == suggestion.toLowerCase())) {
                            chipColor = colorScheme.secondary.withOpacity(0.15);
                            chipIcon = Icons.history;
                          } else if (Provider.of<TodoState>(context, listen: false)
                              .getUniqueTaskNames().any((todo) => 
                              todo.toLowerCase() == suggestion.toLowerCase())) {
                            chipColor = colorScheme.tertiary.withOpacity(0.15);
                            chipIcon = Icons.refresh;
                          } else {
                            chipColor = colorScheme.primary.withOpacity(0.15);
                            chipIcon = Icons.lightbulb_outline;
                          }
                          
                          return ActionChip(
                            avatar: Icon(
                              chipIcon,
                              size: 16,
                              color: colorScheme.onSurface.withOpacity(0.7),
                            ),
                            label: Text(
                              suggestion,
                              style: TextStyle(
                                color: colorScheme.onSurface,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            backgroundColor: chipColor,
                            side: BorderSide(
                              color: colorScheme.outline.withOpacity(0.2),
                            ),
                            onPressed: () {
                              _saveUserSuggestion(suggestion);
                              widget.onSave(suggestion);
                            },
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          );
                        }).toList(),
                      ),
                    ],
                    
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Add Item',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
