import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'firebase_options.dart';
import 'services/sound_service.dart';

/// True when Firebase was successfully initialized on this platform.
bool firebaseReady = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    firebaseReady = true;
  } catch (_) {
    firebaseReady = false;
  }

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  // Fire-and-forget: don't hold the first frame for the music loop.
  SoundService.instance.init();
  runApp(const ProviderScope(child: TicTacToeApp()));
}
