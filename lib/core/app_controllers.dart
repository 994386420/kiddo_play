import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'game_models.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('SharedPreferences must be overridden.'),
);

final appSettingsProvider = ChangeNotifierProvider<AppSettingsController>(
  (ref) => AppSettingsController(ref.watch(sharedPreferencesProvider)),
);

final gameProgressProvider = ChangeNotifierProvider<GameProgressController>(
  (ref) => GameProgressController(ref.watch(sharedPreferencesProvider)),
);

final parentDataProvider = ChangeNotifierProvider<ParentDataController>(
  (ref) => ParentDataController(ref.watch(sharedPreferencesProvider)),
);

class AppSettingsController extends ChangeNotifier {
  AppSettingsController(this._preferences)
      : _localeCode = _preferences.getString(_localeKey);

  static const _localeKey = 'app.localeCode';

  final SharedPreferences _preferences;
  String? _localeCode;

  Locale? get locale => _localeCode == null ? null : Locale(_localeCode!);

  Future<void> setLocaleCode(String? value) async {
    _localeCode = value;
    if (value == null) {
      await _preferences.remove(_localeKey);
    } else {
      await _preferences.setString(_localeKey, value);
    }
    notifyListeners();
  }
}

class GameProgressController extends ChangeNotifier {
  GameProgressController(this._preferences)
      : _totalStars = _preferences.getInt(_starsKey) ??
            _preferences.getInt(_legacyStarsKey) ??
            0,
        _unlockedGames = _readUnlockedGames(_preferences);

  static const _starsKey = 'kidapp_total_stars';
  static const _legacyStarsKey = 'progress.totalStars';
  static const _unlockedKey = 'kidapp_unlocked_games';
  static const _legacyUnlockedKey = 'progress.unlockedGames';

  final SharedPreferences _preferences;
  int _totalStars;
  Set<GameId> _unlockedGames;

  int get totalStars => _totalStars;

  UnmodifiableListView<GameId> get unlockedGames =>
      UnmodifiableListView(orderedGameIds.where(_unlockedGames.contains));

  bool isUnlocked(GameId gameId) => _unlockedGames.contains(gameId);

  GameId? completeGame({
    required GameId gameId,
    required int earnedStars,
  }) {
    _totalStars += earnedStars;
    GameId? newlyUnlocked;
    final next = nextGameId(gameId);
    if (next != null && !_unlockedGames.contains(next)) {
      _unlockedGames = {..._unlockedGames, next};
      newlyUnlocked = next;
    }
    _save();
    notifyListeners();
    return newlyUnlocked;
  }

  static Set<GameId> _readUnlockedGames(SharedPreferences preferences) {
    final modern = preferences.getStringList(_unlockedKey);
    if (modern != null && modern.isNotEmpty) {
      return modern.map(gameIdFromStorage).toSet()..add(GameId.colorMatch);
    }

    final legacy = preferences.getStringList(_legacyUnlockedKey);
    if (legacy != null && legacy.isNotEmpty) {
      return legacy.map(gameIdFromStorage).toSet()..add(GameId.colorMatch);
    }

    return {GameId.colorMatch};
  }

  Future<void> resetProgress() async {
    _totalStars = 0;
    _unlockedGames = {GameId.colorMatch};
    await _save();
    notifyListeners();
  }

  Future<void> _save() async {
    await _preferences.setInt(_starsKey, _totalStars);
    await _preferences.remove(_legacyStarsKey);
    await _preferences.setStringList(
      _unlockedKey,
      unlockedGames.map((gameId) => gameId.storageKey).toList(),
    );
    await _preferences.remove(_legacyUnlockedKey);
  }
}

class ParentGameStats {
  const ParentGameStats({
    required this.played,
    required this.totalStars,
    required this.bestStars,
    required this.bestTotal,
    required this.lastPlayed,
    required this.lastDifficulty,
    required this.highestCompletedDifficulty,
  });

  final int played;
  final int totalStars;
  final int bestStars;
  final int bestTotal;
  final DateTime? lastPlayed;
  final GameDifficulty? lastDifficulty;
  final GameDifficulty? highestCompletedDifficulty;

  bool hasCompletedDifficulty(GameDifficulty difficulty) {
    final highest = highestCompletedDifficulty;
    return highest != null && highest.index >= difficulty.index;
  }

