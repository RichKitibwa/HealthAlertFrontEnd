import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/pin_utils.dart';
import '../../../../core/services/device_storage_service.dart';
import '../../../auth/current_user_session.dart';
import 'pin_setup_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Email OTP Verification Screen for Admin Registration
/// Shows after admin enters email and clicks "Get Verification Code"
class AdminEmailOTPScreen extends StatefulWidget {
  final String email;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String? organization;
  final String? position;

  const AdminEmailOTPScreen({
    Key? key,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    this.organization,
    this.position,
  }) : super(key: key);

  @override
  State<AdminEmailOTPScreen> createState() => _AdminEmailOTPScreenState();
}

class _AdminEmailOTPScreenState extends State<AdminEmailOTPScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  bool _isLoading = false;
  bool _isVerifying = false;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _completeRegistration(String pin, BuildContext navigatorContext) async {
    try {
      final pinHash = PinUtils.hashPin(pin);
      final docRef = FirebaseFirestore.instance.collection('users').doc();
      final uid = docRef.id;

      await docRef.set({
        'uid': uid,
        'id': uid,
        'firstName': widget.firstName,
        'lastName': widget.lastName,
        'phoneNumber': widget.phoneNumber,
        'role': 'Admin',
        'pinHash': pinHash,
        'email': widget.email,
        if (widget.organization != null) 'organization': widget.organization,
        if (widget.position != null) 'position': widget.position,
        'createdAt': DateTime.now().toIso8601String(),
      });

      CurrentUserSession.uid = uid;
      CurrentUserSession.role = 'Admin';
      CurrentUserSession.firstName = widget.firstName;
      CurrentUserSession.lastName = widget.lastName;
      CurrentUserSession.phoneNumber = widget.phoneNumber;
      CurrentUserSession.email = widget.email;

      // Save user data to device for future sessions
      await DeviceStorageService.saveRegisteredUser(
        phoneNumber: widget.phoneNumber,
        firstName: widget.firstName,
        lastName: widget.lastName,
      );

      // Use the passed context (from PinConfirmationScreen) so navigation works after pushReplacement
      if (navigatorContext.mounted) {
        Navigator.of(navigatorContext, rootNavigator: true).pushNamedAndRemoveUntil(
          '/admin-dashboard',
          (route) => false,
        );
      }
    } catch (e) {
      if (navigatorContext.mounted) {
        ScaffoldMessenger.of(navigatorContext).showSnackBar(
          SnackBar(
            content: Text('Registration failed: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _verifyOTP() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isVerifying = true);

    try {
      final functions = FirebaseFunctions.instance;
      final callable = functions.httpsCallable('verifyAdminOTP');

      final result = await callable.call({
        'email': widget.email,
        'code': _otpController.text.trim(),
      });

      if (result.data['success'] == true) {
        // OTP verified successfully, proceed to PIN setup
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => PinSetupScreen(
                registrationData: {
                  'firstName': widget.firstName,
                  'lastName': widget.lastName,
                  'phoneNumber': widget.phoneNumber,
                  'role': 'Admin',
                  'email': widget.email,
                  'organization': widget.organization,
                  'position': widget.position,
                },
                onPinConfirmed: (pin, context) => _completeRegistration(pin, context),
              ),
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _isVerifying = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Verification failed: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _resendOTP() async {
    setState(() => _isLoading = true);

    try {
      final functions = FirebaseFunctions.instance;
      final callable = functions.httpsCallable('sendAdminOTP');

      final result = await callable.call({
        'email': widget.email,
        'phoneNumber': widget.phoneNumber,
      });

      if (result.data['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Verification code resent to your email'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to resend code: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Verify Email'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              left: 24.0,
              right: 24.0,
              top: 24.0,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24.0,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Icon(
                    Icons.email_outlined,
                    size: 64,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Check Your Email',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'We sent a 4-digit verification code to',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.email,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // OTP Input
                  TextFormField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 4,
                    decoration: InputDecoration(
                      labelText: 'Verification Code',
                      hintText: '1234',
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: const OutlineInputBorder(),
                      counterText: '',
                    ),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 8,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the verification code';
                      }
                      if (value.length != 4) {
                        return 'Code must be 4 digits';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Verify Button
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isVerifying ? null : _verifyOTP,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isVerifying
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Verify Code',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Resend Code
                  TextButton(
                    onPressed: _isLoading ? null : _resendOTP,
                    child: _isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Resend Verification Code'),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Code expires in 10 minutes',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
