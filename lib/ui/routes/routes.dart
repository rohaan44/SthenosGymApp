import 'package:app/providers/members/add_member_provider.dart';
import 'package:app/screens/member/add_member_screen.dart';
import 'package:app/screens/member/members_screen.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_routes.dart';
// import 'package:app/ui/screens/splash_screen.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // case AppRoutes.loginView:
      //   return MaterialPageRoute(
      //     builder: (_) => const LoginView(),
      //   );
      case AppRoutes.membersScreen:
        return MaterialPageRoute(
          builder: (_) => const MembersScreen(),
        );
      case AppRoutes.addMemberScreen:
        // ChangeNotifierProvider is scoped to this route:
        // AddMemberProvider (and all its TextEditingControllers) is created
        // fresh when the screen opens and disposed when the user pops back.
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (_) => AddMemberProvider(),
            child: const AddMemberScreen(),
          ),
        );
      // case AppRoutes.splashScreen:
      //   return MaterialPageRoute(
      //     builder: (_) => const SplashScreen(),
      //   );
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Error: Unknown route')),
          ),
        );
    }
  }
}