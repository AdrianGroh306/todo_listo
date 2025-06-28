import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../states/todo_state.dart';

class SmartAddDialog extends StatefulWidget {
  final Function(String) onSave;
  final VoidCallback onCancel;

  const SmartAddDialog({
    super.key,
    required this.onSave,
    required this.onCancel,
  });

  @override
  State<SmartAddDialog> createState() => _SmartAddDialogState();
}

class _SmartAddDialogState extends State<SmartAddDialog> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<String> _suggestions = [];
  List<String> _userSuggestions = []; // Firebase-gespeicherte Benutzereingaben
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // German shopping-focused suggestions with frequency tracking
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
    
    // Verbesserte Fokus-Behandlung für iOS
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          _focusNode.requestFocus();
        }
      });
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

  // Lade gespeicherte Benutzereingaben von Firebase
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
      print('Fehler beim Laden der Vorschläge: $e');
    }
  }

  // Speichere neue Benutzereingabe in Firebase mit Häufigkeits-Tracking
  Future<void> _saveUserSuggestion(String suggestion) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;
      
      final trimmed = suggestion.trim();
      if (trimmed.isEmpty) return;
      
      // Prüfe ob schon in User-Suggestions vorhanden (case-insensitive)
      final existingIndex = _userSuggestions.indexWhere(
        (item) => item.toLowerCase() == trimmed.toLowerCase()
      );
      
      if (existingIndex != -1) {
        // Entferne alte Version und füge aktualisierte Version vorne hinzu
        _userSuggestions.removeAt(existingIndex);
      }
      
      // Füge an den Anfang hinzu (most recently used)
      _userSuggestions.insert(0, trimmed);
      
      // Begrenze auf 50 gespeicherte Eingaben
      if (_userSuggestions.length > 50) {
        _userSuggestions = _userSuggestions.take(50).toList();
      }
      
      // Lade bestehende Häufigkeits-Daten von Firebase
      final userDoc = await _firestore
          .collection('user_suggestions')
          .doc(userId)
          .get();
      
      Map<String, int> frequencyMap = {};
      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        frequencyMap = Map<String, int>.from(data['frequency'] ?? {});
      }
      
      // Erhöhe Häufigkeitszähler
      final lowerCaseItem = trimmed.toLowerCase();
      frequencyMap[lowerCaseItem] = (frequencyMap[lowerCaseItem] ?? 0) + 1;
      
      // Speichere in Firebase
      await _firestore
          .collection('user_suggestions')
          .doc(userId)
          .set({
        'suggestions': _userSuggestions,
        'frequency': frequencyMap,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      
    } catch (e) {
      print('Fehler beim Speichern der Vorschläge: $e');
    }
  }

  // Zeige intelligente Vorschläge basierend auf Firebase-Daten
  void _showInitialSuggestions() async {
    final todoState = Provider.of<TodoState>(context, listen: false);
    final frequentItems = todoState.getMostFrequentItems(limit: 3);
    
    // Lade gespeicherte Häufigkeits-Daten von Firebase
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
        print('Fehler beim Laden der Häufigkeits-Daten: $e');
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
      ...recentUserItems, // Häufigste + neueste Benutzereingaben zuerst
      ...frequentItems.where((item) => 
        !recentUserItems.any((recent) => recent.toLowerCase() == item.toLowerCase())
      ),
    ].take(3).toList(); // Nur 3 Chips anzeigen
    
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
    
    // Lade gespeicherte Häufigkeits-Daten von Firebase für bessere Sortierung
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
        print('Fehler beim Laden der Häufigkeits-Daten: $e');
      }
    }
    
    // Benutzerdefinierte Vorschläge mit Häufigkeits-Sortierung
    final userMatches = _userSuggestions
        .where((suggestion) => suggestion.toLowerCase().contains(text))
        .toList();
    
    userMatches.sort((a, b) {
      final freqA = userFrequencyMap[a.toLowerCase()] ?? 0;
      final freqB = userFrequencyMap[b.toLowerCase()] ?? 0;
      if (freqA != freqB) {
        return freqB.compareTo(freqA); // Häufigere zuerst
      }
      // Bei gleicher Häufigkeit: kürzlich verwendete zuerst
      return _userSuggestions.indexOf(a).compareTo(_userSuggestions.indexOf(b));
    });
    
    // Häufigkeits-Daten aus TodoState für bestehende Todos
    final todoFrequencyMap = todoState.getItemFrequency();
    
    // Bestehende Todos mit Häufigkeits-Sortierung
    final existingTodos = todoState.getUniqueTaskNames()
        .where((name) => name.toLowerCase().contains(text))
        .toList();
    
    existingTodos.sort((a, b) {
      final freqA = todoFrequencyMap[a.toLowerCase()] ?? 0;
      final freqB = todoFrequencyMap[b.toLowerCase()] ?? 0;
      return freqB.compareTo(freqA);
    });

    // Häufige Vorschläge aus der Standard-Liste
    final commonMatches = _commonSuggestions
        .where((suggestion) => suggestion.toLowerCase().contains(text))
        .toList();
    
    // Sortiere Standard-Vorschläge nach User-Häufigkeit falls vorhanden
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
    ].take(3).toList(); // Nur 3 Chips anzeigen

    setState(() {
      _suggestions = allSuggestions;
    });
  }

  void _handleSave() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      // Speichere die Benutzereingabe für zukünftige Vorschläge
      _saveUserSuggestion(text);
      widget.onSave(text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final screenHeight = MediaQuery.of(context).size.height;

    return Align(
      alignment: bottomInset > 0 
        ? Alignment(0, -0.3) // Etwas über der Mitte wenn Tastatur offen
        : Alignment.center, // Zentriert wenn Tastatur zu
      child: Padding(
        padding: EdgeInsets.only(
          top: 20,
          left: 20,
          right: 20,
          bottom: bottomInset > 0 ? bottomInset + 20 : 20, // Abstand über der Tastatur
        ),
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: double.infinity,
            constraints: BoxConstraints(
              maxHeight: bottomInset > 0 
                ? screenHeight * 0.35 // Kompakter wenn Tastatur offen
                : screenHeight * 0.45, // Mehr Platz wenn Tastatur zu
            ),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
                  child: Text(
                    'New Item',
                    style: TextStyle(
                      color: colorScheme.secondary,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                // Content
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Input field
                        TextField(
                          controller: _controller,
                          focusNode: _focusNode,
                          autofocus: true,
                          decoration: InputDecoration(
                            hintText: "Enter item...",
                            hintStyle: TextStyle(
                              color: colorScheme.onSurface.withOpacity(0.6),
                            ),
                            filled: true,
                            fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: colorScheme.primary, width: 2),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          style: TextStyle(
                            color: colorScheme.secondary,
                            fontSize: 16,
                          ),
                          onSubmitted: (_) => _handleSave(),
                        ),
                        
                        // Suggestion chips
                        if (_suggestions.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            children: _suggestions.take(3).map((suggestion) {
                              Color chipColor;
                              if (_userSuggestions.any((user) => 
                                  user.toLowerCase() == suggestion.toLowerCase())) {
                                chipColor = colorScheme.secondary.withOpacity(0.1);
                              } else if (Provider.of<TodoState>(context, listen: false)
                                  .getUniqueTaskNames().any((todo) => 
                                  todo.toLowerCase() == suggestion.toLowerCase())) {
                                chipColor = colorScheme.tertiary.withOpacity(0.1);
                              } else {
                                chipColor = colorScheme.primary.withOpacity(0.1);
                              }
                              
                              return ActionChip(
                                label: Text(
                                  suggestion,
                                  style: TextStyle(
                                    color: colorScheme.onSurface,
                                    fontSize: 13,
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
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              );
                            }).toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                // Actions - näher am Content
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 16), // Weniger Abstand
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: widget.onCancel,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.outline.withOpacity(0.1),
                          foregroundColor: colorScheme.onSurface.withOpacity(0.7),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: _handleSave,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Add'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
