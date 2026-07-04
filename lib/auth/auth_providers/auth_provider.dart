import 'package:app/auth/auth_screens/admin_signin/admin_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final currentPasswordCtrl = TextEditingController();
  final newPasswordCtrl = TextEditingController();
  final confirmPasswordCtrl = TextEditingController();
  final changePasswordFormKey = GlobalKey<FormState>();

  bool hideCurrentPassword = true;
  bool hideNewPassword = true;
  bool hideConfirmPassword = true;

  bool loading = false;

  void toggleCurrentPassword() {
    hideCurrentPassword = !hideCurrentPassword;
    notifyListeners();
  }

  void toggleNewPassword() {
    hideNewPassword = !hideNewPassword;
    notifyListeners();
  }

  void toggleConfirmPassword() {
    hideConfirmPassword = !hideConfirmPassword;
    notifyListeners();
  }

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


Future<String> changePassword({
  required String currentPassword,
  required String newPassword,
}) async {
  loading = true;
  notifyListeners();

  try {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return "User not logged in.";
    }

    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );

    await user.reauthenticateWithCredential(credential);
    await user.updatePassword(newPassword);

    return "Password changed successfully.";
  } on FirebaseAuthException catch (e) {
    switch (e.code) {
      case "wrong-password":
      case "invalid-credential":
        return "Current password is incorrect.";

      case "weak-password":
        return "Password must be at least 6 characters.";

      case "requires-recent-login":
        return "Please sign in again and try.";

      default:
        return e.message ?? "Something went wrong.";
    }
  } finally {
    loading = false;
    notifyListeners();
  }
}
  // Future<String> changePassword({
  //   required String currentPassword,
  //   required String newPassword,
  // }) async {
  //   try {
  //     final user = FirebaseAuth.instance.currentUser;

  //     if (user == null) {
  //       return "User not logged in.";
  //     }

  //     final credential = EmailAuthProvider.credential(
  //       email: user.email!,
  //       password: currentPassword,
  //     );

  //     // Verify current password
  //     await user.reauthenticateWithCredential(credential);

  //     // Update password
  //     await user.updatePassword(newPassword);

  //     return "Password changed successfully.";
  //   } on FirebaseAuthException catch (e) {
  //     switch (e.code) {
  //       case "wrong-password":
  //       case "invalid-credential":
  //         return "Current password is incorrect.";

  //       case "weak-password":
  //         return "Password should be at least 6 characters.";

  //       case "requires-recent-login":
  //         return "Please log in again and try.";

  //       default:
  //         return e.message ?? "Something went wrong.";
  //     }
  //   } catch (e) {
  //     return e.toString();
  //   }
  // }

  String? currentPasswordValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Current password is required";
    }
    return null;
  }

  String? newPasswordValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "New password is required";
    }

    if (value.length < 6) {
      return "Password must be at least 6 characters";
    }

    if (value.trim() == currentPasswordCtrl.text.trim()) {
      return "New password must be different";
    }

    return null;
  }

  String? confirmPasswordValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Confirm password is required";
    }

    if (value.trim() != newPasswordCtrl.text.trim()) {
      return "Passwords do not match";
    }

    return null;
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    currentPasswordCtrl.dispose();
    newPasswordCtrl.dispose();
    confirmPasswordCtrl.dispose();
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
