import 'package:flutter/material.dart';

// Clinic Staff Dashboard Screen
// Main dashboard for clinic staff

class ClinicDashboardScreen extends StatefulWidget {
  const ClinicDashboardScreen({Key? key}) : super(key: key);

  @override
  State<ClinicDashboardScreen> createState() => _ClinicDashboardScreenState();
}

class _ClinicDashboardScreenState extends State<ClinicDashboardScreen> {
  static const Color _primaryBlue = Color(0xFF0077CC);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final bool isWide = size.width >= 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clinic Dashboard'),
        centerTitle: false,
        backgroundColor: _primaryBlue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign out',
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double horizontalPadding = constraints.maxWidth < 400
                ? 16.0
                : 24.0;

            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: 16,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isWide ? 520 : double.infinity,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // TODO: Fetch clinic name from login / user profile information
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 16.0),
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: _primaryBlue.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _primaryBlue.withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Clinic',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Clinic Name',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'Welcome, Clinic Staff',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Monitor active emergency cases and incoming patients.',
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 24),
                      // Primary action button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.assignment_turned_in_outlined),
                          label: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 14.0),
                            child: Text(
                              'View Incoming Emergencies',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primaryBlue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            // Navigate to clinic active cases / incoming cases screen
                            Navigator.pushNamed(
                              context,
                              '/clinic-incoming-case',
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.people_outline),
                          label: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 14.0),
                            child: Text(
                              'View Active Cases',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: _primaryBlue,
                            side: BorderSide(
                              color: _primaryBlue.withOpacity(0.5),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            // Navigate to clinic current patients screen (same list for now)
                            Navigator.pushNamed(
                              context,
                              '/clinic-incoming-case',
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'You will see a list of incoming emergencies and active cases for your clinic.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color?.withOpacity(
                            0.8,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
