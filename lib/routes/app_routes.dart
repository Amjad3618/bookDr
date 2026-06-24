// lib/routes/app_routes.dart
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/dr_model.dart';
import '../providers/gig_details_provider.dart';
import '../views/Register/register_view.dart';
import '../views/login/login_view.dart';
import '../views/details_screens/gigs_details_view.dart';
import '../widgets/bottom_nav_bar.dart';

class RouteNames {
  static const String logindr         = '/login';
  static const String registerdr      = '/register';
  static const String mainscreen      = '/MainScreen';
  static const String doctorDetail    = '/doctor-detail';
  static const String bookAppointment = '/book-appointment';
  static const String gigsdetails     = '/gigsdetails';
}

class AppRoutes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {

      case RouteNames.logindr:
        return MaterialPageRoute(builder: (_) => const LoginView());

      case RouteNames.registerdr:
        return MaterialPageRoute(builder: (_) => const RegisterView());

      case RouteNames.mainscreen:
        return MaterialPageRoute(builder: (_) => const MainScreen());

      // ── Gig details ────────────────────────────────────────────────────
      case RouteNames.gigsdetails:
        final gig = settings.arguments as GigModel;
        // Provider created & populated HERE — before the route animation
        // starts — so nothing async touches the UI thread during the push
        final provider = GigDetailsProvider()..setGig(gig);
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider.value(
            value: provider,
            child: GigDetailsView(gig: gig),
          ),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Route not found')),
          ),
        );
    }
  }
}