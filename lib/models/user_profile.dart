import 'dart:convert';

class UserProfile {
  final String username;
  final String avatarSeed;
  final String? customImagePath; // absolute path to a locally stored image file

  const UserProfile({
    required this.username,
    required this.avatarSeed,
    this.customImagePath,
  });

  UserProfile copyWith({
    String? username,
    String? avatarSeed,
    String? customImagePath,
    bool clearImage = false,
  }) =>
      UserProfile(
        username: username ?? this.username,
        avatarSeed: avatarSeed ?? this.avatarSeed,
        customImagePath: clearImage ? null : (customImagePath ?? this.customImagePath),
      );

  Map<String, dynamic> toJson() => {
        'username': username,
        'avatarSeed': avatarSeed,
        if (customImagePath != null) 'customImagePath': customImagePath,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        username: json['username'] as String,
        avatarSeed: json['avatarSeed'] as String,
        customImagePath: json['customImagePath'] as String?,
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

  // Only Firebase Storage URLs are safe to share in RTDB (no large base64 blobs)
  String? get shareableImageUrl {
    if (customImagePath == null) return null;
    if (customImagePath!.startsWith('https://')) return customImagePath;
    return null;
  }
}
