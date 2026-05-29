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
import '../../../core/widgets/figma_game_icons.dart';
import '../../../core/widgets/figma_game_shell.dart';
import '../../../core/widgets/figma_home_icons.dart';
import '../../../core/widgets/kid_motion.dart';
import '../../../core/widgets/pause_dialog.dart';

const _numberGamePalette = FigmaGamePalette(
  accent: Color(0xFF7EDB8A),
  accentStrong: Color(0xFF2E8A42),
  accentSoft: Color(0xFFF1FFF0),
  progressTrack: Color(0xFFD9F4D8),
  progressBorder: Color(0xFFA6D6A8),
  progressGradient: LinearGradient(
    colors: [Color(0xFF86DB90), Color(0xFF2E8A42)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  ),
  floaterIcon: FigmaFloatIconType.flower,
);

final numberGameViewModelProvider = ChangeNotifierProvider.autoDispose
    .family<NumberGameViewModel, GameRouteArgs>((ref, args) {
  return NumberGameViewModel(args);
});

class EmojiSet {
  const EmojiSet({
    required this.emoji,
    required this.labelZh,
    required this.labelKo,
    required this.labelEn,
    required this.background,
  });

  final String emoji;
  final String labelZh;
  final String labelKo;
  final String labelEn;
  final Color background;

  String label(BuildContext context) {
    return switch (Localizations.localeOf(context).languageCode) {
      'zh' => labelZh,
      'ko' => labelKo,
      _ => labelEn,
    };
  }
}

const _emojiSets = <EmojiSet>[
  EmojiSet(
    emoji: '🍎',
    labelZh: '苹果',
    labelKo: '사과',
    labelEn: 'apples',
    background: Color(0xFFFFE5E5),
  ),
  EmojiSet(
    emoji: '⭐',
    labelZh: '星星',
    labelKo: '별',
    labelEn: 'stars',
    background: Color(0xFFFFFDE7),
  ),
  EmojiSet(
    emoji: '🌸',
    labelZh: '花朵',
    labelKo: '꽃',
    labelEn: 'flowers',
    background: Color(0xFFFCE4EC),
  ),
  EmojiSet(
    emoji: '🦋',
    labelZh: '蝴蝶',
    labelKo: '나비',
    labelEn: 'butterflies',
    background: Color(0xFFE8F5E9),
  ),
  EmojiSet(
    emoji: '🎈',
    labelZh: '气球',
    labelKo: '풍선',
    labelEn: 'balloons',
    background: Color(0xFFE3F2FD),
  ),
  EmojiSet(
    emoji: '🍭',
    labelZh: '棒棒糖',
    labelKo: '막대사탕',
    labelEn: 'lollipops',
    background: Color(0xFFF3E5F5),
  ),
  EmojiSet(
    emoji: '🐠',
    labelZh: '小鱼',
    labelKo: '물고기',
    labelEn: 'fish',
    background: Color(0xFFE0F7FA),
  ),
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
    AppRouter.showGameSelect(context);
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
      child: FigmaGameScaffold(
        palette: _numberGamePalette,
        roundLabel:
            l10n.roundCounter(viewModel.round + 1, viewModel.config.rounds),
        difficulty: args.difficulty,
        stars: viewModel.stars,
        progress: viewModel.round / viewModel.config.rounds,
        onPause: _openPause,
        backgroundGradient: const LinearGradient(
          colors: [
            Color(0xFFE8FFE8),
            Color(0xFFFFF9E6),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 96),
        pauseIcon: const FigmaPauseIcon(size: 18, color: Color(0xFF2E8A42)),
        floatingAction: const FloatingSoundToggle(
          accentColor: Color(0xFF7EDB8A),
          borderColor: Color(0xFF2E8A42),
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
          switchKey:
              '${viewModel.round}-${viewModel.question.count}-${viewModel.question.emojiSet.emoji}',
          child: Column(
            children: [
              _NumberPromptCard(
                prompt: l10n.numberPrompt,
                question: viewModel.question,
                round: viewModel.round,
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
                  childAspectRatio: 1.26,
                ),
                itemBuilder: (context, index) {
                  final value = viewModel.question.options[index];
                  final correct = viewModel.correctValue == value;
                  final wrong = viewModel.wrongValue == value;
                  return _NumberOptionTile(
                    value: value,
                    correct: correct,
                    wrong: wrong,
                    onTap: () => ref
                        .read(numberGameViewModelProvider(args))
                        .select(value),
                  );
                },
              ),
              const SizedBox(height: 14),
              _SimpleFeedbackBanner(
                isCorrect: viewModel.answerState == NumberAnswerState.correct,
                isWrong: viewModel.answerState == NumberAnswerState.wrong,
                correctText: l10n.numberCorrect,
                wrongText: l10n.numberWrong,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NumberPromptCard extends StatelessWidget {
  const _NumberPromptCard({
    required this.prompt,
    required this.question,
    required this.round,
  });

  final String prompt;
  final NumberQuestion question;
  final int round;

  @override
  Widget build(BuildContext context) {
    final emojiSize = question.count > 9
        ? 28.0
        : question.count > 5
            ? 34.0
            : 40.0;
    final promptText = switch (Localizations.localeOf(context).languageCode) {
      'zh' => '数一数，有几个${question.emojiSet.label(context)}？🔢',
      'ko' => '${question.emojiSet.label(context)}가 몇 개 있을까요? 🔢',
      _ => '$prompt ${question.emojiSet.label(context)}? 🔢',
    };

    return FigmaGamePanel(
      palette: _numberGamePalette,
      child: Column(
        children: [
          Text(
            promptText,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Color(0xFF327940),
            ),
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
            decoration: BoxDecoration(
              color: question.emojiSet.background,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: _numberGamePalette.progressBorder,
                width: 2.6,
              ),
            ),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 10,
              runSpacing: 10,
              children: List.generate(
                question.count,
                (index) => KidDelayedReveal(
                  key: ValueKey('$round-${question.emojiSet.emoji}-$index'),
                  delay: Duration(milliseconds: index * 45),
                  beginScale: 0.72,
                  beginOffset: const Offset(0, 0.12),
                  child: Text(
                    question.emojiSet.emoji,
                    style: TextStyle(fontSize: emojiSize),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NumberOptionTile extends StatelessWidget {
  const _NumberOptionTile({
    required this.value,
    required this.correct,
    required this.wrong,
    required this.onTap,
  });

  final int value;
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
                  ? const Color(0xFF2E8A42)
                  : wrong
                      ? const Color(0xFFFFD9D9)
                      : Colors.white,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: correct
                    ? const Color(0xFFFFD700)
                    : wrong
                        ? const Color(0xFFF44336)
                        : _numberGamePalette.progressBorder,
                width: correct || wrong ? 5 : 4,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2E8A42).withValues(alpha: 0.10),
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
                        color: Colors.white.withValues(alpha: 0.22),
                        width: 1.6,
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    '$value',
                    style: TextStyle(
                      fontSize: 50,
                      fontWeight: FontWeight.w900,
                      color: correct ? Colors.white : const Color(0xFF2E8A42),
                    ),
                  ),
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
