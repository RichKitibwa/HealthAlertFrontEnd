import 'package:flutter/material.dart';
// Re-enable Firebase phone verification when Firebase Auth is properly configured
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/utils/pin_utils.dart';
import '../../../../core/services/device_storage_service.dart';
import '../../current_user_session.dart';
import '../../../../core/theme/app_colors.dart';
// Re-enable when Firebase phone verification is restored
// import 'otp_verification_screen.dart';
import 'login_screen.dart';
import 'vht_details_form.dart';
import 'ambulance_driver_details_form.dart';
import 'admin_details_form.dart';
import 'clinician_registration_form.dart';
import 'pin_setup_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
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
    _phoneController.dispose();
    super.dispose();
  }

  void _sendOTP() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final phoneNumber = _phoneController.text.trim();

        // Check if user already exists
        try {
          final existingUser = await FirebaseFirestore.instance
              .collection('users')
              .where('phoneNumber', isEqualTo: phoneNumber)
              .get();

          if (existingUser.docs.isNotEmpty) {
            setState(() => _isLoading = false);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('User with this phone number already exists. Please login instead.'),
                  backgroundColor: AppColors.error,
                ),
              );
            }
            return;
          }
        } catch (e) {
          // Log Firestore error but continue with registration
          print('Firestore query error (continuing anyway): $e');
          // Don't block registration if Firestore query fails
        }

        // TEMPORARY: Skip Firebase phone verification - automatically proceed to details form
        // TODO: Re-enable Firebase phone verification when Firebase Auth is properly configured
        await Future.delayed(const Duration(milliseconds: 500));
        
        setState(() => _isLoading = false);
        
        // Navigate directly to details form (phone is considered "verified")
        if (mounted) {
          _navigateToDetailsForm(phoneNumber);
        }

        /* TODO: Re-enable Firebase phone verification code below when Firebase Auth is properly configured
        // Start Firebase Phone Auth for verification
        await FirebaseAuth.instance.verifyPhoneNumber(
          phoneNumber: phoneNumber,
          verificationCompleted: (PhoneAuthCredential credential) async {
            // Auto-verification (Android only)
            try {
              await _signInWithCredential(credential, phoneNumber);
            } catch (e) {
              print('Error in verificationCompleted: $e');
              setState(() => _isLoading = false);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Verification error: ${e.toString()}'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            }
          },
          verificationFailed: (FirebaseAuthException e) {
            setState(() => _isLoading = false);
            
            String errorMessage;
            // Show raw Firebase messages for SHA/auth errors, custom for validation
            if (e.code == 'app-not-authorized') {
              // Provide helpful guidance for app-not-authorized errors
              errorMessage = 'App authorization error. Please ensure:\n'
                  '1. SHA-1 and SHA-256 fingerprints are added in Firebase Console\n'
                  '2. Play Integrity API is enabled in Google Cloud Console\n'
                  '3. Wait 10-15 minutes after adding fingerprints\n'
                  'See FIREBASE_AUTH_FIX.md for detailed instructions.\n\n'
                  'Error: ${e.message ?? e.code}';
            } else if (e.code == 'too-many-requests') {
              errorMessage = 'Too many requests. Please wait a few minutes and try again.\n\n'
                  'Error: ${e.message ?? e.code}';
            } else if (e.code == 'invalid-phone-number') {
              errorMessage = 'Invalid phone number format. Please check and try again.';
            } else if (e.code == 'missing-phone-number') {
              errorMessage = 'Phone number is required';
            } else if (e.code == 'quota-exceeded') {
              errorMessage = 'Daily SMS limit reached. Please try again tomorrow.';
            } else {
              // Show raw Firebase error for other errors
              errorMessage = e.message ?? 'Error code: ${e.code}';
            }
            
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
          },
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
                    role: _selectedRole,
                    isNewUser: true,
                  ),
                ),
              );
            }
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            print('Auto retrieval timeout');
            setState(() => _isLoading = false);
          },
          timeout: const Duration(seconds: 60),
        );
        */
      } catch (e, stackTrace) {
        setState(() => _isLoading = false);
        print('Error in _sendOTP: $e');
        print('Stack trace: $stackTrace');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: AppColors.error,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    }
  }


  /* TODO: Re-enable when Firebase phone verification is restored
  Future<void> _signInWithCredential(PhoneAuthCredential credential, String phoneNumber) async {
    try {
      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      // Navigate to details form after OTP verification
      if (mounted && userCredential.user != null) {
        _navigateToDetailsForm(phoneNumber);
      }
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Exception in _signInWithCredential: ${e.code} - ${e.message}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Verification failed: ${e.message ?? e.code}'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e, stackTrace) {
      print('Error in _signInWithCredential: $e');
      print('Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Verification failed: ${e.toString()}'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }
  */

  void _navigateToDetailsForm(String phoneNumber) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => _getDetailsScreen(phoneNumber),
      ),
    );
  }

  Widget _getDetailsScreen(String phoneNumber) {
    switch (_selectedRole) {
      case 'VHT':
        return VHTDetailsScreen(phoneNumber: phoneNumber, role: _selectedRole);
      case 'Ambulance Driver':
        return AmbulanceDriverDetailsScreen(phoneNumber: phoneNumber, role: _selectedRole);
      case 'Clinic Staff':
        return ClinicianDetailsScreen(phoneNumber: phoneNumber, role: _selectedRole);
      case 'Admin':
        return AdminDetailsScreen(phoneNumber: phoneNumber, role: _selectedRole);
      default:
        return VHTDetailsScreen(phoneNumber: phoneNumber, role: _selectedRole);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
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
                  const Icon(
                    Icons.local_hospital,
                    size: 80,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'HealthAlert',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
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

                  // Phone Number Helper Text
                  const Text(
                    'Enter your phone number to continue',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.left,
                  ),
                  const SizedBox(height: 8),

                  // Phone Number
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      prefixIcon: Icon(Icons.phone),
                      border: OutlineInputBorder(),
                      hintText: '+256700000001',
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

                  // Role Selection
                  DropdownButtonFormField<String>(
                    value: _selectedRole,
                    decoration: InputDecoration(
                      labelText: 'I am a...',
                      prefixIcon: const Icon(Icons.work),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFFE3E8EF),
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF0077CC),
                          width: 2,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFFE3E8EF),
                          width: 1,
                        ),
                      ),
                    ),
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      color: Color(0xFF1A1A1A),
                    ),
                    icon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Color(0xFF667085),
                    ),
                    iconSize: 24,
                    borderRadius: BorderRadius.circular(12),
                    dropdownColor: Colors.white,
                    elevation: 8,
                    items: _roles.map((String role) {
                      return DropdownMenuItem<String>(
                        value: role,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text(role),
                        ),
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

                  // Send OTP Button
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _sendOTP,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Continue',
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
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(forcePhoneInput: true),
                        ),
                      );
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

