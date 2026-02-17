import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/current_user_session.dart';
import '../../../../core/widgets/back_handling_pop_scope.dart';
import '../../../vht/presentation/screens/vht_navigation_bar.dart';
import '../../../ambulance/presentation/screens/ambulance_navigation_bar.dart';
import '../../../clinic/presentation/screens/clinic_navigation_bar.dart';
import '../../../admin/presentation/screens/admin_navigation_bar.dart';

class _LearningResource {
  final String title;
  final String description;
  final String assetPath;

  const _LearningResource({
    required this.title,
    required this.description,
    required this.assetPath,
  });
}

class LearningResourcesScreen extends StatelessWidget {
  const LearningResourcesScreen({super.key});

  static const List<_LearningResource> _resources = [
    _LearningResource(
      title: 'Uganda Clinical Guidelines 2023',
      description: 'National clinical guidelines for health workers in Uganda',
      assetPath: 'assets/documents/Uganda_Clinical_Guidelines_2023.pdf',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    Widget? bottomNav;

    switch (CurrentUserSession.role) {
      case 'VHT':
        bottomNav = VhtNavigationBar(
          currentIndex: 2, // Learn index for VHT
          onItemSelected: (index) {},
        );
        break;
      case 'Ambulance':
      case 'Ambulance Driver':
        // Ambulance doesn't have Learn tab, so no bottom nav
        bottomNav = null;
        break;
      case 'Clinic':
      case 'Clinic Staff':
        bottomNav = ClinicNavigationBar(
          currentIndex: 3, // Learn index for Clinic
          onItemSelected: (index) {},
        );
        break;
      case 'Admin':
        // Admin doesn't have Learn tab, so no bottom nav
        bottomNav = null;
        break;
      default:
        bottomNav = null;
    }
    return BackHandlingPopScope(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Learning Resources'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              } else {
                // Navigate to appropriate dashboard based on role
                final role = CurrentUserSession.role?.toLowerCase() ?? '';
                String route = '/login';
                if (role == 'admin') route = '/admin-dashboard';
                else if (role == 'vht') route = '/vht-dashboard';
                else if (role.contains('clinic')) route = '/clinic-dashboard';
                else if (role.contains('ambulance')) route = '/ambulance-dashboard';
                Navigator.pushNamedAndRemoveUntil(context, route, (r) => false);
              }
            },
          ),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        surfaceTintColor: Colors.transparent,
      ),
      bottomNavigationBar: bottomNav,
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: _resources.length,
        itemBuilder: (context, index) {
          final resource = _resources[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 0,
            color: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: AppColors.border),
            ),
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => _PdfViewerScreen(
                      title: resource.title,
                      assetPath: resource.assetPath,
                    ),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.picture_as_pdf,
                        color: AppColors.primary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            resource.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            resource.description,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: AppColors.primary,
                      size: 24,
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

/// Uses SfPdfViewer.asset() directly - no file copy needed.
/// This handles large PDFs efficiently with error handling.
class _PdfViewerScreen extends StatefulWidget {
  final String title;
  final String assetPath;

  const _PdfViewerScreen({required this.title, required this.assetPath});

  @override
  State<_PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<_PdfViewerScreen> {
  String? _loadError;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        surfaceTintColor: Colors.transparent,
      ),
      body: _loadError != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: AppColors.error),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load PDF',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _loadError!,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          : SfPdfViewer.asset(
              widget.assetPath,
              onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
                if (mounted) {
                  setState(() {
                    _loadError = details.description;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Could not load PDF: ${details.description}',
                      ),
                      backgroundColor: AppColors.error,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
            ),
    );
  }
}
