import 'package:sqflite/sqflite.dart';
import '../models/profile.dart';
import 'db_helper.dart';

class ProfileDao {
  static Future<List<Profile>> getAll() async {
    final db = await DbHelper.database;
    final rows = await db.query('profiles', orderBy: 'created_at ASC');
    return rows.map(Profile.fromMap).toList();
  }

  static Future<Profile?> getActive() async {
    final db = await DbHelper.database;
    final rows = await db.query('profiles', where: 'is_active = 1', limit: 1);
    if (rows.isEmpty) return null;
    return Profile.fromMap(rows.first);
  }

  static Future<int> insert(Profile p) async {
    final db = await DbHelper.database;
    // Deactivate all first
    await db.update('profiles', {'is_active': 0});
    return db.insert('profiles', p.toInsertMap());
  }

  static Future<void> setActive(int id) async {
    final db = await DbHelper.database;
    await db.update('profiles', {'is_active': 0});
    await db.update('profiles', {'is_active': 1}, where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> update(int id, {String? name, String? avatar}) async {
    final db = await DbHelper.database;
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (avatar != null) data['avatar'] = avatar;
    if (data.isNotEmpty) {
      await db.update('profiles', data, where: 'id = ?', whereArgs: [id]);
    }
  }

  static Future<void> delete(int id) async {
    final db = await DbHelper.database;
    await db.delete('profiles', where: 'id = ?', whereArgs: [id]);
    // Activate the most recent remaining profile if any
    final remaining = await db.query('profiles', orderBy: 'created_at DESC', limit: 1);
    if (remaining.isNotEmpty) {
      await db.update('profiles', {'is_active': 1},
          where: 'id = ?', whereArgs: [remaining.first['id']]);
    }
  }

  static Future<int> count() async {
    final db = await DbHelper.database;
    final res = await db.rawQuery('SELECT COUNT(*) as c FROM profiles');
    return (res.first['c'] as int?) ?? 0;
  }
}
