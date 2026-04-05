import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/profile_provider.dart';
import '../../utils/constants.dart';
import '../home/home_screen.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _controller = TextEditingController();
  String _avatar = AppConstants.avatars.first;
  bool _saving = false;

  Future<void> _create() async {
    if (_controller.text.trim().isEmpty || _saving) return;
    setState(() => _saving = true);
    await context.read<ProfileProvider>().createProfile(_controller.text.trim(), _avatar);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create your profile')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Name', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          TextField(controller: _controller, decoration: const InputDecoration(border: OutlineInputBorder())),
          const SizedBox(height: 20),
          const Text('Choose an avatar', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: AppConstants.avatars.map((a) {
              final selected = a == _avatar;
              return ChoiceChip(
                label: Text(a, style: const TextStyle(fontSize: 20)),
                selected: selected,
                onSelected: (_) => setState(() => _avatar = a),
              );
            }).toList(),
          ),
          const SizedBox(height: 30),
          FilledButton(
            onPressed: _create,
            child: _saving ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Create Profile'),
          ),
        ],
      ),
    );
  }
}
