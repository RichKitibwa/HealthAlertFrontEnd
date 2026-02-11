import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/theme/app_colors.dart';

class AdminUserDetailScreen extends StatelessWidget {
  final String userId;

  const AdminUserDetailScreen({super.key, required this.userId});

  bool _isOnline(Map<String, dynamic> data) {
    final lastActive = data['lastActive'] as Timestamp?;
    if (lastActive == null) return false;
    return DateTime.now().difference(lastActive.toDate()).inMinutes < 5;
  }

  Color _getRoleColor(String? role) {
    switch (role?.toLowerCase()) {
      case 'vht':
        return AppColors.vhtAccent;
      case 'ambulance driver':
        return AppColors.ambulanceAccent;
      case 'clinician':
        return AppColors.clinicAccent;
      case 'admin':
        return AppColors.adminAccent;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('User Details', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(userId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, size: 48, color: AppColors.error.withAlpha(150)),
                  const SizedBox(height: 12),
                  Text('Error loading user', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                ],
              ),
            );
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.person_off_outlined, size: 56, color: AppColors.textSecondary.withAlpha(120)),
                  const SizedBox(height: 12),
                  Text('User not found', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: AppColors.textPrimary)),
                  const SizedBox(height: 8),
                  Text('This user may have been removed.', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                ],
              ),
            );
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final firstName = data['firstName'] as String? ?? '';
          final lastName = data['lastName'] as String? ?? '';
          final phone = data['phoneNumber'] as String? ?? '';
          final email = data['email'] as String? ?? '';
          final role = data['role'] as String? ?? 'Unknown';
          final zone = data['zone'] as String? ?? data['zoneName'] as String? ?? data['camp'] as String? ?? '';
          final workplace = data['workplace'] as String? ?? '';
          final isOnline = _isOnline(data);
          final fullName = '$firstName $lastName'.trim();
          final initials = fullName.isNotEmpty
              ? fullName.split(' ').map((s) => s.isNotEmpty ? s[0] : '').take(2).join().toUpperCase()
              : '?';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: AppColors.border)),
                  color: AppColors.surface,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: _getRoleColor(role).withAlpha(30),
                          child: Text(
                            initials,
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: _getRoleColor(role)),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          fullName.isNotEmpty ? fullName : 'Unknown User',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getRoleColor(role).withAlpha(25),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: _getRoleColor(role).withAlpha(80)),
                          ),
                          child: Text(role, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _getRoleColor(role))),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isOnline ? AppColors.online : AppColors.offline,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              isOnline ? 'Online' : 'Offline',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isOnline ? AppColors.online : AppColors.offline),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: AppColors.border)),
                  color: AppColors.surface,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (phone.isNotEmpty)
                          _InfoRow(icon: Icons.phone_rounded, label: 'Phone', value: phone),
                        if (email.isNotEmpty) ...[
                          if (phone.isNotEmpty) const SizedBox(height: 12),
                          _InfoRow(icon: Icons.email_outlined, label: 'Email', value: email),
                        ],
                        if (zone.isNotEmpty) ...[
                          if (phone.isNotEmpty || email.isNotEmpty) const SizedBox(height: 12),
                          _InfoRow(icon: Icons.location_on_outlined, label: 'Zone / Camp', value: zone),
                        ],
                        if (role.toLowerCase() == 'clinician' && workplace.isNotEmpty) ...[
                          if (phone.isNotEmpty || email.isNotEmpty || zone.isNotEmpty) const SizedBox(height: 12),
                          _InfoRow(icon: Icons.local_hospital_outlined, label: 'Workplace', value: workplace),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                OutlinedButton.icon(
                  onPressed: () => _showRemoveDialog(context, role),
                  icon: const Icon(Icons.person_remove_outlined, size: 20),
                  label: const Text('Remove User', style: TextStyle(fontWeight: FontWeight.w700)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _showRemoveDialog(BuildContext context, String role) async {
    // Prevent removing admin users
    if (role.toLowerCase() == 'admin' || role.toLowerCase() == 'administrator') {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cannot remove admin users'), backgroundColor: AppColors.error),
        );
      }
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Remove User', style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text('Are you sure you want to remove this user?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remove', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirm != true || !context.mounted) return;

    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).delete();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User removed'), backgroundColor: AppColors.success),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to remove user: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              const SizedBox(height: 2),
              Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            ],
          ),
        ),
      ],
    );
  }
}
