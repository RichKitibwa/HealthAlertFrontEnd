import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';

class PinConfirmationScreen extends StatefulWidget {
  final String pin;
  final void Function(BuildContext context) onConfirm;

  const PinConfirmationScreen({
    Key? key,
    required this.pin,
    required this.onConfirm,
  }) : super(key: key);

  @override
  State<PinConfirmationScreen> createState() => _PinConfirmationScreenState();
}

class _PinConfirmationScreenState extends State<PinConfirmationScreen> {
  final _confirmPinController = TextEditingController();
  bool _obscurePin = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _confirmPinController.dispose();
    super.dispose();
  }

  void _confirmPin() {
    final confirmPin = _confirmPinController.text.trim();

    // Clear previous error
    setState(() {
      _errorMessage = null;
    });

    // Validate PIN
    if (confirmPin.isEmpty) {
      setState(() {
        _errorMessage = AppLocalizations.of(context)!.pleaseConfirmYourPin;
      });
      return;
    }

    if (confirmPin != widget.pin) {
      setState(() {
        _errorMessage = AppLocalizations.of(context)!.pinsDoNotMatch;
      });
      _confirmPinController.clear();
      return;
    }

    // PINs match, proceed
    setState(() => _isLoading = true);
    
    widget.onConfirm(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.confirmPin),
        backgroundColor: AppColors.primary,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.lock_outline, size: 80, color: AppColors.primary),
                const SizedBox(height: 32),
                Text(
                  l10n.confirmYourPin,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.pleaseReenterPinToConfirm,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                // Confirm PIN Input
                TextFormField(
                  controller: _confirmPinController,
                  decoration: InputDecoration(
                    labelText: l10n.reenterPin,
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
                  onChanged: (_) {
                    // Clear error when user starts typing
                    if (_errorMessage != null) {
                      setState(() {
                        _errorMessage = null;
                      });
                    }
                  },
                  onFieldSubmitted: (_) => _confirmPin(),
                ),
                const SizedBox(height: 32),

                // Confirm Button
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _confirmPin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            l10n.confirm,
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
