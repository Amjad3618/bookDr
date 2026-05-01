import 'package:bookdr/widgets/bottom_nav_bar.dart';
import 'package:flutter/material.dart';

import '../views/Register/register_view.dart';
import '../views/login/login_view.dart';
import 'route_names.dart';

class AppRoutes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.logindr:
        return MaterialPageRoute(builder: (_) => const LoginView());

      case RouteNames.registerdr:
        return MaterialPageRoute(builder: (_) => const RegisterView());
         case RouteNames.mainscreen:
        return MaterialPageRoute(builder: (_) => const MainScreen());

      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('Route not found'))),
        );
    }
  }
}
