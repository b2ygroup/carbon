// lib/providers/user_provider.dart (Versão MÍNIMA CORRIGIDA)
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import CORRETO

class UserProvider with ChangeNotifier {
  String? _userId; String? _userEmail;
  // Removido _userName, _cpf, etc para simplificar ao máximo por enquanto
  String? get userId => _userId; String? get userEmail => _userEmail;
  bool get isLoggedIn => _userId != null;
  Future<void> loadUserData(String uid) async { _userId = uid; _userEmail = FirebaseAuth.instance.currentUser?.email; print('UserProvider Minimal: User ID set: $uid'); notifyListeners(); }
  void clearUserDataOnLogout() { _userId = null; _userEmail = null; print('UserProvider Minimal: Data cleared'); notifyListeners(); }
}