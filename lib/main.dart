import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'routes/app_routes.dart';
import 'views/login/login_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    // options: const FirebaseOptions(
    //   apiKey: "AIzaSyA8n9sXo2l3m1a5b6c7d8e9f0g1h2i3j4k5l6m7n8o9p0q1r2s3t4u5v6w7x8y9z0",
    //   appId: "1:1234567890:android:abcdef1234567890abcdef1234567890",
    //   messagingSenderId: "1234567890",
    //   projectId: "bookdr-12345",
    // ),
  );
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
      home: const LoginView()
    );
  }
}