// VHT Details Screen
class VHTDetailsScreen extends StatefulWidget {
  final String phoneNumber;
  final String role;

  const VHTDetailsScreen({
    Key? key,
    required this.phoneNumber,
    required this.role,
  }) : super(key: key);

  @override
  State<VHTDetailsScreen> createState() => _VHTDetailsScreenState();
}

class _VHTDetailsScreenState extends State<VHTDetailsScreen> {
  void _onDetailsSubmitted({
    required String firstName,
    required String lastName,
    required String phoneNumber,
    String? village,
    String? district,
    String? subCounty,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PinSetupScreen(
          registrationData: {
            'firstName': firstName,
            'lastName': lastName,
            'phoneNumber': phoneNumber,
            'role': widget.role,
            'village': village,
            'district': district,
            'subCounty': subCounty,
          },
          onPinConfirmed: (pin) => _completeRegistration(
            firstName: firstName,
            lastName: lastName,
            phoneNumber: phoneNumber,
            role: widget.role,
            pin: pin,
            village: village,
            district: district,
            subCounty: subCounty,
          ),
        ),
      ),
    );
  }

  Future<void> _completeRegistration({
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String role,
    required String pin,
    String? village,
    String? district,
    String? subCounty,
  }) async {
    try {
      final pinHash = PinUtils.hashPin(pin);
      final docRef = FirebaseFirestore.instance.collection('users').doc();
      final uid = docRef.id;

      await docRef.set({
        'uid': uid,
        'id': uid,
        'firstName': firstName,
        'lastName': lastName,
        'phoneNumber': phoneNumber,
        'role': role,
        'pinHash': pinHash,
        if (village != null) 'village': village,
        if (district != null) 'district': district,
        if (subCounty != null) 'subCounty': subCounty,
        'createdAt': DateTime.now().toIso8601String(),
      });

      CurrentUserSession.uid = uid;
      CurrentUserSession.role = role;
      CurrentUserSession.firstName = firstName;
      CurrentUserSession.lastName = lastName;
      CurrentUserSession.phoneNumber = phoneNumber;

      // Save user data to device for future sessions
      await DeviceStorageService.saveRegisteredUser(
        phoneNumber: phoneNumber,
        firstName: firstName,
        lastName: lastName,
      );

      if (mounted) {
        Navigator.popUntil(context, (route) => route.isFirst);
        Navigator.pushNamedAndRemoveUntil(context, '/vht-dashboard', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration failed: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('VHT Details'),
        backgroundColor: AppColors.primary,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 24.0,
            right: 24.0,
            top: 24.0,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24.0,
          ),
          child: VHTDetailsForm(
            phoneNumber: widget.phoneNumber,
            onSubmit: _onDetailsSubmitted,
          ),
        ),
      ),
    );
  }
}