  ParentGameStats copyWith({
    int? played,
    int? totalStars,
    int? bestStars,
    int? bestTotal,
    DateTime? lastPlayed,
    GameDifficulty? lastDifficulty,
    GameDifficulty? highestCompletedDifficulty,
  }) {
    return ParentGameStats(
      played: played ?? this.played,
      totalStars: totalStars ?? this.totalStars,
      bestStars: bestStars ?? this.bestStars,
      bestTotal: bestTotal ?? this.bestTotal,
      lastPlayed: lastPlayed ?? this.lastPlayed,
      lastDifficulty: lastDifficulty ?? this.lastDifficulty,
      highestCompletedDifficulty:
          highestCompletedDifficulty ?? this.highestCompletedDifficulty,
    );
  }

  factory ParentGameStats.initial({required int totalRounds}) {
    return ParentGameStats(
      played: 0,
      totalStars: 0,
      bestStars: 0,
      bestTotal: totalRounds,
      lastPlayed: null,
      lastDifficulty: null,
      highestCompletedDifficulty: null,
    );
  }

  factory ParentGameStats.fromJson(Map<String, dynamic> json) {
    final lastDifficulty =
        _difficultyFromStorage(json['lastDifficulty'] as String?);
    return ParentGameStats(
      played: json['played'] as int? ?? 0,
      totalStars: json['totalStars'] as int? ?? 0,
      bestStars: json['bestStars'] as int? ?? 0,
      bestTotal: json['bestTotal'] as int? ?? 0,
      lastPlayed: json['lastPlayed'] == null
          ? null
          : DateTime.tryParse(json['lastPlayed'] as String),
      lastDifficulty: lastDifficulty,
      highestCompletedDifficulty: _difficultyFromStorage(
              json['highestCompletedDifficulty'] as String?) ??
          lastDifficulty,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'played': played,
      'totalStars': totalStars,
      'bestStars': bestStars,
      'bestTotal': bestTotal,
      'lastPlayed': lastPlayed?.toIso8601String(),
      'lastDifficulty': lastDifficulty?.storageKey,
      'highestCompletedDifficulty': highestCompletedDifficulty?.storageKey,
    };
  }
}

class ActivityEntry {
  const ActivityEntry({
    required this.gameId,
    required this.stars,
    required this.total,
    required this.difficulty,
    required this.timestamp,
  });

  final GameId gameId;
  final int stars;
  final int total;
  final GameDifficulty difficulty;
  final DateTime timestamp;

