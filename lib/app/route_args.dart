import '../core/game_models.dart';

class DifficultyRouteArgs {
  const DifficultyRouteArgs({required this.gameId});

  final GameId gameId;
}

class GameRouteArgs {
  const GameRouteArgs({
    required this.gameId,
    required this.difficulty,
  });

  final GameId gameId;
  final GameDifficulty difficulty;
}

class RewardRouteArgs {
  const RewardRouteArgs({
    required this.gameId,
    required this.difficulty,
    required this.earnedStars,
    required this.totalRounds,
  });

  final GameId gameId;
  final GameDifficulty difficulty;
  final int earnedStars;
  final int totalRounds;
}

class ParentPinRouteArgs {
  const ParentPinRouteArgs({this.changeMode = false});

  final bool changeMode;
}
