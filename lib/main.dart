import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/screens/splash_screen.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/register_screen.dart';
import 'features/ambulance/presentation/screens/ambulance_incoming_dispatch_screen.dart';
import 'features/ambulance/presentation/screens/ambulance_dashboard_screen.dart';
import 'features/clinic/presentation/screens/clinic_incoming_case_screen.dart';
import 'features/clinic/presentation/screens/clinic_dashboard_screen.dart';

import 'features/admin/presentation/screens/admin_case_dashboard.dart';
import 'features/vht/presentation/screens/vht_dashboard_screen.dart';
import 'features/vht/presentation/screens/create_emergency_screen.dart';
import 'features/admin/presentation/screens/admin_dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    print('Firebase initialized successfully');
  } catch (e, stackTrace) {
    print('Error initializing Firebase: $e');
    print('Stack trace: $stackTrace');
    // Still run the app, but Firebase operations will fail gracefully
  }
  runApp(const HealthCommApp());
}

class HealthCommApp extends StatelessWidget {
  const HealthCommApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Emergency Health System',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/vht-dashboard': (context) => VHTDashboardScreen(),
        '/vht-main': (context) => VHTDashboardScreen(),
        '/create-emergency': (context) => const CreateEmergencyScreen(),
        '/ambulance-dashboard': (context) => AmbulanceDashboardScreen(),
        '/ambulance-incoming-dispatch': (context) =>
            const AmbulanceIncomingDispatchScreen(),
        '/clinic-dashboard': (context) => ClinicDashboardScreen(),
        '/clinic-incoming-case': (context) => const ClinicIncomingCaseScreen(),
        '/admin-case-dashboard': (context) => const AdminCaseDashboardScreen(),
        '/admin-dashboard': (context) => AdminDashboardScreen(),
      },
    );
  }
}
