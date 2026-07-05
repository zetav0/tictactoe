// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get gameTicTacToe => 'Tic Tac Toe';

  @override
  String get gameConnectFour => 'Connect Four';

  @override
  String get tttTagline => 'The classic game of strategy.';

  @override
  String get c4Tagline => 'Connect four in a line.';

  @override
  String hiUser(String name) {
    return 'HI, $name';
  }

  @override
  String get playerVsPlayer => 'Player vs Player';

  @override
  String get playerVsAi => 'Player vs AI';

  @override
  String get onlineMultiplayer => 'Online Multiplayer';

  @override
  String get badgeNew => 'NEW';

  @override
  String get aiDifficultyLevel => 'AI DIFFICULTY LEVEL';

  @override
  String get difficultyEasy => 'Easy';

  @override
  String get difficultyMedium => 'Medium';

  @override
  String get difficultyHard => 'Hard';

  @override
  String get playNow => 'PLAY NOW';

  @override
  String get navPlay => 'Play';

  @override
  String get navHistory => 'History';

  @override
  String get navProfile => 'Profile';

  @override
  String get restartGame => 'Restart Game';

  @override
  String get playAgain => 'Play Again';

  @override
  String get home => 'Home';

  @override
  String playerWins(String name) {
    return '$name Wins!';
  }

  @override
  String get itsADraw => 'It\'s a Draw!';

  @override
  String get yourTurn => 'Your turn!';

  @override
  String get aiThinking => 'AI thinking...';

  @override
  String get player2Turn => 'Player 2\'s turn!';

  @override
  String get opponentTurn => 'Opponent\'s turn...';

  @override
  String get labelPlayer1 => 'Player 1';

  @override
  String get labelPlayer2 => 'Player 2';

  @override
  String get labelAi => 'AI';

  @override
  String get labelOpponent => 'Opponent';

  @override
  String get createARoom => 'Create a Room';

  @override
  String get createRoomSubtitle =>
      'Start a new game and share the code with a friend.';

  @override
  String get createRoom => 'Create Room';

  @override
  String get orDivider => 'OR';

  @override
  String get joinARoom => 'Join a Room';

  @override
  String get joinRoomSubtitle =>
      'Enter the 6-character code your opponent shared.';

  @override
  String get joinRoom => 'Join Room';

  @override
  String get invalidCode => 'Please enter a valid 6-character code.';

  @override
  String roomNotFound(String code) {
    return 'Room \"$code\" not found. Check the code and try again.';
  }

  @override
  String roomFull(String code) {
    return 'Room \"$code\" is already full.';
  }

  @override
  String get wrongGameMode => 'Wrong game mode';

  @override
  String wrongGameModeContent(
    String code,
    String roomGame,
    String selectedGame,
  ) {
    return 'Room \"$code\" is a $roomGame game, but you have $selectedGame selected.\n\nGo back to the home screen and select $roomGame to join this room.';
  }

  @override
  String get gotIt => 'Got it';

  @override
  String get onlineGame => 'ONLINE GAME';

  @override
  String get shareCode => 'Share this code\nwith your opponent';

  @override
  String get codeCopied => 'Code copied to clipboard!';

  @override
  String get waitingForOpponent => 'Waiting for opponent...';

  @override
  String get opponentLeft => 'Opponent left';

  @override
  String get opponentDisconnected => 'Your opponent disconnected.';

  @override
  String get backToMenu => 'Back to Menu';

  @override
  String get leaveGame => 'Leave game?';

  @override
  String get leaveGameWarning => 'The room will be deleted for both players.';

  @override
  String get stay => 'Stay';

  @override
  String get leave => 'Leave';

  @override
  String get welcome => 'Welcome!';

  @override
  String get setupProfileSubtitle => 'Set up your profile to get started.';

  @override
  String get yourName => 'YOUR NAME';

  @override
  String get enterUsername => 'Enter your username';

  @override
  String get chooseYourAvatar => 'CHOOSE YOUR AVATAR';

  @override
  String get getStarted => 'Get Started';

  @override
  String get editProfile => 'EDIT PROFILE';

  @override
  String get tapToChangeAvatar => 'Tap to change avatar';

  @override
  String get username => 'USERNAME';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get chooseAvatar => 'Choose Avatar';

  @override
  String get profileSaved => 'Profile saved!';

  @override
  String get historyEmpty =>
      'No matches yet.\nFinished games will show up here.';

  @override
  String get resultWin => 'Victory';

  @override
  String get resultLoss => 'Defeat';

  @override
  String get resultDraw => 'Draw';

  @override
  String wonBy(String name) {
    return '$name won';
  }

  @override
  String vsOpponent(String name) {
    return 'vs $name';
  }

  @override
  String get onlineLabel => 'Online';
}