// Ambulance Driver Details Screen
class AmbulanceDriverDetailsScreen extends StatefulWidget {
  final String phoneNumber;
  final String role;

  const AmbulanceDriverDetailsScreen({
    Key? key,
    required this.phoneNumber,
    required this.role,
  }) : super(key: key);

  @override
  State<AmbulanceDriverDetailsScreen> createState() => _AmbulanceDriverDetailsScreenState();
}

class _AmbulanceDriverDetailsScreenState extends State<AmbulanceDriverDetailsScreen> {
  void _onDetailsSubmitted({
    required String firstName,
    required String lastName,
    required String phoneNumber,
    String? licenseNumber,
    String? ambulanceNumber,
    String? organization,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PinSetupScreen(
          registrationData: {
            'firstName': firstName,
            'lastName': lastName,
            'phoneNumber': phoneNumber,
            'role': widget.role,
            'licenseNumber': licenseNumber,
            'ambulanceNumber': ambulanceNumber,
            'organization': organization,
          },
          onPinConfirmed: (pin) => _completeRegistration(
            firstName: firstName,
            lastName: lastName,
            phoneNumber: phoneNumber,
            role: widget.role,
            pin: pin,
            licenseNumber: licenseNumber,
            ambulanceNumber: ambulanceNumber,
            organization: organization,
          ),
        ),
      ),
    );
  }

  Future<void> _completeRegistration({
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String role,
    required String pin,
    String? licenseNumber,
    String? ambulanceNumber,
    String? organization,
  }) async {
    try {
      final pinHash = PinUtils.hashPin(pin);
      final docRef = FirebaseFirestore.instance.collection('users').doc();
      final uid = docRef.id;

      await docRef.set({
        'uid': uid,
        'id': uid,
        'firstName': firstName,
        'lastName': lastName,
        'phoneNumber': phoneNumber,
        'role': role,
        'pinHash': pinHash,
        if (licenseNumber != null) 'licenseNumber': licenseNumber,
        if (ambulanceNumber != null) 'ambulanceNumber': ambulanceNumber,
        if (organization != null) 'organization': organization,
        'createdAt': DateTime.now().toIso8601String(),
      });

      CurrentUserSession.uid = uid;
      CurrentUserSession.role = role;
      CurrentUserSession.firstName = firstName;
      CurrentUserSession.lastName = lastName;
      CurrentUserSession.phoneNumber = phoneNumber;

      // Save user data to device for future sessions
      await DeviceStorageService.saveRegisteredUser(
        phoneNumber: phoneNumber,
        firstName: firstName,
        lastName: lastName,
      );

      if (mounted) {
        Navigator.popUntil(context, (route) => route.isFirst);
        Navigator.pushNamedAndRemoveUntil(context, '/ambulance-dashboard', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration failed: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Ambulance Driver Details'),
        backgroundColor: AppColors.primary,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 24.0,
            right: 24.0,
            top: 24.0,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24.0,
          ),
          child: AmbulanceDriverDetailsForm(
            phoneNumber: widget.phoneNumber,
            onSubmit: _onDetailsSubmitted,
          ),
        ),
      ),
    );
  }
}

// Admin Details Screen
class AdminDetailsScreen extends StatefulWidget {
  final String phoneNumber;
  final String role;

  const AdminDetailsScreen({
    Key? key,
    required this.phoneNumber,
    required this.role,
  }) : super(key: key);

  @override
  State<AdminDetailsScreen> createState() => _AdminDetailsScreenState();
}

