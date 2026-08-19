import 'package:bookdr/providers/dm_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/appointment_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/dm_list_provider.dart';
import 'providers/fetch_dr_provider.dart';
import 'providers/homegig_provider.dart';
import 'providers/order_provider.dart';
import 'widgets/auth_wrapper.dart';

// Zego's call-invitation UI needs a global navigatorKey so it can push the
// incoming-call screen on top of whatever page the patient is currently on.
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PatientAuthProvider()),
        ChangeNotifierProvider(create: (_) => HomeGigProvider()),
        ChangeNotifierProvider(create: (_) => DoctorProvider()),
        ChangeNotifierProvider(create: (_) => DmProvider()),
        ChangeNotifierProvider(create: (_) => DmListProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
        ChangeNotifierProvider(create: (_) => AppointmentsProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        navigatorKey: navigatorKey, // ← required by Zego's invitation overlay
        home: const AuthWrapper(),
      ),
    );
  }
}