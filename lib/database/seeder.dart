import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'question_dao.dart';

class Seeder {
  static const String _seededKey = 'db_seeded_v1';

  static Future<bool> needsSeeding() async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool(_seededKey) ?? false);
  }

  static Future<void> run(void Function(double progress) onProgress) async {
    final needs = await needsSeeding();
    if (!needs) {
      onProgress(1.0);
      return;
    }

    // Load JSON from assets
    final raw = await rootBundle.loadString('assets/data/questions.json');
    final List<dynamic> jsonList = json.decode(raw) as List<dynamic>;
    final total = jsonList.length;
    const chunkSize = 100;
    int done = 0;

    for (int i = 0; i < total; i += chunkSize) {
      final end = (i + chunkSize).clamp(0, total);
      final chunk = jsonList.sublist(i, end);

      final rows = chunk.map((item) {
        final j = item as Map<String, dynamic>;
        final opts = List<String>.from(j['options'] as List);
        return {
          'subject': j['subject'] as String,
          'difficulty': j['difficulty'] as String,
          'question_text': j['question'] as String,
          'option_a': opts[0],
          'option_b': opts[1],
          'option_c': opts[2],
          'option_d': opts[3],
          'correct_index': j['correctIndex'] as int,
          'explanation': (j['explanation'] as String?) ?? '',
        };
      }).toList();

      await QuestionDao.batchInsert(rows);
      done += chunk.length;
      onProgress(done / total);
      await Future.delayed(Duration.zero); // yield to UI thread
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_seededKey, true);
  }

  /// Call this to force a re-seed (e.g. after clearing data)
  static Future<void> resetSeedFlag() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_seededKey);
  }
}