  factory ActivityEntry.fromJson(Map<String, dynamic> json) {
    return ActivityEntry(
      gameId: gameIdFromStorage(json['gameId'] as String? ?? 'color-match'),
      stars: json['stars'] as int? ?? 0,
      total: json['total'] as int? ?? 0,
      difficulty: _difficultyFromStorage(json['difficulty'] as String?) ??
          GameDifficulty.medium,
      timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'gameId': gameId.storageKey,
      'stars': stars,
      'total': total,
      'difficulty': difficulty.storageKey,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

class ParentDataController extends ChangeNotifier {
  ParentDataController(this._preferences)
      : _childName = _preferences.getString(_childNameKey) ?? '小朋友',
        _childAvatar = _preferences.getString(_childAvatarKey) ?? '🦁',
        _soundEnabled = _preferences.getBool(_soundEnabledKey) ?? true,
        _voiceGuideEnabled =
            _preferences.getBool(_voiceGuideEnabledKey) ?? true,
        _sessionTimeLimitMinutes =
            _preferences.getInt(_sessionTimeLimitMinutesKey) ?? 0,
        _dailyTimeLimitMinutes =
            _preferences.getInt(_dailyTimeLimitMinutesKey) ?? 0,
        _gameStats = _readGameStats(_preferences),
        _activityLog = _readActivityLog(_preferences) {
    _mergeDifficultyProgressFromActivityLog();
  }

  static const defaultPin = '1234';
  static const _parentPinKey = 'kidapp_parent_pin';
  static const _childNameKey = 'kidapp_child_name';
  static const _childAvatarKey = 'kidapp_child_avatar';
  static const _soundEnabledKey = 'kidapp_sound_enabled';
  static const _voiceGuideEnabledKey = 'kidapp_voice_guide_enabled';
  static const _sessionTimeLimitMinutesKey =
      'kidapp_session_time_limit_minutes';
  static const _dailyTimeLimitMinutesKey = 'kidapp_daily_time_limit_minutes';
  static const _gameStatsKey = 'kidapp_game_stats';
  static const _activityLogKey = 'kidapp_activity_log';

  final SharedPreferences _preferences;

  String _childName;
  String _childAvatar;
  bool _soundEnabled;
  bool _voiceGuideEnabled;
  int _sessionTimeLimitMinutes;
  int _dailyTimeLimitMinutes;
  Map<GameId, ParentGameStats> _gameStats;
  List<ActivityEntry> _activityLog;

  String get childName => _childName;
  String get childAvatar => _childAvatar;
  bool get soundEnabled => _soundEnabled;
  bool get voiceGuideEnabled => _voiceGuideEnabled;
  int get sessionTimeLimitMinutes => _sessionTimeLimitMinutes;
  int get dailyTimeLimitMinutes => _dailyTimeLimitMinutes;
  bool get isPinSet => _preferences.containsKey(_parentPinKey);

  UnmodifiableMapView<GameId, ParentGameStats> get gameStats =>
      UnmodifiableMapView(_gameStats);

  UnmodifiableListView<ActivityEntry> get activityLog =>
      UnmodifiableListView(_activityLog);

  int get totalPlayed =>
      _gameStats.values.fold(0, (sum, stats) => sum + stats.played);

  int get todayStars {
    final today = DateTime.now();
    return _activityLog
        .where((entry) => _isSameDay(entry.timestamp, today))
        .fold(0, (sum, entry) => sum + entry.stars);
  }

  String get storedOrDefaultPin =>
      _preferences.getString(_parentPinKey) ?? defaultPin;

  bool verifyPin(String pin) => storedOrDefaultPin == pin;

  Future<void> setParentPin(String pin) async {
    await _preferences.setString(_parentPinKey, pin);
    notifyListeners();
  }

  Future<void> setChildName(String value) async {
    _childName = value.trim().isEmpty ? '小朋友' : value.trim();
    await _preferences.setString(_childNameKey, _childName);
    notifyListeners();
  }

  Future<void> setChildAvatar(String value) async {
    _childAvatar = value;
    await _preferences.setString(_childAvatarKey, value);
    notifyListeners();
  }

  Future<void> setSoundEnabled(bool value) async {
    _soundEnabled = value;
    await _preferences.setBool(_soundEnabledKey, value);
    notifyListeners();
  }

  Future<void> setVoiceGuideEnabled(bool value) async {
    _voiceGuideEnabled = value;
    await _preferences.setBool(_voiceGuideEnabledKey, value);
    notifyListeners();
  }

  Future<void> setSessionTimeLimitMinutes(int value) async {
    _sessionTimeLimitMinutes = value;
    await _preferences.setInt(_sessionTimeLimitMinutesKey, value);
    notifyListeners();
  }

  Future<void> setDailyTimeLimitMinutes(int value) async {
    _dailyTimeLimitMinutes = value;
    await _preferences.setInt(_dailyTimeLimitMinutesKey, value);
    notifyListeners();
  }

  Future<void> recordGameCompletion({
    required GameId gameId,
    required int stars,
    required int totalRounds,
    required GameDifficulty difficulty,
  }) async {
    final current =
        _gameStats[gameId] ?? ParentGameStats.initial(totalRounds: totalRounds);
    final now = DateTime.now();

    final updated = current.copyWith(
      played: current.played + 1,
      totalStars: current.totalStars + stars,
      bestStars: stars > current.bestStars ? stars : current.bestStars,
      bestTotal: stars > current.bestStars ? totalRounds : current.bestTotal,
      lastPlayed: now,
      lastDifficulty: difficulty,
      highestCompletedDifficulty:
          _maxDifficulty(current.highestCompletedDifficulty, difficulty),
    );

    _gameStats = {
      ..._gameStats,
      gameId: updated,
    };

    _activityLog = [
      ActivityEntry(
        gameId: gameId,
        stars: stars,
        total: totalRounds,
        difficulty: difficulty,
        timestamp: now,
      ),
      ..._activityLog,
    ].take(30).toList();

    await _saveGameStats();
    await _saveActivityLog();
    notifyListeners();
  }

  Future<void> resetLearningData() async {
    _gameStats = {};
    _activityLog = [];
    await _preferences.remove(_gameStatsKey);
    await _preferences.remove(_activityLogKey);
    notifyListeners();
  }

  bool isDifficultyUnlocked({
    required GameId gameId,
    required GameDifficulty difficulty,
  }) {
    if (difficulty == GameDifficulty.easy) {
      return true;
    }

    final previous = switch (difficulty) {
      GameDifficulty.easy => null,
      GameDifficulty.medium => GameDifficulty.easy,
      GameDifficulty.hard => GameDifficulty.medium,
    };

    final stats = _gameStats[gameId];
    return previous != null &&
        (stats?.hasCompletedDifficulty(previous) ?? false);
  }

  bool isDifficultyNextToUnlock({
    required GameId gameId,
    required GameDifficulty difficulty,
  }) {
    if (difficulty == GameDifficulty.easy) {
      return false;
    }

    final previous = switch (difficulty) {
      GameDifficulty.easy => null,
      GameDifficulty.medium => GameDifficulty.easy,
      GameDifficulty.hard => GameDifficulty.medium,
    };

    return !isDifficultyUnlocked(gameId: gameId, difficulty: difficulty) &&
        previous != null &&
        isDifficultyUnlocked(gameId: gameId, difficulty: previous);
  }

  Future<void> _saveGameStats() async {
    final jsonString = jsonEncode({
      for (final entry in _gameStats.entries)
        entry.key.storageKey: entry.value.toJson(),
    });
    await _preferences.setString(_gameStatsKey, jsonString);
  }

  Future<void> _saveActivityLog() async {
    final jsonString = jsonEncode(
      _activityLog.map((entry) => entry.toJson()).toList(),
    );
    await _preferences.setString(_activityLogKey, jsonString);
  }

  static Map<GameId, ParentGameStats> _readGameStats(
    SharedPreferences preferences,
  ) {
    final raw = preferences.getString(_gameStatsKey);
    if (raw == null || raw.isEmpty) {
      return {};
    }

    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return {
        for (final entry in decoded.entries)
          gameIdFromStorage(entry.key): ParentGameStats.fromJson(
            (entry.value as Map).cast<String, dynamic>(),
          ),
      };
    } catch (_) {
      return {};
    }
  }

  static List<ActivityEntry> _readActivityLog(SharedPreferences preferences) {
    final raw = preferences.getString(_activityLogKey);
    if (raw == null || raw.isEmpty) {
      return const [];
    }

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .whereType<Map>()
          .map(
            (entry) => ActivityEntry.fromJson(
              entry.cast<String, dynamic>(),
            ),
          )
          .toList();
    } catch (_) {
      return const [];
    }
  }

  void _mergeDifficultyProgressFromActivityLog() {
    if (_activityLog.isEmpty) {
      return;
    }

    final merged = <GameId, ParentGameStats>{..._gameStats};
    var changed = false;

    for (final entry in _activityLog) {
      final current = merged[entry.gameId] ??
          ParentGameStats.initial(totalRounds: entry.total);
      final highest = _maxDifficulty(
        current.highestCompletedDifficulty,
        entry.difficulty,
      );

      if (highest != current.highestCompletedDifficulty) {
        merged[entry.gameId] = current.copyWith(
          highestCompletedDifficulty: highest,
        );
        changed = true;
      }
    }

    if (changed) {
      _gameStats = merged;
    }
  }
}

GameDifficulty _maxDifficulty(
  GameDifficulty? current,
  GameDifficulty candidate,
) {
  if (current == null || candidate.index > current.index) {
    return candidate;
  }

  return current;
}

GameDifficulty? _difficultyFromStorage(String? value) {
  switch (value) {
    case 'easy':
      return GameDifficulty.easy;
    case 'medium':
      return GameDifficulty.medium;
    case 'hard':
      return GameDifficulty.hard;
    default:
      return null;
  }
}

bool _isSameDay(DateTime left, DateTime right) {
  return left.year == right.year &&
      left.month == right.month &&
      left.day == right.day;
}
