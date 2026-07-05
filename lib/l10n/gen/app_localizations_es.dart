// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get gameTicTacToe => 'Tres en Raya';

  @override
  String get gameConnectFour => '4 en Raya';

  @override
  String get tttTagline => 'El clásico juego de estrategia.';

  @override
  String get c4Tagline => 'Conecta cuatro en línea.';

  @override
  String hiUser(String name) {
    return 'HOLA, $name';
  }

  @override
  String get playerVsPlayer => 'Jugador vs Jugador';

  @override
  String get playerVsAi => 'Jugador vs IA';

  @override
  String get onlineMultiplayer => 'Multijugador Online';

  @override
  String get badgeNew => 'NUEVO';

  @override
  String get aiDifficultyLevel => 'DIFICULTAD DE LA IA';

  @override
  String get difficultyEasy => 'Fácil';

  @override
  String get difficultyMedium => 'Medio';

  @override
  String get difficultyHard => 'Difícil';

  @override
  String get playNow => 'JUGAR AHORA';

  @override
  String get navPlay => 'Jugar';

  @override
  String get navHistory => 'Historial';

  @override
  String get navProfile => 'Perfil';

  @override
  String get restartGame => 'Reiniciar Partida';

  @override
  String get playAgain => 'Jugar de Nuevo';

  @override
  String get home => 'Inicio';

  @override
  String playerWins(String name) {
    return '¡$name Gana!';
  }

  @override
  String get itsADraw => '¡Empate!';

  @override
  String get yourTurn => '¡Tu turno!';

  @override
  String get aiThinking => 'La IA está pensando...';

  @override
  String get player2Turn => '¡Turno del Jugador 2!';

  @override
  String get opponentTurn => 'Turno del rival...';

  @override
  String get labelPlayer1 => 'Jugador 1';

  @override
  String get labelPlayer2 => 'Jugador 2';

  @override
  String get labelAi => 'IA';

  @override
  String get labelOpponent => 'Rival';

  @override
  String get createARoom => 'Crear una Sala';

  @override
  String get createRoomSubtitle =>
      'Inicia una partida nueva y comparte el código con un amigo.';

  @override
  String get createRoom => 'Crear Sala';

  @override
  String get orDivider => 'O';

  @override
  String get joinARoom => 'Unirse a una Sala';

  @override
  String get joinRoomSubtitle =>
      'Ingresa el código de 6 caracteres que te compartió tu rival.';

  @override
  String get joinRoom => 'Unirse a la Sala';

  @override
  String get invalidCode => 'Ingresa un código válido de 6 caracteres.';

  @override
  String roomNotFound(String code) {
    return 'La sala \"$code\" no existe. Revisa el código e inténtalo de nuevo.';
  }

  @override
  String roomFull(String code) {
    return 'La sala \"$code\" ya está llena.';
  }

  @override
  String get wrongGameMode => 'Modo de juego incorrecto';

  @override
  String wrongGameModeContent(
    String code,
    String roomGame,
    String selectedGame,
  ) {
    return 'La sala \"$code\" es una partida de $roomGame, pero tienes $selectedGame seleccionado.\n\nVuelve al inicio y selecciona $roomGame para unirte a esta sala.';
  }

  @override
  String get gotIt => 'Entendido';

  @override
  String get onlineGame => 'PARTIDA ONLINE';

  @override
  String get shareCode => 'Comparte este código\ncon tu rival';

  @override
  String get codeCopied => '¡Código copiado al portapapeles!';

  @override
  String get waitingForOpponent => 'Esperando al rival...';

  @override
  String get opponentLeft => 'Tu rival se fue';

  @override
  String get opponentDisconnected => 'Tu rival se desconectó.';

  @override
  String get backToMenu => 'Volver al Menú';

  @override
  String get leaveGame => '¿Salir de la partida?';

  @override
  String get leaveGameWarning => 'La sala se eliminará para ambos jugadores.';

  @override
  String get stay => 'Quedarme';

  @override
  String get leave => 'Salir';

  @override
  String get welcome => '¡Bienvenido!';

  @override
  String get setupProfileSubtitle => 'Configura tu perfil para empezar.';

  @override
  String get yourName => 'TU NOMBRE';

  @override
  String get enterUsername => 'Escribe tu nombre de usuario';

  @override
  String get chooseYourAvatar => 'ELIGE TU AVATAR';

  @override
  String get getStarted => 'Comenzar';

  @override
  String get editProfile => 'EDITAR PERFIL';

  @override
  String get tapToChangeAvatar => 'Toca para cambiar el avatar';

  @override
  String get username => 'NOMBRE DE USUARIO';

  @override
  String get saveChanges => 'Guardar Cambios';

  @override
  String get chooseAvatar => 'Elegir Avatar';
}
