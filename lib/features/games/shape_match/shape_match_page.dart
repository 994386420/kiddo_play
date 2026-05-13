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

final shapeMatchViewModelProvider = ChangeNotifierProvider.autoDispose
    .family<ShapeMatchViewModel, GameRouteArgs>((ref, args) {
  return ShapeMatchViewModel(args);
});

class ShapeChoice {
  const ShapeChoice({
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

const _allShapes = <ShapeChoice>[
  ShapeChoice(
    id: 'circle',
    labelZh: '圆形',
    labelKo: '원형',
    labelEn: 'Circle',
    color: Color(0xFFFF4B4B),
    shadow: Color(0xFFC0392B),
  ),
  ShapeChoice(
    id: 'square',
    labelZh: '正方形',
    labelKo: '정사각형',
    labelEn: 'Square',
    color: Color(0xFF4B9FFF),
    shadow: Color(0xFF1976D2),
  ),
  ShapeChoice(
    id: 'triangle',
    labelZh: '三角形',
    labelKo: '삼각형',
    labelEn: 'Triangle',
    color: Color(0xFF4BC96A),
    shadow: Color(0xFF2E7D32),
  ),
  ShapeChoice(
    id: 'star',
    labelZh: '五角星',
    labelKo: '별',
    labelEn: 'Star',
    color: Color(0xFFFFD93D),
    shadow: Color(0xFFF4A200),
  ),
  ShapeChoice(
    id: 'heart',
    labelZh: '心形',
    labelKo: '하트',
    labelEn: 'Heart',
    color: Color(0xFFFF70A6),
    shadow: Color(0xFFC2185B),
  ),
  ShapeChoice(
    id: 'diamond',
    labelZh: '菱形',
    labelKo: '마름모',
    labelEn: 'Diamond',
    color: Color(0xFFA855F7),
    shadow: Color(0xFF6A0DAD),
  ),
];

enum ShapeAnswerState { idle, correct, wrong }

class ShapeQuestion {
  const ShapeQuestion({
    required this.target,
    required this.options,
  });

  final ShapeChoice target;
  final List<ShapeChoice> options;
}

class ShapeMatchViewModel extends ChangeNotifier {
  ShapeMatchViewModel(this.args) {
    _question = _generateQuestion();
  }

  final GameRouteArgs args;
  final Random _random = Random();
  Timer? _timer;

  late ShapeQuestion _question;
  int round = 0;
  int stars = 0;
  bool firstAttempt = true;
  bool locked = false;
  ShapeAnswerState answerState = ShapeAnswerState.idle;
  String? wrongOptionId;
  String? correctOptionId;
  RewardRouteArgs? pendingRewardArgs;

  DifficultyConfig get config => args.difficulty.config;

  List<ShapeChoice> get pool => args.difficulty == GameDifficulty.easy
      ? _allShapes.take(3).toList()
      : _allShapes;

  bool get hideNameInQuestion => args.difficulty == GameDifficulty.hard;

  ShapeQuestion get question => _question;

  void select(ShapeChoice choice) {
    if (locked || pendingRewardArgs != null) {
      return;
    }
    locked = true;

    if (choice.id == _question.target.id) {
      stars += firstAttempt ? 1 : 0;
      answerState = ShapeAnswerState.correct;
      correctOptionId = choice.id;
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
          answerState = ShapeAnswerState.idle;
          wrongOptionId = null;
          correctOptionId = null;
          _question = _generateQuestion(previousId: choice.id);
        }
        notifyListeners();
      });
    } else {
      firstAttempt = false;
      answerState = ShapeAnswerState.wrong;
      wrongOptionId = choice.id;
      notifyListeners();
      _timer?.cancel();
      _timer = Timer(const Duration(milliseconds: 700), () {
        answerState = ShapeAnswerState.idle;
        wrongOptionId = null;
        locked = false;
        notifyListeners();
      });
    }
  }

  ShapeQuestion _generateQuestion({String? previousId}) {
    final available = [...pool];
    if (previousId != null && available.length > 1) {
      available.removeWhere((choice) => choice.id == previousId);
    }
    final target = available[_random.nextInt(available.length)];
    final distractors = [..._allShapes]
      ..removeWhere((choice) => choice.id == target.id);
    distractors.shuffle(_random);
    final options = [target, ...distractors.take(config.optionCount - 1)]
      ..shuffle(_random);
    return ShapeQuestion(target: target, options: options);
  }

