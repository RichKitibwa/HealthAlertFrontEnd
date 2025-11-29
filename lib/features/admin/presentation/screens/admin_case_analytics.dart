import 'package:flutter/material.dart';

class AdminCaseAnalyticsScreen extends StatelessWidget {
  const AdminCaseAnalyticsScreen({super.key});

  static const Color _backgroundColor = Color(0xFFF7F9FC);
  static const Color _primaryBlue = Color(0xFF0077CC);
  static const Color _cardBorder = Color(0xFFE3E8EF);
  static const Color _buttonBlue = Color(0xFF0077CC);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const _AdminCaseAnalyticsHeader(),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 24,
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // Keep content nicely centered on larger screens
                      final maxWidth = constraints.maxWidth > 420
                          ? 420.0
                          : constraints.maxWidth;

                      return Align(
                        alignment: Alignment.topCenter,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: maxWidth,
                            minWidth: maxWidth * 0.85,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Average Response Time card
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 24,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: _cardBorder),
                                ),
                                child: const Center(
                                  // TODO: Replace hard-coded value with computed average response time
                                  child: Text(
                                    'Average Response Time: 12 min',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w400,
                                      fontSize: 16,
                                      height: 19 / 16,
                                      color: _primaryBlue,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: size.height * 0.04),
                              // High Case Volume Areas card
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 24,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: _cardBorder),
                                ),
                                child: const Center(
                                  // TODO: Replace placeholder with visualization or list of high-volume areas
                                  child: Text(
                                    'High Case Volume Areas',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w400,
                                      fontSize: 16,
                                      height: 19 / 16,
                                      color: _primaryBlue,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: size.height * 0.06),
                              // Export Reports button
                              SizedBox(
                                width: double.infinity,
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: 360,
                                  ),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      // TODO: Implement export logic (e.g., generate CSV/PDF reports)
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _buttonBlue,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Text(
                                      'Export Reports',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w400,
                                        fontSize: 20,
                                        height: 24 / 20,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminCaseAnalyticsHeader extends StatelessWidget {
  const _AdminCaseAnalyticsHeader();

  static const Color _primaryBlue = Color(0xFF0077CC);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(color: Colors.white),
      child: Row(
        children: [
          // Back button
          IconButton(
            icon: const Icon(Icons.arrow_back),
            color: _primaryBlue,
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          const SizedBox(width: 4),
          // A square
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: _primaryBlue,
              borderRadius: BorderRadius.circular(4),
            ),
            alignment: Alignment.center,
            child: const Text(
              'A',
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
                fontSize: 14,
                height: 17 / 14,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Analytics',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w700,
                fontSize: 20,
                height: 24 / 20,
                color: _primaryBlue,
              ),
            ),
          ),
          const SizedBox(width: 48), // spacer to balance back button + A
        ],
      ),
    );
  }
}
