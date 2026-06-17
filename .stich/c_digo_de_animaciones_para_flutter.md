# Animaciones del Tablero de Tic Tac Toe Pro

Para lograr una experiencia de usuario fluida y moderna en Flutter, implementaremos animaciones para la aparición de las fichas (X y O) y el resaltado de la línea ganadora utilizando el paquete `flutter_animate`.

## 1. Animación de las Fichas (X y O)

Utilizaremos un `AnimatedSwitcher` o simplemente envolvemos el widget de la ficha en un efecto de escala y opacidad.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class GameSymbol extends StatelessWidget {
  final String symbol; // 'X' o 'O'

  const GameSymbol({super.key, required this.symbol});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        symbol,
        style: TextStyle(
          fontSize: 64,
          fontWeight: FontWeight.bold,
          color: symbol == 'X' ? Colors.indigoAccent : Colors.coral,
        ),
      )
      .animate()
      .scale(
        duration: 300.ms,
        curve: Curves.backOut,
        begin: const Offset(0.5, 0.5),
      )
      .fadeIn(duration: 200.ms),
    );
  }
}
```

## 2. Animación de la Celda (Feedback Táctil)

Cuando el usuario pulsa una celda, podemos añadir un efecto de "pulse" o escala.

```dart
class GameCell extends StatelessWidget {
  final VoidCallback onTap;
  final String? symbol;

  const GameCell({super.key, required this.onTap, this.symbol});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(16),
        ),
        child: symbol != null ? GameSymbol(symbol: symbol!) : null,
      ),
    )
    .animate(target: symbol != null ? 1 : 0)
    .shimmer(duration: 1200.ms, color: Colors.white12)
    .scale(
      begin: const Offset(1, 1),
      end: const Offset(0.95, 0.95),
      duration: 100.ms,
    );
  }
}
```

## 3. Resaltado de la Combinación Ganadora

Para la línea ganadora, animaremos un trazo que cruza las celdas o haremos que las celdas ganadoras parpadeen.

```dart
// Widget para resaltar las celdas ganadoras
Widget buildWinningCell(String symbol) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.indigo.withOpacity(0.2),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.indigoAccent, width: 2),
    ),
    child: GameSymbol(symbol: symbol),
  )
  .animate(onPlay: (controller) => controller.repeat(reverse: true))
  .boxShadow(
    begin: const BoxShadow(color: Colors.transparent, blurRadius: 0),
    end: BoxShadow(color: Colors.indigoAccent.withOpacity(0.5), blurRadius: 15),
    duration: 600.ms,
  );
}
```

## 4. Transiciones de Turno

Animación suave para el indicador de quién tiene el turno.

```dart
Widget buildTurnIndicator(bool isMyTurn) {
  return AnimatedContainer(
    duration: 400.ms,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    decoration: BoxDecoration(
      color: isMyTurn ? Colors.indigo : Colors.grey[800],
      borderRadius: BorderRadius.circular(30),
    ),
    child: Text(
      isMyTurn ? "¡Es tu turno!" : "Esperando a la IA...",
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    ),
  ).animate(target: isMyTurn ? 1 : 0).shake(hz: 2, curve: Curves.easeInOut);
}
```
