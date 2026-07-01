import 'package:app/auth/auth_screens/admin_signin/admin_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  User? _user;
  User? get user => _user;

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  bool _forgotisLoading = false;
  bool get forgotIsLoading => _forgotisLoading;

  String? _error;
  String? get error => _error;

  bool obscurePassword = true;

  void togglePasswordVisibility() {
    obscurePassword = !obscurePassword;
    notifyListeners();
  }

  authProvider() {
    _user = _auth.currentUser;
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
  // NOTE: This now uses direct widget navigation (MaterialPageRoute)
  // instead of Navigator.pushNamed(), because AdminSignIn is not
  // registered as a named route in this app (login uses
  // MaterialPageRoute too, see AdminSignIn's Login button).
  // This avoids the "Unknown route" error.
  Future<void> logout(BuildContext context) async {
    await _auth.signOut();
    _user = null;
    notifyListeners();

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const AdminSignIn()),
      (route) => false,
    );
  }

  // =========================
  // LOADING
  // =========================
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setforgotLoading(bool value) {
    _forgotisLoading = value;
    notifyListeners();
  }

  Future<bool> forgotPassword(String email) async {
    try {
      _setforgotLoading(true);
      _error = null;

      debugPrint("🔐 forgotpassword START");

      await _auth.sendPasswordResetEmail(email: email.trim());

      debugPrint("✅ forgotPassword Success");

      _setforgotLoading(false);
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _handleError(e);

      debugPrint("❌forgotPassword ERROR: ${e.code} - ${e.message}");

      _setforgotLoading(false);
      notifyListeners();
      return false;
    } catch (e) {
      _error = "Something went wrong";

      debugPrint("❌ UNKNOWN LOGIN ERROR: $e");

      _setforgotLoading(false);
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
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
