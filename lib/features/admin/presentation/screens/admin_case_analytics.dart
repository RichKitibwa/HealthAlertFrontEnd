import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'admin_navigation_bar.dart';
import 'admin_all_cases_list_screen.dart';
import '../../../common/presentation/screens/top_navigation_bar.dart';
import '../../../common/presentation/screens/settings_screen.dart';
import '../../../auth/current_user_session.dart';
import '../../../../core/utils/drawer_helpers.dart';
import '../../../../core/utils/logout_utils.dart';
import '../../../../core/theme/app_colors.dart';

class AdminCaseAnalyticsScreen extends StatelessWidget {
  final String? caseId;

  const AdminCaseAnalyticsScreen({super.key, this.caseId});

  Future<void> _exportReportsPdf(BuildContext context) async {
    try {
      final casesSnapshot = await FirebaseFirestore.instance.collection('emergencyCases').get();
      final cases = casesSnapshot.docs;
      
      final totalCases = cases.length;
      final activeCases = cases.where((d) {
        final s = (d.data()['status'] as String?) ?? '';
        return !['completed', 'cancelled'].contains(s);
      }).length;
      final completedCases = cases.where((d) => (d.data()['status'] as String?) == 'completed').length;
      
      final pdf = pw.Document();
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('HealthAlert - Case Report', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 8),
                pw.Text('Generated: ${DateTime.now().toString().substring(0, 16)}', style: const pw.TextStyle(fontSize: 12)),
                pw.SizedBox(height: 20),
                pw.Text('Summary', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 8),
                pw.Text('Total Cases: $totalCases'),
                pw.Text('Active Cases: $activeCases'),
                pw.Text('Completed Cases: $completedCases'),
                pw.SizedBox(height: 20),
                pw.Text('Case Details', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 8),
                pw.Table.fromTextArray(
                  headers: ['ID', 'Type', 'Urgency', 'Status', 'Patient'],
                  data: cases.take(50).map((doc) {
                    final d = doc.data();
                    final first = d['patientFirstName'] as String? ?? '';
                    final last = d['patientLastName'] as String? ?? '';
                    return [
                      doc.id.substring(0, 8),
                      d['emergencyType'] as String? ?? '-',
                      d['urgencyLevel'] as String? ?? '-',
                      d['status'] as String? ?? '-',
                      '$first $last'.trim(),
                    ];
                  }).toList(),
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
                  cellStyle: const pw.TextStyle(fontSize: 9),
                  cellAlignment: pw.Alignment.centerLeft,
                ),
              ],
            );
          },
        ),
      );
      
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: 'HealthAlert_Report',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate report: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopNavigationBar(
        role: CurrentUserSession.role ?? 'Admin',
        profileImageUrl: CurrentUserSession.profileImageUrl,
        pageTitle: 'Analytics',
        showBackButton: true,
        onBack: () => Navigator.pop(context),
        onSignOut: () async {
          await LogoutUtils.logout();
          if (context.mounted) {
            Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
          }
        },
        onDashboard: () {
          Navigator.pushNamedAndRemoveUntil(context, '/admin-dashboard', (route) => false);
        },
        onSettings: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
        },
        onReports: () {},
        onAnalytics: () {},
      ),
      backgroundColor: AppColors.background,
      endDrawer: buildStandardDrawer(context: context, dashboardRoute: '/admin-dashboard'),
      bottomNavigationBar: AdminNavigationBar(
        currentIndex: 1,
        onItemSelected: (index) {
          if (index == 0) {
            Navigator.pushNamedAndRemoveUntil(context, '/admin-dashboard', (route) => false);
          }
        },
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Case Analytics',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Overview of emergency response performance.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Summary stats from Firestore
                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance.collection('emergencyCases').snapshots(),
                          builder: (context, snapshot) {
                            int totalCases = 0;
                            int activeCases = 0;
                            int completedCases = 0;
                            int criticalCases = 0;
                            final Map<String, int> typeCount = {};

                            if (snapshot.hasData) {
                              final docs = snapshot.data!.docs;
                              totalCases = docs.length;
                              for (final doc in docs) {
                                final data = doc.data() as Map<String, dynamic>;
                                final status = data['status'] as String? ?? '';
                                final urgency = data['urgencyLevel'] as String? ?? '';
                                final type = data['emergencyType'] as String? ?? 'Other';

                                if (['completed', 'cancelled', 'delivered'].contains(status)) {
                                  completedCases++;
                                } else {
                                  activeCases++;
                                }
                                if (urgency.toLowerCase() == 'critical') criticalCases++;
                                typeCount[type] = (typeCount[type] ?? 0) + 1;
                              }
                            }

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Stats grid - tappable to view case lists
                                Row(
                                  children: [
                                    Expanded(child: GestureDetector(
                                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminAllCasesListScreen())),
                                      child: _StatCard(label: 'Total Cases', value: '$totalCases', color: AppColors.adminAccent),
                                    )),
                                    const SizedBox(width: 12),
                                    Expanded(child: GestureDetector(
                                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminAllCasesListScreen(filterStatus: 'active'))),
                                      child: _StatCard(label: 'Active', value: '$activeCases', color: Colors.orange),
                                    )),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(child: GestureDetector(
                                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminAllCasesListScreen(filterStatus: 'completed'))),
                                      child: _StatCard(label: 'Completed', value: '$completedCases', color: Colors.green),
                                    )),
                                    const SizedBox(width: 12),
                                    Expanded(child: _StatCard(label: 'Critical', value: '$criticalCases', color: Colors.red)),
                                  ],
                                ),
                                const SizedBox(height: 20),

                                // Cases by type
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: AppColors.border),
                                    boxShadow: [BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 18, offset: const Offset(0, 12))],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Cases by Type', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.adminAccent)),
                                      const SizedBox(height: 12),
                                      if (typeCount.isEmpty)
                                        Text('No data yet.', style: TextStyle(fontSize: 13, color: AppColors.textSecondary))
                                      else
                                        ...typeCount.entries.map((entry) {
                                          final percentage = totalCases > 0 ? (entry.value / totalCases * 100).toStringAsFixed(0) : '0';
                                          return Padding(
                                            padding: const EdgeInsets.only(bottom: 10),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text(entry.key, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textPrimary)),
                                                    Text('${entry.value} ($percentage%)', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                                  ],
                                                ),
                                                const SizedBox(height: 4),
                                                ClipRRect(
                                                  borderRadius: BorderRadius.circular(4),
                                                  child: LinearProgressIndicator(
                                                    value: totalCases > 0 ? entry.value / totalCases : 0,
                                                    backgroundColor: AppColors.border,
                                                    valueColor: AlwaysStoppedAnimation<Color>(_getTypeColor(entry.key)),
                                                    minHeight: 6,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 20),

                        // Export Reports button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => _exportReportsPdf(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.adminAccent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              elevation: 6,
                            ),
                            child: const Text(
                              'Export Reports',
                              style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w800, fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'birth': return Colors.pink;
      case 'trauma': return Colors.orange;
      case 'infection': return Colors.purple;
      default: return AppColors.adminAccent;
    }
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 18, offset: const Offset(0, 12))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 28, color: color)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
