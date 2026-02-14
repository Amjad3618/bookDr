import 'package:bookdr/widgets/bottom_nav_bar.dart';
import 'package:flutter/material.dart';

import 'routes/app_routes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
     debugShowCheckedModeBanner: false,
       onGenerateRoute: AppRoutes.generateRoute,
      home: const MainScreen()
    );
  }
}
