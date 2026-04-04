class Profile {
  final int id;
  final String name;
  final String avatar;
  final DateTime createdAt;
  final bool isActive;

  const Profile({
    required this.id,
    required this.name,
    required this.avatar,
    required this.createdAt,
    required this.isActive,
  });
}
