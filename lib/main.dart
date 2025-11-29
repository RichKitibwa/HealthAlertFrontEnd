import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/register_screen.dart';
import 'features/ambulance/presentation/screens/ambulance_welcome_screen.dart';
import 'features/ambulance/presentation/screens/ambulance_incoming_dispatch_screen.dart';
import 'features/clinic/presentation/screens/clinic_welcome_screen.dart';
import 'features/clinic/presentation/screens/clinic_incoming_case_screen.dart';
import 'features/admin/presentation/screens/admin_welcome_screen.dart';
import 'features/vht/presentation/screens/vht_welcome_screen.dart';
import 'features/vht/presentation/screens/vht_dashboard_screen.dart';
import 'features/vht/presentation/screens/create_emergency_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const HealthCommApp());
}

class HealthCommApp extends StatelessWidget {
  const HealthCommApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Emergency Health System',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.red, useMaterial3: true),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/vht-dashboard': (context) => const VHTWelcomeScreen(),
        '/vht-main': (context) => const VHTDashboardScreen(),
        '/create-emergency': (context) => const CreateEmergencyScreen(),
        '/ambulance-dashboard': (context) => const AmbulanceWelcomeScreen(),
        '/ambulance-incoming-dispatch': (context) =>
            const AmbulanceIncomingDispatchScreen(),
        '/clinic-dashboard': (context) => const ClinicWelcomeScreen(),
        '/clinic-incoming-case': (context) => const ClinicIncomingCaseScreen(),
        '/admin-dashboard': (context) => const AdminWelcomeScreen(),
      },
    );
  }
}
