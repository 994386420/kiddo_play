import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../app_controllers.dart';

final voiceGuideControllerProvider = Provider<VoiceGuideController>((ref) {
  final controller = VoiceGuideController();
  controller.setEnabled(ref.read(parentDataProvider).voiceGuideEnabled);

  ref.listen<bool>(
    parentDataProvider.select((parentData) => parentData.voiceGuideEnabled),
    (_, enabled) {
      unawaited(controller.setEnabled(enabled));
    },
  );

  ref.onDispose(controller.dispose);
  return controller;
});

enum VoiceGuideResult {
  completed,
  interrupted,
  skipped,
  failed,
}

class VoiceGuideController {
  VoiceGuideController() {
    _tts = FlutterTts()
      ..setCancelHandler(_handleSpeechEnd)
      ..setCompletionHandler(_handleSpeechEnd)
      ..setErrorHandler((message) {
        debugPrint('Voice guide error: $message');
        _handleSpeechEnd();
      });
  }

  late final FlutterTts _tts;

  Completer<void>? _speakCompleter;
  bool _enabled = true;
  bool _disposed = false;
  bool _baseConfigured = false;
  int _speakToken = 0;
  String? _languageTag;
  String? _lastPromptKey;
  DateTime? _lastPromptStartedAt;
  DateTime? _lastPromptEndedAt;

  Future<void> setEnabled(bool value) async {
    _enabled = value;
    if (!value) {
      await stop();
    }
  }

  Future<VoiceGuideResult> speak(
    String text, {
    required Locale locale,
    Duration delay = Duration.zero,
    Duration minInterval = const Duration(milliseconds: 900),
    Duration duplicateWindow = const Duration(milliseconds: 1800),
    bool interrupt = false,
  }) async {
    final normalized = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (!_enabled || _disposed || normalized.isEmpty) {
      return VoiceGuideResult.skipped;
    }

    final now = DateTime.now();
    if (_speakCompleter != null && !interrupt) {
      return VoiceGuideResult.skipped;
    }
    if (_shouldSkipForCadence(
      promptKey: normalized,
      now: now,
      minInterval: minInterval,
      duplicateWindow: duplicateWindow,
    )) {
      return VoiceGuideResult.skipped;
    }

    final token = ++_speakToken;
    if (interrupt) {
      await _stopInternal();
    }

    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
      if (!_isCurrentToken(token)) {
        return VoiceGuideResult.interrupted;
      }
    }

    final baseConfigured = await _ensureBaseConfiguration();
    if (!baseConfigured || !_isCurrentToken(token)) {
      return baseConfigured
          ? VoiceGuideResult.interrupted
          : VoiceGuideResult.failed;
    }

    final languageConfigured = await _ensureLanguage(locale);
    if (!languageConfigured || !_isCurrentToken(token)) {
      return languageConfigured
          ? VoiceGuideResult.interrupted
          : VoiceGuideResult.failed;
    }

    final speakCompleter = Completer<void>();
    _speakCompleter = speakCompleter;
    _lastPromptKey = normalized;
    _lastPromptStartedAt = DateTime.now();

    try {
      await _tts.speak(
        normalized,
        focus: !kIsWeb && defaultTargetPlatform == TargetPlatform.android,
      );
      await speakCompleter.future;
      return _isCurrentToken(token)
          ? VoiceGuideResult.completed
          : VoiceGuideResult.interrupted;
    } on MissingPluginException {
      _completeSpeakIfNeeded();
      return VoiceGuideResult.failed;
    } on PlatformException catch (error, stackTrace) {
      debugPrint('Voice guide speak failed: ${error.message ?? error.code}');
      debugPrintStack(stackTrace: stackTrace);
      _completeSpeakIfNeeded();
      return VoiceGuideResult.failed;
    } catch (error, stackTrace) {
      debugPrint('Voice guide speak failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      _completeSpeakIfNeeded();
      return VoiceGuideResult.failed;
    }
  }

  Future<void> stop() async {
    _speakToken++;
    await _stopInternal();
  }

  Future<void> dispose() async {
    _disposed = true;
    _speakToken++;
    await _stopInternal();
  }

  Future<bool> _ensureBaseConfiguration() async {
    if (_baseConfigured) {
      return true;
    }

    try {
      await _tts.awaitSpeakCompletion(true);
      await _tts.setSpeechRate(
        defaultTargetPlatform == TargetPlatform.iOS ? 0.46 : 0.42,
      );
      await _tts.setPitch(1.0);
      await _tts.setVolume(1.0);

      if (defaultTargetPlatform == TargetPlatform.iOS) {
        await _tts.setSharedInstance(true);
        await _tts.autoStopSharedSession(true);
        await _tts.setIosAudioCategory(
          IosTextToSpeechAudioCategory.playback,
          const [
            IosTextToSpeechAudioCategoryOptions.duckOthers,
            IosTextToSpeechAudioCategoryOptions
                .interruptSpokenAudioAndMixWithOthers,
          ],
          IosTextToSpeechAudioMode.voicePrompt,
        );
      }

      _baseConfigured = true;
      return true;
    } on MissingPluginException {
      return false;
    } on PlatformException catch (error, stackTrace) {
      debugPrint(
        'Voice guide configuration failed: ${error.message ?? error.code}',
      );
      debugPrintStack(stackTrace: stackTrace);
      return false;
    } catch (error, stackTrace) {
      debugPrint('Voice guide configuration failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      return false;
    }
  }

  Future<bool> _ensureLanguage(Locale locale) async {
    final preferredTag = switch (locale.languageCode) {
      'zh' => 'zh-CN',
      'ko' => 'ko-KR',
      _ => 'en-US',
    };

    if (_languageTag == preferredTag) {
      return true;
    }

    try {
      await _tts.setLanguage(preferredTag);
      _languageTag = preferredTag;
      return true;
    } on PlatformException {
      final fallbackTag = locale.languageCode;
      if (fallbackTag == preferredTag) {
        return false;
      }
      try {
        await _tts.setLanguage(fallbackTag);
        _languageTag = fallbackTag;
        return true;
      } catch (_) {
        return false;
      }
    } on MissingPluginException {
      return false;
    }
  }

  Future<void> _stopInternal() async {
    _completeSpeakIfNeeded();

    try {
      await _tts.stop();
    } on MissingPluginException {
      // Ignore plugin availability issues in tests and dry environments.
    } on PlatformException {
      // Ignore stop failures during route changes or app shutdown.
    }
  }

  void _handleSpeechEnd() {
    _completeSpeakIfNeeded();
  }

  void _completeSpeakIfNeeded() {
    final shouldComplete = _speakCompleter?.isCompleted == false;
    if (shouldComplete) {
      _speakCompleter?.complete();
      _lastPromptEndedAt = DateTime.now();
    }
    _speakCompleter = null;
  }

  bool _shouldSkipForCadence({
    required String promptKey,
    required DateTime now,
    required Duration minInterval,
    required Duration duplicateWindow,
  }) {
    final lastStartedAt = _lastPromptStartedAt;
    if (duplicateWindow > Duration.zero &&
        _lastPromptKey == promptKey &&
        lastStartedAt != null &&
        now.difference(lastStartedAt) < duplicateWindow) {
      return true;
    }

    final lastEndedAt = _lastPromptEndedAt;
    if (minInterval > Duration.zero &&
        lastEndedAt != null &&
        now.difference(lastEndedAt) < minInterval) {
      return true;
    }

    return false;
  }

  bool _isCurrentToken(int token) {
    return !_disposed && _enabled && _speakToken == token;
  }
}
