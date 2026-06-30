import 'dart:math';

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import 'game_models.dart';

enum DailyTaskKind {
  playAny,
  playGame,
  stars3,
  playHard,
  playEasy,
  playTwoGames,
}

class DailyTask {
  const DailyTask({
    required this.id,
    required this.kind,
    required this.completed,
    this.gameId,
  });

  final String id;
  final DailyTaskKind kind;
  final bool completed;
  final GameId? gameId;

  DailyTask copyWith({
    bool? completed,
  }) {
    return DailyTask(
      id: id,
      kind: kind,
      completed: completed ?? this.completed,
      gameId: gameId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'kind': kind.name,
      'completed': completed,
      'gameId': gameId?.storageKey,
    };
  }

  factory DailyTask.fromJson(Map<String, dynamic> json) {
    return DailyTask(
      id: json['id'] as String? ?? 'task_0',
      kind: DailyTaskKind.values.firstWhere(
        (kind) => kind.name == json['kind'],
        orElse: () => DailyTaskKind.playAny,
      ),
      completed: json['completed'] as bool? ?? false,
      gameId: json['gameId'] is String
          ? gameIdFromStorage(json['gameId'] as String)
          : null,
    );
  }
}

class DailyTasksState {
  const DailyTasksState({
    required this.dateKey,
    required this.tasks,
    required this.gamesPlayedToday,
    required this.allCompletedRewarded,
  });

  final String dateKey;
  final List<DailyTask> tasks;
  final int gamesPlayedToday;
  final bool allCompletedRewarded;

  int get completedCount => tasks.where((task) => task.completed).length;
  bool get allDone => tasks.isNotEmpty && completedCount == tasks.length;

  DailyTasksState copyWith({
    List<DailyTask>? tasks,
    int? gamesPlayedToday,
    bool? allCompletedRewarded,
  }) {
    return DailyTasksState(
      dateKey: dateKey,
      tasks: tasks ?? this.tasks,
      gamesPlayedToday: gamesPlayedToday ?? this.gamesPlayedToday,
      allCompletedRewarded: allCompletedRewarded ?? this.allCompletedRewarded,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dateKey': dateKey,
      'tasks': tasks.map((task) => task.toJson()).toList(),
      'gamesPlayedToday': gamesPlayedToday,
      'allCompletedRewarded': allCompletedRewarded,
    };
  }

  factory DailyTasksState.fromJson(Map<String, dynamic> json) {
    return DailyTasksState(
      dateKey: json['dateKey'] as String? ?? todayKey(),
      tasks: (json['tasks'] as List<dynamic>? ?? const [])
          .whereType<Map>()
          .map((task) => DailyTask.fromJson(task.cast<String, dynamic>()))
          .toList(),
      gamesPlayedToday: json['gamesPlayedToday'] as int? ?? 0,
      allCompletedRewarded: json['allCompletedRewarded'] as bool? ?? false,
    );
  }
}

class DailyTaskResult {
  const DailyTaskResult({
    required this.newlyCompleted,
    required this.allDoneFirstTime,
  });

  final List<DailyTask> newlyCompleted;
  final bool allDoneFirstTime;

  bool get hasUpdates => newlyCompleted.isNotEmpty || allDoneFirstTime;
}

enum MascotId {
  lion,
  fox,
  chick,
  bear,
  panda,
  frog,
}

class MascotInfo {
  const MascotInfo({
    required this.id,
    required this.nameZh,
    required this.nameEn,
    required this.emoji,
    required this.color,
    required this.background,
  });

  final MascotId id;
  final String nameZh;
  final String nameEn;
  final String emoji;
  final Color color;
  final Color background;
}

