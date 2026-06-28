import 'package:app/auth/auth_providers/auth_provider.dart';
import 'package:app/auth/auth_providers/test_provider.dart';
import 'package:app/providers/gym_provider.dart';
import 'package:app/providers/members/edit_member_provider.dart';
import 'package:app/providers/members/members_provider.dart';
import 'package:app/providers/payment_provider.dart';
import 'package:app/screens/main_dashboard_screen.dart';
import 'package:app/ui/helpers/color_helper.dart';
import 'package:app/ui/routes/routes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  /// Status Bar
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarContrastEnforced: false,
    ),
  );

  /// Portrait Only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const AppRoot());
}

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GymProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MembersProvider()),
        ChangeNotifierProvider(create: (_) => EditMemberProvider()),
        ChangeNotifierProvider(create: (_) => FirestoreTestProvider()),
        ChangeNotifierProvider(create: (_) => PaymentsProvider()),
      ],
      child: const MyApp(),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, screenType) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: "Sthenos Gym",

          home: const MainDashboardScreen(),

          onGenerateRoute: AppRouter.generateRoute,

          theme: ThemeData(
            useMaterial3: true,
            fontFamily: "Lato",

            brightness: Brightness.light,

            scaffoldBackgroundColor: AppColor.black,

            //  const Color(0xFFF9FAFB),
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColor.cFFFFFF,
              // const Color(0xFF2563EB),
              brightness: Brightness.light,
            ),

            appBarTheme: const AppBarTheme(
              elevation: 0,
              centerTitle: false,
              backgroundColor: Colors.black,
              surfaceTintColor: Colors.transparent,
              foregroundColor: Colors.white,
              systemOverlayStyle: SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: Brightness.light,
                statusBarBrightness: Brightness.light,
              ),
            ),

            cardTheme: CardThemeData(
              elevation: 0,
              color: AppColor.c252525,
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                // side: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
            ),
            dividerColor: const Color(0xFFE5E7EB),

            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColor.white, width: 1.4),
              ),
            ),
          ),
        );
      },
    );
  }
}

// import 'package:app/auth/auth_providers/auth_provider.dart';
// import 'package:app/auth/auth_providers/test_provider.dart';
// import 'package:app/providers/members/edit_member_provider.dart';
// import 'package:app/providers/members/members_provider.dart';
// import 'package:app/providers/payment_provider.dart';
// import 'package:app/screens/main_dashboard_screen.dart';
// import 'package:app/providers/gym_provider.dart';
// import 'package:app/ui/routes/routes.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:sizer/sizer.dart';

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   await Firebase.initializeApp(
//     options: const FirebaseOptions(
//       apiKey: "AIzaSyCUN89uPzff9NcJ6q1ypIVyPNWYpwycfL4",
//       authDomain: "sthenos-gym-8de40.firebaseapp.com",
//       projectId: "sthenos-gym-8de40",
//       storageBucket: "sthenos-gym-8de40.firebasestorage.app",
//       messagingSenderId: "589496774641",
//       appId: "1:589496774641:web:5710ba9722081f6368de50",
//     ),
//   );
//   // print("🔥 Firebase Initialized Successfully");

//   runApp(
//     MultiProvider(
//       providers: [
//         ChangeNotifierProvider<GymProvider>(create: (_) => GymProvider()),
//         ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
//         ChangeNotifierProvider<MembersProvider>(
//           create: (_) => MembersProvider(),
//         ),
//         ChangeNotifierProvider<EditMemberProvider>(
//           create: (_) => EditMemberProvider(),
//         ),
//         ChangeNotifierProvider<FirestoreTestProvider>(
//           create: (_) => FirestoreTestProvider(),
//         ),
//         ChangeNotifierProvider<PaymentsProvider>(
//           create: (_) => PaymentsProvider(),
//         ),
//       ],
//       child: const MyApp(),
//     ),
//   );
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//   @override
//   Widget build(BuildContext context) {
//     // Sizer must wrap MaterialApp to provide .w / .h / .sp extensions
//     return Sizer(
//       builder: (context, orientation, screenType) => MaterialApp(
//         title: 'SthenosGymApp',

//         // navigatorKey: appLevelKey,
//         debugShowCheckedModeBanner: false,
//         theme: ThemeData(
//           colorScheme: ColorScheme.fromSeed(
//             seedColor: const Color(0xFF2563EB),
//             brightness: Brightness.light,
//           ),
//           useMaterial3: true,
//           fontFamily: 'Lato',
//           cardTheme: CardThemeData(
//             elevation: 0,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//               side: const BorderSide(color: Color(0xFFE5E7EB)),
//             ),
//             color: Colors.white,
//           ),
//           appBarTheme: const AppBarTheme(
//             backgroundColor: Colors.white,
//             elevation: 0,
//             surfaceTintColor: Colors.transparent,
//           ),
//         ),
//         home: const MainDashboardScreen(),
//         onGenerateRoute: AppRouter.generateRoute,
//         // home: SignUpScreen(),
//         // home: FirestoreTestScreen(),
//       ),
//     );
//   }
// }

// // GlobalKey<NavigatorState> appLevelKey = GlobalKey(debugLabel: 'app-key');
