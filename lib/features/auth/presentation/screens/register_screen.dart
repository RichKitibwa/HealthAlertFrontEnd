import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'otp_verification_screen.dart';
import '../../../ambulance/presentation/screens/ambulance_dashboard_screen.dart';
import '../../../clinic/presentation/screens/clinic_dashboard_screen.dart';
import '../../../admin/presentation/screens/admin_dashboard_screen.dart';
import '../../../vht/presentation/screens/vht_dashboard_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  
  String _selectedRole = 'VHT';
  bool _isLoading = false;

  final List<String> _roles = [
    'VHT',
    'Ambulance Driver',
    'Clinic Staff',
    'Admin',
  ];

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      try {
        final phoneNumber = _phoneController.text.trim();
        
        // Start Firebase Phone Auth
        await FirebaseAuth.instance.verifyPhoneNumber(
          phoneNumber: phoneNumber,
          
          // Called when verification is completed automatically (Android only)
          verificationCompleted: (PhoneAuthCredential credential) async {
            await _signInWithCredential(credential);
          },
          
          // Called when verification fails
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
          
          // Called when OTP code is sent
          codeSent: (String verificationId, int? resendToken) {
            setState(() => _isLoading = false);
            
            if (mounted) {
              // Navigate to OTP verification screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OTPVerificationScreen(
                    verificationId: verificationId,
                    phoneNumber: phoneNumber,
                    firstName: _firstNameController.text.trim(),
                    lastName: _lastNameController.text.trim(),
                    role: _selectedRole,
                    isNewUser: true,
                  ),
                ),
              );
            }
          },
          
          // Timeout for automatic verification
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
      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      await _createUserProfile(userCredential.user!.uid);
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

  Future<void> _createUserProfile(String uid) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'uid': uid,
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'phoneNumber': _phoneController.text.trim(),
        'role': _selectedRole,
        'createdAt': DateTime.now().toIso8601String(),
      });

      if (mounted) {
        _navigateToRoleDashboard();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create profile: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _navigateToRoleDashboard() {
    if (!mounted) return;
    
    final normalizedRole = _selectedRole.trim();
    
    String routeName;
    if (normalizedRole == 'VHT' || normalizedRole.toLowerCase() == 'vht') {
      routeName = '/vht-dashboard';
    } else if (normalizedRole == 'Ambulance Driver' || 
               normalizedRole.toLowerCase().contains('ambulance')) {
      routeName = '/ambulance-dashboard';
    } else if (normalizedRole == 'Clinic Staff' || 
               normalizedRole.toLowerCase().contains('clinic')) {
      routeName = '/clinic-dashboard';
    } else if (normalizedRole == 'Admin' || 
               normalizedRole.toLowerCase() == 'admin' ||
               normalizedRole.toLowerCase().contains('admin')) {
      routeName = '/admin-dashboard';
    } else {
      routeName = '/vht-dashboard';
    }
    
    print('DEBUG: Navigating to route: $routeName');
    
    // Use WidgetsBinding to ensure navigation happens after the current frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      
      Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
        routeName,
        (route) => false,
      ).then((_) {
        print('DEBUG: Navigation completed successfully');
      }).catchError((error) {
        print('DEBUG: Navigation error: $error');
        // Fallback: try direct navigation if named route fails
        if (mounted) {
          _navigateWithFallback(normalizedRole);
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
                    size: 80,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'HealthAlert',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Register your account',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),

                  // First Name
                  TextFormField(
                    controller: _firstNameController,
                    decoration: const InputDecoration(
                      labelText: 'First Name',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your first name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Last Name
                  TextFormField(
                    controller: _lastNameController,
                    decoration: const InputDecoration(
                      labelText: 'Last Name',
                      prefixIcon: Icon(Icons.person_outline),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your last name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Phone Number
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      prefixIcon: Icon(Icons.phone),
                      border: OutlineInputBorder(),
                      hintText: '+256700000001',
                      helperText: 'Use +256700000001 to +256700000004 for testing',
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your phone number';
                      }
                      if (!value.startsWith('+')) {
                        return 'Phone number must start with + and country code';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Role Dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedRole,
                    decoration: const InputDecoration(
                      labelText: 'I am a...',
                      prefixIcon: Icon(Icons.work),
                      border: OutlineInputBorder(),
                    ),
                    items: _roles.map((String role) {
                      return DropdownMenuItem<String>(
                        value: role,
                        child: Text(role),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedRole = newValue;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 32),

                  // Register Button
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _register,
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
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Login Link
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    child: const Text('Already have an account? Login'),
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
