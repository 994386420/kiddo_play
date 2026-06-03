import 'dart:collection';

import 'app_controllers.dart';
import 'game_models.dart';

enum KidAchievementId {
  firstGame,
  firstPerfect,
  stars50,
  stars100,
  findDifferentStarter,
  whackMoleStarter,
  memoryCardStarter,
  allGamesPlayed,
  allUnlocked,
  hardPerfect,
  streak7,
}

class KidAchievement {
  const KidAchievement({
    required this.id,
    required this.emoji,
    required this.name,
    required this.description,
    required this.color,
    required this.background,
  });

  final KidAchievementId id;
  final String emoji;
  final String name;
  final String description;
  final int color;
  final int background;
}

final kidAchievements = <KidAchievement>[
  KidAchievement(
    id: KidAchievementId.firstGame,
    emoji: '🎮',
    name: '小玩家',
    description: '完成第一局游戏',
    color: 0xFF1565C0,
    background: 0xFFE3F2FD,
  ),
  KidAchievement(
    id: KidAchievementId.firstPerfect,
    emoji: '🌟',
    name: '首次满星',
    description: '某局游戏全部答对拿满星',
    color: 0xFFF9A825,
    background: 0xFFFFF9C4,
  ),
  KidAchievement(
    id: KidAchievementId.stars50,
    emoji: '⭐',
    name: '积星达人',
    description: '累积获得 50 颗星星',
    color: 0xFFF57F17,
    background: 0xFFFFF8E1,
  ),
  KidAchievement(
    id: KidAchievementId.stars100,
    emoji: '💫',
    name: '百星大师',
    description: '累积获得 100 颗星星',
    color: 0xFF7B1FA2,
    background: 0xFFF3E5F5,
  ),
  KidAchievement(
    id: KidAchievementId.findDifferentStarter,
    emoji: '🔍',
    name: '火眼金睛',
    description: '完成一局找不同',
    color: 0xFF0F9B8E,
    background: 0xFFE4FBF7,
  ),
  KidAchievement(
    id: KidAchievementId.whackMoleStarter,
    emoji: '🔨',
    name: '反应小快手',
    description: '完成一局打地鼠',
    color: 0xFFF97316,
    background: 0xFFFFF1E7,
  ),
  KidAchievement(
    id: KidAchievementId.memoryCardStarter,
    emoji: '🃏',
    name: '记忆小达人',
    description: '完成一局记忆卡片',
    color: 0xFFE84AA5,
    background: 0xFFFFEEF7,
  ),
  KidAchievement(
    id: KidAchievementId.allGamesPlayed,
    emoji: '🌈',
    name: '游戏达人',
    description: '体验全部 ${orderedGameIds.length} 个不同游戏',
    color: 0xFFE64A19,
    background: 0xFFFBE9E7,
  ),
  KidAchievement(
    id: KidAchievementId.allUnlocked,
    emoji: '🏆',
    name: '全部解锁',
    description: '解锁全部 ${orderedGameIds.length} 个游戏',
    color: 0xFFF4A200,
    background: 0xFFFFF8E1,
  ),
  KidAchievement(
    id: KidAchievementId.hardPerfect,
    emoji: '🎯',
    name: '精准挑战',
    description: '困难模式下一局全部答对',
    color: 0xFFC62828,
    background: 0xFFFFEBEE,
  ),
  KidAchievement(
    id: KidAchievementId.streak7,
    emoji: '🔥',
    name: '七日连续',
    description: '连续游玩 7 天不间断',
    color: 0xFFE64A19,
    background: 0xFFFFF3E0,
  ),
];

class PlayDayStatus {
  const PlayDayStatus({
    required this.date,
    required this.played,
    required this.dayLabel,
  });

  final DateTime date;
  final bool played;
  final String dayLabel;
}

const _weekdayLabels = <String>['日', '一', '二', '三', '四', '五', '六'];

