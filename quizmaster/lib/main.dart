import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'database/db_helper.dart';
import 'database/seeder.dart';
import 'providers/history_provider.dart';
import 'providers/profile_provider.dart';
import 'providers/quiz_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final db = AppDatabase();
  await Seeder.seedIfNeeded(db, prefs);

  runApp(QuizMasterBootstrap(db: db));
}

class QuizMasterBootstrap extends StatelessWidget {
  final AppDatabase db;
  const QuizMasterBootstrap({super.key, required this.db});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AppDatabase>.value(value: db),
        ChangeNotifierProvider(
          create: (_) => ProfileProvider(db)..loadInitial(),
        ),
        ChangeNotifierProvider(
          create: (_) => HistoryProvider(db),
        ),
        ChangeNotifierProxyProvider<ProfileProvider, QuizProvider>(
          create: (_) => QuizProvider(db),
          update: (_, profileProvider, quizProvider) =>
              quizProvider!..setActiveProfile(profileProvider.activeProfile),
        ),
      ],
      child: const QuizMasterApp(),
    );
  }
}
