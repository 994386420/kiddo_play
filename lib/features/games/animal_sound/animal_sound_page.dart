import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';

import '../../../app/localization.dart';
import '../../../app/route_args.dart';
import '../../../app/router.dart';
import '../../../core/app_controllers.dart';
import '../../../core/game_models.dart';
import '../../../core/sound/app_audio_context.dart';
import '../../../core/sound/game_sound_controller.dart';
import '../../../core/sound/voice_guide_controller.dart';
import '../../../core/widgets/floating_sound_toggle.dart';
import '../../../core/widgets/figma_game_icons.dart';
import '../../../core/widgets/figma_game_shell.dart';
import '../../../core/widgets/figma_home_icons.dart';
import '../../../core/widgets/kid_motion.dart';
import '../../../core/widgets/pause_dialog.dart';

const _animalSoundPalette = FigmaGamePalette(
  accent: Color(0xFFFFB48E),
  accentStrong: Color(0xFFD8622A),
  accentSoft: Color(0xFFFFF3EC),
  progressTrack: Color(0xFFFFDEC9),
  progressBorder: Color(0xFFFFB48E),
  progressGradient: LinearGradient(
    colors: [Color(0xFFFFB48E), Color(0xFFD8622A)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  ),
  floaterIcon: FigmaFloatIconType.fire,
);

final animalSoundViewModelProvider = ChangeNotifierProvider.autoDispose
    .family<AnimalSoundViewModel, GameRouteArgs>((ref, args) {
  return AnimalSoundViewModel(args);
});

class AnimalChoice {
  const AnimalChoice({
    required this.id,
    required this.emoji,
    required this.nameZh,
    required this.nameKo,
    required this.nameEn,
    required this.soundZh,
    required this.soundKo,
    required this.soundEn,
    required this.background,
    required this.color,
    required this.shadow,
  });

  final String id;
  final String emoji;
  final String nameZh;
  final String nameKo;
  final String nameEn;
  final String soundZh;
  final String soundKo;
  final String soundEn;
  final Color background;
  final Color color;
  final Color shadow;

  String name(BuildContext context) {
    return switch (Localizations.localeOf(context).languageCode) {
      'zh' => nameZh,
      'ko' => nameKo,
      _ => nameEn,
    };
  }

  String sound(String languageCode) {
    return switch (languageCode) {
      'zh' => soundZh,
      'ko' => soundKo,
      _ => soundEn,
    };
  }
}

const _allAnimals = <AnimalChoice>[
  AnimalChoice(
    id: 'dog',
    emoji: '🐶',
    nameZh: '小狗',
    nameKo: '강아지',
    nameEn: 'Dog',
    soundZh: '汪汪汪！',
    soundKo: '멍멍!',
    soundEn: 'Woof woof!',
    background: Color(0xFFFFF9C4),
    color: Color(0xFFF9A825),
    shadow: Color(0xFFF57F17),
  ),
  AnimalChoice(
    id: 'cat',
    emoji: '🐱',
    nameZh: '小猫',
    nameKo: '고양이',
    nameEn: 'Cat',
    soundZh: '喵喵喵～',
    soundKo: '야옹~',
    soundEn: 'Meow meow!',
    background: Color(0xFFFCE4EC),
    color: Color(0xFFE91E63),
    shadow: Color(0xFF880E4F),
  ),
  AnimalChoice(
    id: 'cow',
    emoji: '🐮',
    nameZh: '奶牛',
    nameKo: '소',
    nameEn: 'Cow',
    soundZh: '哞～哞～',
    soundKo: '음메~',
    soundEn: 'Moo moo!',
    background: Color(0xFFF1F8E9),
    color: Color(0xFF7CB342),
    shadow: Color(0xFF33691E),
  ),
  AnimalChoice(
    id: 'duck',
    emoji: '🐤',
    nameZh: '小鸭',
    nameKo: '오리',
    nameEn: 'Duck',
    soundZh: '嘎嘎嘎！',
    soundKo: '꽥꽥!',
    soundEn: 'Quack quack!',
    background: Color(0xFFFFF8E1),
    color: Color(0xFFFFB300),
    shadow: Color(0xFFFF6F00),
  ),
  AnimalChoice(
    id: 'pig',
    emoji: '🐷',
    nameZh: '小猪',
    nameKo: '돼지',
    nameEn: 'Pig',
    soundZh: '哼哼哼～',
    soundKo: '꿀꿀~',
    soundEn: 'Oink oink!',
    background: Color(0xFFFCE4EC),
    color: Color(0xFFFF80AB),
    shadow: Color(0xFFC51162),
  ),
  AnimalChoice(
    id: 'sheep',
    emoji: '🐑',
    nameZh: '小羊',
    nameKo: '양',
    nameEn: 'Sheep',
    soundZh: '咩咩咩～',
    soundKo: '메에~',
    soundEn: 'Baa baa!',
    background: Color(0xFFE8F5E9),
    color: Color(0xFF43A047),
    shadow: Color(0xFF1B5E20),
  ),
  AnimalChoice(
    id: 'frog',
    emoji: '🐸',
    nameZh: '青蛙',
    nameKo: '개구리',
    nameEn: 'Frog',
    soundZh: '呱呱呱！',
    soundKo: '개굴개굴!',
    soundEn: 'Ribbit ribbit!',
    background: Color(0xFFE0F2F1),
    color: Color(0xFF00897B),
    shadow: Color(0xFF004D40),
  ),
  AnimalChoice(
    id: 'chick',
    emoji: '🐣',
    nameZh: '小鸡',
    nameKo: '병아리',
    nameEn: 'Chick',
    soundZh: '叽叽叽～',
    soundKo: '삐약삐약~',
    soundEn: 'Cheep cheep!',
    background: Color(0xFFFFF9C4),
    color: Color(0xFFF9A825),
    shadow: Color(0xFFF57F17),
  ),
];

enum AnimalAnswerState { idle, correct, wrong }

class AnimalQuestion {
  const AnimalQuestion({
    required this.target,
    required this.options,
  });

  final AnimalChoice target;
  final List<AnimalChoice> options;
}

class AnimalSoundViewModel extends ChangeNotifier {
  AnimalSoundViewModel(this.args) {
    _question = _generateQuestion();
    _voicePlayer = AudioPlayer(
      playerId: 'animal-voice-${args.gameId.name}-${args.difficulty.name}',
    );
    _playbackCompleteSubscription = _voicePlayer.onPlayerComplete.listen((_) {
      soundPlaying = false;
      notifyListeners();
    });
  }

  static const _soundAssets = <String, String>{
    'dog': 'assets/sounds/animals/dog.m4a',
    'cat': 'assets/sounds/animals/cat.m4a',
    'cow': 'assets/sounds/animals/cow.m4a',
    'duck': 'assets/sounds/animals/duck.m4a',
    'pig': 'assets/sounds/animals/pig.m4a',
    'sheep': 'assets/sounds/animals/sheep.m4a',
    'frog': 'assets/sounds/animals/frog.m4a',
    'chick': 'assets/sounds/animals/chick.m4a',
  };

  final GameRouteArgs args;
  final Random _random = Random();
  late final AudioPlayer _voicePlayer;
  late final StreamSubscription<void> _playbackCompleteSubscription;
  final Map<String, Future<String>> _preparedSoundFiles = {};
  Timer? _roundTimer;

  late AnimalQuestion _question;
  int round = 0;
  int stars = 0;
  bool firstAttempt = true;
  bool locked = false;
  bool hasPlayedOnce = false;
  bool soundPlaying = false;
  AnimalAnswerState answerState = AnimalAnswerState.idle;
  String? wrongOptionId;
  String? correctOptionId;
  RewardRouteArgs? pendingRewardArgs;

  DifficultyConfig get config => args.difficulty.config;

  List<AnimalChoice> get pool => args.difficulty == GameDifficulty.easy
      ? _allAnimals.take(4).toList()
      : _allAnimals;

  bool get noReplay => args.difficulty == GameDifficulty.hard;

  AnimalQuestion get question => _question;

  String get _soundAssetPath =>
      _soundAssets[question.target.id] ?? 'assets/sounds/animals/dog.m4a';

  Future<String> _getPreparedSoundFile(String assetPath) {
    final cached = _preparedSoundFiles[assetPath];
    if (cached != null) {
      return cached;
    }

    late final Future<String> futurePath;
    futurePath = () async {
      final byteData = await rootBundle.load(assetPath);
      final tempDir = await getTemporaryDirectory();
      final fileName = assetPath.split('/').last;
      final outputDir = Directory('${tempDir.path}/kiddo_animal_sounds');
      if (!outputDir.existsSync()) {
        await outputDir.create(recursive: true);
      }

      final outputFile = File('${outputDir.path}/$fileName');
      final bytes = byteData.buffer.asUint8List();
      await outputFile.writeAsBytes(bytes, flush: true);
      return outputFile.path;
    }();

    _preparedSoundFiles[assetPath] = futurePath;
    return futurePath;
  }

  Future<void> playSound() async {
    if (noReplay && hasPlayedOnce) {
      return;
    }
    hasPlayedOnce = true;
    soundPlaying = true;
    notifyListeners();

    try {
      await _voicePlayer.stop();
      await _voicePlayer.setAudioContext(kiddoAudioContext);
      await _voicePlayer.setPlayerMode(PlayerMode.mediaPlayer);
      await _voicePlayer.setReleaseMode(ReleaseMode.stop);
      await _voicePlayer.setVolume(0.94);
      final filePath = await _getPreparedSoundFile(_soundAssetPath);
      await _voicePlayer.play(DeviceFileSource(filePath));
    } catch (error, stackTrace) {
      debugPrint('Animal sound play failed for $_soundAssetPath: $error');
      debugPrintStack(stackTrace: stackTrace);
      soundPlaying = false;
      notifyListeners();
    }
  }

  void select(AnimalChoice animal) {
    if (locked || pendingRewardArgs != null) {
      return;
    }
    locked = true;

    if (animal.id == _question.target.id) {
      stars += firstAttempt ? 1 : 0;
      answerState = AnimalAnswerState.correct;
      correctOptionId = animal.id;
      notifyListeners();
      _roundTimer?.cancel();
      _roundTimer = Timer(const Duration(milliseconds: 1000), () {
        if (round + 1 >= config.rounds) {
          pendingRewardArgs = RewardRouteArgs(
            gameId: args.gameId,
            difficulty: args.difficulty,
            earnedStars: stars,
            totalRounds: config.rounds,
          );
        } else {
          round += 1;
          firstAttempt = true;
          locked = false;
          hasPlayedOnce = false;
          soundPlaying = false;
          answerState = AnimalAnswerState.idle;
          wrongOptionId = null;
          correctOptionId = null;
          _question = _generateQuestion(previousId: animal.id);
        }
        notifyListeners();
      });
    } else {
      firstAttempt = false;
      answerState = AnimalAnswerState.wrong;
      wrongOptionId = animal.id;
      notifyListeners();
      _roundTimer?.cancel();
      _roundTimer = Timer(const Duration(milliseconds: 700), () {
        answerState = AnimalAnswerState.idle;
        wrongOptionId = null;
        locked = false;
        notifyListeners();
      });
    }
  }

  AnimalQuestion _generateQuestion({String? previousId}) {
    final available = [...pool];
    if (previousId != null && available.length > 1) {
      available.removeWhere((animal) => animal.id == previousId);
    }
    final target = available[_random.nextInt(available.length)];
    final distractors = [..._allAnimals]
      ..removeWhere((animal) => animal.id == target.id);
    distractors.shuffle(_random);
    final options = [target, ...distractors.take(config.optionCount - 1)]
      ..shuffle(_random);
    return AnimalQuestion(target: target, options: options);
  }

  Future<void> stopSound() async {
    await _voicePlayer.stop();
    soundPlaying = false;
    notifyListeners();
  }

  Future<void> reset() async {
    _roundTimer?.cancel();
    await _voicePlayer.stop();
    _question = _generateQuestion();
    round = 0;
    stars = 0;
    firstAttempt = true;
    locked = false;
    hasPlayedOnce = false;
    soundPlaying = false;
    answerState = AnimalAnswerState.idle;
    wrongOptionId = null;
    correctOptionId = null;
    pendingRewardArgs = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _roundTimer?.cancel();
    unawaited(_voicePlayer.stop());
    unawaited(_playbackCompleteSubscription.cancel());
    unawaited(_voicePlayer.dispose());
    super.dispose();
  }
}

class AnimalSoundPage extends ConsumerStatefulWidget {
  const AnimalSoundPage({required this.args, super.key});

  final GameRouteArgs args;

  @override
  ConsumerState<AnimalSoundPage> createState() => _AnimalSoundPageState();
}

class _AnimalSoundPageState extends ConsumerState<AnimalSoundPage> {
  bool _isPaused = false;
  late final VoiceGuideController _voiceGuideController;
  late final ProviderSubscription<String> _questionVoiceSubscription;
  late final ProviderSubscription<bool> _voiceGuideSubscription;

  GameRouteArgs get args => widget.args;

  void _handleBack(BuildContext context) {
    unawaited(_voiceGuideController.stop());
    unawaited(ref.read(animalSoundViewModelProvider(args)).stopSound());
    AppRouter.showGameSelect(context);
  }

  @override
  void initState() {
    super.initState();
    _voiceGuideController = ref.read(voiceGuideControllerProvider);
    _questionVoiceSubscription = ref.listenManual<String>(
      animalSoundViewModelProvider(args).select(
          (viewModel) => '${viewModel.round}-${viewModel.question.target.id}'),
      (_, __) {
        if (!mounted || _isPaused) {
          return;
        }
        unawaited(_speakCurrentPrompt());
      },
    );
    _voiceGuideSubscription = ref.listenManual<bool>(
      parentDataProvider.select((parentData) => parentData.voiceGuideEnabled),
      (_, enabled) {
        if (!mounted) {
          return;
        }
        if (!enabled) {
          unawaited(_voiceGuideController.stop());
          return;
        }
        if (!_isPaused) {
          unawaited(_speakCurrentPrompt());
        }
      },
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_speakCurrentPrompt());
    });
  }

  @override
  void dispose() {
    _questionVoiceSubscription.close();
    _voiceGuideSubscription.close();
    unawaited(_voiceGuideController.stop());
    unawaited(ref.read(animalSoundViewModelProvider(args)).stopSound());
    super.dispose();
  }

  void _openPause() {
    if (_isPaused) {
      return;
    }
    unawaited(ref.read(gameSoundControllerProvider).playClick());
    unawaited(_voiceGuideController.stop());
    unawaited(ref.read(animalSoundViewModelProvider(args)).stopSound());
    setState(() {
      _isPaused = true;
    });
  }

  void _closePause() {
    unawaited(ref.read(gameSoundControllerProvider).playClick());
    setState(() {
      _isPaused = false;
    });
  }

  void _restartGame() {
    unawaited(ref.read(gameSoundControllerProvider).playClick());
    unawaited(_voiceGuideController.stop());
    unawaited(ref.read(animalSoundViewModelProvider(args)).reset());
    setState(() {
      _isPaused = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<RewardRouteArgs?>(
      animalSoundViewModelProvider(args)
          .select((viewModel) => viewModel.pendingRewardArgs),
      (_, next) {
        if (next != null) {
          unawaited(_voiceGuideController.stop());
          unawaited(ref.read(animalSoundViewModelProvider(args)).stopSound());
          Navigator.pushReplacementNamed(context, AppRoutes.reward,
              arguments: next);
        }
      },
    );
    ref.listen<AnimalAnswerState>(
      animalSoundViewModelProvider(args)
          .select((viewModel) => viewModel.answerState),
      (previous, next) {
        if (previous == next) {
          return;
        }
        if (next != AnimalAnswerState.idle) {
          unawaited(_voiceGuideController.stop());
          unawaited(ref.read(animalSoundViewModelProvider(args)).stopSound());
        }
        final soundController = ref.read(gameSoundControllerProvider);
        if (next == AnimalAnswerState.correct) {
          unawaited(soundController.playCorrect());
        } else if (next == AnimalAnswerState.wrong) {
          unawaited(soundController.playWrong());
        }
      },
    );
    ref.listen<bool>(
      parentDataProvider.select((controller) => controller.soundEnabled),
      (_, enabled) {
        if (!enabled) {
          unawaited(ref.read(animalSoundViewModelProvider(args)).stopSound());
        }
      },
    );

    final l10n = context.l10n;
    final viewModel = ref.watch(animalSoundViewModelProvider(args));
    final languageCode = Localizations.localeOf(context).languageCode;
    final soundEnabled = ref.watch(
        parentDataProvider.select((controller) => controller.soundEnabled));

    return PopScope<void>(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        final route = ModalRoute.of(context);
        if (didPop || route?.isCurrent != true) {
          return;
        }
        if (_isPaused) {
          _closePause();
        } else {
          _openPause();
        }
      },
      child: FigmaGameScaffold(
        palette: _animalSoundPalette,
        roundLabel:
            l10n.roundCounter(viewModel.round + 1, viewModel.config.rounds),
        difficulty: args.difficulty,
        stars: viewModel.stars,
        progress: viewModel.round / viewModel.config.rounds,
        onPause: _openPause,
        backgroundGradient: const LinearGradient(
          colors: [
            Color(0xFFFFF3E0),
            Color(0xFFFFF9E6),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 96),
        pauseIcon: const FigmaPauseIcon(size: 18, color: Color(0xFFD8622A)),
        floatingAction: const FloatingSoundToggle(
          accentColor: Color(0xFFFFB48E),
          borderColor: Color(0xFFD8622A),
        ),
        pauseDialog: PauseDialog(
          isOpen: _isPaused,
          gameName: args.gameId.title(l10n),
          gameEmoji: args.gameId.emoji,
          onContinue: _closePause,
          onRestart: _restartGame,
          onQuit: () => _handleBack(context),
        ),
        body: KidRoundSwitcher(
          switchKey: '${viewModel.round}-${viewModel.question.target.id}',
          child: Column(
            children: [
              _AnimalPromptCard(
                prompt: viewModel.noReplay
                    ? l10n.animalPromptHard
                    : l10n.animalPrompt,
                question: viewModel.question,
                soundEnabled: soundEnabled,
                soundPlaying: viewModel.soundPlaying,
                hasPlayedOnce: viewModel.hasPlayedOnce,
                noReplay: viewModel.noReplay,
                soundLabel: viewModel.question.target.sound(languageCode),
                replayLabel: viewModel.hasPlayedOnce
                    ? l10n.animalReplay
                    : l10n.animalPlaySound,
                blockedLabel: l10n.animalReplayBlocked,
                onPlay: !soundEnabled
                    ? null
                    : () {
                        ref
                            .read(animalSoundViewModelProvider(args))
                            .playSound();
                      },
              ),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: viewModel.question.options.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 0.95,
                ),
                itemBuilder: (context, index) {
                  final animal = viewModel.question.options[index];
                  return _AnimalOptionTile(
                    animal: animal,
                    correct: viewModel.correctOptionId == animal.id,
                    wrong: viewModel.wrongOptionId == animal.id,
                    onTap: () => ref
                        .read(animalSoundViewModelProvider(args))
                        .select(animal),
                  );
                },
              ),
              const SizedBox(height: 14),
              _AnimalFeedbackBanner(
                isCorrect: viewModel.answerState == AnimalAnswerState.correct,
                isWrong: viewModel.answerState == AnimalAnswerState.wrong,
                correctText: l10n.animalCorrect,
                wrongText: l10n.animalWrong,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _speakCurrentPrompt() async {
    if (!mounted || _isPaused) {
      return;
    }

    final l10n = context.l10n;
    final viewModel = ref.read(animalSoundViewModelProvider(args));
    final result = await _voiceGuideController.speak(
      viewModel.noReplay ? l10n.animalPromptHard : l10n.animalPrompt,
      locale: Localizations.localeOf(context),
    );

    if (!mounted ||
        _isPaused ||
        result != VoiceGuideResult.completed ||
        !ref.read(parentDataProvider).voiceGuideEnabled ||
        !ref.read(parentDataProvider).soundEnabled) {
      return;
    }

    await ref.read(animalSoundViewModelProvider(args)).playSound();
  }
}

class _AnimalPromptCard extends StatelessWidget {
  const _AnimalPromptCard({
    required this.prompt,
    required this.question,
    required this.soundEnabled,
    required this.soundPlaying,
    required this.hasPlayedOnce,
    required this.noReplay,
    required this.soundLabel,
    required this.replayLabel,
    required this.blockedLabel,
    required this.onPlay,
  });

  final String prompt;
  final AnimalQuestion question;
  final bool soundEnabled;
  final bool soundPlaying;
  final bool hasPlayedOnce;
  final bool noReplay;
  final String soundLabel;
  final String replayLabel;
  final String blockedLabel;
  final VoidCallback? onPlay;

  @override
  Widget build(BuildContext context) {
    final accent = question.target.color;
    final shadow = question.target.shadow;

    return FigmaGamePanel(
      palette: _animalSoundPalette,
      child: Column(
        children: [
          Text(
            prompt,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Color(0xFF8A420A),
            ),
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
            decoration: BoxDecoration(
              color: question.target.background,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: accent.withValues(alpha: 0.4),
                width: 2.8,
              ),
            ),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    for (final radius in [152.0, 126.0, 102.0])
                      AnimatedOpacity(
                        opacity: soundPlaying ? 1 : 0.42,
                        duration: const Duration(milliseconds: 220),
                        child: Container(
                          width: radius,
                          height: radius,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: accent.withValues(
                                alpha: soundPlaying ? 0.18 : 0.08,
                              ),
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    GestureDetector(
                      onTap: onPlay,
                      child: Container(
                        width: 138,
                        height: 138,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: soundEnabled
                                ? [accent, shadow]
                                : const [
                                    Color(0xFFE2E5EC),
                                    Color(0xFFC6CBD7),
                                  ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.86),
                            width: 4,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: shadow.withValues(alpha: 0.22),
                              blurRadius: 24,
                              offset: const Offset(0, 14),
                            ),
                          ],
                        ),
                        child: Center(
                          child: soundPlaying
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(
                                    3,
                                    (index) => KidLoopAnimation(
                                      delay:
                                          Duration(milliseconds: index * 120),
                                      duration:
                                          const Duration(milliseconds: 420),
                                      builder: (context, value, child) {
                                        final height = lerpValue(
                                          18,
                                          42,
                                          wave(value, min: 0, max: 1),
                                        );
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 4,
                                          ),
                                          child: Align(
                                            alignment: Alignment.center,
                                            child: Container(
                                              width: 8,
                                              height: height,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(999),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                )
                              : FigmaSpeakerIcon(
                                  size: 34,
                                  color: soundEnabled
                                      ? Colors.white
                                      : const Color(0xFF7A8391),
                                  muted: !soundEnabled,
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  soundLabel,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    color: shadow,
                  ),
                ),
                const SizedBox(height: 14),
                if (!noReplay || !hasPlayedOnce)
                  _AnimalPlayButton(
                    label: replayLabel,
                    enabled: soundEnabled,
                    accent: accent,
                    shadow: shadow,
                    onTap: onPlay,
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF1E7),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: const Color(0xFFFFB48E),
                        width: 2,
                      ),
                    ),
                    child: Text(
                      '🔥 $blockedLabel',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFD8622A),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimalPlayButton extends StatelessWidget {
  const _AnimalPlayButton({
    required this.label,
    required this.enabled,
    required this.accent,
    required this.shadow,
    required this.onTap,
  });

  final String label;
  final bool enabled;
  final Color accent;
  final Color shadow;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: enabled ? onTap : null,
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: enabled
                  ? [accent, shadow]
                  : const [Color(0xFFE2E5EC), Color(0xFFC6CBD7)],
            ),
            borderRadius: BorderRadius.circular(999),
            boxShadow: [
              BoxShadow(
                color: shadow.withValues(alpha: enabled ? 0.18 : 0.08),
                blurRadius: 12,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FigmaSpeakerIcon(
                size: 18,
                color: enabled ? Colors.white : const Color(0xFF7A8391),
                muted: !enabled,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: enabled ? Colors.white : const Color(0xFF7A8391),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimalOptionTile extends StatelessWidget {
  const _AnimalOptionTile({
    required this.animal,
    required this.correct,
    required this.wrong,
    required this.onTap,
  });

  final AnimalChoice animal;
  final bool correct;
  final bool wrong;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: correct || wrong ? 1 : 0),
      duration: Duration(milliseconds: wrong ? 420 : 260),
      curve: Curves.easeOutCubic,
      builder: (context, effect, child) {
        final dx = wrong ? shakeOffset(effect) : 0.0;
        final scale = correct ? punchScale(effect) : 1.0;
        return Transform.translate(
          offset: Offset(dx, 0),
          child: Transform.scale(scale: scale, child: child),
        );
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: onTap,
          child: Ink(
            decoration: BoxDecoration(
              color: correct
                  ? animal.color
                  : wrong
                      ? const Color(0xFFFFD9D9)
                      : animal.background,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: correct
                    ? const Color(0xFFFFD700)
                    : wrong
                        ? const Color(0xFFF44336)
                        : animal.color.withValues(alpha: 0.56),
                width: correct || wrong ? 5 : 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: animal.color.withValues(alpha: 0.12),
                  blurRadius: 16,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Positioned.fill(
                  child: Container(
                    margin: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.18),
                        width: 1.6,
                      ),
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(animal.emoji, style: const TextStyle(fontSize: 46)),
                    const SizedBox(height: 6),
                    Text(
                      animal.name(context),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: correct ? Colors.white : animal.shadow,
                      ),
                    ),
                  ],
                ),
                AnimatedOpacity(
                  opacity: correct ? 1 : 0,
                  duration: const Duration(milliseconds: 180),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(26),
                    ),
                    child: const Center(
                      child: Text('✅', style: TextStyle(fontSize: 42)),
                    ),
                  ),
                ),
                AnimatedOpacity(
                  opacity: wrong ? 1 : 0,
                  duration: const Duration(milliseconds: 180),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0x1FFF0000),
                      borderRadius: BorderRadius.circular(26),
                    ),
                    child: const Center(
                      child: Text('💨', style: TextStyle(fontSize: 34)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimalFeedbackBanner extends StatelessWidget {
  const _AnimalFeedbackBanner({
    required this.isCorrect,
    required this.isWrong,
    required this.correctText,
    required this.wrongText,
  });

  final bool isCorrect;
  final bool isWrong;
  final String correctText;
  final String wrongText;

  @override
  Widget build(BuildContext context) {
    if (!isCorrect && !isWrong) {
      return const SizedBox(height: 72);
    }

    final background =
        isCorrect ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0);
    final border =
        isCorrect ? const Color(0xFF4CAF50) : const Color(0xFFFF8C42);
    final textColor =
        isCorrect ? const Color(0xFF2E7D32) : const Color(0xFFE65100);
    final emoji = isCorrect ? '🌟' : '💪';

    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: border, width: 2.5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              isCorrect ? correctText : wrongText,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w900,
                color: textColor,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(emoji, style: const TextStyle(fontSize: 28)),
        ],
      ),
    );
  }
}
