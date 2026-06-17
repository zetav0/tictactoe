import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_profile.dart';
import '../services/profile_service.dart';

class ProfileNotifier extends AsyncNotifier<UserProfile?> {
  final _service = ProfileService();

  @override
  Future<UserProfile?> build() => _service.load();

  Future<void> save(UserProfile profile) async {
    await _service.save(profile);
    state = AsyncData(profile);
  }
}

final profileProvider = AsyncNotifierProvider<ProfileNotifier, UserProfile?>(
  ProfileNotifier.new,
);
