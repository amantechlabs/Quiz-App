import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../database/seeder.dart';
import '../providers/profile_provider.dart';
import '../utils/theme.dart';
import 'onboarding/profile_setup_screen.dart';
import 'home/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  double _seedProgress = 0;
  String _statusText = 'Initialising…';

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final needs = await Seeder.needsSeeding();
    if (needs) {
      setState(() => _statusText = 'Building question bank…');
      await Seeder.run((p) {
        if (mounted) setState(() => _seedProgress = p);
      });
    }
    if (!mounted) return;
    setState(() => _statusText = 'Loading profile…');
    final pp = context.read<ProfileProvider>();
    await pp.load();
    if (!mounted) return;
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) =>
            pp.hasProfile ? const HomeScreen() : const ProfileSetupScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: FadeTransition(
        opacity: _fade,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 100, height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [AppTheme.accent, Color(0xFFDA22FF)],
                      begin: Alignment.topLeft, end: Alignment.bottomRight,
                    ),
                    boxShadow: [BoxShadow(
                      color: AppTheme.accent.withOpacity(0.4),
                      blurRadius: 30, spreadRadius: 4,
                    )],
                  ),
                  child: const Center(child: Text('🧠', style: TextStyle(fontSize: 48))),
                ),
                const SizedBox(height: 24),
                const Text('QuizMaster Pro',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary, letterSpacing: 0.5)),
                const SizedBox(height: 6),
                Text(_statusText,
                    style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
                const SizedBox(height: 32),
                if (_seedProgress > 0 && _seedProgress < 1) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: _seedProgress,
                      backgroundColor: AppTheme.surfaceLight,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accent),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('${(_seedProgress * 100).toInt()}%',
                      style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                ] else
                  SizedBox(
                    width: 28, height: 28,
                    child: CircularProgressIndicator(
                      color: AppTheme.accent.withOpacity(0.7), strokeWidth: 2),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
