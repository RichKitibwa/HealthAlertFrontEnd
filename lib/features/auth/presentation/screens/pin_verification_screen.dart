import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../current_user_session.dart';
import '../../../../core/utils/pin_utils.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../vht/presentation/screens/vht_dashboard_screen.dart';
import '../../../ambulance/presentation/screens/ambulance_dashboard_screen.dart';
import '../../../clinic/presentation/screens/clinic_dashboard_screen.dart';
import '../../../admin/presentation/screens/admin_dashboard_screen.dart';

class PinVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final Map<String, dynamic> userData;

  const PinVerificationScreen({
    Key? key,
    required this.phoneNumber,
    required this.userData,
  }) : super(key: key);

  @override
  State<PinVerificationScreen> createState() => _PinVerificationScreenState();
}

class _PinVerificationScreenState extends State<PinVerificationScreen> {
  final _pinController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePin = true;
  String? _errorMessage;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  String _getWelcomeMessage() {
    final role = widget.userData['role'] ?? '';
    final firstName = widget.userData['firstName'] ?? '';
    final lastName = widget.userData['lastName'] ?? '';
    final fullName = '$firstName $lastName'.trim();

    if (role == 'Clinic Staff' || role.toLowerCase().contains('clinic')) {
      final specialty = widget.userData['specialty'] ?? '';
      if (specialty.isNotEmpty) {
        return 'Welcome back, Dr. $fullName';
      }
      return 'Welcome back, $fullName';
    } else if (role == 'Admin') {
      return 'Welcome back, $fullName';
    } else {
      return 'Welcome back, $fullName';
    }
  }

  Future<void> _verifyPin() async {
    final pin = _pinController.text.trim();

    if (pin.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your PIN';
      });
      return;
    }

    if (!PinUtils.isValidPinFormat(pin)) {
      setState(() {
        _errorMessage = 'PIN must be 4-6 digits';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final pinHash = PinUtils.hashPin(pin);
      final storedPinHash = widget.userData['pinHash'] as String?;

      if (storedPinHash == null || storedPinHash != pinHash) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Incorrect PIN. Please try again.';
        });
        _pinController.clear();
        return;
      }

      // PIN is correct - populate session and navigate
      final uid = widget.userData['uid'] as String? ?? widget.userData['id'] as String? ?? '';
      
      CurrentUserSession.uid = uid;
      CurrentUserSession.role = widget.userData['role'] ?? 'VHT';
      CurrentUserSession.firstName = widget.userData['firstName'] as String?;
      CurrentUserSession.lastName = widget.userData['lastName'] as String?;
      CurrentUserSession.phoneNumber = widget.userData['phoneNumber'] as String?;
      CurrentUserSession.profileImageUrl = widget.userData['profileImageUrl'] as String?;
      CurrentUserSession.workplace = widget.userData['workplace'] as String?;
      CurrentUserSession.specialty = widget.userData['specialty'] as String?;

      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login successful!'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to role-specific dashboard
        _navigateToRoleDashboard(CurrentUserSession.role ?? 'VHT');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error: ${e.toString()}';
      });
    }
  }

  void _navigateToRoleDashboard(String role) {
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
        route,
        (r) => false,
      ).then((_) {
        print('DEBUG: Navigation completed successfully to $route');
      }).catchError((error) {
        print('DEBUG: Navigation error: $error');
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
      destination = const VHTDashboardScreen();
    } else if (role == 'Ambulance Driver' || role.toLowerCase().contains('ambulance')) {
      destination = const AmbulanceDashboardScreen();
    } else if (role == 'Clinic Staff' || role.toLowerCase().contains('clinic')) {
      destination = const ClinicDashboardScreen();
    } else if (role == 'Admin' || role.toLowerCase() == 'admin' || role.toLowerCase().contains('admin')) {
      destination = const AdminDashboardScreen();
    } else {
      destination = const VHTDashboardScreen();
    }

    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => destination),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter PIN'),
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
                const Icon(Icons.lock, size: 80, color: AppColors.primary),
                const SizedBox(height: 32),
                Text(
                  _getWelcomeMessage(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Enter your PIN to continue',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                // PIN Input
                TextFormField(
                  controller: _pinController,
                  decoration: InputDecoration(
                    labelText: 'PIN',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePin ? Icons.visibility : Icons.visibility_off),
                      onPressed: () {
                        setState(() {
                          _obscurePin = !_obscurePin;
                        });
                      },
                    ),
                    border: const OutlineInputBorder(),
                    errorText: _errorMessage,
                  ),
                  keyboardType: TextInputType.number,
                  obscureText: _obscurePin,
                  maxLength: 6,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    letterSpacing: 8,
                    fontWeight: FontWeight.bold,
                  ),
                  onFieldSubmitted: (_) => _verifyPin(),
                ),
                const SizedBox(height: 32),

                // Verify Button
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _verifyPin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Verify PIN',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 24),

                // Back Button
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Go back'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
