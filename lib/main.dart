import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'firebase_options.dart';

/// True when Firebase was successfully initialized on this platform.
bool firebaseReady = false;

bool get _supported =>
    kIsWeb || defaultTargetPlatform != TargetPlatform.linux;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (_supported) {
    try {
      await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform);
      firebaseReady = true;
    } catch (_) {
      firebaseReady = false;
    }
  }

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const ProviderScope(child: TicTacToeApp()));
}
