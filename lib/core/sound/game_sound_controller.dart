import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app_controllers.dart';

final gameSoundControllerProvider = Provider<GameSoundController>((ref) {
  final controller = GameSoundController();
  controller.setEnabled(ref.read(parentDataProvider).soundEnabled);

  ref.listen<bool>(
    parentDataProvider.select((parentData) => parentData.soundEnabled),
    (_, enabled) {
      unawaited(controller.setEnabled(enabled));
    },
  );

  ref.onDispose(controller.dispose);
  return controller;
});

enum GameSoundEffect {
  click('click.wav', 0.68),
  correct('correct.wav', 0.82),
  wrong('wrong.wav', 0.8),
  star('star.wav', 0.84),
  unlock('unlock.wav', 0.84);

  const GameSoundEffect(this.fileName, this.volume);

  final String fileName;
  final double volume;

  String get assetPath => 'sounds/$fileName';
}

class GameSoundController {
  GameSoundController() {
    _bgmPlayer = AudioPlayer(playerId: 'kiddo-bgm');
    unawaited(_primeSfxPools());
  }

  static const _bgmAssetPath = 'sounds/bgm_loop.wav';
  static const _bgmVolume = 0.18;
  static const _sfxMaxPlayers = 3;

  late final AudioPlayer _bgmPlayer;
  final Map<GameSoundEffect, Future<AudioPool>> _sfxPools = {};

  bool _soundEnabled = true;
  bool _bgmRequested = false;
  bool _bgmPlaying = false;
  bool _disposed = false;

  Future<void> setEnabled(bool value) async {
    _soundEnabled = value;
    if (!_soundEnabled) {
      await _stopBgmInternal();
      return;
    }

    if (_bgmRequested) {
      await _ensureBgmPlaying();
    }
  }

  Future<void> playClick() => _playEffect(GameSoundEffect.click);

  Future<void> playCorrect() => _playEffect(GameSoundEffect.correct);

  Future<void> playWrong() => _playEffect(GameSoundEffect.wrong);

  Future<void> playStar() => _playEffect(GameSoundEffect.star);

  Future<void> playUnlock() => _playEffect(GameSoundEffect.unlock);

  Future<void> startBgm() async {
    _bgmRequested = true;
    await _ensureBgmPlaying();
  }

  Future<void> stopBgm() async {
    _bgmRequested = false;
    await _stopBgmInternal();
  }

  Future<void> dispose() async {
    _disposed = true;
    await _stopBgmInternal();
    for (final poolFuture in _sfxPools.values) {
      try {
        final pool = await poolFuture;
        await pool.dispose();
      } catch (_) {
        // Ignore SFX pool shutdown issues while app is closing.
      }
    }
    await _bgmPlayer.dispose();
  }

  Future<void> _playEffect(GameSoundEffect effect) async {
    if (!_soundEnabled || _disposed) {
      return;
    }

    try {
      final pool = await _getSfxPool(effect);
      if (!_soundEnabled || _disposed) {
        return;
      }

      await pool.start(volume: effect.volume);
    } catch (error, stackTrace) {
      debugPrint('SFX play failed for ${effect.fileName}: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> _primeSfxPools() async {
    for (final effect in GameSoundEffect.values) {
      if (_disposed) {
        return;
      }

      try {
        await _getSfxPool(effect);
      } catch (error, stackTrace) {
        debugPrint('SFX prewarm failed for ${effect.fileName}: $error');
        debugPrintStack(stackTrace: stackTrace);
      }
    }
  }

  Future<AudioPool> _getSfxPool(GameSoundEffect effect) {
    final existingPool = _sfxPools[effect];
    if (existingPool != null) {
      return existingPool;
    }

    late final Future<AudioPool> poolFuture;
    poolFuture = AudioPool.createFromAsset(
      path: effect.assetPath,
      minPlayers: 1,
      maxPlayers: _sfxMaxPlayers,
      playerMode: PlayerMode.mediaPlayer,
    ).catchError((Object error, StackTrace stackTrace) {
      if (identical(_sfxPools[effect], poolFuture)) {
        _sfxPools.remove(effect);
      }
      Error.throwWithStackTrace(error, stackTrace);
    });

    _sfxPools[effect] = poolFuture;
    return poolFuture;
  }

  Future<void> _ensureBgmPlaying() async {
    if (!_soundEnabled || _disposed || _bgmPlaying) {
      return;
    }

    _bgmPlaying = true;

    try {
      await _bgmPlayer.setPlayerMode(PlayerMode.mediaPlayer);
      await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
      await _bgmPlayer.setVolume(_bgmVolume);
      await _bgmPlayer.play(AssetSource(_bgmAssetPath));
    } catch (_) {
      _bgmPlaying = false;
    }
  }

  Future<void> _stopBgmInternal() async {
    if (!_bgmPlaying && !_disposed) {
      return;
    }

    _bgmPlaying = false;
    try {
      await _bgmPlayer.stop();
    } catch (_) {
      // Ignore player shutdown issues during route changes.
    }
  }
}
