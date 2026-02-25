import 'package:flutter/material.dart';
import '../../../../core/utils/pin_utils.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import 'pin_confirmation_screen.dart';

class PinSetupScreen extends StatefulWidget {
  final Map<String, dynamic> registrationData;
  final void Function(String pin, BuildContext context) onPinConfirmed;

  const PinSetupScreen({
    Key? key,
    required this.registrationData,
    required this.onPinConfirmed,
  }) : super(key: key);

  @override
  State<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends State<PinSetupScreen> {
  final _pinController = TextEditingController();
  bool _obscurePin = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  void _submitPin() {
    final pin = _pinController.text.trim();

    // Clear previous error
    setState(() {
      _errorMessage = null;
    });

    // Validate PIN
    if (pin.isEmpty) {
      setState(() {
        _errorMessage = AppLocalizations.of(context)!.pleaseEnterAPin;
      });
      return;
    }

    if (!PinUtils.isValidPinFormat(pin)) {
      setState(() {
        _errorMessage = AppLocalizations.of(context)!.pinMustBeDigits;
      });
      return;
    }

    // PIN is valid, navigate to PIN confirmation
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PinConfirmationScreen(
            pin: pin,
            onConfirm: (confirmContext) {
              widget.onPinConfirmed(pin, confirmContext);
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(l10n.setUpPin),
        backgroundColor: AppColors.primary,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              left: 24.0,
              right: 24.0,
              top: 24.0,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.lock, size: 80, color: AppColors.primary),
                const SizedBox(height: 32),
                Text(
                  l10n.setYourPin,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.enterPinBetween4And6,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                // PIN Input
                TextFormField(
                  controller: _pinController,
                  decoration: InputDecoration(
                    labelText: l10n.enterPin,
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePin ? Icons.visibility : Icons.visibility_off),
                      onPressed: () {
                        setState(() {
                          _obscurePin = !_obscurePin;
                        });
                      },
                    ),
                    border: const OutlineInputBorder(),
                    helperText: l10n.pinHelperText,
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
                  onChanged: (_) {
                    // Clear error when user starts typing
                    if (_errorMessage != null) {
                      setState(() {
                        _errorMessage = null;
                      });
                    }
                  },
                  onFieldSubmitted: (_) => _submitPin(),
                ),
                const SizedBox(height: 32),

                // Enter Button
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitPin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      l10n.enterButton,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
