import 'package:app/auth/auth_gate/auth_gate.dart';
import 'package:app/auth/auth_providers/auth_provider.dart';
import 'package:app/auth/auth_providers/test_provider.dart';
import 'package:app/providers/gym_provider.dart';
import 'package:app/providers/members/members_provider.dart';
import 'package:app/providers/payment_provider.dart';
import 'package:app/service/connectivity_service.dart';
import 'package:app/ui/helpers/color_helper.dart';
import 'package:app/ui/routes/routes.dart';
import 'package:app/widgets/no_internet_overlay.dart';
import 'package:camera/camera.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

List<CameraDescription> cameras = [];

/// App-level navigator key used by [InactivityService] to navigate
/// without a BuildContext (safe from timer callbacks).
final GlobalKey<NavigatorState> appNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'app-nav-key');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    cameras = await availableCameras();
  } catch (_) {
    // Ignore camera init errors if offline
  }

  // Web-only: pre-check internet before Firebase JS SDK dynamic import
  if (kIsWeb) {
    final hasNet = await _hasInternetBeforeInit();
    if (!hasNet) {
      runApp(const _NoInternetInitApp());
      return;
    }
  }

  try {
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

    await ConnectivityService().initialize();
  } catch (e) {
    runApp(const _FirebaseInitFailureApp());
    return;
  }

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
        ChangeNotifierProvider(
          create: (_) => GymProvider(),
        ),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MembersProvider()),
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
          navigatorKey: appNavigatorKey,
          builder: (context, child) => NoInternetOverlay(child: child ?? const SizedBox()),

          home:
              // AdminAuthDialog(),
              const AuthGate(),
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

// (appNavigatorKey is now declared at the top of this file and used in MaterialApp)

// ─────────────────────────────────────────────────────────────────────────────
// PRE-INIT ERROR HANDLING
// ─────────────────────────────────────────────────────────────────────────────

Future<bool> _hasInternetBeforeInit() async {
  try {
    final response = await http.get(
      Uri.parse('https://www.gstatic.com/firebasejs/12.14.0/firebase-app.js'),
    ).timeout(const Duration(seconds: 3));
    return response.statusCode == 200;
  } catch (_) {
    return false;
  }
}

class _NoInternetInitApp extends StatelessWidget {
  const _NoInternetInitApp();

  @override
  Widget build(BuildContext context) {
    return const _InitErrorScreen(
      title: 'No Internet Connection',
      message: 'Please connect to the internet to load Sthenos Gym.',
      icon: Icons.wifi_off_rounded,
    );
  }
}

class _FirebaseInitFailureApp extends StatelessWidget {
  const _FirebaseInitFailureApp();

  @override
  Widget build(BuildContext context) {
    return const _InitErrorScreen(
      title: 'Initialization Failed',
      message: 'Unable to connect to the server. Please check your connection and try again.',
      icon: Icons.error_outline_rounded,
    );
  }
}

class _InitErrorScreen extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;

  const _InitErrorScreen({
    required this.title,
    required this.message,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFF151515), // AppColor.c151515
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: Color(0xFF252525), // AppColor.c252525
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 64,
                  color: const Color(0xFFE53935), // AppColor.red
                ),
              ),
              const SizedBox(height: 32),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'Lato',
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withValues(alpha: 0.7),
                    fontFamily: 'Lato',
                  ),
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: () {
                  // Re-run main to try again
                  main();
                },
                icon: const Icon(Icons.refresh, color: Colors.white),
                label: const Text(
                  'Retry',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE53935), // AppColor.red
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
