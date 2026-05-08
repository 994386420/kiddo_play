import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../../app/localization.dart';
import '../../../app/route_args.dart';
import '../../../app/router.dart';
import '../../../core/app_controllers.dart';
import '../../../core/game_models.dart';
import '../../../core/sound/game_sound_controller.dart';
import '../../../core/widgets/floating_sound_toggle.dart';
import '../../../core/widgets/kid_badges.dart';
import '../../../core/widgets/kid_motion.dart';
import '../../../core/widgets/pause_dialog.dart';
import '../../../core/widgets/round_back_button.dart';

final animalSoundViewModelProvider = ChangeNotifierProvider.autoDispose
    .family<AnimalSoundViewModel, GameRouteArgs>((ref, args) {
  return AnimalSoundViewModel(args);
});

class AnimalChoice {
  const AnimalChoice({
    required this.id,
    required this.emoji,
    required this.nameZh,
    required this.nameEn,
    required this.soundZh,
    required this.soundEn,
    required this.background,
    required this.color,
    required this.shadow,
  });

  final String id;
  final String emoji;
  final String nameZh;
  final String nameEn;
  final String soundZh;
  final String soundEn;
  final Color background;
  final Color color;
  final Color shadow;

  String name(BuildContext context) {
    return Localizations.localeOf(context).languageCode == 'zh'
        ? nameZh
        : nameEn;
  }

  String sound(String languageCode) {
    return languageCode == 'zh' ? soundZh : soundEn;
  }
}

