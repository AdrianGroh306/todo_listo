import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthState extends ChangeNotifier {
  User? _user;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get user => _user;

  AuthState() {
    _auth.authStateChanges().listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  Future<void> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      print('Login error: $e');
    }
  }

  Future<void> signOutUser() async {
    try {
      await _auth.signOut();
      notifyListeners();
    } catch (e) {
      print('Error signing out: $e');
    }
  }
}