import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class RegistrationForm extends StatefulWidget {
  final String role;
  final Function({
    required String firstName,
    required String lastName,
    required String phoneNumber,
  }) onSubmit;

  const RegistrationForm({
    Key? key,
    required this.role,
    required this.onSubmit,
  }) : super(key: key);

  @override
  State<RegistrationForm> createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<RegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      widget.onSubmit(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
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
              final cleaned = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
              if (cleaned.length < 9) {
                return 'Phone number must be at least 9 digits';
              }
              return null;
            },
          ),
          const SizedBox(height: 32),

          // Continue Button (will navigate to PIN setup)
          SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Continue to PIN Setup',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
