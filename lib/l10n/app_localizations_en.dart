// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Kiddo Play';

  @override
  String get homeTitle => 'Kiddo Playland';

  @override
  String get homeSubtitle => 'Let\'s learn and play together today!';

  @override
  String get homeStartGame => 'Start Game';

  @override
  String get homeChooseGame => 'Choose Game';

  @override
  String get homeParentEntry => 'Parent Center';

  @override
  String get homeParentComingSoon => 'Parent entry is coming soon.';

  @override
  String get homeWelcomeSubtitle => 'Let\'s discover something new today!';

  @override
  String homeGreeting(String name) {
    return '$name, let\'s learn carefully today!';
  }

  @override
  String homeWelcomeTitle(String name) {
    return 'Hello, $name! 👋';
  }

  @override
  String get homeParentProtected => 'PIN Protected';

  @override
  String get splashSubtitle => 'Bright minds, happy growth';

  @override
  String get gameSelectTitle => 'Choose a Game';

  @override
  String get gameSelectSubtitle =>
      'Finish the previous game to unlock the next one!';

  @override
  String get gameSelectUnlocked => 'Unlocked';

  @override
  String get gameSelectUnlockSoon => 'Unlocking Soon';

  @override
  String get gameSelectLocked => 'Locked';

  @override
  String get gameSelectLockedDescription =>
      'Finish the previous game to unlock this one!';

  @override
  String get gameSelectLockedHint =>
      'Complete the previous game first to unlock this stage!';

  @override
  String get difficultyEasy => 'Easy';

  @override
  String get difficultyMedium => 'Medium';

  @override
  String get difficultyHard => 'Hard';

  @override
  String get difficultyEasySummary => '2 choices · 3 rounds';

  @override
  String get difficultyMediumSummary => '4 choices · 5 rounds';

  @override
  String get difficultyHardSummary => '4 choices · 7 rounds';

  @override
  String get difficultyEasyDescription => 'Gentle and fun for new learners!';

  @override
  String get difficultyMediumDescription => 'A balanced challenge for today!';

  @override
  String get difficultyHardDescription =>
      'A bigger challenge for little masters!';

  @override
  String get difficultySelectTitle => 'Choose Difficulty';

  @override
  String get difficultySelectSubtitle => 'Pick the challenge that fits best!';

  @override
  String get difficultySelectHint =>
      'Every first-try correct answer earns 1 star. Higher difficulty gives more chances to shine!';

  @override
  String get difficultySelectLockedDescription =>
      'Finish the previous difficulty to unlock this one!';

  @override
  String get difficultySelectLockedHint =>
      'Complete the previous difficulty first, then come back for this challenge!';

  @override
  String get difficultyOptionCountSuffix => ' choices';

  @override
  String get difficultyRoundCountSuffix => ' rounds';

  @override
  String get gameColorMatchTitle => 'Color Match';

  @override
  String get gameColorMatchDescription =>
      'Learn colors and find the matching one!';

  @override
  String get gameNumberTitle => 'Number Fun';

  @override
  String get gameNumberDescription =>
      'Count carefully and choose the right number!';

  @override
  String get gameShapeTitle => 'Shape Match';

  @override
  String get gameShapeDescription => 'Spot circles, triangles, stars and more!';

  @override
  String get gameAnimalTitle => 'Animal Sounds';

  @override
  String get gameAnimalDescription => 'Listen carefully and guess the animal!';

  @override
  String get gamePuzzleTitle => 'Simple Puzzle';

  @override
  String get gamePuzzleDescription =>
      'Place the pieces in the right spot to finish the picture!';

  @override
  String get gameFindDifferentTitle => 'Find Different';

  @override
  String get gameFindDifferentDescription =>
      'Spot the one that looks different and train your eyes!';

  @override
  String get gameWhackMoleTitle => 'Whack-a-Mole';

  @override
  String get gameWhackMoleDescription =>
      'Watch closely and tap the popping mole fast!';

  @override
  String get gameMemoryCardTitle => 'Memory Cards';

  @override
  String get gameMemoryCardDescription =>
      'Remember the cards and flip the matching pair!';

  @override
  String roundCounter(int round, int total) {
    return 'Round $round / $total';
  }

  @override
  String puzzleRoundCounter(int round, int total) {
    return 'Level $round / $total';
  }

  @override
  String get colorMatchPrompt => 'Can you find this color?';

  @override
  String get findDifferentPrompt => 'Find the one that is different';

  @override
  String get memoryCardPrompt => 'Flip two matching cards';

  @override
  String get memoryCardPairsLabel => 'Pairs';

  @override
  String get memoryCardFlipsLabel => 'Flips';

  @override
  String get memoryCardPreviewHint =>
      'Remember the cards now. Matching starts in a moment!';

  @override
  String get whackMolePrompt => 'Tap the mole as soon as it pops up';

  @override
  String get whackMoleHitsLabel => 'Hits';

  @override
  String get whackMoleMissesLabel => 'Misses';

  @override
  String get whackMoleGoalLabel => 'Goal';

  @override
  String get feedbackCorrect => 'Amazing! You got it!';

  @override
  String get feedbackTryAgain => 'Try again, you can do it!';

  @override
  String get pauseStatus => 'Game paused';

  @override
  String get pauseContinue => 'Continue Game';

  @override
  String get pauseRestart => 'Restart';

  @override
  String get pauseQuit => 'Quit to Game List';

  @override
  String get pauseTapOutsideHint => 'Tap outside the dialog to continue';

  @override
  String get soundOnTooltip => 'Turn sound on';

  @override
  String get soundOffTooltip => 'Turn sound off';

  @override
  String get numberPrompt => 'How many do you see?';

  @override
  String get numberCorrect => 'Great counting! That\'s right!';

  @override
  String get numberWrong => 'Count again carefully!';

  @override
  String get shapePrompt => 'What shape is this?';

  @override
  String get shapePromptHard => 'Can you name this shape without a hint?';

  @override
  String get shapeCorrect => 'You found the shape! Great job!';

  @override
  String get shapeWrong => 'Almost there, try another one!';

  @override
  String get shapeHardModeHint => 'no name hint';

  @override
  String get animalPrompt => 'Listen to the sound. Who is it?';

  @override
  String get animalPromptHard => 'Listen once and guess the animal!';

  @override
  String get animalPlaySound => 'Play Sound';

  @override
  String get animalReplay => 'Play Again';

  @override
  String get animalReplayBlocked => 'Hard mode: you can only hear it once!';

  @override
  String get animalCorrect => 'You guessed it right! Brilliant!';

  @override
  String get animalWrong => 'Listen again in your mind and try once more!';

  @override
  String get animalHardModeHint => 'one listen only';

  @override
  String get puzzleReference => 'Reference';

  @override
  String get puzzlePrompt => 'Place each piece where it belongs.';

  @override
  String get puzzlePromptHard =>
      'Match the reference picture without position hints.';

  @override
  String get puzzlePieceSelected => 'Piece selected, tap a slot to place it';

  @override
  String puzzleSlotLabel(int slot) {
    return 'Slot $slot';
  }

  @override
  String get puzzleTrayTitle => 'Piece tray — tap a piece, then tap a slot:';

  @override
  String get puzzleHardModeHint => 'no slot hints';

  @override
  String get puzzleCorrect => 'Puzzle complete! Fantastic!';

  @override
  String get puzzleWrong => 'That piece doesn\'t fit there. Try another spot!';

  @override
  String get puzzleSelectHint => 'Pick a piece first, then tap a slot.';

  @override
  String get puzzleTapSlotHint => 'Great, now tap the matching slot.';

  @override
  String get rewardEncouragement1 => 'Amazing work!';

  @override
  String get rewardEncouragement2 => 'You were awesome!';

  @override
  String get rewardEncouragement3 => 'Super star performance!';

  @override
  String get rewardEncouragement4 => 'Little genius at work!';

  @override
  String get rewardEncouragement5 => 'You are doing great!';

  @override
  String rewardCompleted(String gameName) {
    return 'You finished $gameName!';
  }

  @override
  String rewardDifficultyLabel(String difficulty) {
    return 'Difficulty: $difficulty';
  }

  @override
  String rewardStarsResult(int earned, int total) {
    return 'You earned $earned / $total stars!';
  }

  @override
  String get rewardUnlockedTitle => 'New game unlocked!';

  @override
  String rewardUnlockedDescription(String emoji, String gameName) {
    return '$emoji $gameName is ready for your next challenge!';
  }

  @override
  String get rewardPlayAgain => 'Play Again';

  @override
  String get rewardTryOtherDifficulty => 'Try Another Difficulty';

  @override
  String get rewardChooseOtherGame => 'Choose Another Game';

  @override
  String get rewardBackHome => 'Back Home';

  @override
  String get parentDashboardHeaderTag => 'PARENT CENTER';

  @override
  String get parentDashboardTitle => 'Parent Center 👨‍👩‍👧';

  @override
  String get parentTabOverview => 'Overview';

  @override
  String get parentTabProgress => 'Progress';

  @override
  String get parentTabSettings => 'Settings';

  @override
  String get parentOverviewStars => 'Total Stars';

  @override
  String get parentOverviewUnlockedGames => 'Unlocked Games';

  @override
  String get parentOverviewPlayed => 'Total Plays';

  @override
  String get parentOverviewTodayStars => 'Stars Today';

  @override
  String get parentOverviewProfileTitle => 'Your Little Learner';

  @override
  String parentOverviewTotalStars(int count) {
    return '$count stars earned in total';
  }

  @override
  String get parentOverviewRecentTitle => '📋 Recent Activity';

  @override
  String get parentOverviewNoActivity => 'No play history yet';

  @override
  String parentProgressSummary(int total, int unlocked) {
    return '$unlocked of $total games unlocked';
  }

  @override
  String get parentProgressUnlocked => '🔓 Unlocked';

  @override
  String get parentProgressLocked => '🔒 Locked';

  @override
  String get parentProgressNotStarted => 'Not played yet';

  @override
  String get parentProgressLockedHint =>
      'Finish the previous game to unlock this one';

  @override
  String parentProgressPlayedCount(int count) {
    return 'Played $count times';
  }

  @override
  String parentProgressDifficultyTag(String difficulty) {
    return 'Recent: $difficulty';
  }

  @override
  String get parentProgressUnknownDifficulty => 'Unknown';

  @override
  String get parentProgressBestRate => 'Best star rate';

  @override
  String parentProgressLastPlayed(String time) {
    return '📅 Last played: $time';
  }

  @override
  String get parentSettingsProfileSection => '👶 Child Profile';

  @override
  String get parentSettingsAvatarTitle => 'Avatar';

  @override
  String get parentSettingsAvatarSubtitle => 'Tap to change the avatar';

  @override
  String get parentSettingsNameHint => 'Child nickname';

  @override
  String get parentSettingsSave => 'Save';

  @override
  String get parentSettingsAppSection => '⚙️ App Settings';

  @override
  String get parentSettingsSoundTitle => 'Game Sound';

  @override
  String get parentSettingsSoundOn => 'Enabled';

  @override
  String get parentSettingsSoundOff => 'Disabled';

  @override
  String get parentSettingsSecuritySection => '🔒 Security';

  @override
  String get parentSettingsChangePinTitle => 'Change PIN';

  @override
  String get parentSettingsChangePinSubtitle => 'Update the 4-digit parent PIN';

  @override
  String get parentSettingsDangerSection => '⚠️ Danger Zone';

  @override
  String get parentSettingsResetWarning =>
      'Resetting will clear all stars, play records, and unlock progress. This cannot be undone.';

  @override
  String get parentSettingsResetButton => 'Reset All Learning Progress';

  @override
  String get parentSettingsResetDone => 'Reset completed!';

  @override
  String get parentSettingsResetConfirmTitle => 'Reset everything?';

  @override
  String get parentSettingsResetConfirmBody =>
      'This will remove all stars, play history, and unlocked game progress. This action cannot be undone.';

  @override
  String get parentSettingsCancel => 'Cancel';

  @override
  String get parentSettingsConfirmReset => 'Confirm Reset';

  @override
  String parentTimeToday(String time) {
    return 'Today $time';
  }

  @override
  String parentTimeYesterday(String time) {
    return 'Yesterday $time';
  }

  @override
  String parentTimeDate(int month, int day, String time) {
    return '$month/$day $time';
  }

  @override
  String get parentPinErrorWrong => 'Incorrect PIN. Please try again.';

  @override
  String get parentPinErrorMismatch =>
      'The two PIN entries did not match. Please set it again.';

  @override
  String get parentPinTitleVerify => 'Parent Verification';

  @override
  String get parentPinTitleSetup => 'Set a PIN';

  @override
  String get parentPinTitleConfirm => 'Confirm PIN';

  @override
  String get parentPinTitleChange => 'Set New PIN';

  @override
  String get parentPinTitleChangeConfirm => 'Confirm New PIN';

  @override
  String get parentPinSubtitleVerify =>
      'Enter the 4-digit PIN to open the parent center';

  @override
  String get parentPinSubtitleSetup =>
      'Create a 4-digit PIN for the parent center';

  @override
  String get parentPinSubtitleConfirm => 'Enter the same 4-digit PIN again';

  @override
  String get parentPinSubtitleChange => 'Enter your new 4-digit PIN';

  @override
  String get parentPinSubtitleChangeConfirm => 'Enter the same new PIN again';

  @override
  String get parentPinSuccess => '✅ Verified. Opening the parent center…';

  @override
  String parentPinDefaultHint(String pin) {
    return 'Forgot it? The default PIN is $pin';
  }

  @override
  String get parentPinSetupHint =>
      '💡 This PIN helps prevent children from entering the parent center by mistake. It is meant as a simple protection step.';
}
