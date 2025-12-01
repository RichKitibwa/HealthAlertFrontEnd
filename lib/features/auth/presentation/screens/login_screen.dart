import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'otp_verification_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      try {
        final phoneNumber = _phoneController.text.trim();
        
        // Check if user exists first with timeout
        QuerySnapshot usersQuery;
        try {
          usersQuery = await FirebaseFirestore.instance
              .collection('users')
              .where('phoneNumber', isEqualTo: phoneNumber)
              .get()
              .timeout(
                const Duration(seconds: 10),
                onTimeout: () {
                  throw TimeoutException(
                    'Connection timeout. Check your internet connection and emulator network settings.',
                    const Duration(seconds: 10),
                  );
                },
              );
        } on TimeoutException catch (e) {
          setState(() => _isLoading = false);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Network error: ${e.message}\n\n'
                  'The emulator cannot reach Firebase. Please:\n'
                  '1. Check emulator internet connection\n'
                  '2. Restart the emulator\n'
                  '3. Verify Firebase is accessible',
                ),
                backgroundColor: Colors.orange,
                duration: const Duration(seconds: 8),
              ),
            );
          }
          return;
        } catch (e) {
          setState(() => _isLoading = false);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Firestore error: ${e.toString()}'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 5),
              ),
            );
          }
          return;
        }
        
        if (usersQuery.docs.isEmpty) {
          setState(() => _isLoading = false);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('User not found. Please register first.'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }
        
        // Start Firebase Phone Auth
        await FirebaseAuth.instance.verifyPhoneNumber(
          phoneNumber: phoneNumber,
          
          // Auto-verification (Android only)
          verificationCompleted: (PhoneAuthCredential credential) async {
            await _signInWithCredential(credential);
          },
          
          // Verification failed
          verificationFailed: (FirebaseAuthException e) {
            setState(() => _isLoading = false);
            
            String errorMessage = 'Verification failed';
            if (e.code == 'invalid-phone-number') {
              errorMessage = 'Invalid phone number format';
            } else if (e.code == 'too-many-requests') {
              errorMessage = 'Too many requests. Please try again later';
            } else {
              errorMessage = e.message ?? 'An error occurred';
            }
            
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(errorMessage),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          
          // OTP code sent
          codeSent: (String verificationId, int? resendToken) {
            setState(() => _isLoading = false);
            
            if (mounted) {
              // Navigate to OTP verification
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OTPVerificationScreen(
                    verificationId: verificationId,
                    phoneNumber: phoneNumber,
                    isNewUser: false,
                  ),
                ),
              );
            }
          },
          
          // Auto-retrieval timeout
          codeAutoRetrievalTimeout: (String verificationId) {
            print('Auto retrieval timeout');
          },
          
          timeout: const Duration(seconds: 60),
        );
        
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
  }

  Future<void> _signInWithCredential(PhoneAuthCredential credential) async {
    try {
      await FirebaseAuth.instance.signInWithCredential(credential);
      
      // Get user role from Firestore
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      
      final role = userDoc.data()?['role'] ?? 'VHT';
      
      if (mounted) {
        _navigateToRoleDashboard(role);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign in failed: ${e.toString()}'),
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
    
    Navigator.pushReplacementNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App Logo/Title
                  const Icon(
                    Icons.local_hospital,
                    size: 100,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'HealthAlert',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Welcome back!',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 64),

                  // Phone Number
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      prefixIcon: Icon(Icons.phone),
                      border: OutlineInputBorder(),
                      hintText: '+256700000001',
                      helperText: 'Use test numbers: +256700000001 to +256700000004',
                    ),
                    keyboardType: TextInputType.phone,
                    style: const TextStyle(fontSize: 18),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your phone number';
                      }
                      if (!value.startsWith('+')) {
                        return 'Phone must start with + and country code';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),

                  // Login Button
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _login,
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
                              'Send Verification Code',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Register Link
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/register');
                    },
                    child: const Text(
                      'Don\'t have an account? Register',
                      style: TextStyle(fontSize: 16),
                    ),
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
