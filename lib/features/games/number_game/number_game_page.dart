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

final numberGameViewModelProvider = ChangeNotifierProvider.autoDispose
    .family<NumberGameViewModel, GameRouteArgs>((ref, args) {
  return NumberGameViewModel(args);
});

class EmojiSet {
  const EmojiSet(this.emoji, this.label, this.background);

  final String emoji;
  final String label;
  final Color background;
}

const _emojiSets = <EmojiSet>[
  EmojiSet('🍎', 'Apples', Color(0xFFFFE5E5)),
  EmojiSet('⭐', 'Stars', Color(0xFFFFFDE7)),
  EmojiSet('🌸', 'Flowers', Color(0xFFFCE4EC)),
  EmojiSet('🦋', 'Butterflies', Color(0xFFE8F5E9)),
  EmojiSet('🎈', 'Balloons', Color(0xFFE3F2FD)),
  EmojiSet('🍭', 'Lollipops', Color(0xFFF3E5F5)),
  EmojiSet('🐠', 'Fish', Color(0xFFE0F7FA)),
];

enum NumberAnswerState { idle, correct, wrong }

class NumberQuestion {
  const NumberQuestion({
    required this.emojiSet,
    required this.count,
    required this.options,
  });

  final EmojiSet emojiSet;
  final int count;
  final List<int> options;
}

class NumberGameViewModel extends ChangeNotifier {
  NumberGameViewModel(this.args) {
    _question = _generateQuestion();
  }

  final GameRouteArgs args;
  final Random _random = Random();
  Timer? _timer;

  late NumberQuestion _question;
  int round = 0;
  int stars = 0;
  bool firstAttempt = true;
  bool locked = false;
  NumberAnswerState answerState = NumberAnswerState.idle;
  int? wrongValue;
  int? correctValue;
  RewardRouteArgs? pendingRewardArgs;

  DifficultyConfig get config => args.difficulty.config;

  NumberQuestion get question => _question;

  int get maxCount {
    switch (args.difficulty) {
      case GameDifficulty.easy:
        return 5;
      case GameDifficulty.medium:
        return 9;
      case GameDifficulty.hard:
        return 15;
    }
  }

