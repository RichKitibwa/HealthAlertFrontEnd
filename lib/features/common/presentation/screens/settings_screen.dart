import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/current_user_session.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const String _preferredLanguageKey = 'preferred_language';

  late String _selectedLanguage;

  @override
  void initState() {
    super.initState();
    _selectedLanguage = 'English';
    _loadLanguagePreference();
  }

  Future<void> _loadLanguagePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_preferredLanguageKey);
      if (saved != null && mounted) {
        setState(() => _selectedLanguage = saved);
      }
    } catch (_) {
      // Keep default
    }
  }

  Future<void> _saveLanguagePreference(String lang) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_preferredLanguageKey, lang);
      if (mounted) {
        setState(() => _selectedLanguage = lang);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save language preference')),
        );
      }
    }
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About'),
        content: Text(
          'HealthAlert\n\nVersion 1.0.0\n\nEmergency communication for front line health response.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'OK',
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
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
              _buildSectionHeader('Account'),
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
                      title: 'Name',
                      subtitle: CurrentUserSession.fullName,
                    ),
                    Divider(height: 1, color: AppColors.divider),
                    _buildListTile(
                      icon: Icons.badge,
                      title: 'Role',
                      subtitle: CurrentUserSession.role ?? '—',
                    ),
                    Divider(height: 1, color: AppColors.divider),
                    _buildListTile(
                      icon: Icons.phone,
                      title: 'Phone',
                      subtitle: CurrentUserSession.phoneNumber ?? '—',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              _buildSectionHeader('Preferences'),
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
                          'Language',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      _buildLanguageOption('English'),
                      _buildLanguageOption('Swahili'),
                      _buildLanguageOption('Luganda'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              _buildSectionHeader('App'),
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
                        'About',
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
                        'Help & Support',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Help & Support coming soon'),
                          ),
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

  Widget _buildLanguageOption(String language) {
    final isSelected = _selectedLanguage == language;
    return InkWell(
      onTap: () => _saveLanguagePreference(language),
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
              language,
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
