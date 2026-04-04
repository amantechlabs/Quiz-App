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

    final questions = data.map((item) {
      final map = Map<String, dynamic>.from(item as Map);
      final options = (map['options'] as List).cast<String>();
      return DbQuestion(
        id: map['id'] as int,
        subject: map['subject'] as String,
        difficulty: map['difficulty'] as String,
        questionText: map['question'] as String,
        optionA: options[0],
        optionB: options[1],
        optionC: options[2],
        optionD: options[3],
        correctIndex: map['correctIndex'] as int,
        explanation: map['explanation'] as String,
      );
    }).toList();

    await db.questionDao.replaceAll(questions);
    await prefs.setBool(_seedKey, true);
  }
}