Set<KidAchievementId> deriveUnlockedAchievements({
  required int totalStars,
  required Iterable<GameId> unlockedGames,
  required Map<GameId, ParentGameStats> gameStats,
  required Iterable<ActivityEntry> activityLog,
}) {
  final unlocked = <KidAchievementId>{};
  final entries = activityLog.toList();
  final playedGames = {
    ...entries.map((entry) => entry.gameId),
    ...gameStats.entries
        .where((entry) => entry.value.played > 0)
        .map((entry) => entry.key),
  };

  if (playedGames.isNotEmpty) {
    unlocked.add(KidAchievementId.firstGame);
  }

  final hasPerfectRound =
      entries.any((entry) => entry.stars == entry.total && entry.total > 0) ||
          gameStats.values.any(
            (stats) =>
                stats.bestStars == stats.bestTotal && stats.bestTotal > 0,
          );
  if (hasPerfectRound) {
    unlocked.add(KidAchievementId.firstPerfect);
  }

  if (totalStars >= 50) {
    unlocked.add(KidAchievementId.stars50);
  }
  if (totalStars >= 100) {
    unlocked.add(KidAchievementId.stars100);
  }

  if (playedGames.contains(GameId.findDifferent)) {
    unlocked.add(KidAchievementId.findDifferentStarter);
  }

  if (playedGames.contains(GameId.whackMole)) {
    unlocked.add(KidAchievementId.whackMoleStarter);
  }

  if (playedGames.contains(GameId.memoryCard)) {
    unlocked.add(KidAchievementId.memoryCardStarter);
  }

  if (playedGames.length == orderedGameIds.length) {
    unlocked.add(KidAchievementId.allGamesPlayed);
  }

  if (unlockedGames.length == orderedGameIds.length) {
    unlocked.add(KidAchievementId.allUnlocked);
  }

  final hardPerfect = entries.any(
    (entry) =>
        entry.difficulty == GameDifficulty.hard &&
        entry.stars == entry.total &&
        entry.total > 0,
  );
  if (hardPerfect) {
    unlocked.add(KidAchievementId.hardPerfect);
  }

  if (computeCurrentStreak(entries) >= 7) {
    unlocked.add(KidAchievementId.streak7);
  }

  if (gameStats.values.any(
    (stats) =>
        stats.highestCompletedDifficulty == GameDifficulty.hard &&
        stats.bestStars == stats.bestTotal &&
        stats.bestTotal > 0,
  )) {
    unlocked.add(KidAchievementId.hardPerfect);
  }

  return unlocked;
}

int computeCurrentStreak(Iterable<ActivityEntry> activityLog) {
  final dayKeys = activityLog
      .map((entry) => _dayKey(entry.timestamp))
      .toSet()
      .toList()
    ..sort((left, right) => right.compareTo(left));

  if (dayKeys.isEmpty) {
    return 0;
  }

  final today = _dayKey(DateTime.now());
  final yesterday = _dayKey(DateTime.now().subtract(const Duration(days: 1)));
  if (dayKeys.first != today && dayKeys.first != yesterday) {
    return 0;
  }

  var streak = 1;
  for (var index = 0; index < dayKeys.length - 1; index++) {
    final current = DateTime.parse(dayKeys[index]);
    final next = DateTime.parse(dayKeys[index + 1]);
    final diff = current.difference(next).inDays;
    if (diff == 1) {
      streak += 1;
    } else {
      break;
    }
  }

  return streak;
}

UnmodifiableListView<PlayDayStatus> lastSevenPlayDays(
  Iterable<ActivityEntry> activityLog,
) {
  final playedDays =
      activityLog.map((entry) => _dayKey(entry.timestamp)).toSet();
  final today = DateTime.now();

  final values = List<PlayDayStatus>.generate(7, (index) {
    final date = DateTime(today.year, today.month, today.day)
        .subtract(Duration(days: 6 - index));
    return PlayDayStatus(
      date: date,
      played: playedDays.contains(_dayKey(date)),
      dayLabel: _weekdayLabels[date.weekday % 7],
    );
  });

  return UnmodifiableListView(values);
}

KidAchievement achievementById(KidAchievementId id) {
  return kidAchievements.firstWhere((achievement) => achievement.id == id);
}

String _dayKey(DateTime dateTime) {
  final normalized = DateTime(dateTime.year, dateTime.month, dateTime.day);
  final month = normalized.month.toString().padLeft(2, '0');
  final day = normalized.day.toString().padLeft(2, '0');
  return '${normalized.year}-$month-$day';
}
