import 'package:drift/drift.dart';
import 'db_helper.dart';

part 'profile_dao.g.dart';

@DriftAccessor(tables: [DbProfiles, DbSessions, DbSessionAnswers, DbAchievements])
class ProfileDao extends DatabaseAccessor<AppDatabase> with _$ProfileDaoMixin {
ProfileDao(super.db);

Future<List<DbProfile>> getAllProfiles() {
return select(dbProfiles).get();
}

Future<DbProfile?> getActiveProfile() {
return (select(dbProfiles)..where((t) => t.isActive.equals(true)))
.getSingleOrNull();
}

Future<int> createProfile({
required String name,
required String avatar,
}) async {
await transaction(() async {
await (update(dbProfiles))
.write(const DbProfilesCompanion(isActive: Value(false)));
});

```
final id = await into(dbProfiles).insert(
  DbProfilesCompanion.insert(
    name: name,
    avatar: avatar,
    createdAt: DateTime.now().toIso8601String(),
    isActive: const Value(true),
  ),
);

return id;
```

}

Future<void> setActiveProfile(int id) async {
await transaction(() async {
await (update(dbProfiles))
.write(const DbProfilesCompanion(isActive: Value(false)));

```
  await (update(dbProfiles)..where((t) => t.id.equals(id)))
      .write(const DbProfilesCompanion(isActive: Value(true)));
});
```

}

Future<void> renameProfile(int id, String name) async {
await (update(dbProfiles)..where((t) => t.id.equals(id)))
.write(DbProfilesCompanion(name: Value(name)));
}

// ✅ FIXED HERE
Future<void> updateAvatar(int id, String avatar) async {
await (update(dbProfiles)..where((t) => t.id.equals(id)))
.write(DbProfilesCompanion(avatar: Value(avatar)));
}

Future<void> deleteProfile(int id) async {
await (delete(dbProfiles)..where((t) => t.id.equals(id))).go();

```
final remaining = await getAllProfiles();

if (remaining.isNotEmpty && remaining.every((p) => !p.isActive)) {
  await setActiveProfile(remaining.first.id);
}
```

}

Future<void> resetProfileData(int profileId) async {
await (delete(dbSessionAnswers)..where((t) =>
t.sessionId.isInQuery(selectOnly(dbSessions)
..addColumns([dbSessions.id])
..where(dbSessions.profileId.equals(profileId)))))
.go();

```
await (delete(dbAchievements)
      ..where((t) => t.profileId.equals(profileId)))
    .go();

await (delete(dbSessions)..where((t) => t.profileId.equals(profileId)))
    .go();
```

}
}
