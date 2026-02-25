import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_navigation_bar.dart';
import 'admin_user_detail_screen.dart';
import '../../../common/presentation/screens/top_navigation_bar.dart';
import '../../../common/presentation/screens/settings_screen.dart';
import '../../../auth/current_user_session.dart';
import '../../../../core/utils/drawer_helpers.dart';
import '../../../../core/utils/logout_utils.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/back_handling_pop_scope.dart';

class AdminManageUsersScreen extends StatefulWidget {
  const AdminManageUsersScreen({super.key});

  @override
  State<AdminManageUsersScreen> createState() => _AdminManageUsersScreenState();
}

class _AdminManageUsersScreenState extends State<AdminManageUsersScreen> {
  String _selectedRole = 'all';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Stream<QuerySnapshot> _getUsersStream() {
    Query query = FirebaseFirestore.instance.collection('users');
    if (_selectedRole != 'all') {
      query = query.where('role', isEqualTo: _selectedRole);
    }
    return query.snapshots();
  }

  bool _matchesSearch(Map<String, dynamic> data) {
    if (_searchQuery.isEmpty) return true;
    final q = _searchQuery.toLowerCase();
    final firstName = (data['firstName'] as String? ?? '').toLowerCase();
    final lastName = (data['lastName'] as String? ?? '').toLowerCase();
    final phone = (data['phoneNumber'] as String? ?? '').toLowerCase();
    final role = (data['role'] as String? ?? '').toLowerCase();
    return firstName.contains(q) || lastName.contains(q) || phone.contains(q) || role.contains(q);
  }

  bool _isOnline(Map<String, dynamic> data) {
    final lastActive = data['lastActive'] as Timestamp?;
    if (lastActive == null) return false;
    return DateTime.now().difference(lastActive.toDate()).inMinutes < 5;
  }

  Color _getRoleColor(String? role) {
    switch (role?.toLowerCase()) {
      case 'vht': return AppColors.vhtAccent;
      case 'ambulance driver': return AppColors.ambulanceAccent;
      case 'clinician': return AppColors.clinicAccent;
      case 'admin': return AppColors.adminAccent;
      default: return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BackHandlingPopScope(
      dashboardRoute: '/admin-dashboard',
      child: Scaffold(
      appBar: TopNavigationBar(
        role: CurrentUserSession.role ?? 'Admin',
        profileImageUrl: CurrentUserSession.profileImageUrl,
        pageTitle: l10n.manageUsers,
        showBackButton: true,
        onBack: () {
          if (Navigator.of(context).canPop()) {
            Navigator.pop(context);
          } else {
            Navigator.pushNamedAndRemoveUntil(context, '/admin-dashboard', (route) => false);
          }
        },
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
      endDrawer: buildStandardDrawer(context: context, dashboardRoute: '/admin-dashboard'),
      backgroundColor: AppColors.background,
      bottomNavigationBar: AdminNavigationBar(
        currentIndex: 3, // Admin nav: 0=Home, 1=Notifications, 2=Analytics, 3=Users
        // Navigation is handled by AdminNavigationBar itself
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.manageUsers, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                  const SizedBox(height: 6),
                  Text(l10n.viewAndManageSystemUsers, style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Search
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: l10n.searchUsers,
                  hintStyle: TextStyle(fontSize: 13, color: AppColors.textSecondary.withAlpha(150)),
                  prefixIcon: const Icon(Icons.search, size: 20),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(icon: const Icon(Icons.clear, size: 18), onPressed: () { _searchController.clear(); setState(() => _searchQuery = ''); })
                      : null,
                  filled: true,
                  fillColor: AppColors.surface,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.border)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.border)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.adminAccent, width: 1.5)),
                ),
                onChanged: (value) => setState(() => _searchQuery = value.trim()),
              ),
            ),
            const SizedBox(height: 10),

            // Role filter
            SizedBox(
              height: 36,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildRoleChip(l10n.allFilter, 'all'),
                    const SizedBox(width: 6),
                    _buildRoleChip(l10n.vht, 'VHT'),
                    const SizedBox(width: 6),
                    _buildRoleChip(l10n.ambulance, 'Ambulance Driver'),
                    const SizedBox(width: 6),
                    _buildRoleChip(l10n.clinicianLabel, 'Clinician'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Users list
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _getUsersStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text(l10n.errorGeneric('${snapshot.error}')));
                  }

                  final allDocs = snapshot.data?.docs ?? [];
                  final docs = allDocs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    // Filter out admin users when showing 'all'
                    if (_selectedRole == 'all') {
                      final role = (data['role'] as String? ?? '').toLowerCase();
                      if (role == 'admin') {
                        return false;
                      }
                    }
                    return _matchesSearch(data);
                  }).toList();

                  if (docs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.people_outline, size: 56, color: AppColors.textSecondary.withAlpha(80)),
                          const SizedBox(height: 12),
                          Text(l10n.noUsersFound, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: AppColors.textPrimary)),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: docs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      final firstName = data['firstName'] as String? ?? '';
                      final lastName = data['lastName'] as String? ?? '';
                      final phone = data['phoneNumber'] as String? ?? '';
                      final role = data['role'] as String? ?? 'Unknown';
                      final isOnline = _isOnline(data);
                      final name = '$firstName $lastName'.trim();

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AdminUserDetailScreen(userId: docs[index].id),
                            ),
                          );
                        },
                        child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            // Online indicator
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isOnline ? Colors.green : Colors.grey.shade400,
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Avatar
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: _getRoleColor(role).withAlpha(20),
                              child: Text(
                                name.isNotEmpty ? name[0].toUpperCase() : '?',
                                style: TextStyle(fontWeight: FontWeight.w700, color: _getRoleColor(role)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(name.isNotEmpty ? name : l10n.unknownUser, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textPrimary)),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: _getRoleColor(role).withAlpha(15),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(role, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: _getRoleColor(role))),
                                      ),
                                      if (phone.isNotEmpty) ...[
                                        const SizedBox(width: 8),
                                        Text(phone, style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  isOnline ? 'Online' : 'Offline',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: isOnline ? Colors.green : AppColors.textSecondary),
                                ),
                                const SizedBox(height: 4),
                                Icon(Icons.chevron_right, size: 18, color: AppColors.textSecondary),
                              ],
                            ),
                          ],
                        ),
                      ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }

  Widget _buildRoleChip(String label, String value) {
    final isSelected = _selectedRole == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedRole = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.adminAccent : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? AppColors.adminAccent : AppColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: isSelected ? Colors.white : AppColors.textSecondary),
        ),
      ),
    );
  }
}
