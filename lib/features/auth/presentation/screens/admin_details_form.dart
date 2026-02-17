import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../../../../core/theme/app_colors.dart';

class AdminDetailsForm extends StatefulWidget {
  final String phoneNumber;
  final Function({
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String email,
    String? organization,
    String? position,
  }) onSubmit;

  const AdminDetailsForm({
    Key? key,
    required this.phoneNumber,
    required this.onSubmit,
  }) : super(key: key);

  @override
  State<AdminDetailsForm> createState() => _AdminDetailsFormState();
}

class _AdminDetailsFormState extends State<AdminDetailsForm> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  late final _phoneController = TextEditingController(text: widget.phoneNumber);
  final _organizationController = TextEditingController();
  final _positionController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isLoadingOTP = false;
  bool _otpSent = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _organizationController.dispose();
    _positionController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendOTP() async {
    if (!_formKey.currentState!.validate()) return;
    
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your email address'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoadingOTP = true);

    try {
      final functions = FirebaseFunctions.instance;
      final callable = functions.httpsCallable('sendAdminOTP');
      
      final result = await callable.call({
        'email': email,
        'phoneNumber': widget.phoneNumber,
      });

      if (result.data['success'] == true) {
        setState(() {
          _otpSent = true;
          _isLoadingOTP = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification code sent to your email'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to OTP verification screen
        Navigator.pushNamed(
          context,
          '/admin-email-otp',
          arguments: {
            'email': email,
            'firstName': _firstNameController.text.trim(),
            'lastName': _lastNameController.text.trim(),
            'phoneNumber': widget.phoneNumber,
            'organization': _organizationController.text.trim().isEmpty ? null : _organizationController.text.trim(),
            'position': _positionController.text.trim().isEmpty ? null : _positionController.text.trim(),
          },
        );
      }
    } catch (e) {
      setState(() => _isLoadingOTP = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send verification code: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();
      if (email.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter your email address'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      if (!_otpSent) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please verify your email first by clicking "Get Verification Code"'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      widget.onSubmit(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        email: email,
        organization: _organizationController.text.trim().isEmpty ? null : _organizationController.text.trim(),
        position: _positionController.text.trim().isEmpty ? null : _positionController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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

                // Email (Required for Admin)
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email Address *',
                    hintText: 'admin@example.com',
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email is required for admin registration';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Get Verification Code Button
                SizedBox(
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: _isLoadingOTP ? null : _sendOTP,
                    icon: _isLoadingOTP
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.email),
                    label: Text(_otpSent ? 'Code Sent - Resend?' : 'Get Verification Code'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _otpSent ? Colors.green : AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                if (_otpSent) ...[
                  const SizedBox(height: 8),
                  Text(
                    '✓ Verification code sent. Please check your email and verify.',
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          );
  }
}