  void select(int value) {
    if (locked || pendingRewardArgs != null) {
      return;
    }
    locked = true;

    if (value == _question.count) {
      stars += firstAttempt ? 1 : 0;
      answerState = NumberAnswerState.correct;
      correctValue = value;
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
          answerState = NumberAnswerState.idle;
          wrongValue = null;
          correctValue = null;
          _question = _generateQuestion(previousCount: value);
        }
        notifyListeners();
      });
    } else {
      firstAttempt = false;
      answerState = NumberAnswerState.wrong;
      wrongValue = value;
      notifyListeners();
      _timer?.cancel();
      _timer = Timer(const Duration(milliseconds: 700), () {
        answerState = NumberAnswerState.idle;
        wrongValue = null;
        locked = false;
        notifyListeners();
      });
    }
  }

  NumberQuestion _generateQuestion({int? previousCount}) {
    int count;
    do {
      count = _random.nextInt(maxCount) + 1;
    } while (previousCount != null && count == previousCount);

    final optionCount = config.optionCount;
    final options = <int>{count};
    while (options.length < optionCount) {
      options.add(_random.nextInt(maxCount) + 1);
    }
    final items = options.toList()..shuffle(_random);
    return NumberQuestion(
      emojiSet: _emojiSets[_random.nextInt(_emojiSets.length)],
      count: count,
      options: items,
    );
  }

  void reset() {
    _timer?.cancel();
    _question = _generateQuestion();
    round = 0;
    stars = 0;
    firstAttempt = true;
    locked = false;
    answerState = NumberAnswerState.idle;
    wrongValue = null;
    correctValue = null;
    pendingRewardArgs = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

class NumberGamePage extends ConsumerStatefulWidget {
  const NumberGamePage({required this.args, super.key});

  final GameRouteArgs args;

  @override
  ConsumerState<NumberGamePage> createState() => _NumberGamePageState();
}

class _NumberGamePageState extends ConsumerState<NumberGamePage> {
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
    ref.read(numberGameViewModelProvider(args)).reset();
    setState(() {
      _isPaused = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<RewardRouteArgs?>(
      numberGameViewModelProvider(args)
          .select((viewModel) => viewModel.pendingRewardArgs),
      (_, next) {
        if (next != null) {
          Navigator.pushReplacementNamed(context, AppRoutes.reward,
              arguments: next);
        }
      },
    );
    ref.listen<NumberAnswerState>(
      numberGameViewModelProvider(args)
          .select((viewModel) => viewModel.answerState),
      (previous, next) {
        if (previous == next) {
          return;
        }
        final soundController = ref.read(gameSoundControllerProvider);
        if (next == NumberAnswerState.correct) {
          unawaited(soundController.playCorrect());
        } else if (next == NumberAnswerState.wrong) {
          unawaited(soundController.playWrong());
        }
      },
    );

    final l10n = context.l10n;
    final viewModel = ref.watch(numberGameViewModelProvider(args));

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
                  colors: [Color(0xFFE8FFE8), Color(0xFFFFF9E6)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: SafeArea(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                  children: [
                    _NumberHeader(
                      title: l10n.roundCounter(
                          viewModel.round + 1, viewModel.config.rounds),
                      difficulty: args.difficulty,
                      stars: viewModel.stars,
                      onBack: _openPause,
                    ),
                    const SizedBox(height: 16),
                    KidAnimatedProgressBar(
                      value: viewModel.round / viewModel.config.rounds,
                      backgroundColor: const Color(0xFFC8F0C8),
                      borderColor: const Color(0xFFA5D6A7),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF81C784), Color(0xFF388E3C)],
                      ),
                    ),
                    const SizedBox(height: 22),
                    KidRoundSwitcher(
                      switchKey:
                          '${viewModel.round}-${viewModel.question.count}-${viewModel.question.emojiSet.emoji}',
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(22),
                            decoration: BoxDecoration(
                              color: viewModel.question.emojiSet.background,
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                  color: const Color(0xFFA5D6A7), width: 4),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  '${l10n.numberPrompt} 🔢',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF2E7D32),
                                  ),
                                ),
                                const SizedBox(height: 18),
                                Wrap(
                                  alignment: WrapAlignment.center,
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: List.generate(
                                    viewModel.question.count,
                                    (index) => KidDelayedReveal(
                                      key: ValueKey(
                                          '${viewModel.round}-${viewModel.question.emojiSet.emoji}-$index'),
                                      delay: Duration(milliseconds: index * 45),
                                      beginScale: 0.7,
                                      beginOffset: const Offset(0, 0.12),
                                      child: Text(
                                        viewModel.question.emojiSet.emoji,
                                        style: TextStyle(
                                          fontSize: viewModel.question.count > 9
                                              ? 28
                                              : viewModel.question.count > 5
                                                  ? 34
                                                  : 40,
                                        ),
                                      ),
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
                              childAspectRatio: 1.6,
                            ),
                            itemBuilder: (context, index) {
                              final value = viewModel.question.options[index];
                              final correct = viewModel.correctValue == value;
                              final wrong = viewModel.wrongValue == value;
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
                                        .read(numberGameViewModelProvider(args))
                                        .select(value),
                                    child: Ink(
                                      decoration: BoxDecoration(
                                        color: correct
                                            ? const Color(0xFF388E3C)
                                            : wrong
                                                ? const Color(0xFFFFCDD2)
                                                : Colors.white,
                                        borderRadius: BorderRadius.circular(28),
                                        border: Border.all(
                                          color: correct
                                              ? const Color(0xFFFFD700)
                                              : wrong
                                                  ? const Color(0xFFF44336)
                                                  : const Color(0xFFA5D6A7),
                                          width: correct || wrong ? 5 : 4,
                                        ),
                                      ),
                                      child: Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          Center(
                                            child: Text(
                                              '$value',
                                              style: TextStyle(
                                                fontSize: 50,
                                                fontWeight: FontWeight.w900,
                                                color: correct
                                                    ? Colors.white
                                                    : const Color(0xFF2E7D32),
                                              ),
                                            ),
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
                    _SimpleFeedbackBanner(
                      isCorrect:
                          viewModel.answerState == NumberAnswerState.correct,
                      isWrong: viewModel.answerState == NumberAnswerState.wrong,
                      correctText: l10n.numberCorrect,
                      wrongText: l10n.numberWrong,
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

class _NumberHeader extends StatelessWidget {
  const _NumberHeader({
    required this.title,
    required this.difficulty,
    required this.stars,
    required this.onBack,
  });

  final String title;
  final GameDifficulty difficulty;
  final int stars;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        KidRoundBackButton(
          iconColor: const Color(0xFF388E3C),
          borderColor: const Color(0xFFA5D6A7),
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
                      Border.all(color: const Color(0xFFA5D6A7), width: 2.5),
                ),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF388E3C),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${difficulty.badgeEmoji} ${difficulty.label(context.l10n)}',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF546E7A),
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

class _SimpleFeedbackBanner extends StatelessWidget {
  const _SimpleFeedbackBanner({
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
