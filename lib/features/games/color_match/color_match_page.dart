import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/localization.dart';
import '../../../app/route_args.dart';
import '../../../app/router.dart';
import '../../../core/game_models.dart';
import '../../../core/sound/game_sound_controller.dart';
import '../../../core/widgets/floating_sound_toggle.dart';
import '../../../core/widgets/kid_badges.dart';
import '../../../core/widgets/kid_motion.dart';
import '../../../core/widgets/pause_dialog.dart';
import '../../../core/widgets/round_back_button.dart';

final colorMatchViewModelProvider = ChangeNotifierProvider.autoDispose
    .family<ColorMatchViewModel, GameRouteArgs>((ref, args) {
  return ColorMatchViewModel(args);
});

class ColorChoice {
  const ColorChoice({
    required this.id,
    required this.labelZh,
    required this.labelKo,
    required this.labelEn,
    required this.color,
    required this.shadow,
  });

  final String id;
  final String labelZh;
  final String labelKo;
  final String labelEn;
  final Color color;
  final Color shadow;

  String label(BuildContext context) {
    return switch (Localizations.localeOf(context).languageCode) {
      'zh' => labelZh,
      'ko' => labelKo,
      _ => labelEn,
    };
  }
}

const _allColors = <ColorChoice>[
  ColorChoice(
    id: 'red',
    labelZh: '红色',
    labelKo: '빨간색',
    labelEn: 'Red',
    color: Color(0xFFFF4B4B),
    shadow: Color(0xFFC0392B),
  ),
  ColorChoice(
    id: 'blue',
    labelZh: '蓝色',
    labelKo: '파란색',
    labelEn: 'Blue',
    color: Color(0xFF4B9FFF),
    shadow: Color(0xFF1976D2),
  ),
  ColorChoice(
    id: 'yellow',
    labelZh: '黄色',
    labelKo: '노란색',
    labelEn: 'Yellow',
    color: Color(0xFFFFD93D),
    shadow: Color(0xFFF4A200),
  ),
  ColorChoice(
    id: 'green',
    labelZh: '绿色',
    labelKo: '초록색',
    labelEn: 'Green',
    color: Color(0xFF4BC96A),
    shadow: Color(0xFF2E7D32),
  ),
  ColorChoice(
    id: 'orange',
    labelZh: '橙色',
    labelKo: '주황색',
    labelEn: 'Orange',
    color: Color(0xFFFF8C42),
    shadow: Color(0xFFE64A19),
  ),
  ColorChoice(
    id: 'purple',
    labelZh: '紫色',
    labelKo: '보라색',
    labelEn: 'Purple',
    color: Color(0xFFA855F7),
    shadow: Color(0xFF6A0DAD),
  ),
  ColorChoice(
    id: 'pink',
    labelZh: '粉色',
    labelKo: '분홍색',
    labelEn: 'Pink',
    color: Color(0xFFFF70A6),
    shadow: Color(0xFFC2185B),
  ),
  ColorChoice(
    id: 'cyan',
    labelZh: '青色',
    labelKo: '하늘색',
    labelEn: 'Cyan',
    color: Color(0xFF26C6DA),
    shadow: Color(0xFF00838F),
  ),
  ColorChoice(
    id: 'brown',
    labelZh: '棕色',
    labelKo: '갈색',
    labelEn: 'Brown',
    color: Color(0xFFA98274),
    shadow: Color(0xFF6D4C41),
  ),
  ColorChoice(
    id: 'lime',
    labelZh: '黄绿色',
    labelKo: '연두색',
    labelEn: 'Lime',
    color: Color(0xFF9CCC65),
    shadow: Color(0xFF558B2F),
  ),
  ColorChoice(
    id: 'teal',
    labelZh: '青绿色',
    labelKo: '청록색',
    labelEn: 'Teal',
    color: Color(0xFF26A69A),
    shadow: Color(0xFF00695C),
  ),
  ColorChoice(
    id: 'indigo',
    labelZh: '靛蓝色',
    labelKo: '남색',
    labelEn: 'Indigo',
    color: Color(0xFF5C6BC0),
    shadow: Color(0xFF303F9F),
  ),
  ColorChoice(
    id: 'mint',
    labelZh: '薄荷色',
    labelKo: '민트색',
    labelEn: 'Mint',
    color: Color(0xFF66D9B8),
    shadow: Color(0xFF1B9E77),
  ),
];

