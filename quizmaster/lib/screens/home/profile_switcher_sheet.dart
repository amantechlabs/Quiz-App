import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/profile_provider.dart';
import '../onboarding/profile_setup_screen.dart';

class ProfileSwitcherSheet extends StatelessWidget {
  const ProfileSwitcherSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProfileProvider>();
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          shrinkWrap: true,
          children: [
            const Text('Switch profile', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            ...provider.profiles.map((p) {
              return Card(
                child: ListTile(
                  leading: CircleAvatar(child: Text(p.avatar)),
                  title: Text(p.name),
                  subtitle: Text(p.isActive ? 'Active' : 'Tap to switch'),
                  onTap: () async {
                    await context.read<ProfileProvider>().switchProfile(p.id);
                    if (context.mounted) Navigator.pop(context);
                  },
                  onLongPress: () async {
                    await context.read<ProfileProvider>().deleteProfile(p.id);
                    if (context.mounted) Navigator.pop(context);
                  },
                ),
              );
            }),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: () {
                Navigator.pop(context);
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProfileSetupScreen()));
              },
              icon: const Icon(Icons.add),
              label: const Text('Add New Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
