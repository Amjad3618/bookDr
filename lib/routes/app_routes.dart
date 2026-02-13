import 'package:flutter/material.dart';

import '../views/Register/dr/register_view_dr.dart';
import '../views/login/dr/login_viewdr.dart';
import 'route_names.dart';

class AppRoutes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.logindr:
        return MaterialPageRoute(builder: (_) => const LoginViewDr());

      case RouteNames.registerdr:
        return MaterialPageRoute(builder: (_) => const RegisterViewDr());

      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('Route not found'))),
        );
    }
  }
}