const _allAnimals = <AnimalChoice>[
  AnimalChoice(
    id: 'dog',
    emoji: '🐶',
    nameZh: '小狗',
    nameEn: 'Dog',
    soundZh: '汪汪汪！',
    soundEn: 'Woof woof!',
    background: Color(0xFFFFF9C4),
    color: Color(0xFFF9A825),
    shadow: Color(0xFFF57F17),
  ),
  AnimalChoice(
    id: 'cat',
    emoji: '🐱',
    nameZh: '小猫',
    nameEn: 'Cat',
    soundZh: '喵喵喵～',
    soundEn: 'Meow meow!',
    background: Color(0xFFFCE4EC),
    color: Color(0xFFE91E63),
    shadow: Color(0xFF880E4F),
  ),
  AnimalChoice(
    id: 'cow',
    emoji: '🐮',
    nameZh: '奶牛',
    nameEn: 'Cow',
    soundZh: '哞～哞～',
    soundEn: 'Moo moo!',
    background: Color(0xFFF1F8E9),
    color: Color(0xFF7CB342),
    shadow: Color(0xFF33691E),
  ),
  AnimalChoice(
    id: 'duck',
    emoji: '🐤',
    nameZh: '小鸭',
    nameEn: 'Duck',
    soundZh: '嘎嘎嘎！',
    soundEn: 'Quack quack!',
    background: Color(0xFFFFF8E1),
    color: Color(0xFFFFB300),
    shadow: Color(0xFFFF6F00),
  ),
  AnimalChoice(
    id: 'pig',
    emoji: '🐷',
    nameZh: '小猪',
    nameEn: 'Pig',
    soundZh: '哼哼哼～',
    soundEn: 'Oink oink!',
    background: Color(0xFFFCE4EC),
    color: Color(0xFFFF80AB),
    shadow: Color(0xFFC51162),
  ),
  AnimalChoice(
    id: 'sheep',
    emoji: '🐑',
    nameZh: '小羊',
    nameEn: 'Sheep',
    soundZh: '咩咩咩～',
    soundEn: 'Baa baa!',
    background: Color(0xFFE8F5E9),
    color: Color(0xFF43A047),
    shadow: Color(0xFF1B5E20),
  ),
  AnimalChoice(
    id: 'frog',
    emoji: '🐸',
    nameZh: '青蛙',
    nameEn: 'Frog',
    soundZh: '呱呱呱！',
    soundEn: 'Ribbit ribbit!',
    background: Color(0xFFE0F2F1),
    color: Color(0xFF00897B),
    shadow: Color(0xFF004D40),
  ),
  AnimalChoice(
    id: 'chick',
    emoji: '🐣',
    nameZh: '小鸡',
    nameEn: 'Chick',
    soundZh: '叽叽叽～',
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
    _tts = FlutterTts();
  }

  final GameRouteArgs args;
  final Random _random = Random();
  late final FlutterTts _tts;
  Timer? _timer;

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

  Future<void> playSound(String languageCode) async {
    if (noReplay && hasPlayedOnce) {
      return;
    }
    hasPlayedOnce = true;
    soundPlaying = true;
    notifyListeners();

    await _tts.stop();
    await _tts.setLanguage(languageCode == 'zh' ? 'zh-CN' : 'en-US');
    await _tts.setSpeechRate(0.42);
    await _tts.setPitch(languageCode == 'zh' ? 1.25 : 1.1);
    await _tts.speak(question.target.sound(languageCode));

    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 1200), () {
      soundPlaying = false;
      notifyListeners();
    });
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
      _timer?.cancel();
      _timer = Timer(const Duration(milliseconds: 1000), () {
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
      _timer?.cancel();
      _timer = Timer(const Duration(milliseconds: 700), () {
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
    if (!soundPlaying) {
      return;
    }
    await _tts.stop();
    soundPlaying = false;
    notifyListeners();
  }

  Future<void> reset() async {
    _timer?.cancel();
    await _tts.stop();
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
    _timer?.cancel();
    _tts.stop();
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

  GameRouteArgs get args => widget.args;

  void _handleBack(BuildContext context) {
    AppRouter.pushBackwardAndRemoveUntil(
      context,
      name: AppRoutes.gameSelect,
      predicate: (route) => route.settings.name == AppRoutes.home,
    );
  }

  void _openPause() {
    if (_isPaused) {
      return;
    }
    unawaited(ref.read(gameSoundControllerProvider).playClick());
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
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFFF3E0), Color(0xFFFFF9E6)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: SafeArea(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                  children: [
                    _AnimalHeader(
                      title: l10n.roundCounter(
                          viewModel.round + 1, viewModel.config.rounds),
                      difficulty: args.difficulty,
                      stars: viewModel.stars,
                      noReplay: viewModel.noReplay,
                      onBack: _openPause,
                    ),
                    const SizedBox(height: 16),
                    KidAnimatedProgressBar(
                      value: viewModel.round / viewModel.config.rounds,
                      backgroundColor: const Color(0xFFFFD0B5),
                      borderColor: const Color(0xFFFFAB91),
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFAB91), Color(0xFFE64A19)],
                      ),
                    ),
                    const SizedBox(height: 22),
                    KidRoundSwitcher(
                      switchKey:
                          '${viewModel.round}-${viewModel.question.target.id}',
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(22),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                  color: const Color(0xFFFFAB91), width: 4),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  viewModel.noReplay
                                      ? '${l10n.animalPromptHard} 🎵'
                                      : '${l10n.animalPrompt} 🎵',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 21,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF7B3A00),
                                  ),
                                ),
                                const SizedBox(height: 18),
                                Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 24, vertical: 18),
                                      decoration: BoxDecoration(
                                        color: viewModel
                                            .question.target.background,
                                        borderRadius: BorderRadius.circular(28),
                                        border: Border.all(
                                          color: viewModel.question.target.color
                                              .withValues(alpha: 0.56),
                                          width: 3,
                                        ),
                                      ),
                                      child: Column(
                                        children: [
                                          SizedBox(
                                            height: 28,
                                            child: viewModel.soundPlaying
                                                ? Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: List.generate(
                                                      3,
                                                      (index) =>
                                                          KidLoopAnimation(
                                                        delay: Duration(
                                                            milliseconds:
                                                                index * 120),
                                                        duration:
                                                            const Duration(
                                                                milliseconds:
                                                                    420),
                                                        builder: (context,
                                                            value, child) {
                                                          final height =
                                                              lerpValue(
                                                            10,
                                                            24,
                                                            wave(
                                                              value,
                                                              min: 0,
                                                              max: 1,
                                                            ),
                                                          );
                                                          return Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        4),
                                                            child: Align(
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              child: Container(
                                                                width: 6,
                                                                height: height,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: viewModel
                                                                      .question
                                                                      .target
                                                                      .color,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              999),
                                                                ),
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  )
                                                : const Center(
                                                    child: Text('🔊',
                                                        style: TextStyle(
                                                            fontSize: 24)),
                                                  ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            viewModel.question.target
                                                .sound(languageCode),
                                            style: TextStyle(
                                              fontSize: 30,
                                              fontWeight: FontWeight.w900,
                                              color: viewModel
                                                  .question.target.shadow,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Transform.translate(
                                      offset: const Offset(0, -4),
                                      child: Transform.rotate(
                                        angle: pi / 4,
                                        child: Container(
                                          width: 16,
                                          height: 16,
                                          color: viewModel
                                              .question.target.background,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                if (!viewModel.noReplay ||
                                    !viewModel.hasPlayedOnce)
                                  DecoratedBox(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: soundEnabled
                                            ? [
                                                viewModel.question.target.color,
                                                viewModel
                                                    .question.target.shadow,
                                              ]
                                            : [
                                                Colors.grey.shade400,
                                                Colors.grey.shade500,
                                              ],
                                      ),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: ElevatedButton.icon(
                                      onPressed: !soundEnabled
                                          ? null
                                          : () {
                                              ref
                                                  .read(
                                                      animalSoundViewModelProvider(
                                                          args))
                                                  .playSound(languageCode);
                                            },
                                      style: ElevatedButton.styleFrom(
                                        elevation: 0,
                                        shadowColor: Colors.transparent,
                                        backgroundColor: Colors.transparent,
                                        disabledBackgroundColor:
                                            Colors.transparent,
                                        foregroundColor: Colors.white,
                                        disabledForegroundColor: Colors.white70,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 22, vertical: 14),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(999),
                                        ),
                                      ),
                                      icon: const Icon(Icons.volume_up_rounded),
                                      label: Text(
                                        viewModel.hasPlayedOnce
                                            ? l10n.animalReplay
                                            : l10n.animalPlaySound,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w900),
                                      ),
                                    ),
                                  )
                                else
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFF3E0),
                                      borderRadius: BorderRadius.circular(999),
                                      border: Border.all(
                                        color: const Color(0xFFFFAB91),
                                      ),
                                    ),
                                    child: Text(
                                      '🔥 ${l10n.animalReplayBlocked}',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFFE64A19),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: viewModel.question.options.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 14,
                              mainAxisSpacing: 14,
                              childAspectRatio: 0.95,
                            ),
                            itemBuilder: (context, index) {
                              final animal = viewModel.question.options[index];
                              final correct =
                                  viewModel.correctOptionId == animal.id;
                              final wrong =
                                  viewModel.wrongOptionId == animal.id;
                              return TweenAnimationBuilder<double>(
                                tween: Tween<double>(
                                    end: correct || wrong ? 1 : 0),
                                duration:
                                    Duration(milliseconds: wrong ? 420 : 260),
                                curve: Curves.easeOutCubic,
                                builder: (context, effect, child) {
                                  final dx = wrong ? shakeOffset(effect) : 0.0;
                                  final scale =
                                      correct ? punchScale(effect) : 1.0;
                                  return Transform.translate(
                                    offset: Offset(dx, 0),
                                    child: Transform.scale(
                                      scale: scale,
                                      child: child,
                                    ),
                                  );
                                },
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(28),
                                    onTap: () => ref
                                        .read(
                                            animalSoundViewModelProvider(args))
                                        .select(animal),
                                    child: Ink(
                                      decoration: BoxDecoration(
                                        color: correct
                                            ? animal.color
                                            : wrong
                                                ? const Color(0xFFFFCDD2)
                                                : animal.background,
                                        borderRadius: BorderRadius.circular(28),
                                        border: Border.all(
                                          color: correct
                                              ? const Color(0xFFFFD700)
                                              : wrong
                                                  ? const Color(0xFFF44336)
                                                  : animal.color
                                                      .withValues(alpha: 0.56),
                                          width: correct || wrong ? 5 : 3,
                                        ),
                                      ),
                                      child: Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(animal.emoji,
                                                  style: const TextStyle(
                                                      fontSize: 46)),
                                              const SizedBox(height: 6),
                                              Text(
                                                animal.name(context),
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w900,
                                                  color: correct
                                                      ? Colors.white
                                                      : animal.shadow,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ],
                                          ),
                                          AnimatedOpacity(
                                            opacity: correct ? 1 : 0,
                                            duration: const Duration(
                                                milliseconds: 180),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.white
                                                    .withValues(alpha: 0.25),
                                                borderRadius:
                                                    BorderRadius.circular(24),
                                              ),
                                              child: const Center(
                                                child: Text('✅',
                                                    style: TextStyle(
                                                        fontSize: 42)),
                                              ),
                                            ),
                                          ),
                                          AnimatedOpacity(
                                            opacity: wrong ? 1 : 0,
                                            duration: const Duration(
                                                milliseconds: 180),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: const Color(0x1FFF0000),
                                                borderRadius:
                                                    BorderRadius.circular(24),
                                              ),
                                              child: const Center(
                                                child: Text('💨',
                                                    style: TextStyle(
                                                        fontSize: 34)),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    _AnimalFeedbackBanner(
                      isCorrect:
                          viewModel.answerState == AnimalAnswerState.correct,
                      isWrong: viewModel.answerState == AnimalAnswerState.wrong,
                      correctText: l10n.animalCorrect,
                      wrongText: l10n.animalWrong,
                    ),
                  ],
                ),
              ),
            ),
            const FloatingSoundToggle(),
            PauseDialog(
              isOpen: _isPaused,
              gameName: args.gameId.title(l10n),
              gameEmoji: args.gameId.emoji,
              onContinue: _closePause,
              onRestart: _restartGame,
              onQuit: () => _handleBack(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimalHeader extends StatelessWidget {
  const _AnimalHeader({
    required this.title,
    required this.difficulty,
    required this.stars,
    required this.noReplay,
    required this.onBack,
  });

  final String title;
  final GameDifficulty difficulty;
  final int stars;
  final bool noReplay;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        KidRoundBackButton(
          iconColor: const Color(0xFFE64A19),
          borderColor: const Color(0xFFFFAB91),
          icon: Icons.pause_rounded,
          onTap: onBack,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(999),
                  border:
                      Border.all(color: const Color(0xFFFFAB91), width: 2.5),
                ),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFBF360C),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                noReplay
                    ? '${difficulty.badgeEmoji} ${difficulty.label(context.l10n)} · ${context.l10n.animalHardModeHint}'
                    : '${difficulty.badgeEmoji} ${difficulty.label(context.l10n)}',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF546E7A),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        KidStarCounterBadge(
          count: stars,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          iconSize: 20,
          textSize: 18,
        ),
      ],
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
    return SizedBox(
      height: 68,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        switchInCurve: Curves.easeOutBack,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.25),
                end: Offset.zero,
              ).animate(animation),
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.88, end: 1).animate(animation),
                child: child,
              ),
            ),
          );
        },
        child: !isCorrect && !isWrong
            ? const SizedBox.shrink()
            : Container(
                key: ValueKey('${isCorrect}_$isWrong'),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: isCorrect
                      ? const Color(0xFFE8F5E9)
                      : const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isCorrect
                        ? const Color(0xFF4CAF50)
                        : const Color(0xFFFF8C42),
                    width: 2.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    isCorrect ? correctText : wrongText,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: isCorrect
                          ? const Color(0xFF2E7D32)
                          : const Color(0xFFE65100),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