const mascotInfos = <MascotInfo>[
  MascotInfo(
    id: MascotId.lion,
    nameZh: '小狮子',
    nameEn: 'Lion',
    emoji: '🦁',
    color: Color(0xFFE65100),
    background: Color(0xFFFFF3E0),
  ),
  MascotInfo(
    id: MascotId.fox,
    nameZh: '小狐狸',
    nameEn: 'Fox',
    emoji: '🦊',
    color: Color(0xFFBF360C),
    background: Color(0xFFFBE9E7),
  ),
  MascotInfo(
    id: MascotId.chick,
    nameZh: '小鸡',
    nameEn: 'Chick',
    emoji: '🐥',
    color: Color(0xFFF9A825),
    background: Color(0xFFFFF9C4),
  ),
  MascotInfo(
    id: MascotId.bear,
    nameZh: '小熊',
    nameEn: 'Bear',
    emoji: '🐻',
    color: Color(0xFF5D4037),
    background: Color(0xFFEFEBE9),
  ),
  MascotInfo(
    id: MascotId.panda,
    nameZh: '熊猫',
    nameEn: 'Panda',
    emoji: '🐼',
    color: Color(0xFF37474F),
    background: Color(0xFFECEFF1),
  ),
  MascotInfo(
    id: MascotId.frog,
    nameZh: '青蛙',
    nameEn: 'Frog',
    emoji: '🐸',
    color: Color(0xFF2E7D32),
    background: Color(0xFFE8F5E9),
  ),
];

String todayKey([DateTime? date]) {
  final value = date ?? DateTime.now();
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  return '${value.year}-$month-$day';
}

List<DailyTask> generateDailyTasks({
  required String dateKey,
  Random? random,
}) {
  final rng = random ?? Random(_stableSeed(dateKey));
  final games = [...orderedGameIds]..shuffle(rng);
  final candidates = <DailyTask>[
    const DailyTask(
        id: 'task_any', kind: DailyTaskKind.playAny, completed: false),
    const DailyTask(
        id: 'task_star', kind: DailyTaskKind.stars3, completed: false),
    const DailyTask(
        id: 'task_hard', kind: DailyTaskKind.playHard, completed: false),
    const DailyTask(
        id: 'task_easy', kind: DailyTaskKind.playEasy, completed: false),
    const DailyTask(
      id: 'task_two_games',
      kind: DailyTaskKind.playTwoGames,
      completed: false,
    ),
    DailyTask(
      id: 'task_game_${games.first.storageKey}',
      kind: DailyTaskKind.playGame,
      gameId: games.first,
      completed: false,
    ),
    DailyTask(
      id: 'task_game_${games[1].storageKey}',
      kind: DailyTaskKind.playGame,
      gameId: games[1],
      completed: false,
    ),
  ]..shuffle(rng);

  return candidates.take(3).toList();
}

int _stableSeed(String value) {
  var hash = 0;
  for (final unit in value.codeUnits) {
    hash = (hash * 31 + unit) & 0x7fffffff;
  }
  return hash;
}

String dailyTaskDescription(
  DailyTask task,
  AppLocalizations l10n,
) {
  switch (task.kind) {
    case DailyTaskKind.playAny:
      return _localized(
        l10n,
        zh: '完成任意一局游戏',
        en: 'Finish any game',
        ko: '아무 게임이나 완료하기',
      );
    case DailyTaskKind.playGame:
      return _localized(
        l10n,
        zh: '玩一局「${task.gameId?.title(l10n) ?? ''}」',
        en: 'Play ${task.gameId?.title(l10n) ?? 'a game'} once',
        ko: '${task.gameId?.title(l10n) ?? '게임'} 한 번 하기',
      );
    case DailyTaskKind.stars3:
      return _localized(
        l10n,
        zh: '单局拿到 3 颗星',
        en: 'Earn 3 stars in one round',
        ko: '한 판에서 별 3개 받기',
      );
    case DailyTaskKind.playHard:
      return _localized(
        l10n,
        zh: '完成一局困难模式',
        en: 'Finish one hard game',
        ko: '어려움 게임 한 판 완료',
      );
    case DailyTaskKind.playEasy:
      return _localized(
        l10n,
        zh: '完成一局简单模式',
        en: 'Finish one easy game',
        ko: '쉬움 게임 한 판 완료',
      );
    case DailyTaskKind.playTwoGames:
      return _localized(
        l10n,
        zh: '今天完成 2 局游戏',
        en: 'Finish 2 games today',
        ko: '오늘 게임 2판 완료',
      );
  }
}

String _localized(
  AppLocalizations l10n, {
  required String zh,
  required String en,
  required String ko,
}) {
  return switch (l10n.localeName) {
    'zh' => zh,
    'ko' => ko,
    _ => en,
  };
}

MascotInfo mascotInfoById(MascotId id) {
  return mascotInfos.firstWhere((info) => info.id == id);
}

MascotId? mascotIdFromStorage(String? value) {
  for (final id in MascotId.values) {
    if (id.name == value) {
      return id;
    }
  }
  return null;
}
