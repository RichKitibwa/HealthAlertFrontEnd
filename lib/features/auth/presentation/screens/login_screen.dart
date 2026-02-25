import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../current_user_session.dart';
import '../../../../core/utils/pin_utils.dart';
import '../../../../core/services/device_storage_service.dart';
import '../../../../core/services/fcm_notification_service.dart';
import '../../../../core/services/locale_notifier.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  final bool forcePhoneInput;

  const LoginScreen({Key? key, this.forcePhoneInput = false}) : super(key: key);

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
  bool _showForgotPin = false;
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
        _userData = null; // Clear any cached user data to force phone input
        _phoneNumber = null; // Clear phone number
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
          _userName = name ?? AppLocalizations.of(context)!.user;
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
      // Prefer fetch by UID when user is already signed in (passes Firestore rules)
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();
        if (userDoc.exists && mounted) {
          final data = userDoc.data()!;
          data['uid'] = userDoc.id;
          data['id'] = userDoc.id;
          setState(() => _userData = data);
          return;
        }
      }

      // Otherwise query by phoneNumber (allowed by rules when auth.token.phone_number matches)
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
      // ignore: avoid_print
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
      // Prefer fetch by UID when already signed in
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();
        if (userDoc.exists && mounted) {
          final data = userDoc.data()!;
          data['uid'] = userDoc.id;
          data['id'] = userDoc.id;
          setState(() {
            _userData = data;
            _phoneNumber = phoneNumber;
            _userName = '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}'.trim();
            if (_userName?.isEmpty ?? true) _userName = AppLocalizations.of(context)!.user;
            _isLoading = false;
          });
          return;
        }
      }

      final usersQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('phoneNumber', isEqualTo: phoneNumber)
          .get();

      if (!mounted) return;

      if (usersQuery.docs.isEmpty) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorMessage = AppLocalizations.of(context)!.noAccountFoundRegisterFirst;
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
          final fullName =
              '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}'.trim();
          _userName = fullName.isEmpty ? AppLocalizations.of(context)!.user : fullName;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = '${AppLocalizations.of(context)!.errorLoadingUserData}: ${e.toString()}';
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
        _errorMessage = AppLocalizations.of(context)!.pleaseEnterPin;
        _showForgotPin = false;
      });
      return;
    }

    if (!PinUtils.isValidPinFormat(pin)) {
      setState(() {
        _errorMessage = AppLocalizations.of(context)!.pinMustBeDigits;
        _showForgotPin = false;
      });
      return;
    }

    if (_userData == null) {
      setState(() {
        _errorMessage = AppLocalizations.of(context)!.userDataNotLoaded;
        _showForgotPin = false;
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
          _errorMessage = AppLocalizations.of(context)!.incorrectPinTryAgain;
          _showForgotPin = true;
        });
        _pinController.clear();
        return;
      }

      // PIN is correct - populate session and navigate
      final uid =
          _userData!['uid'] as String? ?? _userData!['id'] as String? ?? '';

      CurrentUserSession.uid = uid;
      CurrentUserSession.role = _userData!['role'] ?? 'VHT';
      CurrentUserSession.firstName = _userData!['firstName'] as String?;
      CurrentUserSession.lastName = _userData!['lastName'] as String?;
      CurrentUserSession.phoneNumber = _userData!['phoneNumber'] as String?;
      CurrentUserSession.profileImageUrl =
          _userData!['profileImageUrl'] as String?;
      CurrentUserSession.workplace = _userData!['workplace'] as String?;
      CurrentUserSession.specialty = _userData!['specialty'] as String?;
      CurrentUserSession.camp = _userData!['camp'] as String?;
      CurrentUserSession.email = _userData!['email'] as String?;

      // Save user data to device for future logins
      if (!_isRegisteredOnDevice && _phoneNumber != null) {
        await DeviceStorageService.saveRegisteredUser(
          phoneNumber: _phoneNumber!,
          firstName: CurrentUserSession.firstName ?? '',
          lastName: CurrentUserSession.lastName ?? '',
        );
      }

      // Restore this user's saved language preference.
      final sessionUid = CurrentUserSession.uid;
      if (mounted && sessionUid != null && sessionUid.isNotEmpty) {
        final localeNotifier =
            Provider.of<LocaleNotifier>(context, listen: false);
        await localeNotifier.loadAndApplyLocaleForUser(sessionUid);
      }

      // Initialize FCM and save token to user document
      final fcmService = FCMNotificationService();
      fcmService.initialize();
      // Start real-time notification listener (badge/list updates)
      if (sessionUid != null && sessionUid.isNotEmpty) {
        fcmService.startNotificationListener(sessionUid);
      }

      setState(() => _isLoading = false);

      if (mounted) {
        _navigateToRoleDashboard(CurrentUserSession.role ?? 'VHT');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = AppLocalizations.of(context)!.errorGeneric(e.toString());
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

      Navigator.of(
        context,
        rootNavigator: true,
      ).pushNamedAndRemoveUntil(route, (r) => false);
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
    final l10n = AppLocalizations.of(context)!;
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
                  Image.asset(
                    'assets/images/healthcare_logo.png',
                    height: 100,
                    fit: BoxFit.contain,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    (widget.forcePhoneInput || !_isRegisteredOnDevice)
                        ? l10n.login
                        : l10n.welcomeBack,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (!widget.forcePhoneInput &&
                      _isRegisteredOnDevice &&
                      _userName != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _userName!,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 32),

                  // Phone Number Input
                  if ((widget.forcePhoneInput || _showPhoneInput) &&
                      _userData == null) ...[
                    TextFormField(
                      controller: _phoneController,
                      decoration: InputDecoration(
                        labelText: l10n.phoneNumber,
                        hintText: l10n.phoneNumberHint,
                        labelStyle: const TextStyle(
                          color: AppColors.textSecondary,
                        ),
                        prefixIcon: const Icon(Icons.phone),
                        prefixIconColor: AppColors.textSecondary,
                        border: const OutlineInputBorder(),
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l10n.pleaseEnterPhoneNumber;
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
                      labelText: l10n.pin,
                      labelStyle: const TextStyle(
                        color: AppColors.textSecondary,
                      ),
                      prefixIcon: const Icon(Icons.lock_outline),
                      prefixIconColor: AppColors.textSecondary,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePin ? Icons.visibility : Icons.visibility_off,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePin = !_obscurePin;
                          });
                        },
                      ),
                      border: const OutlineInputBorder(),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                          color: AppColors.primary,
                          width: 2,
                        ),
                      ),
                      errorText: _errorMessage,
                    ),
                    keyboardType: TextInputType.number,
                    obscureText: _obscurePin,
                    maxLength: 6,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      letterSpacing: 6,
                      fontWeight: FontWeight.bold,
                    ),
                    onFieldSubmitted: (_) => _verifyPin(),
                  ),
                  const SizedBox(height: 24),

                  // Login Button (3D solid CTA)
                  SizedBox(
                    height: 56,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: AppColors.primary.withValues(alpha: 0.92),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryDark.withValues(
                              alpha: 0.22,
                            ),
                            blurRadius: 14,
                            offset: const Offset(0, 8),
                          ),
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _isLoading ? null : _verifyPin,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Subtle top highlight “sheen” for depth
                                Positioned.fill(
                                  child: IgnorePointer(
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.white.withValues(
                                              alpha: 0.22,
                                            ),
                                            Colors.white.withValues(
                                              alpha: 0.00,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                _isLoading
                                    ? const SizedBox(
                                        height: 22,
                                        width: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Text(
                                        l10n.login,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                          letterSpacing: 0.2,
                                        ),
                                      ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // If user is registered but PIN fails repeatedly, offer re-register
                  if (!_isCheckingRegistration &&
                      _isRegisteredOnDevice &&
                      _showForgotPin) ...[
                    TextButton(
                      onPressed: _registerAgain,
                      child: Text(
                        l10n.forgotPinRegisterAgain,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],

                  // Register New Account Link
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisterScreen(),
                        ),
                      );
                    },
                    child: Text(
                      l10n.registerNewAccount,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
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
