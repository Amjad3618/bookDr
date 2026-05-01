import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class Splashview extends StatelessWidget {
  final Animation<double> logoAnim;
  const Splashview({required this.logoAnim});
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [AppColors.primaryDark, AppColors.primary, AppColors.primaryLight],
          ),
        ),
        child: Stack(children: [
          Positioned(top: -60, right: -60, child: _bubble(220, 0.08)),
          Positioned(bottom: -80, left: -40, child: _bubble(260, 0.07)),
          SafeArea(child: Center(child: Column(
            mainAxisAlignment: MainAxisAlignment.center, children: [
            ScaleTransition(scale: logoAnim,
              child: Container(
                width: 100, height: 100,
                decoration: BoxDecoration(color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15),
                    blurRadius: 24, offset: const Offset(0, 8))]),
                child: const Center(child: Icon(Icons.medical_services_rounded,
                  color: AppColors.primary, size: 50)))),
            const SizedBox(height: 24),
            const Text('CareSync', style: TextStyle(color: Colors.white,
              fontSize: 30, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
            const SizedBox(height: 6),
            Text('Book Doctors Online', style: TextStyle(
              color: Colors.white.withOpacity(0.8), fontSize: 14)),
            const SizedBox(height: 48),
            const SizedBox(width: 32, height: 32,
              child: CircularProgressIndicator(strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation(Colors.white))),
          ]))),
          Positioned(bottom: 24, left: 0, right: 0,
            child: Center(child: Text('v1.0.0  ·  Powered by CareSync',
              style: TextStyle(color: Colors.white.withOpacity(0.4),
                fontSize: 11)))),
        ]),
      ),
    );
  }
  Widget _bubble(double s, double o) => Container(width: s, height: s,
    decoration: BoxDecoration(shape: BoxShape.circle,
      color: Colors.white.withOpacity(o)));
}