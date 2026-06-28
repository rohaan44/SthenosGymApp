import 'package:app/auth/auth_screens/sign_in/sign_in_screen.dart';
import 'package:app/ui/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? _user;
  User? get user => _user;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  authProvider() {
    _user = _auth.currentUser;
  }

  // =========================
  // SIGN UP
  // =========================
  Future<bool> signUp(context, String email, String password) async {
    try {
      _setLoading(true);
      _error = null;

      debugPrint("🔥 SIGNUP START");

      final result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      _user = result.user;

      debugPrint("✅ SIGNUP SUCCESS: ${_user?.uid}");

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SignInScreen()),
      );

      _setLoading(false);
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _handleError(e);

      debugPrint("❌ SIGNUP ERROR: ${e.code} - ${e.message}");

      _setLoading(false);
      notifyListeners();
      return false;
    } catch (e) {
      _error = "Something went wrong";

      debugPrint("❌ UNKNOWN ERROR: $e");

      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  // =========================
  // SIGN IN
  // =========================
  Future<bool> signIn(String email, String password) async {
    try {
      _setLoading(true);
      _error = null;

      debugPrint("🔐 LOGIN START");

      final result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      _user = result.user;

      debugPrint("✅ LOGIN SUCCESS: ${_user?.uid}");

      _setLoading(false);
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _handleError(e);

      debugPrint("❌ LOGIN ERROR: ${e.code} - ${e.message}");

      _setLoading(false);
      notifyListeners();
      return false;
    } catch (e) {
      _error = "Something went wrong";

      debugPrint("❌ UNKNOWN LOGIN ERROR: $e");

      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  // =========================
  // LOGOUT
  // =========================
  Future<void> logout(context) async {
    await _auth.signOut();
    _user = null;
    notifyListeners();

    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AppRoutes.loginView, (route) => false);
  }

  // =========================
  // LOADING
  // =========================
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // =========================
  // ERROR HANDLER
  // =========================
  String _handleError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return "Email already registered";
      case 'invalid-email':
        return "Invalid email format";
      case 'weak-password':
        return "Password too weak";
      case 'user-not-found':
        return "User not found";
      case 'wrong-password':
        return "Wrong password";
      default:
        return e.message ?? "Authentication failed";
    }
  }
}
