class Profile {
  final int id;
  final String name;
  final String avatar; // single emoji
  final DateTime createdAt;
  final bool isActive;

  const Profile({
    required this.id,
    required this.name,
    required this.avatar,
    required this.createdAt,
    required this.isActive,
  });

  factory Profile.fromMap(Map<String, dynamic> m) => Profile(
        id: m['id'] as int,
        name: m['name'] as String,
        avatar: m['avatar'] as String,
        createdAt: DateTime.parse(m['created_at'] as String),
        isActive: (m['is_active'] as int) == 1,
      );

  Map<String, dynamic> toInsertMap() => {
        'name': name,
        'avatar': avatar,
        'created_at': createdAt.toIso8601String(),
        'is_active': isActive ? 1 : 0,
      };

  Profile copyWith({String? name, String? avatar, bool? isActive}) => Profile(
        id: id,
        name: name ?? this.name,
        avatar: avatar ?? this.avatar,
        createdAt: createdAt,
        isActive: isActive ?? this.isActive,
      );
}