enum ColorAnswerState { idle, correct, wrong }

class ColorQuestion {
  const ColorQuestion({
    required this.target,
    required this.options,
  });

  final ColorChoice target;
  final List<ColorChoice> options;
}

class ColorMatchViewModel extends ChangeNotifier {
  ColorMatchViewModel(this.args) {
    _pool = _buildSessionPool();
    _question = _generateQuestion();
  }

  final GameRouteArgs args;
  final Random _random = Random();
  Timer? _timer;

  late List<ColorChoice> _pool;
  late ColorQuestion _question;
  int round = 0;
  int stars = 0;
  bool firstAttempt = true;
  bool locked = false;
  ColorAnswerState answerState = ColorAnswerState.idle;
  String? wrongOptionId;
  String? correctOptionId;
  RewardRouteArgs? pendingRewardArgs;

  DifficultyConfig get config => args.difficulty.config;

  List<ColorChoice> get pool => _pool;

  ColorQuestion get question => _question;

  void select(ColorChoice choice) {
    if (locked || pendingRewardArgs != null) {
      return;
    }
    locked = true;

    if (choice.id == _question.target.id) {
      final earnedStar = firstAttempt ? 1 : 0;
      stars += earnedStar;
      correctOptionId = choice.id;
      answerState = ColorAnswerState.correct;
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
          answerState = ColorAnswerState.idle;
          wrongOptionId = null;
          correctOptionId = null;
          _question = _generateQuestion(previousTargetId: choice.id);
        }
        notifyListeners();
      });
    } else {
      answerState = ColorAnswerState.wrong;
      wrongOptionId = choice.id;
      firstAttempt = false;
      notifyListeners();

      _timer?.cancel();
      _timer = Timer(const Duration(milliseconds: 700), () {
        answerState = ColorAnswerState.idle;
        wrongOptionId = null;
        locked = false;
        notifyListeners();
      });
    }
  }

  ColorQuestion _generateQuestion({String? previousTargetId}) {
    final available = [...pool];
    if (previousTargetId != null && available.length > 1) {
      available.removeWhere((choice) => choice.id == previousTargetId);
    }
    final target = available[_random.nextInt(available.length)];
    final distractors = [...pool]
      ..removeWhere((choice) => choice.id == target.id);
    distractors.shuffle(_random);
    final optionCount = args.difficulty.config.optionCount;
    final options = [target, ...distractors.take(optionCount - 1)]
      ..shuffle(_random);
    return ColorQuestion(target: target, options: options);
  }

  List<ColorChoice> _buildSessionPool() {
    final desiredCount = switch (args.difficulty) {
      GameDifficulty.easy => 5,
      GameDifficulty.medium => 8,
      GameDifficulty.hard => 10,
    };

    final shuffled = [..._allColors]..shuffle(_random);
    return shuffled.take(min(desiredCount, shuffled.length)).toList();
  }

  void reset() {
    _timer?.cancel();
    _pool = _buildSessionPool();
    _question = _generateQuestion();
    round = 0;
    stars = 0;
    firstAttempt = true;
    locked = false;
    answerState = ColorAnswerState.idle;
    wrongOptionId = null;
    correctOptionId = null;
    pendingRewardArgs = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

class ColorMatchPage extends ConsumerStatefulWidget {
  const ColorMatchPage({required this.args, super.key});

  final GameRouteArgs args;

  @override
  ConsumerState<ColorMatchPage> createState() => _ColorMatchPageState();
}

class _ColorMatchPageState extends ConsumerState<ColorMatchPage> {
  bool _isPaused = false;
  late final GameSoundController _soundController;

  GameRouteArgs get args => widget.args;

  void _handleBack(BuildContext context) {
    AppRouter.pushBackwardAndRemoveUntil(
      context,
      name: AppRoutes.gameSelect,
      predicate: (route) => route.settings.name == AppRoutes.home,
    );
  }

  @override
  void initState() {
    super.initState();
    _soundController = ref.read(gameSoundControllerProvider);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_soundController.startBgm());
    });
  }

  @override
  void dispose() {
    unawaited(_soundController.stopBgm());
    super.dispose();
  }

  void _openPause() {
    if (_isPaused) {
      return;
    }
    unawaited(ref.read(gameSoundControllerProvider).playClick());
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
    ref.read(colorMatchViewModelProvider(args)).reset();
    setState(() {
      _isPaused = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<RewardRouteArgs?>(
      colorMatchViewModelProvider(args)
          .select((viewModel) => viewModel.pendingRewardArgs),
      (_, next) {
        if (next != null) {
          Navigator.pushReplacementNamed(
            context,
            AppRoutes.reward,
            arguments: next,
          );
        }
      },
    );
    ref.listen<ColorAnswerState>(
      colorMatchViewModelProvider(args)
          .select((viewModel) => viewModel.answerState),
      (previous, next) {
        if (previous == next) {
          return;
        }
        final soundController = ref.read(gameSoundControllerProvider);
        if (next == ColorAnswerState.correct) {
          unawaited(soundController.playCorrect());
        } else if (next == ColorAnswerState.wrong) {
          unawaited(soundController.playWrong());
        }
      },
    );

    final l10n = context.l10n;
    final viewModel = ref.watch(colorMatchViewModelProvider(args));
    final progress = viewModel.round / viewModel.config.rounds;

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
                  colors: [Color(0xFFE8F5FF), Color(0xFFFFF9E6)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: SafeArea(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                  children: [
                    _GameHeader(
                      iconColor: const Color(0xFF1976D2),
                      progressColor: const Color(0xFF1976D2),
                      borderColor: const Color(0xFF90CAF9),
                      title: l10n.roundCounter(
                          viewModel.round + 1, viewModel.config.rounds),
                      difficulty: args.difficulty,
                      stars: viewModel.stars,
                      onBack: _openPause,
                    ),
                    const SizedBox(height: 16),
                    KidAnimatedProgressBar(
                      value: progress,
                      backgroundColor: const Color(0xFFC8E6FB),
                      borderColor: const Color(0xFF90CAF9),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4FC3F7), Color(0xFF1976D2)],
                      ),
                    ),
                    const SizedBox(height: 22),
                    KidRoundSwitcher(
                      switchKey:
                          '${viewModel.round}-${viewModel.question.target.id}',
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.fromLTRB(24, 24, 24, 22),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                  color: const Color(0xFF4FC3F7), width: 4),
                            ),
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      gradient: RadialGradient(
                                        colors: [
                                          viewModel.question.target.color
                                              .withValues(alpha: 0.16),
                                          Colors.transparent,
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Column(
                                  children: [
                                    Text(
                                      '${l10n.colorMatchPrompt} 👇',
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF546E7A),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    KidLoopAnimation(
                                      duration: const Duration(seconds: 2),
                                      builder: (context, value, child) {
                                        final scale =
                                            lerpValue(1, 1.05, wave(value));
                                        return Transform.scale(
                                          scale: scale,
                                          child: child,
                                        );
                                      },
                                      child: Container(
                                        width: 120,
                                        height: 120,
                                        decoration: BoxDecoration(
                                          color:
                                              viewModel.question.target.color,
                                          borderRadius:
                                              BorderRadius.circular(28),
                                          boxShadow: [
                                            BoxShadow(
                                              color: viewModel
                                                  .question.target.shadow
                                                  .withValues(alpha: 0.36),
                                              blurRadius: 20,
                                              offset: const Offset(0, 10),
                                            ),
                                          ],
                                        ),
                                        child: Align(
                                          alignment:
                                              const Alignment(-0.36, -0.5),
                                          child: Container(
                                            width: 30,
                                            height: 16,
                                            decoration: BoxDecoration(
                                              color: Colors.white
                                                  .withValues(alpha: 0.42),
                                              borderRadius:
                                                  BorderRadius.circular(999),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: viewModel.question.target.color,
                                        borderRadius:
                                            BorderRadius.circular(999),
                                        boxShadow: [
                                          BoxShadow(
                                            color: viewModel
                                                .question.target.shadow
                                                .withValues(alpha: 0.3),
                                            blurRadius: 14,
                                            offset: const Offset(0, 8),
                                          ),
                                        ],
                                      ),
                                      child: Text(
                                        viewModel.question.target
                                            .label(context),
                                        style: const TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
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
                              childAspectRatio: 1.18,
                            ),
                            itemBuilder: (context, index) {
                              final option = viewModel.question.options[index];
                              return _ColorOptionTile(
                                label: option.label(context),
                                color: option.color,
                                shadow: option.shadow,
                                correct: viewModel.correctOptionId == option.id,
                                wrong: viewModel.wrongOptionId == option.id,
                                onTap: () => ref
                                    .read(colorMatchViewModelProvider(args))
                                    .select(option),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    _FeedbackBanner(state: viewModel.answerState),
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

class _GameHeader extends StatelessWidget {
  const _GameHeader({
    required this.iconColor,
    required this.progressColor,
    required this.borderColor,
    required this.title,
    required this.difficulty,
    required this.stars,
    required this.onBack,
  });

  final Color iconColor;
  final Color progressColor;
  final Color borderColor;
  final String title;
  final GameDifficulty difficulty;
  final int stars;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        KidRoundBackButton(
          iconColor: iconColor,
          borderColor: borderColor,
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
                  border: Border.all(color: borderColor, width: 2.5),
                ),
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: progressColor,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${difficulty.badgeEmoji} ${difficulty.label(context.l10n)}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF546E7A),
                  ),
                ),
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

class _ColorOptionTile extends StatelessWidget {
  const _ColorOptionTile({
    required this.label,
    required this.color,
    required this.shadow,
    required this.correct,
    required this.wrong,
    required this.onTap,
  });

  final String label;
  final Color color;
  final Color shadow;
  final bool correct;
  final bool wrong;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: correct || wrong ? 1 : 0),
      duration: Duration(milliseconds: wrong ? 420 : 260),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        final dx = wrong ? shakeOffset(value) : 0.0;
        final scale = correct ? punchScale(value) : 1.0;
        return Transform.translate(
          offset: Offset(dx, 0),
          child: Transform.scale(scale: scale, child: child),
        );
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: onTap,
          child: Ink(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: correct
                    ? const Color(0xFFFFD700)
                    : wrong
                        ? const Color(0xFFF44336)
                        : shadow,
                width: correct || wrong ? 5 : 4,
              ),
              boxShadow: [
                BoxShadow(
                  color: shadow.withValues(alpha: 0.34),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Align(
                  alignment: const Alignment(-0.6, -0.72),
                  child: Container(
                    width: 36,
                    height: 18,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.28),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
                AnimatedOpacity(
                  opacity: correct ? 1 : 0,
                  duration: const Duration(milliseconds: 180),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(24),
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
                      color: const Color(0x33FF0000),
                      borderRadius: BorderRadius.circular(24),
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

class _FeedbackBanner extends StatelessWidget {
  const _FeedbackBanner({required this.state});

  final ColorAnswerState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SizedBox(
      height: 68,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        switchInCurve: Curves.easeOutBack,
        switchOutCurve: Curves.easeInCubic,
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
        child: state == ColorAnswerState.idle
            ? const SizedBox.shrink()
            : Container(
                key: ValueKey(state),
                margin: const EdgeInsets.only(top: 4),
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                decoration: BoxDecoration(
                  color: state == ColorAnswerState.correct
                      ? const Color(0xFFE8F5E9)
                      : const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: state == ColorAnswerState.correct
                        ? const Color(0xFF4CAF50)
                        : const Color(0xFFFF8C42),
                    width: 2.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    state == ColorAnswerState.correct
                        ? l10n.feedbackCorrect
                        : l10n.feedbackTryAgain,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: state == ColorAnswerState.correct
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