class _AdminDetailsScreenState extends State<AdminDetailsScreen> {
  void _onDetailsSubmitted({
    required String firstName,
    required String lastName,
    required String phoneNumber,
    String? organization,
    String? position,
    String? email,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PinSetupScreen(
          registrationData: {
            'firstName': firstName,
            'lastName': lastName,
            'phoneNumber': phoneNumber,
            'role': widget.role,
            'organization': organization,
            'position': position,
            'email': email,
          },
          onPinConfirmed: (pin) => _completeRegistration(
            firstName: firstName,
            lastName: lastName,
            phoneNumber: phoneNumber,
            role: widget.role,
            pin: pin,
            organization: organization,
            position: position,
            email: email,
          ),
        ),
      ),
    );
  }

  Future<void> _completeRegistration({
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String role,
    required String pin,
    String? organization,
    String? position,
    String? email,
  }) async {
    try {
      final pinHash = PinUtils.hashPin(pin);
      final docRef = FirebaseFirestore.instance.collection('users').doc();
      final uid = docRef.id;

      await docRef.set({
        'uid': uid,
        'id': uid,
        'firstName': firstName,
        'lastName': lastName,
        'phoneNumber': phoneNumber,
        'role': role,
        'pinHash': pinHash,
        if (organization != null) 'organization': organization,
        if (position != null) 'position': position,
        if (email != null) 'email': email,
        'createdAt': DateTime.now().toIso8601String(),
      });

      CurrentUserSession.uid = uid;
      CurrentUserSession.role = role;
      CurrentUserSession.firstName = firstName;
      CurrentUserSession.lastName = lastName;
      CurrentUserSession.phoneNumber = phoneNumber;

      // Save user data to device for future sessions
      await DeviceStorageService.saveRegisteredUser(
        phoneNumber: phoneNumber,
        firstName: firstName,
        lastName: lastName,
      );

      if (mounted) {
        Navigator.popUntil(context, (route) => route.isFirst);
        Navigator.pushNamedAndRemoveUntil(context, '/admin-dashboard', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration failed: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Admin Details'),
        backgroundColor: AppColors.primary,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 24.0,
            right: 24.0,
            top: 24.0,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24.0,
          ),
          child: AdminDetailsForm(
            phoneNumber: widget.phoneNumber,
            onSubmit: _onDetailsSubmitted,
          ),
        ),
      ),
    );
  }
}

// Clinician Details Screen
class ClinicianDetailsScreen extends StatefulWidget {
  final String phoneNumber;
  final String role;

  const ClinicianDetailsScreen({
    Key? key,
    required this.phoneNumber,
    required this.role,
  }) : super(key: key);

  @override
  State<ClinicianDetailsScreen> createState() => _ClinicianDetailsScreenState();
}

class _ClinicianDetailsScreenState extends State<ClinicianDetailsScreen> {
  void _onDetailsSubmitted({
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String specialty,
    required String workplace,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PinSetupScreen(
          registrationData: {
            'firstName': firstName,
            'lastName': lastName,
            'phoneNumber': phoneNumber,
            'role': widget.role,
            'specialty': specialty,
            'workplace': workplace,
          },
          onPinConfirmed: (pin) => _completeRegistration(
            firstName: firstName,
            lastName: lastName,
            phoneNumber: phoneNumber,
            role: widget.role,
            pin: pin,
            specialty: specialty,
            workplace: workplace,
          ),
        ),
      ),
    );
  }

  Future<void> _completeRegistration({
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String role,
    required String pin,
    required String specialty,
    required String workplace,
  }) async {
    try {
      final pinHash = PinUtils.hashPin(pin);
      final docRef = FirebaseFirestore.instance.collection('users').doc();
      final uid = docRef.id;

      await docRef.set({
        'uid': uid,
        'id': uid,
        'firstName': firstName,
        'lastName': lastName,
        'phoneNumber': phoneNumber,
        'role': role,
        'pinHash': pinHash,
        'specialty': specialty,
        'workplace': workplace,
        'createdAt': DateTime.now().toIso8601String(),
      });

      CurrentUserSession.uid = uid;
      CurrentUserSession.role = role;
      CurrentUserSession.firstName = firstName;
      CurrentUserSession.lastName = lastName;
      CurrentUserSession.phoneNumber = phoneNumber;
      CurrentUserSession.workplace = workplace;
      CurrentUserSession.specialty = specialty;

      // Save user data to device for future sessions
      await DeviceStorageService.saveRegisteredUser(
        phoneNumber: phoneNumber,
        firstName: firstName,
        lastName: lastName,
      );

      if (mounted) {
        Navigator.popUntil(context, (route) => route.isFirst);
        Navigator.pushNamedAndRemoveUntil(context, '/clinic-dashboard', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration failed: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Clinician Details'),
        backgroundColor: AppColors.primary,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 24.0,
            right: 24.0,
            top: 24.0,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24.0,
          ),
          child: ClinicianRegistrationForm(
            phoneNumber: widget.phoneNumber,
            onSubmit: _onDetailsSubmitted,
          ),
        ),
      ),
    );
  }
}
