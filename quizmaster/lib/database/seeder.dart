import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'db_helper.dart';

class Seeder {
  static const _seedKey = 'db_seeded';

  static Future<void> seedIfNeeded(AppDatabase db, SharedPreferences prefs) async {
    final seeded = prefs.getBool(_seedKey) ?? false;
    if (seeded) return;

    final jsonString = await rootBundle.loadString('assets/questions.json');
    final List<dynamic> data = json.decode(jsonString);

    final buffer = <DbQuestionsCompanion>[];
    for (final item in data) {
      buffer.add(DbQuestionsCompanion.insert(
        subject: item['subject'] as String,
        difficulty: item['difficulty'] as String,
        questionText: item['question'] as String,
        optionA: (item['options'] as List)[0] as String,
        optionB: (item['options'] as List)[1] as String,
        optionC: (item['options'] as List)[2] as String,
        optionD: (item['options'] as List)[3] as String,
        correctIndex: item['correctIndex'] as int,
        explanation: item['explanation'] as String,
      ));
    }

    const chunkSize = 100;
    for (var i = 0; i < buffer.length; i += chunkSize) {
      final end = (i + chunkSize) > buffer.length ? buffer.length : i + chunkSize;
      await db.batch((batch) {
        batch.insertAll(db.dbQuestions, buffer.sublist(i, end));
      });
    }

    await prefs.setBool(_seedKey, true);
  }
}
