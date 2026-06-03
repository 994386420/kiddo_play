import 'package:flutter_test/flutter_test.dart';

import 'package:kiddo_play/core/app_controllers.dart';
import 'package:kiddo_play/core/game_models.dart';
import 'package:kiddo_play/core/progress_insights.dart';

void main() {
  test('new game achievements unlock from activity history', () {
    final now = DateTime(2026, 6, 3, 10);
    final activityLog = [
      for (final gameId in orderedGameIds)
        ActivityEntry(
          gameId: gameId,
          stars: 1,
          total: 1,
          difficulty: GameDifficulty.easy,
          timestamp: now,
        ),
    ];

    final unlocked = deriveUnlockedAchievements(
      totalStars: 8,
      unlockedGames: orderedGameIds,
      gameStats: {
        for (final gameId in orderedGameIds)
          gameId: ParentGameStats.initial(totalRounds: 3).copyWith(
            played: 1,
            bestStars: 1,
            bestTotal: 1,
          ),
      },
      activityLog: activityLog,
    );

    expect(unlocked, contains(KidAchievementId.findDifferentStarter));
    expect(unlocked, contains(KidAchievementId.whackMoleStarter));
    expect(unlocked, contains(KidAchievementId.memoryCardStarter));
    expect(unlocked, contains(KidAchievementId.allGamesPlayed));
    expect(unlocked, contains(KidAchievementId.allUnlocked));
  });

  test('new game achievements also unlock for migrated stats-only users', () {
    final unlocked = deriveUnlockedAchievements(
      totalStars: 0,
      unlockedGames: const [GameId.colorMatch],
      gameStats: {
        GameId.findDifferent:
            ParentGameStats.initial(totalRounds: 3).copyWith(played: 2),
        GameId.whackMole:
            ParentGameStats.initial(totalRounds: 3).copyWith(played: 1),
        GameId.memoryCard:
            ParentGameStats.initial(totalRounds: 6).copyWith(played: 1),
      },
      activityLog: const [],
    );

    expect(unlocked, contains(KidAchievementId.findDifferentStarter));
    expect(unlocked, contains(KidAchievementId.whackMoleStarter));
    expect(unlocked, contains(KidAchievementId.memoryCardStarter));
  });
}
