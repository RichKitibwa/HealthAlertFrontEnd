// Create Emergency Case Screen
// VHT creates new emergency case

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'vht_add_media_screen.dart';
import '../../../common/presentation/screens/top_navigation_bar.dart';
import '../../../common/presentation/widgets/app_drawer.dart';
import '../../../../core/utils/logout_utils.dart';
import 'vht_navigation_bar.dart';
import '../../../auth/current_user_session.dart';

class CreateEmergencyScreen extends StatefulWidget {
  const CreateEmergencyScreen({Key? key}) : super(key: key);

  @override
  State<CreateEmergencyScreen> createState() => _CreateEmergencyScreenState();
}

class _CreateEmergencyScreenState extends State<CreateEmergencyScreen> {
  int _currentIndex = 0; // 0 = Home, 1 = Map, 2 = Patients
  bool _isScrolling = false;

  void _onNavItemSelected(int index) {
    setState(() {
      _currentIndex = index;
    });

    // TODO: wire up navigation if needed
    // Example:
    // if (index == 0) Navigator.pushNamed(context, '/vht-dashboard');
    // if (index == 1) Navigator.pushNamed(context, '/vht-map');
    // if (index == 2) Navigator.pushNamed(context, '/vht-patients');
  }

  void _goToAddMedia(String type) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddMediaScreen(emergencyType: type),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopNavigationBar(
        role: CurrentUserSession.role ?? 'VHT',
        profileImageUrl: CurrentUserSession.profileImageUrl,
        showBackButton: true,
        onBack: () {
          Navigator.pop(context);
        },
        onSignOut: () async {
          await LogoutUtils.logout();
          if (context.mounted) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/login',
              (route) => false,
            );
          }
        },
        onDashboard: () {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/vht-dashboard',
            (route) => false,
          );
        },
        onSettings: () {
          // TODO: Navigate to settings screen
        },
        onLearningResources: () {
          // TODO: Navigate to learning resources screen (offline-first)
        },
      ),
      endDrawer: AppDrawer(
        onDashboard: () {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/vht-dashboard',
            (route) => false,
          );
        },
        onSettings: () {
          // TODO: Navigate to settings screen
        },
        onLearningResources: () {
          // TODO: Navigate to learning resources screen
        },
        onLogout: () async {
          await LogoutUtils.logout();
          if (context.mounted) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/login',
              (route) => false,
            );
          }
        },
      ),
      backgroundColor: AppColors.background,
      bottomNavigationBar: VhtNavigationBar(
        currentIndex: _currentIndex,
        onItemSelected: _onNavItemSelected,
      ),
      body: SafeArea(
        child: NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification is ScrollStartNotification ||
                notification is UserScrollNotification ||
                notification is ScrollUpdateNotification) {
              if (!_isScrolling) {
                setState(() => _isScrolling = true);
              }
            } else if (notification is ScrollEndNotification) {
              if (_isScrolling) {
                setState(() => _isScrolling = false);
              }
            }
            return false;
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Report Emergency',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Select the type of emergency',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                _EmergencyTypeCard(
                  icon: Icons.pregnant_woman_rounded,
                  title: 'Birth',
                  accentColor: AppColors.vhtAccent,
                  disableHover: _isScrolling,
                  onTap: () => _goToAddMedia('Birth'),
                ),
                const SizedBox(height: 12),
                _EmergencyTypeCard(
                  icon: Icons.car_crash_rounded,
                  title: 'Trauma',
                  accentColor: AppColors.warningDark,
                  disableHover: _isScrolling,
                  onTap: () => _goToAddMedia('Trauma'),
                ),
                const SizedBox(height: 12),
                _EmergencyTypeCard(
                  icon: Icons.coronavirus_rounded,
                  title: 'Infection',
                  accentColor: AppColors.secondary,
                  disableHover: _isScrolling,
                  onTap: () => _goToAddMedia('Infection'),
                ),
                const SizedBox(height: 12),
                _EmergencyTypeCard(
                  icon: Icons.more_horiz_rounded,
                  title: 'Other',
                  accentColor: AppColors.adminAccent,
                  disableHover: _isScrolling,
                  onTap: () => _goToAddMedia('Other'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmergencyTypeCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final Color accentColor;
  final VoidCallback onTap;
  final bool disableHover;

  const _EmergencyTypeCard({
    Key? key,
    required this.icon,
    required this.title,
    required this.accentColor,
    required this.disableHover,
    required this.onTap,
  }) : super(key: key);

  @override
  State<_EmergencyTypeCard> createState() => _EmergencyTypeCardState();
}

class _EmergencyTypeCardState extends State<_EmergencyTypeCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        if (widget.disableHover) return;
        setState(() => _isHovered = true);
      },
      onExit: (_) {
        if (widget.disableHover) return;
        setState(() => _isHovered = false);
      },
      child: AnimatedScale(
        scale: _isHovered ? 1.02 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: Card(
          elevation: 0,
          color: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: AppColors.border.withValues(alpha: 0.85)),
          ),
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(16),
            onHighlightChanged: (isPressed) {
              if (widget.disableHover) return;
              setState(() {
                _isHovered = isPressed;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: _isHovered ? 0.06 : 0.03,
                    ),
                    blurRadius: _isHovered ? 22 : 16,
                    offset: Offset(0, _isHovered ? 14 : 10),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    height: 52,
                    width: 52,
                    decoration: BoxDecoration(
                      color: widget.accentColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      widget.icon,
                      color: widget.accentColor,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Icon(Icons.chevron_right, color: AppColors.textSecondary),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
