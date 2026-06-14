// import 'package:app/auth/auth_providers/auth_provider.dart';
// import 'package:app/auth/auth_screens/sign_in/sign_in_screen.dart';
// import 'package:app/auth/auth_screens/sign_up/sign_up_screen.dart';
// import 'package:app/main.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// class AuthGate extends StatelessWidget {
//   const AuthGate({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final auth = Provider.of<AuthProvider>(context);

//     // 🔥 IMPORTANT: WAIT UNTIL INIT COMPLETE
//     if (!auth.initialized) {
//       return const Scaffold(body: Center(child: CircularProgressIndicator()));
//     }

//     // logged in
//     if (auth.user != null) {
//       return MainScaffold();
//     }

//     // first time
//     if (!auth.adminExists) {
//       return const SignUpScreen();
//     }

//     // normal login
//     return const SignInScreen();
//   }
// }
