import 'package:flutter/material.dart';
import 'admin_case_timeline.dart';
import 'admin_navigation_bar.dart';
import '../../../common/presentation/screens/top_navigation_bar.dart';
import '../../../auth/current_user_session.dart';

class AdminCaseDashboardScreen extends StatelessWidget {
  const AdminCaseDashboardScreen({super.key});

  static const Color _backgroundColor = Color(0xFFF7F9FC);
  static const Color _primaryBlue = Color(0xFF0077CC);
  static const Color _cardBorder = Color(0xFFE3E8EF);
  static const Color _statusGreen = Color(0xFF4BD964);
  static const Color _statusOrange = Color(0xFFFF6A3D);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: TopNavigationBar(
        role: CurrentUserSession.role ?? 'Admin',
        profileImageUrl: CurrentUserSession.profileImageUrl,
        showBackButton: true,
        onBack: () {
          Navigator.pop(context);
        },
        onSignOut: () {
          CurrentUserSession.clear();
          Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
        },
      ),
      backgroundColor: _backgroundColor,
      bottomNavigationBar: AdminNavigationBar(
        currentIndex: 0, // 0 = Home, 1 = Reports/Analytics
        onItemSelected: (index) {
          // TODO: wire up navigation when admin tabs are ready
          // if (index == 0) Navigator.pushNamed(context, '/admin-dashboard');
          // if (index == 1) Navigator.pushNamed(context, '/admin-analytics');
        },
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Simple centered header; avatar and back button handled by TopNavigationBar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(color: Colors.white),
              child: const Center(
                child: Text(
                  'Active Cases',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    height: 24 / 20,
                    color: _primaryBlue,
                  ),
                ),
              ),
            ),
            // Sort dropdown row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      // TODO: Implement actual sorting based on selected criterion
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Sort by $value (coming soon)')),
                      );
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: 'Severity',
                        child: Text('Sort by severity'),
                      ),
                      PopupMenuItem(
                        value: 'Time arrived',
                        child: Text('Sort by time arrived'),
                      ),
                      PopupMenuItem(
                        value: 'Clinic',
                        child: Text('Sort by clinic'),
                      ),
                      PopupMenuItem(
                        value: 'Distance',
                        child: Text('Sort by distance'),
                      ),
                    ],
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _cardBorder),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.sort, size: 18, color: _primaryBlue),
                          SizedBox(width: 6),
                          Text(
                            'Sort',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              color: _primaryBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
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
                              // Sample active cases (clickable)
                              GestureDetector(
                                onTap: () {
                                  // TODO: Replace with navigation using selected case ID
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const AdminCaseTimelineScreen(),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  margin: const EdgeInsets.only(bottom: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: _cardBorder),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: const [
                                            Text(
                                              'Case #001 - Adult Female, Trauma',
                                              style: TextStyle(
                                                fontFamily: 'Inter',
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                                height: 17 / 14,
                                                color: _primaryBlue,
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              'VHT Zone 3 • ETA 12 min',
                                              style: TextStyle(
                                                fontFamily: 'Inter',
                                                fontWeight: FontWeight.w400,
                                                fontSize: 12,
                                                height: 15 / 12,
                                                color: Colors.black54,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _statusOrange,
                                          borderRadius: BorderRadius.circular(
                                            999,
                                          ),
                                        ),
                                        child: const Text(
                                          'Critical',
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w400,
                                            fontSize: 12,
                                            height: 15 / 12,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  // TODO: Replace with navigation using selected case ID
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const AdminCaseTimelineScreen(),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  margin: const EdgeInsets.only(bottom: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: _cardBorder),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: const [
                                            Text(
                                              'Case #002 - Child, Respiratory',
                                              style: TextStyle(
                                                fontFamily: 'Inter',
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                                height: 17 / 14,
                                                color: _primaryBlue,
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              'VHT Zone 1 • ETA 8 min',
                                              style: TextStyle(
                                                fontFamily: 'Inter',
                                                fontWeight: FontWeight.w400,
                                                fontSize: 12,
                                                height: 15 / 12,
                                                color: Colors.black54,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _statusGreen,
                                          borderRadius: BorderRadius.circular(
                                            999,
                                          ),
                                        ),
                                        child: const Text(
                                          'Normal',
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w400,
                                            fontSize: 12,
                                            height: 15 / 12,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Map / Active Cases placeholder card
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: _cardBorder),
                                ),
                                child: SizedBox(
                                  height: size.height * 0.35,
                                  child: const Center(
                                    child: Text(
                                      'Map / Active Cases Placeholder',
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
                              ),
                              SizedBox(height: size.height * 0.06),
                              // Status legend row: Normal / Critical
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Normal
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _statusGreen,
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: const Text(
                                      'Normal',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w400,
                                        fontSize: 14,
                                        height: 17 / 14,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  // Critical
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _statusOrange,
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: const Text(
                                      'Critical',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w400,
                                        fontSize: 14,
                                        height: 17 / 14,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
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

class _AdminActiveCasesHeader extends StatelessWidget {
  const _AdminActiveCasesHeader();

  static const Color _primaryBlue = Color(0xFF0077CC);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(color: Colors.white),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              size: 18,
              color: _primaryBlue,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          // A square logo
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
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Active Cases',
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
          const SizedBox(width: 8), // small spacer on the right
        ],
      ),
    );
  }
}
