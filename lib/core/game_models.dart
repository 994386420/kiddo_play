import 'package:flutter/material.dart';

import '../app/router.dart';
import '../l10n/app_localizations.dart';

enum GameId {
  colorMatch,
  numberGame,
  shapeMatch,
  animalSound,
  simplePuzzle,
}

enum GameDifficulty {
  easy,
  medium,
  hard,
}

class DifficultyConfig {
  const DifficultyConfig({
    required this.rounds,
    required this.optionCount,
    required this.icon,
    required this.accentBackground,
    required this.accentText,
    required this.borderColor,
  });

  final int rounds;
  final int optionCount;
  final String icon;
  final Color accentBackground;
  final Color accentText;
  final Color borderColor;
}

const orderedGameIds = <GameId>[
  GameId.colorMatch,
  GameId.numberGame,
  GameId.shapeMatch,
  GameId.animalSound,
  GameId.simplePuzzle,
];

extension GameDifficultyX on GameDifficulty {
  DifficultyConfig get config {
    switch (this) {
      case GameDifficulty.easy:
        return const DifficultyConfig(
          rounds: 3,
          optionCount: 2,
          icon: '🌱',
          accentBackground: Color(0xFFE8F5E9),
          accentText: Color(0xFF2E7D32),
          borderColor: Color(0xFFA5D6A7),
        );
      case GameDifficulty.medium:
        return const DifficultyConfig(
          rounds: 5,
          optionCount: 4,
          icon: '⭐',
          accentBackground: Color(0xFFFFF9C4),
          accentText: Color(0xFFF57F17),
          borderColor: Color(0xFFFFD54F),
        );
      case GameDifficulty.hard:
        return const DifficultyConfig(
          rounds: 7,
          optionCount: 4,
          icon: '🔥',
          accentBackground: Color(0xFFFFF3E0),
          accentText: Color(0xFFE64A19),
          borderColor: Color(0xFFFFAB91),
        );
    }
  }

  String get storageKey {
    switch (this) {
      case GameDifficulty.easy:
        return 'easy';
      case GameDifficulty.medium:
        return 'medium';
      case GameDifficulty.hard:
        return 'hard';
    }
  }

  String get badgeEmoji {
    return config.icon;
  }

  String label(AppLocalizations l10n) {
    switch (this) {
      case GameDifficulty.easy:
        return l10n.difficultyEasy;
      case GameDifficulty.medium:
        return l10n.difficultyMedium;
      case GameDifficulty.hard:
        return l10n.difficultyHard;
    }
  }

  String summary(AppLocalizations l10n) {
    switch (this) {
      case GameDifficulty.easy:
        return l10n.difficultyEasySummary;
      case GameDifficulty.medium:
        return l10n.difficultyMediumSummary;
      case GameDifficulty.hard:
        return l10n.difficultyHardSummary;
    }
  }

  String description(AppLocalizations l10n) {
    switch (this) {
      case GameDifficulty.easy:
        return l10n.difficultyEasyDescription;
      case GameDifficulty.medium:
        return l10n.difficultyMediumDescription;
      case GameDifficulty.hard:
        return l10n.difficultyHardDescription;
    }
  }
}

extension GameIdX on GameId {
  String get storageKey {
    switch (this) {
      case GameId.colorMatch:
        return 'color-match';
      case GameId.numberGame:
        return 'number-game';
      case GameId.shapeMatch:
        return 'shape-match';
      case GameId.animalSound:
        return 'animal-sound';
      case GameId.simplePuzzle:
        return 'simple-puzzle';
    }
  }

  String get routeName {
    switch (this) {
      case GameId.colorMatch:
        return AppRoutes.colorMatch;
      case GameId.numberGame:
        return AppRoutes.numberGame;
      case GameId.shapeMatch:
        return AppRoutes.shapeMatch;
      case GameId.animalSound:
        return AppRoutes.animalSound;
      case GameId.simplePuzzle:
        return AppRoutes.simplePuzzle;
    }
  }

  String get emoji {
    switch (this) {
      case GameId.colorMatch:
        return '🎨';
      case GameId.numberGame:
        return '🔢';
      case GameId.shapeMatch:
        return '⬡';
      case GameId.animalSound:
        return '🐾';
      case GameId.simplePuzzle:
        return '🧩';
    }
  }

  Gradient get gradient {
    switch (this) {
      case GameId.colorMatch:
        return const LinearGradient(
          colors: [Color(0xFF4FC3F7), Color(0xFF1976D2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case GameId.numberGame:
        return const LinearGradient(
          colors: [Color(0xFFA5D6A7), Color(0xFF388E3C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case GameId.shapeMatch:
        return const LinearGradient(
          colors: [Color(0xFFFFD54F), Color(0xFFF4A200)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case GameId.animalSound:
        return const LinearGradient(
          colors: [Color(0xFFFFAB91), Color(0xFFE64A19)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case GameId.simplePuzzle:
        return const LinearGradient(
          colors: [Color(0xFFCE93D8), Color(0xFF7B1FA2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  Color get borderColor {
    switch (this) {
      case GameId.colorMatch:
        return const Color(0xFF0D47A1);
      case GameId.numberGame:
        return const Color(0xFF1B5E20);
      case GameId.shapeMatch:
        return const Color(0xFFB77B00);
      case GameId.animalSound:
        return const Color(0xFFBF360C);
      case GameId.simplePuzzle:
        return const Color(0xFF4A148C);
    }
  }

  String title(AppLocalizations l10n) {
    switch (this) {
      case GameId.colorMatch:
        return l10n.gameColorMatchTitle;
      case GameId.numberGame:
        return l10n.gameNumberTitle;
      case GameId.shapeMatch:
        return l10n.gameShapeTitle;
      case GameId.animalSound:
        return l10n.gameAnimalTitle;
      case GameId.simplePuzzle:
        return l10n.gamePuzzleTitle;
    }
  }

  String description(AppLocalizations l10n) {
    switch (this) {
      case GameId.colorMatch:
        return l10n.gameColorMatchDescription;
      case GameId.numberGame:
        return l10n.gameNumberDescription;
      case GameId.shapeMatch:
        return l10n.gameShapeDescription;
      case GameId.animalSound:
        return l10n.gameAnimalDescription;
      case GameId.simplePuzzle:
        return l10n.gamePuzzleDescription;
    }
  }
}

GameId? nextGameId(GameId gameId) {
  final index = orderedGameIds.indexOf(gameId);
  if (index == -1 || index == orderedGameIds.length - 1) {
    return null;
  }

  return orderedGameIds[index + 1];
}

GameId gameIdFromStorage(String value) {
  return orderedGameIds.firstWhere(
    (gameId) => gameId.storageKey == value,
    orElse: () => GameId.colorMatch,
  );
}
