import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/profile_provider.dart';
import '../../utils/theme.dart';
import '../quiz/quiz_config_screen.dart';
import '../history/history_screen.dart';
import '../stats/stats_screen.dart';
import '../achievements/achievements_screen.dart';
import 'profile_switcher_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;

  static const List<String> _subjects = [
    'Geography', 'History', 'Political Science', 'Physics',
    'Biology', 'Chemistry', 'Mathematics', 'General Knowledge',
    'General Science',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: IndexedStack(
        index: _tab,
        children: const [
          _SubjectGrid(),
          HistoryScreen(),
          StatsScreen(),
          AchievementsScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: AppTheme.surface,
        indicatorColor: AppTheme.accent.withOpacity(0.2),
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.grid_view_rounded), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.history_rounded), label: 'History'),
          NavigationDestination(icon: Icon(Icons.bar_chart_rounded), label: 'Stats'),
          NavigationDestination(icon: Icon(Icons.emoji_events_rounded), label: 'Badges'),
        ],
      ),
    );
  }
}

class _SubjectGrid extends StatelessWidget {
  const _SubjectGrid();

  static const List<String> subjects = [
    'Geography', 'History', 'Political Science', 'Physics',
    'Biology', 'Chemistry', 'Mathematics', 'General Knowledge',
    'General Science',
  ];

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>().active;
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Hello, ${profile?.name ?? ''}! 👋',
                          style: const TextStyle(fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textPrimary)),
                      const SizedBox(height: 2),
                      const Text('Pick a subject to quiz',
                          style: TextStyle(fontSize: 14,
                              color: AppTheme.textSecondary)),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    isScrollControlled: true,
                    builder: (_) => const ProfileSwitcherSheet(),
                  ),
                  child: Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Center(
                      child: Text(profile?.avatar ?? '🧠',
                          style: const TextStyle(fontSize: 22)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, crossAxisSpacing: 12,
                mainAxisSpacing: 12, childAspectRatio: 0.9,
              ),
              itemCount: subjects.length,
              itemBuilder: (ctx, i) => _SubjectCard(subject: subjects[i]),
            ),
          ),
        ],
      ),
    );
  }
}

class _SubjectCard extends StatelessWidget {
  final String subject;
  const _SubjectCard({required this.subject});

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.subjectColors[subject] ?? AppTheme.accent;
    final emoji = AppTheme.subjectEmojis[subject] ?? '📚';

    return GestureDetector(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => QuizConfigScreen(subject: subject))),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 50, height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Center(child: Text(emoji,
                  style: const TextStyle(fontSize: 26))),
            ),
            const Spacer(),
            Text(subject,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary)),
            const SizedBox(height: 4),
            Text('500 Questions',
                style: TextStyle(fontSize: 12,
                    color: AppTheme.textSecondary.withOpacity(0.7))),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('Play →',
                  style: TextStyle(fontSize: 11, color: color,
                      fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }
}
