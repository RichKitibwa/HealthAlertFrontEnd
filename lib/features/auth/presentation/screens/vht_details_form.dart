import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';

class VHTDetailsForm extends StatefulWidget {
  final String phoneNumber;
  final Function({
    required String firstName,
    required String lastName,
    required String phoneNumber,
    String? village,
    String? district,
    String? subCounty,
  }) onSubmit;

  const VHTDetailsForm({
    Key? key,
    required this.phoneNumber,
    required this.onSubmit,
  }) : super(key: key);

  @override
  State<VHTDetailsForm> createState() => _VHTDetailsFormState();
}

class _VHTDetailsFormState extends State<VHTDetailsForm> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  late final _phoneController = TextEditingController(text: widget.phoneNumber);
  final _villageController = TextEditingController();
  final _districtController = TextEditingController();
  final _subCountyController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _villageController.dispose();
    _districtController.dispose();
    _subCountyController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      widget.onSubmit(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        village: _villageController.text.trim().isEmpty ? null : _villageController.text.trim(),
        district: _districtController.text.trim().isEmpty ? null : _districtController.text.trim(),
        subCounty: _subCountyController.text.trim().isEmpty ? null : _subCountyController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
                TextFormField(
                  controller: _firstNameController,
                  decoration: InputDecoration(
                    labelText: l10n.firstName,
                    prefixIcon: const Icon(Icons.person),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.pleaseEnterFirstName;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _lastNameController,
                  decoration: InputDecoration(
                    labelText: l10n.lastName,
                    prefixIcon: const Icon(Icons.person_outline),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.pleaseEnterLastName;
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
                    child: Text(
                      l10n.setUpPin,
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
