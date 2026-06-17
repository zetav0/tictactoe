import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  static final _storage = FirebaseStorage.instance;

  static Future<String> uploadAvatar(List<int> bytes) async {
    final ref = _storage.ref(
      'avatars/${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
    await ref.putData(
      Uint8List.fromList(bytes),
      SettableMetadata(contentType: 'image/jpeg'),
    );
    return ref.getDownloadURL();
  }
}
