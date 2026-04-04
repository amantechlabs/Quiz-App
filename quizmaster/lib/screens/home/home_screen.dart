import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../database/db_helper.dart';
import '../../models/profile.dart';
import '../../providers/profile_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/category_card.dart';
import '../achievements/achievements_screen.dart';
import '../history/history_screen.dart';
import '../quiz/quiz_config_screen.dart';
import '../settings/settings_screen.dart';
import '../stats/stats_screen.dart';
import 'profile_switcher_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final active = context.watch<ProfileProvider>().activeProfile;

    final pages = [
      _HomeTab(active: active),
      const HistoryScreen(),
      const StatsScreen(),
      const AchievementsScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(active == null ? 'QuizMaster Pro' : '${active.avatar} ${active.name}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.switch_account),
            onPressed: () => showModalBottomSheet(
              context: context,
              showDragHandle: true,
              isScrollControlled: true,
              builder: (_) => const ProfileSwitcherSheet(),
            ),
          ),
        ],
      ),
      body: pages[_tab],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (v) => setState(() => _tab = v),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.history), label: 'History'),
          NavigationDestination(icon: Icon(Icons.query_stats), label: 'Stats'),
          NavigationDestination(icon: Icon(Icons.emoji_events_outlined), label: 'Awards'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), label: 'Settings'),
        ],
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  final Profile? active;
  const _HomeTab({required this.active});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: AppConstants.subjects.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.95,
      ),
      itemBuilder: (_, i) {
        final subject = AppConstants.subjects[i];
        return CategoryCard(
          title: subject['name'] as String,
          emoji: subject['emoji'] as String,
          questionCount: 500,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => QuizConfigScreen(subject: subject['name'] as String)),
          ),
        );
      },
    );
  }
}
