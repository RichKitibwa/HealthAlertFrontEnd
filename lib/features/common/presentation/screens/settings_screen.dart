import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/locale_notifier.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/current_user_session.dart';

/// Supported locale codes: en (English), sw (Kiswahili - Tanzania), ar (Arabic - Northern Uganda).
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const List<String> _localeCodes = ['en', 'sw', 'ar'];

  static String _languageLabel(AppLocalizations l10n, String code) {
    switch (code) {
      case 'en':
        return l10n.languageEnglish;
      case 'sw':
        return l10n.languageSwahili;
      case 'ar':
        return l10n.languageArabic;
      default:
        return code;
    }
  }

  void _showLanguageChangeConfirmation(String localeCode, String languageLabel) {
    final l10n = AppLocalizations.of(context)!;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.changeLanguageConfirmTitle),
        content: Text(l10n.changeLanguageConfirmMessage(languageLabel)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _saveLanguagePreference(localeCode);
            },
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
  }

  Future<void> _saveLanguagePreference(String localeCode) async {
    final notifier = Provider.of<LocaleNotifier>(context, listen: false);
    final languageLabel = _languageLabel(AppLocalizations.of(context)!, localeCode);
    final uid = CurrentUserSession.uid;
    try {
      // Save locale against the currently logged-in user so other accounts
      // on the same device keep their own language setting.
      await notifier.setLocaleForUser(uid, localeCode);
      if (uid != null && uid.isNotEmpty) {
        try {
          await FirebaseFirestore.instance.collection('users').doc(uid).update({'preferredLocale': localeCode});
        } catch (_) {
          // Non-fatal: locale still saved locally
        }
      }
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.languageChangedSuccess(languageLabel))),
          );
        });
      }
    } catch (_) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.failedToSaveLanguage)),
        );
      }
    }
  }

  void _showAboutDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.about),
        content: Text(
          l10n.aboutMessage,
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              l10n.ok,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeNotifier = Provider.of<LocaleNotifier>(context);
    final selectedCode = localeNotifier.locale?.languageCode ?? 'en';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.settings),
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader(l10n.account),
              Card(
                elevation: 0,
                color: AppColors.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    _buildListTile(
                      icon: Icons.person,
                      title: l10n.name,
                      subtitle: CurrentUserSession.fullName,
                    ),
                    Divider(height: 1, color: AppColors.divider),
                    _buildListTile(
                      icon: Icons.badge,
                      title: l10n.role,
                      subtitle: CurrentUserSession.role ?? '—',
                    ),
                    Divider(height: 1, color: AppColors.divider),
                    _buildListTile(
                      icon: Icons.phone,
                      title: l10n.phone,
                      subtitle: CurrentUserSession.phoneNumber ?? '—',
                    ),
                    if (CurrentUserSession.email != null) ...[
                      Divider(height: 1, color: AppColors.divider),
                      _buildListTile(
                        icon: Icons.email,
                        title: l10n.email,
                        subtitle: CurrentUserSession.email ?? '—',
                      ),
                    ],
                    if ((CurrentUserSession.role ?? '').toLowerCase().contains('clinic')) ...[
                      if (CurrentUserSession.workplace != null) ...[
                        Divider(height: 1, color: AppColors.divider),
                        _buildListTile(
                          icon: Icons.local_hospital_outlined,
                          title: l10n.assignedFacility,
                          subtitle: CurrentUserSession.workplace!,
                        ),
                      ],
                      if (CurrentUserSession.camp != null) ...[
                        Divider(height: 1, color: AppColors.divider),
                        _buildListTile(
                          icon: Icons.location_city_outlined,
                          title: l10n.settlementCamp,
                          subtitle: CurrentUserSession.camp!,
                        ),
                      ],
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),

              _buildSectionHeader(l10n.preferences),
              Card(
                elevation: 0,
                color: AppColors.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: AppColors.border),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          l10n.language,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      for (final code in _localeCodes)
                        _buildLanguageOption(
                          localeCode: code,
                          label: _languageLabel(l10n, code),
                          isSelected: selectedCode == code,
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              _buildSectionHeader(l10n.app),
              Card(
                elevation: 0,
                color: AppColors.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.info_outline, color: AppColors.primary),
                      title: Text(
                        l10n.about,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: _showAboutDialog,
                    ),
                    Divider(height: 1, color: AppColors.divider),
                    ListTile(
                      leading: Icon(Icons.help_outline, color: AppColors.primary),
                      title: Text(
                        l10n.helpSupport,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.helpSupportComingSoon)),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.textSecondary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          color: AppColors.textSecondary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildLanguageOption({
    required String localeCode,
    required String label,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () => _showLanguageChangeConfirmation(localeCode, label),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? AppColors.primary : AppColors.textTertiary,
              size: 22,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 16,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
