import 'package:flutter/foundation.dart';
import '../database/db_helper.dart';
import '../database/db_instance.dart';
import '../models/profile.dart';

class ProfileProvider extends ChangeNotifier {
  final AppDatabase db;
  ProfileProvider(this.db);

  List<Profile> _profiles = [];
  Profile? _activeProfile;
  bool _loading = false;

  List<Profile> get profiles => _profiles;
  Profile? get activeProfile => _activeProfile;
  bool get loading => _loading;

  Future<void> loadInitial() async {
    _loading = true;
    notifyListeners();

    final dbProfiles = await db.profileDao.getAllProfiles();
    _profiles = dbProfiles
        .map((e) => Profile(
              id: e.id,
              name: e.name,
              avatar: e.avatar,
              createdAt: DateTime.parse(e.createdAt),
              isActive: e.isActive,
            ))
        .toList();

    final active = await db.profileDao.getActiveProfile();
    _activeProfile = active == null
        ? null
        : Profile(
            id: active.id,
            name: active.name,
            avatar: active.avatar,
            createdAt: DateTime.parse(active.createdAt),
            isActive: active.isActive,
          );

    _loading = false;
    notifyListeners();
  }

  Future<void> createProfile(String name, String avatar) async {
    await db.profileDao.createProfile(name: name, avatar: avatar);
    await loadInitial();
  }

  Future<void> switchProfile(int id) async {
    await db.profileDao.setActiveProfile(id);
    await loadInitial();
  }

  Future<void> renameActive(String name) async {
    final p = _activeProfile;
    if (p == null) return;
    await db.profileDao.renameProfile(p.id, name);
    await loadInitial();
  }

  Future<void> changeAvatar(String avatar) async {
    final p = _activeProfile;
    if (p == null) return;
    await db.profileDao.updateAvatar(p.id, avatar);
    await loadInitial();
  }

  Future<void> deleteProfile(int id) async {
    await db.profileDao.deleteProfile(id);
    await loadInitial();
  }

  Future<void> resetActiveProfile() async {
    final p = _activeProfile;
    if (p == null) return;
    await db.profileDao.resetProfileData(p.id);
    await db.sessionDao.resetProfileData(p.id);
    await loadInitial();
  }
}