  void reset() {
    _timer?.cancel();
    _question = _generateQuestion();
    round = 0;
    stars = 0;
    firstAttempt = true;
    locked = false;
    answerState = ShapeAnswerState.idle;
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

class ShapeMatchPage extends ConsumerStatefulWidget {
  const ShapeMatchPage({required this.args, super.key});

  final GameRouteArgs args;

  @override
  ConsumerState<ShapeMatchPage> createState() => _ShapeMatchPageState();
}

class _ShapeMatchPageState extends ConsumerState<ShapeMatchPage> {
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
    ref.read(shapeMatchViewModelProvider(args)).reset();
    setState(() {
      _isPaused = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<RewardRouteArgs?>(
      shapeMatchViewModelProvider(args)
          .select((viewModel) => viewModel.pendingRewardArgs),
      (_, next) {
        if (next != null) {
          Navigator.pushReplacementNamed(context, AppRoutes.reward,
              arguments: next);
        }
      },
    );
    ref.listen<ShapeAnswerState>(
      shapeMatchViewModelProvider(args)
          .select((viewModel) => viewModel.answerState),
      (previous, next) {
        if (previous == next) {
          return;
        }
        final soundController = ref.read(gameSoundControllerProvider);
        if (next == ShapeAnswerState.correct) {
          unawaited(soundController.playCorrect());
        } else if (next == ShapeAnswerState.wrong) {
          unawaited(soundController.playWrong());
        }
      },
    );

    final l10n = context.l10n;
    final viewModel = ref.watch(shapeMatchViewModelProvider(args));

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
                  colors: [Color(0xFFFFFDE7), Color(0xFFFFF3E0)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: SafeArea(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                  children: [
                    _ShapeHeader(
                      title: l10n.roundCounter(
                          viewModel.round + 1, viewModel.config.rounds),
                      difficulty: args.difficulty,
                      stars: viewModel.stars,
                      onBack: _openPause,
                    ),
                    const SizedBox(height: 16),
                    KidAnimatedProgressBar(
                      value: viewModel.round / viewModel.config.rounds,
                      backgroundColor: const Color(0xFFFFF59D),
                      borderColor: const Color(0xFFFFD54F),
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFD54F), Color(0xFFF4A200)],
                      ),
                    ),
                    const SizedBox(height: 22),
                    KidRoundSwitcher(
                      switchKey:
                          '${viewModel.round}-${viewModel.question.target.id}',
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                  color: const Color(0xFFFFD54F), width: 4),
                            ),
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      gradient: RadialGradient(
                                        colors: [
                                          viewModel.question.target.color
                                              .withValues(alpha: 0.14),
                                          Colors.transparent,
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Column(
                                  children: [
                                    Text(
                                      viewModel.hideNameInQuestion
                                          ? '${l10n.shapePromptHard} 🤔'
                                          : '${l10n.shapePrompt} ⬡',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xFF7B5800),
                                      ),
                                    ),
                                    const SizedBox(height: 18),
                                    KidLoopAnimation(
                                      duration:
                                          const Duration(milliseconds: 2200),
                                      builder: (context, value, child) {
                                        final scale =
                                            lerpValue(1, 1.06, wave(value));
                                        return Transform.scale(
                                          scale: scale,
                                          child: child,
                                        );
                                      },
                                      child: _ShapePreview(
                                        shapeId: viewModel.question.target.id,
                                        color: viewModel.question.target.color,
                                        size: 120,
                                      ),
                                    ),
                                    if (!viewModel.hideNameInQuestion) ...[
                                      const SizedBox(height: 16),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 18, vertical: 10),
                                        decoration: BoxDecoration(
                                          color:
                                              viewModel.question.target.color,
                                          borderRadius:
                                              BorderRadius.circular(999),
                                          boxShadow: [
                                            BoxShadow(
                                              color: viewModel
                                                  .question.target.shadow
                                                  .withValues(alpha: 0.28),
                                              blurRadius: 14,
                                              offset: const Offset(0, 8),
                                            ),
                                          ],
                                        ),
                                        child: Text(
                                          viewModel.question.target.label(
                                            context,
                                          ),
                                          style: const TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.w900,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
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
                              childAspectRatio: 0.95,
                            ),
                            itemBuilder: (context, index) {
                              final option = viewModel.question.options[index];
                              final correct =
                                  viewModel.correctOptionId == option.id;
                              final wrong =
                                  viewModel.wrongOptionId == option.id;
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
                                        .read(shapeMatchViewModelProvider(args))
                                        .select(option),
                                    child: Ink(
                                      decoration: BoxDecoration(
                                        color: correct
                                            ? option.color
                                            : wrong
                                                ? const Color(0xFFFFCDD2)
                                                : Colors.white,
                                        borderRadius: BorderRadius.circular(28),
                                        border: Border.all(
                                          color: correct
                                              ? const Color(0xFFFFD700)
                                              : wrong
                                                  ? const Color(0xFFF44336)
                                                  : option.color
                                                      .withValues(alpha: 0.62),
                                          width: correct || wrong ? 5 : 4,
                                        ),
                                      ),
                                      child: Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              _ShapePreview(
                                                shapeId: option.id,
                                                color: correct
                                                    ? Colors.white
                                                    : option.color,
                                                size: 56,
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                option.label(context),
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w900,
                                                  color: correct
                                                      ? Colors.white
                                                      : option.color,
                                                ),
                                              ),
                                            ],
                                          ),
                                          AnimatedOpacity(
                                            opacity: correct ? 1 : 0,
                                            duration: const Duration(
                                              milliseconds: 180,
                                            ),
                                            child: const Align(
                                              alignment: Alignment.topRight,
                                              child: Padding(
                                                padding: EdgeInsets.all(10),
                                                child: Text('✅',
                                                    style: TextStyle(
                                                        fontSize: 22)),
                                              ),
                                            ),
                                          ),
                                          AnimatedOpacity(
                                            opacity: wrong ? 1 : 0,
                                            duration: const Duration(
                                              milliseconds: 180,
                                            ),
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
                    _SimpleShapeFeedbackBanner(
                      isCorrect:
                          viewModel.answerState == ShapeAnswerState.correct,
                      isWrong: viewModel.answerState == ShapeAnswerState.wrong,
                      correctText: l10n.shapeCorrect,
                      wrongText: l10n.shapeWrong,
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

class _ShapeHeader extends StatelessWidget {
  const _ShapeHeader({
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
          iconColor: const Color(0xFFF4A200),
          borderColor: const Color(0xFFFFD54F),
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
                      Border.all(color: const Color(0xFFFFD54F), width: 2.5),
                ),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFB77B00),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${difficulty.badgeEmoji} ${difficulty.label(context.l10n)}'
                '${difficulty == GameDifficulty.hard ? ' · ${context.l10n.shapeHardModeHint}' : ''}',
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

class _ShapePreview extends StatelessWidget {
  const _ShapePreview({
    required this.shapeId,
    required this.color,
    required this.size,
  });

  final String shapeId;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final box = BoxConstraints.tight(Size.square(size));

    switch (shapeId) {
      case 'circle':
        return ConstrainedBox(
          constraints: box,
          child: DecoratedBox(
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
        );
      case 'square':
        return ConstrainedBox(
          constraints: box,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(size * 0.18),
            ),
          ),
        );
      case 'triangle':
        return CustomPaint(
            size: Size.square(size), painter: _TrianglePainter(color));
      case 'star':
        return CustomPaint(
            size: Size.square(size), painter: _StarPainter(color));
      case 'heart':
        return CustomPaint(
            size: Size.square(size), painter: _HeartPainter(color));
      case 'diamond':
        return Transform.rotate(
          angle: pi / 4,
          child: ConstrainedBox(
            constraints: BoxConstraints.tight(Size.square(size * 0.72)),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(size * 0.08),
              ),
            ),
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

class _TrianglePainter extends CustomPainter {
  const _TrianglePainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _StarPainter extends CustomPainter {
  const _StarPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    final center = Offset(size.width / 2, size.height / 2);
    final outer = size.width / 2;
    final inner = outer * 0.45;
    for (var i = 0; i < 10; i++) {
      final radius = i.isEven ? outer : inner;
      final angle = -pi / 2 + i * pi / 5;
      final point = Offset(
        center.dx + cos(angle) * radius,
        center.dy + sin(angle) * radius,
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _HeartPainter extends CustomPainter {
  const _HeartPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width / 2, size.height * 0.92)
      ..cubicTo(size.width * 0.1, size.height * 0.6, 0, size.height * 0.32,
          size.width * 0.24, size.height * 0.18)
      ..cubicTo(size.width * 0.38, size.height * 0.08, size.width * 0.5,
          size.height * 0.16, size.width * 0.5, size.height * 0.26)
      ..cubicTo(size.width * 0.5, size.height * 0.16, size.width * 0.62,
          size.height * 0.08, size.width * 0.76, size.height * 0.18)
      ..cubicTo(size.width, size.height * 0.32, size.width * 0.9,
          size.height * 0.6, size.width / 2, size.height * 0.92)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SimpleShapeFeedbackBanner extends StatelessWidget {
  const _SimpleShapeFeedbackBanner({
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
