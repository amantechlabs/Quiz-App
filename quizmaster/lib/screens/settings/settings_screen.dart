import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/profile_provider.dart';
import '../../utils/constants.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>().activeProfile;
    if (profile == null) return const Center(child: Text('No profile selected.'));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ListTile(
          title: const Text('Rename profile'),
          subtitle: Text(profile.name),
          onTap: () async {
            final controller = TextEditingController(text: profile.name);
            final name = await showDialog<String>(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Rename profile'),
                content: TextField(controller: controller),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                  FilledButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: const Text('Save')),
                ],
              ),
            );
            if (name != null && name.isNotEmpty) {
              await context.read<ProfileProvider>().renameActive(name);
            }
          },
        ),
        ListTile(
          title: const Text('Change avatar'),
          subtitle: Text(profile.avatar),
          onTap: () async {
            final avatar = await showModalBottomSheet<String>(
              context: context,
              builder: (_) => SafeArea(
                child: Wrap(
                  children: AppConstants.avatars.map((a) {
                    return ListTile(
                      title: Text(a, style: const TextStyle(fontSize: 24)),
                      onTap: () => Navigator.pop(context, a),
                    );
                  }).toList(),
                ),
              ),
            );
            if (avatar != null) {
              await context.read<ProfileProvider>().changeAvatar(avatar);
            }
          },
        ),
        ListTile(
          title: const Text('Reset profile data'),
          subtitle: const Text('Deletes sessions, answers, and achievements'),
          onTap: () async {
            final ok = await showDialog<bool>(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Reset data?'),
                content: const Text('This action cannot be undone.'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                  FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Reset')),
                ],
              ),
            );
            if (ok == true) {
              await context.read<ProfileProvider>().resetActiveProfile();
            }
          },
        ),
        ListTile(
          title: const Text('Delete profile'),
          subtitle: const Text('Remove this profile permanently'),
          onTap: () async {
            final ok = await showDialog<bool>(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Delete profile?'),
                content: const Text('This removes the profile and all related data.'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                  FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
                ],
              ),
            );
            if (ok == true) {
              await context.read<ProfileProvider>().deleteProfile(profile.id);
            }
          },
        ),
        const SizedBox(height: 20),
        const ListTile(
          title: Text('Version'),
          subtitle: Text('1.0.0'),
        ),
      ],
    );
  }
}
