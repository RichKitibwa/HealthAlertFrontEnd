import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../current_user_session.dart';
import '../../../../core/services/fcm_notification_service.dart';
import '../../../../core/services/locale_notifier.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import 'register_screen.dart';
import '../../../vht/presentation/screens/vht_dashboard_screen.dart';
import '../../../ambulance/presentation/screens/ambulance_dashboard_screen.dart';
import '../../../clinic/presentation/screens/clinic_dashboard_screen.dart';
import '../../../admin/presentation/screens/admin_dashboard_screen.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String verificationId;
  final String phoneNumber;
  final String? firstName;
  final String? lastName;
  final String? role;
  final bool isNewUser;

  const OTPVerificationScreen({
    Key? key,
    required this.verificationId,
    required this.phoneNumber,
    this.firstName,
    this.lastName,
    this.role,
    this.isNewUser = true,
  }) : super(key: key);

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final _otpController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verifyOTP() async {
    if (_otpController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.pleaseEnterVerificationCode),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Create credential with verification ID and OTP code
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: _otpController.text.trim(),
      );

      // Sign in with credential
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(credential);

      setState(() => _isLoading = false);

      if (mounted) {
        if (widget.isNewUser) {
          // Navigate to details form for new users (role is already selected)
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => _getDetailsScreen(),
            ),
          );
        } else {
          // For existing users, get user data and navigate to dashboard
          final uid = userCredential.user!.uid;
          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .get();

          final data = userDoc.data();
          final role = data?['role'] ?? 'VHT';

          CurrentUserSession.uid = uid;
          CurrentUserSession.role = role;
          CurrentUserSession.firstName = data?['firstName'];
          CurrentUserSession.lastName = data?['lastName'];
          CurrentUserSession.phoneNumber = data?['phoneNumber'];
          CurrentUserSession.profileImageUrl = data?['profileImageUrl'];
          CurrentUserSession.workplace = data?['workplace'];
          CurrentUserSession.specialty = data?['specialty'];
          CurrentUserSession.camp = data?['camp'];
          CurrentUserSession.email = data?['email'];

          // Restore this user's saved language preference.
          if (mounted) {
            final localeNotifier =
                Provider.of<LocaleNotifier>(context, listen: false);
            await localeNotifier.loadAndApplyLocaleForUser(uid);
          }

          // Initialize FCM and notification listener.
          final fcmService = FCMNotificationService();
          fcmService.initialize();
          fcmService.startNotificationListener(uid);

          _navigateToRoleDashboard(role);
        }
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _isLoading = false);

      // Show raw Firebase error message
      final errorMessage = e.message ?? 'Error code: ${e.code}';
      
      print('Firebase Auth Error Code: ${e.code}');
      print('Firebase Auth Error Message: ${e.message}');
      print('Full Firebase Exception: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 8),
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.errorGeneric(e.toString())),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Widget _getDetailsScreen() {
    final role = widget.role ?? 'VHT';
    switch (role) {
      case 'VHT':
        return VHTDetailsScreen(phoneNumber: widget.phoneNumber, role: role);
      case 'Ambulance Driver':
        return AmbulanceDriverDetailsScreen(phoneNumber: widget.phoneNumber, role: role);
      case 'Clinic Staff':
        return ClinicianDetailsScreen(phoneNumber: widget.phoneNumber, role: role);
      case 'Admin':
        return AdminDetailsScreen(phoneNumber: widget.phoneNumber, role: role);
      default:
        return VHTDetailsScreen(phoneNumber: widget.phoneNumber, role: role);
    }
  }

  void _navigateToRoleDashboard(String role) {
    String route;
    switch (role) {
      case 'VHT':
        // 001 numbers in your test data
        route = '/vht-dashboard';
        break;
      case 'Ambulance Driver':
        // 002 numbers → ambulance dashboard
        route = '/ambulance-dashboard';
        break;
      case 'Clinic Staff':
        // 003 numbers → clinic dashboard (or incoming case if you prefer)
        route = '/clinic-dashboard';
        break;
      case 'Admin':
        // 004 numbers → admin dashboard
        route = '/admin-dashboard';
        break;
      default:
        route = '/vht-dashboard';
    }

    print('DEBUG: About to navigate to route: $route for role: $role');
    
    // Use WidgetsBinding to ensure navigation happens after the current frame
    // This prevents navigation issues when called during build or async operations
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      
      // Use pushNamedAndRemoveUntil with named routes for reliable navigation
      Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
        route,
        (r) => false,
      ).then((_) {
        print('DEBUG: Navigation completed successfully to $route');
      }).catchError((error) {
        print('DEBUG: Navigation error: $error');
        // Fallback: try direct navigation if named route fails
        if (mounted) {
          _navigateWithFallback(role);
        }
      });
    });
  }
  
  void _navigateWithFallback(String role) {
    if (!mounted) return;
    
    Widget destination;

    if (role == 'VHT' || role.toLowerCase() == 'vht') {
      destination = VHTDashboardScreen();
    } else if (role == 'Ambulance Driver' || role.toLowerCase().contains('ambulance')) {
      destination = AmbulanceDashboardScreen();
    } else if (role == 'Clinic Staff' || role.toLowerCase().contains('clinic')) {
      destination = ClinicDashboardScreen();
    } else if (role == 'Admin' || role.toLowerCase() == 'admin' || role.toLowerCase().contains('admin')) {
      destination = AdminDashboardScreen();
    } else {
      destination = VHTDashboardScreen();
    }
    
    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => destination),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.verifyPhoneNumber),
        backgroundColor: AppColors.primary,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.message, size: 80, color: AppColors.primary),
                const SizedBox(height: 32),
                Text(
                  l10n.enterVerificationCode,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.weSentCodeTo(widget.phoneNumber),
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.forTestNumbersEnter,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                // OTP Input
                TextField(
                  controller: _otpController,
                  decoration: InputDecoration(
                    labelText: l10n.verificationCode,
                    prefixIcon: const Icon(Icons.lock),
                    border: const OutlineInputBorder(),
                    hintText: l10n.verificationCodeHint,
                  ),
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    letterSpacing: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 32),

                // Verify Button
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _verifyOTP,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            l10n.verifyButton,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 24),

                // Resend Code (not implemented yet)
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(l10n.goBackAndTryAgain),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
