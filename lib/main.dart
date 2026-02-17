import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'core/services/fcm_notification_service.dart';
import 'core/services/local_storage_service.dart';
import 'core/services/connectivity_service.dart';
import 'features/auth/presentation/screens/splash_screen.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/register_screen.dart';
import 'features/ambulance/presentation/screens/ambulance_dashboard_screen.dart';
import 'features/clinic/presentation/screens/clinic_incoming_case_screen.dart';
import 'features/clinic/presentation/screens/clinic_dashboard_screen.dart';

import 'features/admin/presentation/screens/admin_case_dashboard.dart';
import 'features/vht/presentation/screens/vht_dashboard_screen.dart';
import 'features/vht/presentation/screens/create_emergency_screen.dart';
import 'features/admin/presentation/screens/admin_dashboard_screen.dart';
import 'features/auth/presentation/screens/admin_email_otp_screen.dart';
import 'features/auth/presentation/screens/pin_setup_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    debugPrint('Firebase initialized successfully');
    FCMNotificationService.registerBackgroundHandler();
  } catch (e, stackTrace) {
    debugPrint('Error initializing Firebase: $e');
    debugPrint('Stack trace: $stackTrace');
    // Still run the app, but Firebase operations will fail gracefully
  }

  // Initialize offline-first local storage (Hive)
  try {
    await LocalStorageService.initialize();
    debugPrint('Local storage initialized successfully');
  } catch (e) {
    debugPrint('Error initializing local storage: $e');
  }

  // Initialize connectivity monitoring
  try {
    await ConnectivityService().initialize();
    debugPrint('Connectivity service initialized');
  } catch (e) {
    debugPrint('Error initializing connectivity service: $e');
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
        // ambulance-incoming-dispatch is navigated via MaterialPageRoute with caseId
        '/clinic-dashboard': (context) => ClinicDashboardScreen(),
        '/clinic-incoming-case': (context) => const ClinicIncomingCaseScreen(),
        '/admin-case-dashboard': (context) => const AdminCaseDashboardScreen(),
        '/admin-dashboard': (context) => AdminDashboardScreen(),
        '/admin-email-otp': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return AdminEmailOTPScreen(
            email: args['email'],
            firstName: args['firstName'],
            lastName: args['lastName'],
            phoneNumber: args['phoneNumber'],
            organization: args['organization'],
            position: args['position'],
          );
        },
        '/pin-setup': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return PinSetupScreen(
            registrationData: args,
            onPinConfirmed: (pin, confirmContext) {
              // Handle PIN confirmation - this will be handled by the calling screen
              Navigator.pop(confirmContext);
            },
          );
        },
      },
    );
  }
}
