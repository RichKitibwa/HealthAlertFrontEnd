import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../current_user_session.dart';
import '../../../../core/utils/pin_utils.dart';
import '../../../../core/services/device_storage_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../vht/presentation/screens/vht_dashboard_screen.dart';
import '../../../ambulance/presentation/screens/ambulance_dashboard_screen.dart';
import '../../../clinic/presentation/screens/clinic_dashboard_screen.dart';
import '../../../admin/presentation/screens/admin_dashboard_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  final bool forcePhoneInput;
  
  const LoginScreen({
    Key? key,
    this.forcePhoneInput = false,
  }) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _pinController = TextEditingController();
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  bool _isLoading = false;
  bool _obscurePin = true;
  String? _errorMessage;
  bool _isRegisteredOnDevice = false;
  String? _userName;
  String? _phoneNumber;
  Map<String, dynamic>? _userData;
  bool _showPhoneInput = true; // Show phone input by default (for guest users)
  bool _isCheckingRegistration = true; // Track if we're still checking

  @override
  void initState() {
    super.initState();
    if (widget.forcePhoneInput) {
      // Force showing phone input, skip device registration check
      setState(() {
        _showPhoneInput = true;
        _isRegisteredOnDevice = false;
        _isCheckingRegistration = false;
      });
    } else {
      _checkDeviceRegistration();
    }
  }

  @override
  void dispose() {
    _pinController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _checkDeviceRegistration() async {
    final isRegistered = await DeviceStorageService.isUserRegisteredOnDevice();
    if (!mounted) return;
    
    if (isRegistered) {
      final userData = await DeviceStorageService.getRegisteredUserData();
      final phone = userData['phoneNumber'];
      final name = userData['name'];
      
      if (phone != null) {
        if (!mounted) return;
        setState(() {
          _isRegisteredOnDevice = true;
          _phoneNumber = phone;
          _userName = name ?? 'User';
          _showPhoneInput = false;
          _isCheckingRegistration = false;
        });
        _loadUserData();
      } else {
        if (!mounted) return;
        setState(() {
          _showPhoneInput = true;
          _isCheckingRegistration = false;
        });
      }
    } else {
      if (!mounted) return;
      setState(() {
        _showPhoneInput = true;
        _isCheckingRegistration = false;
      });
    }
  }

  Future<void> _loadUserData() async {
    if (_phoneNumber == null) return;
    if (!mounted) return;
    
    try {
      final usersQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('phoneNumber', isEqualTo: _phoneNumber)
          .get();

      if (!mounted) return;
      
      if (usersQuery.docs.isNotEmpty) {
        final userDoc = usersQuery.docs.first;
        final data = userDoc.data();
        data['uid'] = userDoc.id;
        data['id'] = userDoc.id;
        if (mounted) {
          setState(() {
            _userData = data;
          });
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  Future<void> _loadUserByPhone(String phoneNumber) async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final usersQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('phoneNumber', isEqualTo: phoneNumber)
          .get();

      if (!mounted) return;

      if (usersQuery.docs.isEmpty) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'No account found with this phone number. Please register first.';
          });
        }
        return;
      }

      final userDoc = usersQuery.docs.first;
      final data = userDoc.data();
      data['uid'] = userDoc.id;
      data['id'] = userDoc.id;
      
      if (mounted) {
        setState(() {
          _userData = data;
          _phoneNumber = phoneNumber;
          final fullName = '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}'.trim();
          _userName = fullName.isEmpty ? 'User' : fullName;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Error loading user data: ${e.toString()}';
        });
      }
    }
  }

  Future<void> _verifyPin() async {
    // If phone input is shown and phone number is not loaded, load user first
    if (_showPhoneInput && _userData == null) {
      if (!_formKey.currentState!.validate()) {
        return;
      }
      
      final phoneNumber = _phoneController.text.trim();
      await _loadUserByPhone(phoneNumber);
      
      // If user data is still null after loading, return (error already set)
      if (_userData == null) {
        return;
      }
    }

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

    if (_userData == null) {
      setState(() {
        _errorMessage = 'User data not loaded. Please try again.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final pinHash = PinUtils.hashPin(pin);
      final storedPinHash = _userData!['pinHash'] as String?;

      if (storedPinHash == null || storedPinHash != pinHash) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Incorrect PIN. Please try again.';
        });
        _pinController.clear();
        return;
      }

      // PIN is correct - populate session and navigate
      final uid = _userData!['uid'] as String? ?? _userData!['id'] as String? ?? '';
      
      CurrentUserSession.uid = uid;
      CurrentUserSession.role = _userData!['role'] ?? 'VHT';
      CurrentUserSession.firstName = _userData!['firstName'] as String?;
      CurrentUserSession.lastName = _userData!['lastName'] as String?;
      CurrentUserSession.phoneNumber = _userData!['phoneNumber'] as String?;
      CurrentUserSession.profileImageUrl = _userData!['profileImageUrl'] as String?;
      CurrentUserSession.workplace = _userData!['workplace'] as String?;
      CurrentUserSession.specialty = _userData!['specialty'] as String?;

      // Save user data to device for future logins
      if (!_isRegisteredOnDevice && _phoneNumber != null) {
        await DeviceStorageService.saveRegisteredUser(
          phoneNumber: _phoneNumber!,
          firstName: CurrentUserSession.firstName ?? '',
          lastName: CurrentUserSession.lastName ?? '',
        );
      }

      setState(() => _isLoading = false);

      if (mounted) {
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
      );
    });
  }

  Future<void> _registerAgain() async {
    // Clear device registration data
    await DeviceStorageService.clearRegisteredUser();
    
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const RegisterScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Always show the login form immediately
    // Phone input will show if user is not registered on device (guest user)
    // PIN-only will show if user is registered on device
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
                  Icon(
                    Icons.local_hospital,
                    size: 100,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 32),
                  Text(
                    (widget.forcePhoneInput || !_isRegisteredOnDevice) ? 'Login' : 'Welcome back!',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (!widget.forcePhoneInput && _isRegisteredOnDevice && _userName != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _userName!,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 32),
                  
                  // Phone Number Input (only if not registered on device or user data not loaded, or forcePhoneInput is true)
                  if ((widget.forcePhoneInput || _showPhoneInput) && _userData == null) ...[
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
                    const SizedBox(height: 24),
                  ],

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

                  // Login Button
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _verifyPin,
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
                              'Login',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Register New Account Link
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const RegisterScreen()),
                      );
                    },
                    child: const Text(
                      'Register new account',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
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
