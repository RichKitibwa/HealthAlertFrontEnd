import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

/// Shared PDF export for admin reports. Used by the hamburger "Reports" action
/// and the Analytics screen "Export Reports" button.
Future<void> exportReportsPdf(BuildContext context) async {
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
