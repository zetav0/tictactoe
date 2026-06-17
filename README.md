# Tic Tac Toe & 4 en Raya — Flutter

Juego de Tic Tac Toe y 4 en Raya con modo local, vs IA y multijugador online en tiempo real via Firebase.

## Requisitos

- [Flutter SDK](https://docs.flutter.dev/get-started/install) >= 3.12
- [Firebase CLI](https://firebase.google.com/docs/cli)
- [FlutterFire CLI](https://firebase.flutter.dev/docs/cli)

## Setup inicial

### 1. Instalar dependencias

```bash
flutter pub get
```

### 2. Configurar Firebase

Los archivos de configuración de Firebase **no están incluidos en el repo** (están en `.gitignore`). Debes generarlos tú mismo:

```bash
# Instalar FlutterFire CLI si no lo tienes
dart pub global activate flutterfire_cli

# Conectar con tu proyecto Firebase (abre el navegador para elegir proyecto)
flutterfire configure
```

Esto genera automáticamente:
- `lib/firebase_options.dart`
- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`

> Si no tienes un proyecto Firebase, créalo en [console.firebase.google.com](https://console.firebase.google.com) y activa **Realtime Database**.

### 3. Reglas de Realtime Database

En Firebase Console → **Realtime Database → Rules**, configura:

```json
{
  "rules": {
    "rooms": {
      "$code": {
        ".read": true,
        ".write": true
      }
    }
  }
}
```

### 4. Correr la app

```bash
flutter run             # dispositivo por defecto
flutter run -d chrome   # web
flutter run -d linux    # desktop Linux
```

## Build

```bash
# APK Android (debug keys — solo para pruebas)
flutter build apk

# Web
flutter build web
```

## Estructura

```
lib/
  models/       # Game state y board models
  screens/      # HomeScreen, GameScreen, MultiplayerScreen
  widgets/      # Board, Cell, ScoreCard, GameSymbol
  services/     # RoomService (Firebase), AIService (Minimax)
  providers/    # Riverpod state management
  controllers/  # RemoteGameController
```

## Stack

- **Flutter** + **Riverpod** (estado)
- **Firebase Realtime Database** (multijugador online)
- **Flame** (motor de juego Tic Tac Toe)
- **flutter_animate** + **google_fonts**
- **audioplayers** (efectos de sonido)

## Notas conocidas

### Warning "Built-in Kotlin migration" en Android

Al correr en Android aparece este aviso en la consola:

```
WARNING: Your app uses the following plugins that apply Kotlin Gradle Plugin (KGP): audioplayers_android
Future versions of Flutter will fail to build if your app uses plugins that apply KGP.
```

**No es un error** — el build completa y la app funciona con normalidad. Es un issue del paquete `audioplayers_android` que todavía usa la API antigua de Gradle. En cuanto los autores del plugin publiquen una versión con Built-in Kotlin, desaparecerá al hacer:

```bash
flutter pub upgrade
```

Referencia: [Flutter – Migrate to Built-in Kotlin](https://docs.flutter.dev/release/breaking-changes/migrate-to-built-in-kotlin/for-app-developers)
