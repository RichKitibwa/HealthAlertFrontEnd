import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class ClinicianRegistrationForm extends StatefulWidget {
  final String phoneNumber; // Pre-filled from OTP verification
  final Function({
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String specialty,
    required String workplace,
  }) onSubmit;

  const ClinicianRegistrationForm({
    Key? key,
    required this.phoneNumber,
    required this.onSubmit,
  }) : super(key: key);

  @override
  State<ClinicianRegistrationForm> createState() => _ClinicianRegistrationFormState();
}

class _ClinicianRegistrationFormState extends State<ClinicianRegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  late final _phoneController = TextEditingController(text: widget.phoneNumber);
  final _specialtyController = TextEditingController();
  final _workplaceController = TextEditingController();
  String? _selectedSpecialty;

  final List<String> _commonSpecialties = [
    'General Medicine',
    'Pediatrics',
    'Obstetrics & Gynecology',
    'Surgery',
    'Clinical Officer',
    'Nurse',
  ];

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _specialtyController.dispose();
    _workplaceController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final specialty = _selectedSpecialty ?? _specialtyController.text.trim();
      
      widget.onSubmit(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        specialty: specialty,
        workplace: _workplaceController.text.trim(),
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

                // Profession/Specialty
                DropdownButtonFormField<String>(
                  value: _selectedSpecialty,
                  decoration: InputDecoration(
                    labelText: 'Profession',
                    prefixIcon: const Icon(Icons.medical_services),
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
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.red,
                        width: 1,
                      ),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.red,
                        width: 2,
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
                  items: [
                    ..._commonSpecialties.map((String specialty) {
                      return DropdownMenuItem<String>(
                        value: specialty,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text(specialty),
                        ),
                      );
                    }),
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 4),
                        child: Text('Other (type below)'),
                      ),
                    ),
                  ],
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedSpecialty = newValue;
                      if (newValue != null) {
                        _specialtyController.clear();
                      }
                    });
                  },
                  validator: (value) {
                    if (value == null && _specialtyController.text.trim().isEmpty) {
                      return 'Please select or enter your profession';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Custom Profession Input (shown when "Other" is selected)
                if (_selectedSpecialty == null)
                  TextFormField(
                    controller: _specialtyController,
                    decoration: const InputDecoration(
                      labelText: 'Enter Your Profession',
                      prefixIcon: Icon(Icons.edit),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (_selectedSpecialty == null && (value == null || value.isEmpty)) {
                        return 'Please enter your profession';
                      }
                      return null;
                    },
                  ),
                if (_selectedSpecialty == null) const SizedBox(height: 16),

                // Clinic
                TextFormField(
                  controller: _workplaceController,
                  decoration: const InputDecoration(
                    labelText: 'Clinic',
                    prefixIcon: Icon(Icons.local_hospital),
                    border: OutlineInputBorder(),
                    helperText: 'Enter the name of the clinic you are attached to',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your clinic';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // Set PIN Button
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
                      'Set PIN',
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
