import 'package:bookdr/widgets/bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../views/login/login_view.dart';
import '../views/splash_view/splash_view.dart';


class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _logoCtrl;
  late Animation<double> _logoAnim;

  @override
  void initState() {
    super.initState();

    _logoCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..repeat(reverse: true);

    _logoAnim = Tween<double>(
      begin: 0.85,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _logoCtrl, curve: Curves.easeInOut));

    Future.microtask(() {
      context.read<PatientAuthProvider>().initialize();
    });
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PatientAuthProvider>(
      builder: (_, auth, __) {
        switch (auth.state) {
          case PatientAuthState.initial:
          case PatientAuthState.loading:
            return Splashview(logoAnim: _logoAnim);

          case PatientAuthState.authenticated:
            return const MainScreen();

          case PatientAuthState.unauthenticated:
          case PatientAuthState.error:
            return const LoginView();
        }
      },
    );
  }
}