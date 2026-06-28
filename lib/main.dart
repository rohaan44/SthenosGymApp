import 'package:app/auth/auth_gate/auth_gate.dart';
import 'package:app/auth/auth_providers/auth_provider.dart';
import 'package:app/auth/auth_providers/test_provider.dart';
import 'package:app/providers/members/edit_member_provider.dart';
import 'package:app/providers/members/members_provider.dart';
import 'package:app/providers/payment_provider.dart';
import 'package:app/providers/gym_provider.dart';
import 'package:app/ui/routes/routes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyCUN89uPzff9NcJ6q1ypIVyPNWYpwycfL4",
      authDomain: "sthenos-gym-8de40.firebaseapp.com",
      projectId: "sthenos-gym-8de40",
      storageBucket: "sthenos-gym-8de40.firebasestorage.app",
      messagingSenderId: "589496774641",
      appId: "1:589496774641:web:5710ba9722081f6368de50",
    ),
  );
  // print("🔥 Firebase Initialized Successfully");

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<GymProvider>(create: (_) => GymProvider()),
        ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
        ChangeNotifierProvider<MembersProvider>(
          create: (_) => MembersProvider(),
        ),
        ChangeNotifierProvider<EditMemberProvider>(
          create: (_) => EditMemberProvider(),
        ),
        ChangeNotifierProvider<FirestoreTestProvider>(
          create: (_) => FirestoreTestProvider(),
        ),
        ChangeNotifierProvider<PaymentsProvider>(
          create: (_) => PaymentsProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    // Sizer must wrap MaterialApp to provide .w / .h / .sp extensions
    return Sizer(
      builder: (context, orientation, screenType) => MaterialApp(
        title: 'SthenosGymApp',

        // navigatorKey: appLevelKey,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF2563EB),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          fontFamily: 'Lato',
          cardTheme: CardThemeData(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            color: Colors.white,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
          ),
        ),
        home: const AuthGate(),
        onGenerateRoute: AppRouter.generateRoute,
        // home: SignUpScreen(),
        // home: FirestoreTestScreen(),
      ),
    );
  }
}

// GlobalKey<NavigatorState> appLevelKey = GlobalKey(debugLabel: 'app-key');
