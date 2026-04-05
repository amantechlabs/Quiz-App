import 'package:flutter/material.dart';
import '../database/profile_dao.dart';
import '../models/profile.dart';

class ProfileProvider extends ChangeNotifier {
  Profile? _active;
  List<Profile> _all = [];

  Profile? get active => _active;
  List<Profile> get all => _all;
  bool get hasProfile => _active != null;

  Future<void> load() async {
    _all = await ProfileDao.getAll();
    _active = await ProfileDao.getActive();
    notifyListeners();
  }

  Future<void> createProfile(String name, String avatar) async {
    final p = Profile(
      id: 0,
      name: name,
      avatar: avatar,
      createdAt: DateTime.now(),
      isActive: true,
    );
    final id = await ProfileDao.insert(p);
    await load();
  }

  Future<void> switchProfile(int id) async {
    await ProfileDao.setActive(id);
    await load();
  }

  Future<void> updateProfile(int id, {String? name, String? avatar}) async {
    await ProfileDao.update(id, name: name, avatar: avatar);
    await load();
  }

  Future<void> deleteProfile(int id) async {
    await ProfileDao.delete(id);
    await load();
  }
}
