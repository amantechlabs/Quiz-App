import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../database/session_dao.dart';
import '../../database/achievement_dao.dart';
import '../../database/seeder.dart';
import '../../providers/profile_provider.dart';
import '../../providers/history_provider.dart';
import '../../utils/theme.dart';
import '../onboarding/profile_setup_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Future<void> _resetData(BuildContext ctx) async {
    final confirm = await showDialog<bool>(
      context: ctx,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Reset All Data?',
            style: TextStyle(color: AppTheme.textPrimary)),
        content: const Text(
            'This will delete all quiz history and achievements for this profile.',
            style: TextStyle(color: AppTheme.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Reset',
                  style: TextStyle(color: AppTheme.wrong))),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    final id = context.read<ProfileProvider>().active?.id;
    if (id != null) {
      await SessionDao.deleteAllForProfile(id);
      await AchievementDao.deleteAllForProfile(id);
      context.read<HistoryProvider>().clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile data reset.')));
      }
    }
  }

  Future<void> _editProfile(BuildContext ctx) async {
    final pp = context.read<ProfileProvider>();
    final profile = pp.active;
    if (profile == null) return;

    final nameCtrl = TextEditingController(text: profile.name);
    String selectedAvatar = profile.avatar;

    await showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(builder: (ctx2, setSheet) {
        return Container(
          decoration: const BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.fromLTRB(
              20, 16, 20,
              MediaQuery.of(ctx2).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4,
                  decoration: BoxDecoration(color: AppTheme.border,
                      borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 16),
              const Text('Edit Profile',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary)),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 6, crossAxisSpacing: 8, mainAxisSpacing: 8),
                itemCount: AppTheme.avatarOptions.length,
                itemBuilder: (_, i) {
                  final av = AppTheme.avatarOptions[i];
                  final sel = av == selectedAvatar;
                  return GestureDetector(
                    onTap: () => setSheet(() => selectedAvatar = av),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      decoration: BoxDecoration(
                        color: sel ? AppTheme.accent.withOpacity(0.2)
                            : AppTheme.surfaceLight,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: sel ? AppTheme.accent : AppTheme.border,
                            width: sel ? 2 : 1),
                      ),
                      child: Center(child: Text(av,
                          style: const TextStyle(fontSize: 20))),
                    ),
                  );
                },
              ),
              const SizedBox(height: 14),
              TextField(
                controller: nameCtrl,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Name',
                  hintStyle: const TextStyle(color: AppTheme.textSecondary),
                  filled: true, fillColor: AppTheme.surfaceLight,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.border)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.border)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.accent)),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await pp.updateProfile(profile.id,
                        name: nameCtrl.text.trim().isEmpty
                            ? profile.name : nameCtrl.text.trim(),
                        avatar: selectedAvatar);
                    if (ctx2.mounted) Navigator.pop(ctx2);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Save Changes'),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pp = context.watch<ProfileProvider>();
    final profile = pp.active;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.bg, elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppTheme.textPrimary, size: 18),
        ),
        title: const Text('Settings',
            style: TextStyle(color: AppTheme.textPrimary,
                fontWeight: FontWeight.w700)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile card
          if (profile != null) ...[
            _sectionLabel('Profile'),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.border),
              ),
              child: Row(
                children: [
                  Text(profile.avatar,
                      style: const TextStyle(fontSize: 36)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(profile.name,
                            style: const TextStyle(fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary)),
                        Text('Member since ${profile.createdAt.day}/'
                            '${profile.createdAt.month}/${profile.createdAt.year}',
                            style: const TextStyle(fontSize: 12,
                                color: AppTheme.textSecondary)),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => _editProfile(context),
                    child: const Text('Edit'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          _sectionLabel('Data'),
          _tile(
            icon: Icons.delete_sweep_rounded,
            iconColor: AppTheme.wrong,
            title: 'Reset Profile Data',
            subtitle: 'Delete all history and achievements',
            onTap: () => _resetData(context),
          ),
          const SizedBox(height: 24),

          _sectionLabel('About'),
          _tile(
            icon: Icons.info_outline_rounded,
            iconColor: AppTheme.accent,
            title: 'QuizMaster Pro',
            subtitle: 'Version 1.0.0',
            onTap: null,
          ),
          _tile(
            icon: Icons.quiz_rounded,
            iconColor: AppTheme.warning,
            title: 'Question Bank',
            subtitle: '4,500 questions across 9 subjects',
            onTap: null,
          ),
          _tile(
            icon: Icons.wifi_off_rounded,
            iconColor: AppTheme.correct,
            title: '100% Offline',
            subtitle: 'No internet connection required',
            onTap: null,
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(t, style: const TextStyle(fontSize: 12,
        fontWeight: FontWeight.w700, color: AppTheme.textSecondary,
        letterSpacing: 1)),
  );

  Widget _tile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
  }) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: AppTheme.border),
          ),
          child: Row(
            children: [
              Container(
                width: 38, height: 38,
                decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary)),
                    Text(subtitle, style: const TextStyle(fontSize: 12,
                        color: AppTheme.textSecondary)),
                  ],
                ),
              ),
              if (onTap != null)
                const Icon(Icons.chevron_right_rounded,
                    color: AppTheme.textSecondary, size: 18),
            ],
          ),
        ),
      );
}
