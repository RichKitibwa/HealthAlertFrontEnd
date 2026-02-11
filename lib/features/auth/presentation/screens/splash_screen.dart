import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../current_user_session.dart';
import '../../../../core/services/device_storage_service.dart';
import '../../../../core/services/fcm_notification_service.dart';
import '../../../../core/theme/app_colors.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));
    _navigateToNext();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _navigateToNext() async {
    // Wait for 3 seconds
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    // Start fade out animation
    await _fadeController.forward();

    if (!mounted) return;

    // Check if user is already logged in
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // User is logged in, check Firestore for role
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          final data = userDoc.data();
          final role = data?['role'] ?? 'VHT';

          // Populate session
          CurrentUserSession.uid = user.uid;
          CurrentUserSession.role = role;
          CurrentUserSession.firstName = data?['firstName'];
          CurrentUserSession.lastName = data?['lastName'];
          CurrentUserSession.phoneNumber = data?['phoneNumber'];
          CurrentUserSession.profileImageUrl = data?['profileImageUrl'];
          CurrentUserSession.workplace = data?['workplace'];
          CurrentUserSession.specialty = data?['specialty'];

          // Initialize FCM and save token to user document
          FCMNotificationService().initialize();

          // Navigate to appropriate dashboard
          _navigateToRoleDashboard(role);
          return;
        }
      } catch (e) {
        print('Error checking user session: $e');
      }
    }

    // Check if user is registered on this device
    final isRegisteredOnDevice =
        await DeviceStorageService.isUserRegisteredOnDevice();

    if (mounted) {
      if (isRegisteredOnDevice) {
        // Returning user - go to login screen (welcome + PIN)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      } else {
        // New user - go directly to registration screen (phone + role + OTP)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const RegisterScreen()),
        );
      }
    }
  }

  void _navigateToRoleDashboard(String role) {
    if (!mounted) return;

    String route;
    switch (role) {
      case 'VHT':
        route = '/vht-dashboard';
        break;
      case 'Ambulance Driver':
        route = '/ambulance-dashboard';
        break;
      case 'Clinic Staff':
        route = '/clinic-dashboard';
        break;
      case 'Admin':
        route = '/admin-dashboard';
        break;
      default:
        route = '/vht-dashboard';
    }

    Navigator.pushNamedAndRemoveUntil(context, route, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo (same green as welcome/register)
              Image.asset(
                'assets/images/healthcare_logo.png',
                height: 120,
                fit: BoxFit.contain,
                color: AppColors.primary,
              ),
              const SizedBox(height: 24),

              // App Name
              const Text(
                'HealthAlert',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),

              // Tagline
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 40.0),
                child: Text(
                  'Emergency communication for front line health response',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 48),

              // Loading indicator
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
