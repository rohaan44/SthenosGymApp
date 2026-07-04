import 'package:app/auth/auth_providers/auth_provider.dart';
import 'package:app/auth/auth_screens/admin_signin/admin_sign_in.dart';
import 'package:app/main.dart';
import 'package:app/screens/main_dashboard_screen.dart';
import 'package:app/service/inactivity_service.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AuthGate
//
// Listens to Firebase authStateChanges and routes the user to either
// MainDashboardScreen (authenticated) or AdminSignIn (unauthenticated).
//
// Also the canonical wiring point for InactivityService:
//   • user logged in  → InactivityService().start(...)
//   • user logged out → InactivityService().stop()
// ─────────────────────────────────────────────────────────────────────────────
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _serviceRunning = false;

  void _startInactivityService(AuthProvider authProvider) {
    if (_serviceRunning) return;
    _serviceRunning = true;
    InactivityService().start(appNavigatorKey, authProvider);
  }

  void _stopInactivityService() {
    if (!_serviceRunning) return;
    _serviceRunning = false;
    InactivityService().stop();
  }

  @override
  void dispose() {
    _stopInactivityService();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFF2563EB)),
            ),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          // User is authenticated — ensure the inactivity service is running.
          _startInactivityService(authProvider);
          return const MainDashboardScreen();
        }

        // User is logged out — stop the inactivity service.
        _stopInactivityService();
        return const AdminSignIn();
      },
    );
  }
}
