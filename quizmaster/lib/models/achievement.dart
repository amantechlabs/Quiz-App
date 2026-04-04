class Achievement {
  final int id;
  final int profileId;
  final String achievement;
  final DateTime unlockedAt;

  const Achievement({
    required this.id,
    required this.profileId,
    required this.achievement,
    required this.unlockedAt,
  });
}
