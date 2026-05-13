import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('ko'),
    Locale('zh')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Kiddo Play'**
  String get appTitle;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Kiddo Playland'**
  String get homeTitle;

  /// No description provided for @homeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Let\'s learn and play together today!'**
  String get homeSubtitle;

  /// No description provided for @homeStartGame.
  ///
  /// In en, this message translates to:
  /// **'Start Game'**
  String get homeStartGame;

  /// No description provided for @homeChooseGame.
  ///
  /// In en, this message translates to:
  /// **'Choose Game'**
  String get homeChooseGame;

  /// No description provided for @homeParentEntry.
  ///
  /// In en, this message translates to:
  /// **'Parent Center'**
  String get homeParentEntry;

  /// No description provided for @homeParentComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Parent entry is coming soon.'**
  String get homeParentComingSoon;

  /// No description provided for @homeWelcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Let\'s discover something new today!'**
  String get homeWelcomeSubtitle;

  /// No description provided for @homeGreeting.
  ///
  /// In en, this message translates to:
  /// **'{name}, let\'s learn carefully today!'**
  String homeGreeting(String name);

  /// No description provided for @homeWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Hello, {name}! 👋'**
  String homeWelcomeTitle(String name);

  /// No description provided for @homeParentProtected.
  ///
  /// In en, this message translates to:
  /// **'PIN Protected'**
  String get homeParentProtected;

  /// No description provided for @splashSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Bright minds, happy growth'**
  String get splashSubtitle;

  /// No description provided for @gameSelectTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a Game'**
  String get gameSelectTitle;

  /// No description provided for @gameSelectSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Finish the previous game to unlock the next one!'**
  String get gameSelectSubtitle;

  /// No description provided for @gameSelectUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Unlocked'**
  String get gameSelectUnlocked;

  /// No description provided for @gameSelectUnlockSoon.
  ///
  /// In en, this message translates to:
  /// **'Unlocking Soon'**
  String get gameSelectUnlockSoon;

  /// No description provided for @gameSelectLocked.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get gameSelectLocked;

  /// No description provided for @gameSelectLockedDescription.
  ///
  /// In en, this message translates to:
  /// **'Finish the previous game to unlock this one!'**
  String get gameSelectLockedDescription;

  /// No description provided for @gameSelectLockedHint.
  ///
  /// In en, this message translates to:
  /// **'Complete the previous game first to unlock this stage!'**
  String get gameSelectLockedHint;

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

  /// No description provided for @difficultyEasySummary.
  ///
  /// In en, this message translates to:
  /// **'2 choices · 3 rounds'**
  String get difficultyEasySummary;

  /// No description provided for @difficultyMediumSummary.
  ///
  /// In en, this message translates to:
  /// **'4 choices · 5 rounds'**
  String get difficultyMediumSummary;

  /// No description provided for @difficultyHardSummary.
  ///
  /// In en, this message translates to:
  /// **'4 choices · 7 rounds'**
  String get difficultyHardSummary;

  /// No description provided for @difficultyEasyDescription.
  ///
  /// In en, this message translates to:
  /// **'Gentle and fun for new learners!'**
  String get difficultyEasyDescription;

  /// No description provided for @difficultyMediumDescription.
  ///
  /// In en, this message translates to:
  /// **'A balanced challenge for today!'**
  String get difficultyMediumDescription;

  /// No description provided for @difficultyHardDescription.
  ///
  /// In en, this message translates to:
  /// **'A bigger challenge for little masters!'**
  String get difficultyHardDescription;

  /// No description provided for @difficultySelectTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose Difficulty'**
  String get difficultySelectTitle;

  /// No description provided for @difficultySelectSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pick the challenge that fits best!'**
  String get difficultySelectSubtitle;

  /// No description provided for @difficultySelectHint.
  ///
  /// In en, this message translates to:
  /// **'Every first-try correct answer earns 1 star. Higher difficulty gives more chances to shine!'**
  String get difficultySelectHint;

  /// No description provided for @difficultySelectLockedDescription.
  ///
  /// In en, this message translates to:
  /// **'Finish the previous difficulty to unlock this one!'**
  String get difficultySelectLockedDescription;

  /// No description provided for @difficultySelectLockedHint.
  ///
  /// In en, this message translates to:
  /// **'Complete the previous difficulty first, then come back for this challenge!'**
  String get difficultySelectLockedHint;

  /// No description provided for @difficultyOptionCountSuffix.
  ///
  /// In en, this message translates to:
  /// **' choices'**
  String get difficultyOptionCountSuffix;

  /// No description provided for @difficultyRoundCountSuffix.
  ///
  /// In en, this message translates to:
  /// **' rounds'**
  String get difficultyRoundCountSuffix;

  /// No description provided for @gameColorMatchTitle.
  ///
  /// In en, this message translates to:
  /// **'Color Match'**
  String get gameColorMatchTitle;

  /// No description provided for @gameColorMatchDescription.
  ///
  /// In en, this message translates to:
  /// **'Learn colors and find the matching one!'**
  String get gameColorMatchDescription;

  /// No description provided for @gameNumberTitle.
  ///
  /// In en, this message translates to:
  /// **'Number Fun'**
  String get gameNumberTitle;

  /// No description provided for @gameNumberDescription.
  ///
  /// In en, this message translates to:
  /// **'Count carefully and choose the right number!'**
  String get gameNumberDescription;

  /// No description provided for @gameShapeTitle.
  ///
  /// In en, this message translates to:
  /// **'Shape Match'**
  String get gameShapeTitle;

  /// No description provided for @gameShapeDescription.
  ///
  /// In en, this message translates to:
  /// **'Spot circles, triangles, stars and more!'**
  String get gameShapeDescription;

  /// No description provided for @gameAnimalTitle.
  ///
  /// In en, this message translates to:
  /// **'Animal Sounds'**
  String get gameAnimalTitle;

  /// No description provided for @gameAnimalDescription.
  ///
  /// In en, this message translates to:
  /// **'Listen carefully and guess the animal!'**
  String get gameAnimalDescription;

  /// No description provided for @gamePuzzleTitle.
  ///
  /// In en, this message translates to:
  /// **'Simple Puzzle'**
  String get gamePuzzleTitle;

  /// No description provided for @gamePuzzleDescription.
  ///
  /// In en, this message translates to:
  /// **'Place the pieces in the right spot to finish the picture!'**
  String get gamePuzzleDescription;

  /// No description provided for @roundCounter.
  ///
  /// In en, this message translates to:
  /// **'Round {round} / {total}'**
  String roundCounter(int round, int total);

  /// No description provided for @puzzleRoundCounter.
  ///
  /// In en, this message translates to:
  /// **'Level {round} / {total}'**
  String puzzleRoundCounter(int round, int total);

  /// No description provided for @colorMatchPrompt.
  ///
  /// In en, this message translates to:
  /// **'Can you find this color?'**
  String get colorMatchPrompt;

  /// No description provided for @feedbackCorrect.
  ///
  /// In en, this message translates to:
  /// **'Amazing! You got it!'**
  String get feedbackCorrect;

  /// No description provided for @feedbackTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again, you can do it!'**
  String get feedbackTryAgain;

  /// No description provided for @pauseStatus.
  ///
  /// In en, this message translates to:
  /// **'Game paused'**
  String get pauseStatus;

  /// No description provided for @pauseContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue Game'**
  String get pauseContinue;

  /// No description provided for @pauseRestart.
  ///
  /// In en, this message translates to:
  /// **'Restart'**
  String get pauseRestart;

  /// No description provided for @pauseQuit.
  ///
  /// In en, this message translates to:
  /// **'Quit to Game List'**
  String get pauseQuit;

  /// No description provided for @pauseTapOutsideHint.
  ///
  /// In en, this message translates to:
  /// **'Tap outside the dialog to continue'**
  String get pauseTapOutsideHint;

  /// No description provided for @soundOnTooltip.
  ///
  /// In en, this message translates to:
  /// **'Turn sound on'**
  String get soundOnTooltip;

  /// No description provided for @soundOffTooltip.
  ///
  /// In en, this message translates to:
  /// **'Turn sound off'**
  String get soundOffTooltip;

  /// No description provided for @numberPrompt.
  ///
  /// In en, this message translates to:
  /// **'How many do you see?'**
  String get numberPrompt;

  /// No description provided for @numberCorrect.
  ///
  /// In en, this message translates to:
  /// **'Great counting! That\'s right!'**
  String get numberCorrect;

  /// No description provided for @numberWrong.
  ///
  /// In en, this message translates to:
  /// **'Count again carefully!'**
  String get numberWrong;

  /// No description provided for @shapePrompt.
  ///
  /// In en, this message translates to:
  /// **'What shape is this?'**
  String get shapePrompt;

  /// No description provided for @shapePromptHard.
  ///
  /// In en, this message translates to:
  /// **'Can you name this shape without a hint?'**
  String get shapePromptHard;

  /// No description provided for @shapeCorrect.
  ///
  /// In en, this message translates to:
  /// **'You found the shape! Great job!'**
  String get shapeCorrect;

  /// No description provided for @shapeWrong.
  ///
  /// In en, this message translates to:
  /// **'Almost there, try another one!'**
  String get shapeWrong;

  /// No description provided for @shapeHardModeHint.
  ///
  /// In en, this message translates to:
  /// **'no name hint'**
  String get shapeHardModeHint;

  /// No description provided for @animalPrompt.
  ///
  /// In en, this message translates to:
  /// **'Listen to the sound. Who is it?'**
  String get animalPrompt;

  /// No description provided for @animalPromptHard.
  ///
  /// In en, this message translates to:
  /// **'Listen once and guess the animal!'**
  String get animalPromptHard;

  /// No description provided for @animalPlaySound.
  ///
  /// In en, this message translates to:
  /// **'Play Sound'**
  String get animalPlaySound;

  /// No description provided for @animalReplay.
  ///
  /// In en, this message translates to:
  /// **'Play Again'**
  String get animalReplay;

  /// No description provided for @animalReplayBlocked.
  ///
  /// In en, this message translates to:
  /// **'Hard mode: you can only hear it once!'**
  String get animalReplayBlocked;

  /// No description provided for @animalCorrect.
  ///
  /// In en, this message translates to:
  /// **'You guessed it right! Brilliant!'**
  String get animalCorrect;

  /// No description provided for @animalWrong.
  ///
  /// In en, this message translates to:
  /// **'Listen again in your mind and try once more!'**
  String get animalWrong;

  /// No description provided for @animalHardModeHint.
  ///
  /// In en, this message translates to:
  /// **'one listen only'**
  String get animalHardModeHint;

  /// No description provided for @puzzleReference.
  ///
  /// In en, this message translates to:
  /// **'Reference'**
  String get puzzleReference;

  /// No description provided for @puzzlePrompt.
  ///
  /// In en, this message translates to:
  /// **'Place each piece where it belongs.'**
  String get puzzlePrompt;

  /// No description provided for @puzzlePromptHard.
  ///
  /// In en, this message translates to:
  /// **'Match the reference picture without position hints.'**
  String get puzzlePromptHard;

  /// No description provided for @puzzlePieceSelected.
  ///
  /// In en, this message translates to:
  /// **'Piece selected, tap a slot to place it'**
  String get puzzlePieceSelected;

  /// No description provided for @puzzleSlotLabel.
  ///
  /// In en, this message translates to:
  /// **'Slot {slot}'**
  String puzzleSlotLabel(int slot);

  /// No description provided for @puzzleTrayTitle.
  ///
  /// In en, this message translates to:
  /// **'Piece tray — tap a piece, then tap a slot:'**
  String get puzzleTrayTitle;

  /// No description provided for @puzzleHardModeHint.
  ///
  /// In en, this message translates to:
  /// **'no slot hints'**
  String get puzzleHardModeHint;

  /// No description provided for @puzzleCorrect.
  ///
  /// In en, this message translates to:
  /// **'Puzzle complete! Fantastic!'**
  String get puzzleCorrect;

  /// No description provided for @puzzleWrong.
  ///
  /// In en, this message translates to:
  /// **'That piece doesn\'t fit there. Try another spot!'**
  String get puzzleWrong;

  /// No description provided for @puzzleSelectHint.
  ///
  /// In en, this message translates to:
  /// **'Pick a piece first, then tap a slot.'**
  String get puzzleSelectHint;

  /// No description provided for @puzzleTapSlotHint.
  ///
  /// In en, this message translates to:
  /// **'Great, now tap the matching slot.'**
  String get puzzleTapSlotHint;

  /// No description provided for @rewardEncouragement1.
  ///
  /// In en, this message translates to:
  /// **'Amazing work!'**
  String get rewardEncouragement1;

  /// No description provided for @rewardEncouragement2.
  ///
  /// In en, this message translates to:
  /// **'You were awesome!'**
  String get rewardEncouragement2;

  /// No description provided for @rewardEncouragement3.
  ///
  /// In en, this message translates to:
  /// **'Super star performance!'**
  String get rewardEncouragement3;

  /// No description provided for @rewardEncouragement4.
  ///
  /// In en, this message translates to:
  /// **'Little genius at work!'**
  String get rewardEncouragement4;

  /// No description provided for @rewardEncouragement5.
  ///
  /// In en, this message translates to:
  /// **'You are doing great!'**
  String get rewardEncouragement5;

  /// No description provided for @rewardCompleted.
  ///
  /// In en, this message translates to:
  /// **'You finished {gameName}!'**
  String rewardCompleted(String gameName);

  /// No description provided for @rewardDifficultyLabel.
  ///
  /// In en, this message translates to:
  /// **'Difficulty: {difficulty}'**
  String rewardDifficultyLabel(String difficulty);

  /// No description provided for @rewardStarsResult.
  ///
  /// In en, this message translates to:
  /// **'You earned {earned} / {total} stars!'**
  String rewardStarsResult(int earned, int total);

  /// No description provided for @rewardUnlockedTitle.
  ///
  /// In en, this message translates to:
  /// **'New game unlocked!'**
  String get rewardUnlockedTitle;

  /// No description provided for @rewardUnlockedDescription.
  ///
  /// In en, this message translates to:
  /// **'{emoji} {gameName} is ready for your next challenge!'**
  String rewardUnlockedDescription(String emoji, String gameName);

  /// No description provided for @rewardPlayAgain.
  ///
  /// In en, this message translates to:
  /// **'Play Again'**
  String get rewardPlayAgain;

  /// No description provided for @rewardTryOtherDifficulty.
  ///
  /// In en, this message translates to:
  /// **'Try Another Difficulty'**
  String get rewardTryOtherDifficulty;

  /// No description provided for @rewardChooseOtherGame.
  ///
  /// In en, this message translates to:
  /// **'Choose Another Game'**
  String get rewardChooseOtherGame;

  /// No description provided for @rewardBackHome.
  ///
  /// In en, this message translates to:
  /// **'Back Home'**
  String get rewardBackHome;

  /// No description provided for @parentDashboardHeaderTag.
  ///
  /// In en, this message translates to:
  /// **'PARENT CENTER'**
  String get parentDashboardHeaderTag;

  /// No description provided for @parentDashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Parent Center 👨‍👩‍👧'**
  String get parentDashboardTitle;

  /// No description provided for @parentTabOverview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get parentTabOverview;

  /// No description provided for @parentTabProgress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get parentTabProgress;

  /// No description provided for @parentTabSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get parentTabSettings;

  /// No description provided for @parentOverviewStars.
  ///
  /// In en, this message translates to:
  /// **'Total Stars'**
  String get parentOverviewStars;

  /// No description provided for @parentOverviewUnlockedGames.
  ///
  /// In en, this message translates to:
  /// **'Unlocked Games'**
  String get parentOverviewUnlockedGames;

  /// No description provided for @parentOverviewPlayed.
  ///
  /// In en, this message translates to:
  /// **'Total Plays'**
  String get parentOverviewPlayed;

  /// No description provided for @parentOverviewTodayStars.
  ///
  /// In en, this message translates to:
  /// **'Stars Today'**
  String get parentOverviewTodayStars;

  /// No description provided for @parentOverviewProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Little Learner'**
  String get parentOverviewProfileTitle;

  /// No description provided for @parentOverviewTotalStars.
  ///
  /// In en, this message translates to:
  /// **'{count} stars earned in total'**
  String parentOverviewTotalStars(int count);

  /// No description provided for @parentOverviewRecentTitle.
  ///
  /// In en, this message translates to:
  /// **'📋 Recent Activity'**
  String get parentOverviewRecentTitle;

  /// No description provided for @parentOverviewNoActivity.
  ///
  /// In en, this message translates to:
  /// **'No play history yet'**
  String get parentOverviewNoActivity;

  /// No description provided for @parentProgressSummary.
  ///
  /// In en, this message translates to:
  /// **'{unlocked} of {total} games unlocked'**
  String parentProgressSummary(int total, int unlocked);

  /// No description provided for @parentProgressUnlocked.
  ///
  /// In en, this message translates to:
  /// **'🔓 Unlocked'**
  String get parentProgressUnlocked;

  /// No description provided for @parentProgressLocked.
  ///
  /// In en, this message translates to:
  /// **'🔒 Locked'**
  String get parentProgressLocked;

  /// No description provided for @parentProgressNotStarted.
  ///
  /// In en, this message translates to:
  /// **'Not played yet'**
  String get parentProgressNotStarted;

  /// No description provided for @parentProgressLockedHint.
  ///
  /// In en, this message translates to:
  /// **'Finish the previous game to unlock this one'**
  String get parentProgressLockedHint;

  /// No description provided for @parentProgressPlayedCount.
  ///
  /// In en, this message translates to:
  /// **'Played {count} times'**
  String parentProgressPlayedCount(int count);

  /// No description provided for @parentProgressDifficultyTag.
  ///
  /// In en, this message translates to:
  /// **'Recent: {difficulty}'**
  String parentProgressDifficultyTag(String difficulty);

  /// No description provided for @parentProgressUnknownDifficulty.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get parentProgressUnknownDifficulty;

  /// No description provided for @parentProgressBestRate.
  ///
  /// In en, this message translates to:
  /// **'Best star rate'**
  String get parentProgressBestRate;

  /// No description provided for @parentProgressLastPlayed.
  ///
  /// In en, this message translates to:
  /// **'📅 Last played: {time}'**
  String parentProgressLastPlayed(String time);

  /// No description provided for @parentSettingsProfileSection.
  ///
  /// In en, this message translates to:
  /// **'👶 Child Profile'**
  String get parentSettingsProfileSection;

  /// No description provided for @parentSettingsAvatarTitle.
  ///
  /// In en, this message translates to:
  /// **'Avatar'**
  String get parentSettingsAvatarTitle;

  /// No description provided for @parentSettingsAvatarSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap to change the avatar'**
  String get parentSettingsAvatarSubtitle;

  /// No description provided for @parentSettingsNameHint.
  ///
  /// In en, this message translates to:
  /// **'Child nickname'**
  String get parentSettingsNameHint;

  /// No description provided for @parentSettingsSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get parentSettingsSave;

  /// No description provided for @parentSettingsAppSection.
  ///
  /// In en, this message translates to:
  /// **'⚙️ App Settings'**
  String get parentSettingsAppSection;

  /// No description provided for @parentSettingsSoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Game Sound'**
  String get parentSettingsSoundTitle;

  /// No description provided for @parentSettingsSoundOn.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get parentSettingsSoundOn;

  /// No description provided for @parentSettingsSoundOff.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get parentSettingsSoundOff;

  /// No description provided for @parentSettingsSecuritySection.
  ///
  /// In en, this message translates to:
  /// **'🔒 Security'**
  String get parentSettingsSecuritySection;

  /// No description provided for @parentSettingsChangePinTitle.
  ///
  /// In en, this message translates to:
  /// **'Change PIN'**
  String get parentSettingsChangePinTitle;

  /// No description provided for @parentSettingsChangePinSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Update the 4-digit parent PIN'**
  String get parentSettingsChangePinSubtitle;

  /// No description provided for @parentSettingsDangerSection.
  ///
  /// In en, this message translates to:
  /// **'⚠️ Danger Zone'**
  String get parentSettingsDangerSection;

  /// No description provided for @parentSettingsResetWarning.
  ///
  /// In en, this message translates to:
  /// **'Resetting will clear all stars, play records, and unlock progress. This cannot be undone.'**
  String get parentSettingsResetWarning;

  /// No description provided for @parentSettingsResetButton.
  ///
  /// In en, this message translates to:
  /// **'Reset All Learning Progress'**
  String get parentSettingsResetButton;

  /// No description provided for @parentSettingsResetDone.
  ///
  /// In en, this message translates to:
  /// **'Reset completed!'**
  String get parentSettingsResetDone;

  /// No description provided for @parentSettingsResetConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset everything?'**
  String get parentSettingsResetConfirmTitle;

  /// No description provided for @parentSettingsResetConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This will remove all stars, play history, and unlocked game progress. This action cannot be undone.'**
  String get parentSettingsResetConfirmBody;

  /// No description provided for @parentSettingsCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get parentSettingsCancel;

  /// No description provided for @parentSettingsConfirmReset.
  ///
  /// In en, this message translates to:
  /// **'Confirm Reset'**
  String get parentSettingsConfirmReset;

  /// No description provided for @parentTimeToday.
  ///
  /// In en, this message translates to:
  /// **'Today {time}'**
  String parentTimeToday(String time);

  /// No description provided for @parentTimeYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday {time}'**
  String parentTimeYesterday(String time);

  /// No description provided for @parentTimeDate.
  ///
  /// In en, this message translates to:
  /// **'{month}/{day} {time}'**
  String parentTimeDate(int month, int day, String time);

  /// No description provided for @parentPinErrorWrong.
  ///
  /// In en, this message translates to:
  /// **'Incorrect PIN. Please try again.'**
  String get parentPinErrorWrong;

  /// No description provided for @parentPinErrorMismatch.
  ///
  /// In en, this message translates to:
  /// **'The two PIN entries did not match. Please set it again.'**
  String get parentPinErrorMismatch;

  /// No description provided for @parentPinTitleVerify.
  ///
  /// In en, this message translates to:
  /// **'Parent Verification'**
  String get parentPinTitleVerify;

  /// No description provided for @parentPinTitleSetup.
  ///
  /// In en, this message translates to:
  /// **'Set a PIN'**
  String get parentPinTitleSetup;

  /// No description provided for @parentPinTitleConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm PIN'**
  String get parentPinTitleConfirm;

  /// No description provided for @parentPinTitleChange.
  ///
  /// In en, this message translates to:
  /// **'Set New PIN'**
  String get parentPinTitleChange;

  /// No description provided for @parentPinTitleChangeConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm New PIN'**
  String get parentPinTitleChangeConfirm;

  /// No description provided for @parentPinSubtitleVerify.
  ///
  /// In en, this message translates to:
  /// **'Enter the 4-digit PIN to open the parent center'**
  String get parentPinSubtitleVerify;

  /// No description provided for @parentPinSubtitleSetup.
  ///
  /// In en, this message translates to:
  /// **'Create a 4-digit PIN for the parent center'**
  String get parentPinSubtitleSetup;

  /// No description provided for @parentPinSubtitleConfirm.
  ///
  /// In en, this message translates to:
  /// **'Enter the same 4-digit PIN again'**
  String get parentPinSubtitleConfirm;

  /// No description provided for @parentPinSubtitleChange.
  ///
  /// In en, this message translates to:
  /// **'Enter your new 4-digit PIN'**
  String get parentPinSubtitleChange;

  /// No description provided for @parentPinSubtitleChangeConfirm.
  ///
  /// In en, this message translates to:
  /// **'Enter the same new PIN again'**
  String get parentPinSubtitleChangeConfirm;

  /// No description provided for @parentPinSuccess.
  ///
  /// In en, this message translates to:
  /// **'✅ Verified. Opening the parent center…'**
  String get parentPinSuccess;

  /// No description provided for @parentPinDefaultHint.
  ///
  /// In en, this message translates to:
  /// **'Forgot it? The default PIN is {pin}'**
  String parentPinDefaultHint(String pin);

  /// No description provided for @parentPinSetupHint.
  ///
  /// In en, this message translates to:
  /// **'💡 This PIN helps prevent children from entering the parent center by mistake. It is meant as a simple protection step.'**
  String get parentPinSetupHint;
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
      <String>['en', 'ko', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ko':
      return AppLocalizationsKo();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
