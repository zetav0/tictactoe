import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';

class ProfileService {
  static const _key = 'user_profile';

  Future<UserProfile?> load() async {
    final prefs = await SharedPreferences.getInstance();
    return UserProfile.tryDecode(prefs.getString(_key));
  }

  Future<void> save(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, profile.encode());
  }
}
