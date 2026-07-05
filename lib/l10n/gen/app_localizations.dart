import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @gameTicTacToe.
  ///
  /// In en, this message translates to:
  /// **'Tic Tac Toe'**
  String get gameTicTacToe;

  /// No description provided for @gameConnectFour.
  ///
  /// In en, this message translates to:
  /// **'Connect Four'**
  String get gameConnectFour;

  /// No description provided for @tttTagline.
  ///
  /// In en, this message translates to:
  /// **'The classic game of strategy.'**
  String get tttTagline;

  /// No description provided for @c4Tagline.
  ///
  /// In en, this message translates to:
  /// **'Connect four in a line.'**
  String get c4Tagline;

  /// No description provided for @hiUser.
  ///
  /// In en, this message translates to:
  /// **'HI, {name}'**
  String hiUser(String name);

  /// No description provided for @playerVsPlayer.
  ///
  /// In en, this message translates to:
  /// **'Player vs Player'**
  String get playerVsPlayer;

  /// No description provided for @playerVsAi.
  ///
  /// In en, this message translates to:
  /// **'Player vs AI'**
  String get playerVsAi;

  /// No description provided for @onlineMultiplayer.
  ///
  /// In en, this message translates to:
  /// **'Online Multiplayer'**
  String get onlineMultiplayer;

  /// No description provided for @badgeNew.
  ///
  /// In en, this message translates to:
  /// **'NEW'**
  String get badgeNew;

  /// No description provided for @aiDifficultyLevel.
  ///
  /// In en, this message translates to:
  /// **'AI DIFFICULTY LEVEL'**
  String get aiDifficultyLevel;

  /// No description provided for @difficultyEasy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get difficultyEasy;

  /// No description provided for @difficultyMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get difficultyMedium;

  /// No description provided for @difficultyHard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get difficultyHard;

  /// No description provided for @playNow.
  ///
  /// In en, this message translates to:
  /// **'PLAY NOW'**
  String get playNow;

  /// No description provided for @navPlay.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get navPlay;

  /// No description provided for @navHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get navHistory;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @restartGame.
  ///
  /// In en, this message translates to:
  /// **'Restart Game'**
  String get restartGame;

  /// No description provided for @playAgain.
  ///
  /// In en, this message translates to:
  /// **'Play Again'**
  String get playAgain;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @playerWins.
  ///
  /// In en, this message translates to:
  /// **'{name} Wins!'**
  String playerWins(String name);

  /// No description provided for @itsADraw.
  ///
  /// In en, this message translates to:
  /// **'It\'s a Draw!'**
  String get itsADraw;

  /// No description provided for @yourTurn.
  ///
  /// In en, this message translates to:
  /// **'Your turn!'**
  String get yourTurn;

  /// No description provided for @aiThinking.
  ///
  /// In en, this message translates to:
  /// **'AI thinking...'**
  String get aiThinking;

  /// No description provided for @player2Turn.
  ///
  /// In en, this message translates to:
  /// **'Player 2\'s turn!'**
  String get player2Turn;

  /// No description provided for @opponentTurn.
  ///
  /// In en, this message translates to:
  /// **'Opponent\'s turn...'**
  String get opponentTurn;

  /// No description provided for @labelPlayer1.
  ///
  /// In en, this message translates to:
  /// **'Player 1'**
  String get labelPlayer1;

  /// No description provided for @labelPlayer2.
  ///
  /// In en, this message translates to:
  /// **'Player 2'**
  String get labelPlayer2;

  /// No description provided for @labelAi.
  ///
  /// In en, this message translates to:
  /// **'AI'**
  String get labelAi;

  /// No description provided for @labelOpponent.
  ///
  /// In en, this message translates to:
  /// **'Opponent'**
  String get labelOpponent;

  /// No description provided for @createARoom.
  ///
  /// In en, this message translates to:
  /// **'Create a Room'**
  String get createARoom;

  /// No description provided for @createRoomSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start a new game and share the code with a friend.'**
  String get createRoomSubtitle;

  /// No description provided for @createRoom.
  ///
  /// In en, this message translates to:
  /// **'Create Room'**
  String get createRoom;

  /// No description provided for @orDivider.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get orDivider;

  /// No description provided for @joinARoom.
  ///
  /// In en, this message translates to:
  /// **'Join a Room'**
  String get joinARoom;

  /// No description provided for @joinRoomSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-character code your opponent shared.'**
  String get joinRoomSubtitle;

  /// No description provided for @joinRoom.
  ///
  /// In en, this message translates to:
  /// **'Join Room'**
  String get joinRoom;

  /// No description provided for @invalidCode.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid 6-character code.'**
  String get invalidCode;

  /// No description provided for @roomNotFound.
  ///
  /// In en, this message translates to:
  /// **'Room \"{code}\" not found. Check the code and try again.'**
  String roomNotFound(String code);

  /// No description provided for @roomFull.
  ///
  /// In en, this message translates to:
  /// **'Room \"{code}\" is already full.'**
  String roomFull(String code);

  /// No description provided for @wrongGameMode.
  ///
  /// In en, this message translates to:
  /// **'Wrong game mode'**
  String get wrongGameMode;

  /// No description provided for @wrongGameModeContent.
  ///
  /// In en, this message translates to:
  /// **'Room \"{code}\" is a {roomGame} game, but you have {selectedGame} selected.\n\nGo back to the home screen and select {roomGame} to join this room.'**
  String wrongGameModeContent(
    String code,
    String roomGame,
    String selectedGame,
  );

  /// No description provided for @gotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get gotIt;

  /// No description provided for @onlineGame.
  ///
  /// In en, this message translates to:
  /// **'ONLINE GAME'**
  String get onlineGame;

  /// No description provided for @shareCode.
  ///
  /// In en, this message translates to:
  /// **'Share this code\nwith your opponent'**
  String get shareCode;

  /// No description provided for @codeCopied.
  ///
  /// In en, this message translates to:
  /// **'Code copied to clipboard!'**
  String get codeCopied;

  /// No description provided for @waitingForOpponent.
  ///
  /// In en, this message translates to:
  /// **'Waiting for opponent...'**
  String get waitingForOpponent;

  /// No description provided for @opponentLeft.
  ///
  /// In en, this message translates to:
  /// **'Opponent left'**
  String get opponentLeft;

  /// No description provided for @opponentDisconnected.
  ///
  /// In en, this message translates to:
  /// **'Your opponent disconnected.'**
  String get opponentDisconnected;

  /// No description provided for @backToMenu.
  ///
  /// In en, this message translates to:
  /// **'Back to Menu'**
  String get backToMenu;

  /// No description provided for @leaveGame.
  ///
  /// In en, this message translates to:
  /// **'Leave game?'**
  String get leaveGame;

  /// No description provided for @leaveGameWarning.
  ///
  /// In en, this message translates to:
  /// **'The room will be deleted for both players.'**
  String get leaveGameWarning;

  /// No description provided for @stay.
  ///
  /// In en, this message translates to:
  /// **'Stay'**
  String get stay;

  /// No description provided for @leave.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get leave;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome!'**
  String get welcome;

  /// No description provided for @setupProfileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Set up your profile to get started.'**
  String get setupProfileSubtitle;

  /// No description provided for @yourName.
  ///
  /// In en, this message translates to:
  /// **'YOUR NAME'**
  String get yourName;

  /// No description provided for @enterUsername.
  ///
  /// In en, this message translates to:
  /// **'Enter your username'**
  String get enterUsername;

  /// No description provided for @chooseYourAvatar.
  ///
  /// In en, this message translates to:
  /// **'CHOOSE YOUR AVATAR'**
  String get chooseYourAvatar;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'EDIT PROFILE'**
  String get editProfile;

  /// No description provided for @tapToChangeAvatar.
  ///
  /// In en, this message translates to:
  /// **'Tap to change avatar'**
  String get tapToChangeAvatar;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'USERNAME'**
  String get username;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @chooseAvatar.
  ///
  /// In en, this message translates to:
  /// **'Choose Avatar'**
  String get chooseAvatar;

  /// No description provided for @profileSaved.
  ///
  /// In en, this message translates to:
  /// **'Profile saved!'**
  String get profileSaved;

  /// No description provided for @historyEmpty.
  ///
  /// In en, this message translates to:
  /// **'No matches yet.\nFinished games will show up here.'**
  String get historyEmpty;

  /// No description provided for @resultWin.
  ///
  /// In en, this message translates to:
  /// **'Victory'**
  String get resultWin;

  /// No description provided for @resultLoss.
  ///
  /// In en, this message translates to:
  /// **'Defeat'**
  String get resultLoss;

  /// No description provided for @resultDraw.
  ///
  /// In en, this message translates to:
  /// **'Draw'**
  String get resultDraw;

  /// No description provided for @wonBy.
  ///
  /// In en, this message translates to:
  /// **'{name} won'**
  String wonBy(String name);

  /// No description provided for @vsOpponent.
  ///
  /// In en, this message translates to:
  /// **'vs {name}'**
  String vsOpponent(String name);

  /// No description provided for @onlineLabel.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get onlineLabel;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
