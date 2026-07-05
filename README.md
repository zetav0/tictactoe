# 🎮 Tic Tac Toe & 4 en Raya

<p align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.12+-02569B?logo=flutter\&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-Realtime%20Database-FFCA28?logo=firebase\&logoColor=black)
![Riverpod](https://img.shields.io/badge/Riverpod-State%20Management-0175C2)
![Flame](https://img.shields.io/badge/Flame-Game%20Engine-orange)
![Platform](https://img.shields.io/badge/Android-Web-Linux-success)
![License](https://img.shields.io/badge/License-MIT-green)

Una aplicación desarrollada en **Flutter** que reúne los clásicos **Tic Tac Toe (3 en Raya)** y **4 en Raya**, ofreciendo juego local, contra Inteligencia Artificial y multijugador online en tiempo real mediante Firebase.

</p>

---

## ✨ Características

* 🎮 Dos juegos clásicos en una sola aplicación.
* 🤖 IA basada en el algoritmo **Minimax**.
* 🌐 Multijugador online en tiempo real.
* 👥 Multijugador local en el mismo dispositivo.
* 🔥 Salas privadas mediante código.
* 🎨 Interfaz moderna con animaciones fluidas.
* 🔊 Efectos de sonido durante la partida.
* 📱 Compatible con Android, Web y Linux.

---

# 📸 Capturas

<p align="center">
<img src="https://github.com/user-attachments/assets/1a6386cf-a9f2-403f-9eb0-ba4bf5534e06" width="260">
<img src="https://github.com/user-attachments/assets/7c2c25dc-038f-48ff-8c0a-c67b3fa8a040" width="260">
<img src="https://github.com/user-attachments/assets/defa44dc-e83e-47cb-abf8-b135ecb7644d" width="260">
</p>

---

# 🎥 Demo

> **Próximamente**

Una demostración en GIF mostrando:

* Crear una sala
* Unirse con un código
* Jugar online
* Reiniciar la partida

> Un GIF de 10–15 segundos suele captar más atención que varias capturas estáticas.

---

# 🚀 Tecnologías

| Tecnología                 | Uso                 |
| -------------------------- | ------------------- |
| Flutter                    | Framework principal |
| Riverpod                   | Gestión de estado   |
| Firebase Realtime Database | Multijugador online |
| Flame                      | Motor del juego     |
| flutter_animate            | Animaciones         |
| google_fonts               | Tipografías         |
| audioplayers               | Efectos de sonido   |

---

# 🧠 Arquitectura

El proyecto sigue una arquitectura modular para facilitar el mantenimiento.

```
lib/
│
├── controllers/     # Controladores del juego online
├── models/          # Modelos de datos
├── providers/       # Estado global (Riverpod)
├── screens/         # Pantallas
├── services/        # Firebase e IA
├── widgets/         # Componentes reutilizables
└── main.dart
```

---

# 📋 Requisitos

* Flutter SDK >= 3.12
* Firebase CLI
* FlutterFire CLI

---

# ⚙️ Instalación

## Clonar el repositorio

```bash
git clone https://github.com/TU_USUARIO/TU_REPOSITORIO.git

cd TU_REPOSITORIO
```

## Instalar dependencias

```bash
flutter pub get
```

---

# 🔥 Configuración de Firebase

Los archivos de configuración **no están incluidos** en el repositorio.

Instalar FlutterFire CLI:

```bash
dart pub global activate flutterfire_cli
```

Configurar Firebase:

```bash
flutterfire configure
```

Archivos generados:

```
lib/firebase_options.dart
android/app/google-services.json
ios/Runner/GoogleService-Info.plist
```

Si todavía no tienes un proyecto Firebase, créalo desde:

https://console.firebase.google.com

y habilita **Realtime Database**.

---

# 🔐 Reglas de Firebase

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

> ⚠️ Estas reglas son únicamente para desarrollo.

---

# ▶️ Ejecutar

Dispositivo conectado

```bash
flutter run
```

Web (Pruebas)

```bash
flutter run -d chrome
```

---

# 📦 Compilar

Android

```bash
flutter build apk
```

Web

```bash
flutter build web
```

---

# 🎮 Modos de juego

## 👥 Local

Dos jugadores utilizan el mismo dispositivo.

---

## 🤖 Contra IA

La computadora utiliza **Minimax** para realizar movimientos óptimos.

---

## 🌐 Online

Permite crear una sala privada y compartir un código para jugar en tiempo real.

Características:

* sincronización instantánea
* reinicio de partida
* control de turnos
* detección de ganador
* actualización automática

---

# 🛣️ Roadmap

## Próximas características

* [ ] Chat dentro de las partidas
* [ ] Sistema de amigos
* [ ] Ranking global
* [ ] Estadísticas de victorias
* [ ] Login con Google
* [ ] Login anónimo
* [ ] Avatares personalizados
* [ ] Historial de partidas
* [ ] Matchmaking automático
* [ ] Soporte para iOS
* [ ] Tema oscuro
* [ ] Logros (Achievements)
* [ ] Sonidos configurables
* [ ] Animaciones de victoria mejoradas

---

# 🤝 Contribuciones

Las contribuciones son bienvenidas.

Si deseas colaborar:

1. Haz un Fork.
2. Crea una nueva rama.

```bash
git checkout -b feature/nueva-funcionalidad
```

3. Realiza tus cambios.

4. Haz commit.

```bash
git commit -m "feat: agregar nueva funcionalidad"
```

5. Envía los cambios.

```bash
git push origin feature/nueva-funcionalidad
```

6. Abre un Pull Request.

---

# 🐞 Problemas conocidos

## Android

Puede aparecer el siguiente warning:

```text
WARNING: Your app uses the following plugins that apply Kotlin Gradle Plugin (KGP)
```

No afecta el funcionamiento de la aplicación.

Se debe al paquete **audioplayers_android**, que aún utiliza una API antigua de Gradle.

---

# 💡 Ideas futuras

* IA con varios niveles de dificultad.
* Torneos online.
* Repetición de partidas.
* Espectadores.
* Modo sin conexión.
* Diferentes tamaños de tablero.
* Notificaciones push.
* Estadísticas por jugador.

---

# ❤️ Agradecimientos

Gracias a los proyectos open source utilizados:

* Flutter
* Flame
* Riverpod
* Firebase
* audioplayers

---

# 📄 Licencia

Distribuido bajo la licencia **MIT**.

Puedes modificarlo y distribuirlo respetando los términos de la licencia.

---

<p align="center">

⭐ **Si este proyecto te fue útil, considera darle una estrella al repositorio.**

</p>
