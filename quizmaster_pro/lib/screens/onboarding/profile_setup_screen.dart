import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/profile_provider.dart';
import '../../utils/theme.dart';
import '../home/home_screen.dart';

class ProfileSetupScreen extends StatefulWidget {
  final bool isAddingNew;
  const ProfileSetupScreen({super.key, this.isAddingNew = false});
  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _nameCtrl = TextEditingController();
  String _selectedAvatar = AppTheme.avatarOptions[0];
  bool _loading = false;

  @override
  void dispose() { _nameCtrl.dispose(); super.dispose(); }

  Future<void> _create() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a name')));
      return;
    }
    setState(() => _loading = true);
    await context.read<ProfileProvider>().createProfile(name, _selectedAvatar);
    if (!mounted) return;
    if (widget.isAddingNew) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.isAddingNew) ...[
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: AppTheme.textPrimary),
                ),
                const SizedBox(height: 24),
              ] else
                const SizedBox(height: 40),

              const Text('Create Profile',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary)),
              const SizedBox(height: 8),
              const Text('Choose an avatar and enter your name',
                  style: TextStyle(fontSize: 15, color: AppTheme.textSecondary)),
              const SizedBox(height: 36),

              // Avatar grid
              const Text('Pick your avatar',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary, letterSpacing: 0.8)),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6, crossAxisSpacing: 10, mainAxisSpacing: 10,
                  childAspectRatio: 1,
                ),
                itemCount: AppTheme.avatarOptions.length,
                itemBuilder: (_, i) {
                  final av = AppTheme.avatarOptions[i];
                  final selected = av == _selectedAvatar;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedAvatar = av),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppTheme.accent.withOpacity(0.25)
                            : AppTheme.surfaceLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selected ? AppTheme.accent : AppTheme.border,
                          width: selected ? 2 : 1,
                        ),
                      ),
                      child: Center(
                        child: Text(av, style: const TextStyle(fontSize: 22)),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 32),
              const Text('Your name',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary, letterSpacing: 0.8)),
              const SizedBox(height: 10),
              TextField(
                controller: _nameCtrl,
                style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'e.g. Ashraf',
                  hintStyle: TextStyle(color: AppTheme.textSecondary.withOpacity(0.5)),
                  filled: true,
                  fillColor: AppTheme.surfaceLight,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppTheme.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppTheme.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppTheme.accent, width: 1.5),
                  ),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(_selectedAvatar,
                        style: const TextStyle(fontSize: 20)),
                  ),
                ),
              ),

              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _loading ? null : _create,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    textStyle: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  child: _loading
                      ? const SizedBox(width: 20, height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : Text(widget.isAddingNew ? 'Create' : 'Get Started'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
