import 'dart:convert';

class UserProfile {
  final String username;
  final String avatarSeed;

  const UserProfile({
    required this.username,
    required this.avatarSeed,
  });

  UserProfile copyWith({
    String? username,
    String? avatarSeed,
  }) =>
      UserProfile(
        username: username ?? this.username,
        avatarSeed: avatarSeed ?? this.avatarSeed,
      );

  Map<String, dynamic> toJson() => {
        'username': username,
        'avatarSeed': avatarSeed,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        username: json['username'] as String,
        avatarSeed: json['avatarSeed'] as String,
      );

  static UserProfile? tryDecode(String? raw) {
    if (raw == null) return null;
    try {
      return UserProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  String encode() => jsonEncode(toJson());
}
