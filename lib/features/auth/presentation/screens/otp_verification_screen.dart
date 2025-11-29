import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
        const SnackBar(
          content: Text('Please enter the verification code'),
          backgroundColor: Colors.red,
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

      // Get the user's UID
      String uid = userCredential.user!.uid;

      if (widget.isNewUser) {
        // Create user profile in Firestore
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'uid': uid,
          'firstName': widget.firstName,
          'lastName': widget.lastName,
          'phoneNumber': widget.phoneNumber,
          'role': widget.role,
          'createdAt': DateTime.now().toIso8601String(),
        });
      }

      // Get user role
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      final role = userDoc.data()?['role'] ?? 'VHT';

      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification successful!'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to role-specific dashboard
        _navigateToRoleDashboard(role);
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _isLoading = false);

      String errorMessage = 'Verification failed';
      if (e.code == 'invalid-verification-code') {
        errorMessage = 'Invalid verification code. Please try again.';
      } else if (e.code == 'session-expired') {
        errorMessage = 'Verification code expired. Please request a new one.';
      } else {
        errorMessage = e.message ?? 'An error occurred';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _navigateToRoleDashboard(String role) {
    String route;
    switch (role) {
      case 'VHT':
        route = '/create-emergency';
        break;
      case 'Ambulance Driver':
        route = '/ambulance-incoming-dispatch';
        break;
      case 'Clinic Staff':
        route = '/clinic-dashboard';
        break;
      case 'Admin':
        route = '/admin-dashboard';
        break;
      default:
        route = '/create-emergency';
    }

    Navigator.pushNamedAndRemoveUntil(context, route, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Phone Number'),
        backgroundColor: Colors.red,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.message, size: 80, color: Colors.red),
                const SizedBox(height: 32),
                const Text(
                  'Enter Verification Code',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'We sent a code to ${widget.phoneNumber}',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'For test numbers, enter: 123456',
                  style: TextStyle(
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
                  decoration: const InputDecoration(
                    labelText: 'Verification Code',
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(),
                    hintText: '123456',
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
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Verify',
                            style: TextStyle(
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
                  child: const Text('Go back and try again'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
