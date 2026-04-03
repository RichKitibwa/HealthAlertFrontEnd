import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/health_facility_constants.dart';

class ClinicianRegistrationForm extends StatefulWidget {
  final String phoneNumber;
  final Function({
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String workplace,
    required String camp,
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

  String? _selectedCamp;
  String? _selectedFacility;

  List<String> get _facilitiesForCamp =>
      _selectedCamp != null
          ? HealthFacilityConstants.facilitiesByCamp[_selectedCamp!] ?? []
          : [];

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
        workplace: _selectedFacility!,
        camp: _selectedCamp!,
      );
    }
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE3E8EF), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF0077CC), width: 2),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE3E8EF), width: 1),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
    );
  }

  static const _dropdownStyle = TextStyle(
    fontFamily: 'Inter',
    fontWeight: FontWeight.w400,
    fontSize: 14,
    color: Color(0xFF1A1A1A),
  );

  static const _dropdownIcon = Icon(
    Icons.keyboard_arrow_down_rounded,
    color: Color(0xFF667085),
  );

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
            decoration: _inputDecoration(label: 'First Name', icon: Icons.person),
            validator: (v) => (v == null || v.isEmpty) ? 'Please enter your first name' : null,
          ),
          const SizedBox(height: 16),

          // Last Name
          TextFormField(
            controller: _lastNameController,
            decoration: _inputDecoration(label: 'Last Name', icon: Icons.person_outline),
            validator: (v) => (v == null || v.isEmpty) ? 'Please enter your last name' : null,
          ),
          const SizedBox(height: 16),

          // Camp Selection
          DropdownButtonFormField<String>(
            value: _selectedCamp,
            isExpanded: true,
            decoration: _inputDecoration(label: 'Settlement / Camp', icon: Icons.location_city),
            style: _dropdownStyle,
            icon: _dropdownIcon,
            iconSize: 24,
            borderRadius: BorderRadius.circular(12),
            dropdownColor: Colors.white,
            elevation: 8,
            items: HealthFacilityConstants.camps.map((c) {
              return DropdownMenuItem<String>(value: c, child: Text(c));
            }).toList(),
            onChanged: (v) {
              setState(() {
                _selectedCamp = v;
                _selectedFacility = null; // reset facility when camp changes
              });
            },
            validator: (v) => (v == null) ? 'Please select your settlement / camp' : null,
          ),
          const SizedBox(height: 16),

          // Facility / Clinic Selection (depends on camp)
          DropdownButtonFormField<String>(
            value: _selectedFacility,
            isExpanded: true,
            decoration: _inputDecoration(
              label: 'Health Facility / Clinic',
              icon: Icons.local_hospital,
            ),
            style: _dropdownStyle,
            icon: _dropdownIcon,
            iconSize: 24,
            borderRadius: BorderRadius.circular(12),
            dropdownColor: Colors.white,
            elevation: 8,
            hint: Text(
              _selectedCamp == null ? 'Select a camp first' : 'Select your facility',
              style: const TextStyle(fontSize: 14, color: Color(0xFF9CA3AF)),
            ),
            items: _facilitiesForCamp.map((f) {
              return DropdownMenuItem<String>(value: f, child: Text(f));
            }).toList(),
            onChanged: _selectedCamp == null ? null : (v) => setState(() => _selectedFacility = v),
            validator: (v) => (v == null) ? 'Please select your health facility' : null,
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
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
