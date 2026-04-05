import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/profile_provider.dart';
import '../../utils/theme.dart';
import '../onboarding/profile_setup_screen.dart';
import '../settings/settings_screen.dart';

class ProfileSwitcherSheet extends StatelessWidget {
  const ProfileSwitcherSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final pp = context.watch<ProfileProvider>();
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 40, height: 4,
              decoration: BoxDecoration(color: AppTheme.border,
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Profiles',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary)),
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(
                      builder: (_) => const SettingsScreen()));
                },
                icon: const Icon(Icons.settings_rounded,
                    color: AppTheme.textSecondary, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...pp.all.map((p) {
            final isActive = p.id == pp.active?.id;
            return GestureDetector(
              onLongPress: () => _confirmDelete(context, pp, p.id, p.name),
              onTap: () async {
                await pp.switchProfile(p.id);
                if (context.mounted) Navigator.pop(context);
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppTheme.accent.withOpacity(0.12)
                      : AppTheme.surfaceLight,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isActive ? AppTheme.accent.withOpacity(0.5)
                        : AppTheme.border,
                  ),
                ),
                child: Row(
                  children: [
                    Text(p.avatar, style: const TextStyle(fontSize: 24)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(p.name,
                          style: const TextStyle(fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary)),
                    ),
                    if (isActive)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.accent.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text('Active',
                            style: TextStyle(fontSize: 11,
                                color: AppTheme.accent,
                                fontWeight: FontWeight.w700)),
                      ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 4),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(
                    builder: (_) => const ProfileSetupScreen(isAddingNew: true)));
              },
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Add New Profile'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.accent,
                side: const BorderSide(color: AppTheme.accent),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, ProfileProvider pp,
      int id, String name) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: Text('Delete $name?',
            style: const TextStyle(color: AppTheme.textPrimary)),
        content: const Text('All data for this profile will be deleted.',
            style: TextStyle(color: AppTheme.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await pp.deleteProfile(id);
            },
            child: const Text('Delete',
                style: TextStyle(color: AppTheme.wrong)),
          ),
        ],
      ),
    );
  }
}
