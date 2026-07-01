import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/localization.dart';
import '../../../app/route_args.dart';
import '../../../app/router.dart';
import '../../../core/app_controllers.dart';
import '../../../core/game_models.dart';
import '../../../core/sound/game_sound_controller.dart';
import '../../../core/sound/voice_guide_controller.dart';
import '../../../core/widgets/floating_sound_toggle.dart';
import '../../../core/widgets/figma_game_icons.dart';
import '../../../core/widgets/figma_game_shell.dart';
import '../../../core/widgets/figma_home_icons.dart';
import '../../../core/widgets/kid_motion.dart';
import '../../../core/widgets/pause_dialog.dart';

const _shapeMatchPalette = FigmaGamePalette(
  accent: Color(0xFFFFD56C),
  accentStrong: Color(0xFFB97B00),
  accentSoft: Color(0xFFFFFBEB),
  progressTrack: Color(0xFFFFF0B2),
  progressBorder: Color(0xFFFFD46B),
  progressGradient: LinearGradient(
    colors: [Color(0xFFFFDD7A), Color(0xFFEE9D11)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  ),
  floaterIcon: FigmaFloatIconType.star,
);

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
  ShapeChoice(
    id: 'oval',
    labelZh: '椭圆形',
    labelKo: '타원형',
    labelEn: 'Oval',
    color: Color(0xFF26C6DA),
    shadow: Color(0xFF00838F),
  ),
  ShapeChoice(
    id: 'rectangle',
    labelZh: '长方形',
    labelKo: '직사각형',
    labelEn: 'Rectangle',
    color: Color(0xFFFF8A3D),
    shadow: Color(0xFFE65100),
  ),
  ShapeChoice(
    id: 'semicircle',
    labelZh: '半圆形',
    labelKo: '반원',
    labelEn: 'Semicircle',
    color: Color(0xFF7ED957),
    shadow: Color(0xFF43A047),
  ),
  ShapeChoice(
    id: 'hexagon',
    labelZh: '六边形',
    labelKo: '육각형',
    labelEn: 'Hexagon',
    color: Color(0xFF5C7CFA),
    shadow: Color(0xFF304FFE),
  ),
  ShapeChoice(
    id: 'moon',
    labelZh: '月牙形',
    labelKo: '초승달',
    labelEn: 'Crescent',
    color: Color(0xFFFFC857),
    shadow: Color(0xFFFF9800),
  ),
];

const _shapeVariantColors = <Color>[
  Color(0xFFFF4B4B),
  Color(0xFF4B9FFF),
  Color(0xFF4BC96A),
  Color(0xFFFFD93D),
  Color(0xFFFF70A6),
  Color(0xFFA855F7),
  Color(0xFF26C6DA),
  Color(0xFFFF8A3D),
];

enum ShapeAnswerState { idle, correct, wrong }

enum ShapeQuestionVariant { classic, colorNoise, sizeNoise, rotateNoise }

class ShapeVisual {
  const ShapeVisual({
    required this.color,
    required this.rotation,
    required this.scale,
  });

  final Color color;
  final double rotation;
  final double scale;

  String get key =>
      '${color.toARGB32()}-${rotation.toStringAsFixed(2)}-${scale.toStringAsFixed(2)}';
}

class ShapeQuestion {
  const ShapeQuestion({
    required this.target,
    required this.options,
    required this.variant,
    required this.targetVisual,
    required this.optionVisuals,
  });

  final ShapeChoice target;
  final List<ShapeChoice> options;
  final ShapeQuestionVariant variant;
  final ShapeVisual targetVisual;
  final Map<String, ShapeVisual> optionVisuals;
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

  bool get showShapeNames =>
      args.difficulty == GameDifficulty.easy &&
      _question.variant == ShapeQuestionVariant.classic;

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
    final variant = _pickVariant();
    return ShapeQuestion(
      target: target,
      options: options,
      variant: variant,
      targetVisual: _visualFor(target, variant: variant, isTarget: true),
      optionVisuals: {
        for (final option in options)
          option.id: _visualFor(
            option,
            variant: variant,
            isTarget: option.id == target.id,
          ),
      },
    );
  }

  ShapeQuestionVariant _pickVariant() {
    final variants = switch (args.difficulty) {
      GameDifficulty.easy => const [
          ShapeQuestionVariant.classic,
          ShapeQuestionVariant.classic,
          ShapeQuestionVariant.colorNoise,
        ],
      GameDifficulty.medium => const [
          ShapeQuestionVariant.colorNoise,
          ShapeQuestionVariant.sizeNoise,
          ShapeQuestionVariant.rotateNoise,
        ],
      GameDifficulty.hard => const [
          ShapeQuestionVariant.colorNoise,
          ShapeQuestionVariant.rotateNoise,
          ShapeQuestionVariant.sizeNoise,
        ],
    };
    return variants[_random.nextInt(variants.length)];
  }

  ShapeVisual _visualFor(
    ShapeChoice shape, {
    required ShapeQuestionVariant variant,
    required bool isTarget,
  }) {
    final color = switch (variant) {
      ShapeQuestionVariant.colorNoise =>
        _shapeVariantColors[_random.nextInt(_shapeVariantColors.length)],
      _ => shape.color,
    };
    final rotation = switch (variant) {
      ShapeQuestionVariant.rotateNoise => (_random.nextDouble() * 0.56) - 0.28,
      ShapeQuestionVariant.sizeNoise
          when args.difficulty == GameDifficulty.hard =>
        isTarget ? 0.08 : ((_random.nextDouble() * 0.28) - 0.14),
      _ => 0.0,
    };
    final scale = switch (variant) {
      ShapeQuestionVariant.sizeNoise =>
        isTarget ? 1.04 : 0.84 + _random.nextDouble() * 0.36,
      ShapeQuestionVariant.rotateNoise
          when args.difficulty == GameDifficulty.hard =>
        0.92 + _random.nextDouble() * 0.2,
      _ => 1.0,
    };

    return ShapeVisual(
      color: color,
      rotation: rotation,
      scale: scale,
    );
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
  late final VoiceGuideController _voiceGuideController;
  late final ProviderSubscription<String> _questionVoiceSubscription;
  late final ProviderSubscription<bool> _voiceGuideSubscription;

  GameRouteArgs get args => widget.args;

  void _handleBack(BuildContext context) {
    unawaited(_voiceGuideController.stop());
    AppRouter.showGameSelect(context);
  }

  @override
  void initState() {
    super.initState();
    _soundController = ref.read(gameSoundControllerProvider);
    _voiceGuideController = ref.read(voiceGuideControllerProvider);
    _questionVoiceSubscription = ref.listenManual<String>(
      shapeMatchViewModelProvider(args).select(
        (viewModel) => '${viewModel.round}-${viewModel.question.target.id}-'
            '${viewModel.question.variant.name}-${viewModel.question.targetVisual.key}',
      ),
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
      unawaited(_soundController.startBgm());
      unawaited(_speakCurrentPrompt());
    });
  }

  @override
  void dispose() {
    _questionVoiceSubscription.close();
    _voiceGuideSubscription.close();
    unawaited(_voiceGuideController.stop());
    unawaited(_soundController.stopBgm());
    super.dispose();
  }

  void _openPause() {
    if (_isPaused) {
      return;
    }
    unawaited(ref.read(gameSoundControllerProvider).playClick());
    unawaited(_voiceGuideController.stop());
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
          unawaited(_voiceGuideController.stop());
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
        if (next != ShapeAnswerState.idle) {
          unawaited(_voiceGuideController.stop());
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
      child: FigmaGameScaffold(
        palette: _shapeMatchPalette,
        roundLabel:
            l10n.roundCounter(viewModel.round + 1, viewModel.config.rounds),
        difficulty: args.difficulty,
        stars: viewModel.stars,
        progress: viewModel.round / viewModel.config.rounds,
        onPause: _openPause,
        backgroundGradient: const LinearGradient(
          colors: [
            Color(0xFFFFFDE7),
            Color(0xFFFFF3E0),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 96),
        pauseIcon: const FigmaPauseIcon(size: 18, color: Color(0xFFB97B00)),
        floatingAction: const FloatingSoundToggle(
          accentColor: Color(0xFFFFD56C),
          borderColor: Color(0xFFB97B00),
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
          switchKey: '${viewModel.round}-${viewModel.question.target.id}-'
              '${viewModel.question.variant.name}-${viewModel.question.targetVisual.key}',
          child: Column(
            children: [
              _ShapePromptCard(
                prompt: viewModel.hideNameInQuestion
                    ? l10n.shapePromptHard
                    : l10n.shapePrompt,
                question: viewModel.question,
                hideName: viewModel.hideNameInQuestion,
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
                  childAspectRatio: 0.96,
                ),
                itemBuilder: (context, index) {
                  final option = viewModel.question.options[index];
                  return _ShapeOptionTile(
                    option: option,
                    visual: viewModel.question.optionVisuals[option.id] ??
                        ShapeVisual(
                          color: option.color,
                          rotation: 0,
                          scale: 1,
                        ),
                    showName: viewModel.showShapeNames,
                    correct: viewModel.correctOptionId == option.id,
                    wrong: viewModel.wrongOptionId == option.id,
                    onTap: () => ref
                        .read(shapeMatchViewModelProvider(args))
                        .select(option),
                  );
                },
              ),
              const SizedBox(height: 14),
              _SimpleShapeFeedbackBanner(
                isCorrect: viewModel.answerState == ShapeAnswerState.correct,
                isWrong: viewModel.answerState == ShapeAnswerState.wrong,
                correctText: l10n.shapeCorrect,
                wrongText: l10n.shapeWrong,
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

    final viewModel = ref.read(shapeMatchViewModelProvider(args));
    await _voiceGuideController.speak(
      _shapeVoicePrompt(
        context,
        target: viewModel.question.target,
        hideName: viewModel.hideNameInQuestion,
      ),
      locale: Localizations.localeOf(context),
    );
  }
}

String _shapeVoicePrompt(
  BuildContext context, {
  required ShapeChoice target,
  required bool hideName,
}) {
  if (hideName) {
    return context.l10n.shapePromptHard;
  }

  final label = target.label(context);
  return switch (Localizations.localeOf(context).languageCode) {
    'zh' => '请找到$label。',
    'ko' => '$label 모양을 찾아보세요.',
    _ => 'Find the $label shape.',
  };
}

class _ShapePromptCard extends StatelessWidget {
  const _ShapePromptCard({
    required this.prompt,
    required this.question,
    required this.hideName,
  });

  final String prompt;
  final ShapeQuestion question;
  final bool hideName;

  @override
  Widget build(BuildContext context) {
    final target = question.target;
    return FigmaGamePanel(
      palette: _shapeMatchPalette,
      child: Column(
        children: [
          Text(
            prompt,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Color(0xFF805600),
            ),
          ),
          const SizedBox(height: 10),
          _ShapeRuleChip(question: question),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
            decoration: BoxDecoration(
              color: _shapeMatchPalette.accentSoft,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: target.color.withValues(alpha: 0.18),
                width: 2.5,
              ),
            ),
            child: Column(
              children: [
                KidLoopAnimation(
                  duration: const Duration(milliseconds: 2200),
                  builder: (context, value, child) {
                    final scale = lerpValue(1, 1.06, wave(value));
                    return Transform.scale(scale: scale, child: child);
                  },
                  child: _ShapePreview(
                    shapeId: target.id,
                    color: question.targetVisual.color,
                    size: 130,
                    rotation: question.targetVisual.rotation,
                    scale: question.targetVisual.scale,
                  ),
                ),
                if (!hideName) ...[
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 10),
                    decoration: BoxDecoration(
                      color: target.color,
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: [
                        BoxShadow(
                          color: target.shadow.withValues(alpha: 0.24),
                          blurRadius: 14,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Text(
                      target.label(context),
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
          ),
        ],
      ),
    );
  }
}

class _ShapeRuleChip extends StatelessWidget {
  const _ShapeRuleChip({required this.question});

  final ShapeQuestion question;

  @override
  Widget build(BuildContext context) {
    final label = switch (question.variant) {
      ShapeQuestionVariant.classic => switch (
            Localizations.localeOf(context).languageCode) {
          'zh' => '看形状',
          'ko' => '모양 보기',
          _ => 'Match shape',
        },
      ShapeQuestionVariant.colorNoise => switch (
            Localizations.localeOf(context).languageCode) {
          'zh' => '颜色会变，只看形状',
          'ko' => '색은 달라도 모양을 봐요',
          _ => 'Ignore colors',
        },
      ShapeQuestionVariant.sizeNoise => switch (
            Localizations.localeOf(context).languageCode) {
          'zh' => '大小会变，只看形状',
          'ko' => '크기는 달라도 모양을 봐요',
          _ => 'Ignore size',
        },
      ShapeQuestionVariant.rotateNoise => switch (
            Localizations.localeOf(context).languageCode) {
          'zh' => '方向会变，只看形状',
          'ko' => '방향은 달라도 모양을 봐요',
          _ => 'Ignore rotation',
        },
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: const Color(0xFFFFD46B),
          width: 2,
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w900,
          color: Color(0xFF805600),
        ),
      ),
    );
  }
}

class _ShapeOptionTile extends StatelessWidget {
  const _ShapeOptionTile({
    required this.option,
    required this.visual,
    required this.showName,
    required this.correct,
    required this.wrong,
    required this.onTap,
  });

  final ShapeChoice option;
  final ShapeVisual visual;
  final bool showName;
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
                  ? visual.color
                  : wrong
                      ? const Color(0xFFFFD9D9)
                      : Colors.white,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: correct
                    ? const Color(0xFFFFD700)
                    : wrong
                        ? const Color(0xFFF44336)
                        : visual.color.withValues(alpha: 0.62),
                width: correct || wrong ? 5 : 4,
              ),
              boxShadow: [
                BoxShadow(
                  color: option.color.withValues(alpha: 0.12),
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
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _ShapePreview(
                      shapeId: option.id,
                      color: correct ? Colors.white : visual.color,
                      size: 58,
                      rotation: visual.rotation,
                      scale: visual.scale,
                    ),
                    if (showName) ...[
                      const SizedBox(height: 8),
                      Text(
                        option.label(context),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: correct ? Colors.white : visual.color,
                        ),
                      ),
                    ],
                  ],
                ),
                AnimatedOpacity(
                  opacity: correct ? 1 : 0,
                  duration: const Duration(milliseconds: 180),
                  child: const Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Text('✅', style: TextStyle(fontSize: 22)),
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

class _ShapePreview extends StatelessWidget {
  const _ShapePreview({
    required this.shapeId,
    required this.color,
    required this.size,
    this.rotation = 0,
    this.scale = 1,
  });

  final String shapeId;
  final Color color;
  final double size;
  final double rotation;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final box = BoxConstraints.tight(Size.square(size));

    final Widget shape = switch (shapeId) {
      'circle' => ConstrainedBox(
          constraints: box,
          child: DecoratedBox(
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
        ),
      'square' => ConstrainedBox(
          constraints: box,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(size * 0.18),
            ),
          ),
        ),
      'triangle' =>
        CustomPaint(size: Size.square(size), painter: _TrianglePainter(color)),
      'star' =>
        CustomPaint(size: Size.square(size), painter: _StarPainter(color)),
      'heart' =>
        CustomPaint(size: Size.square(size), painter: _HeartPainter(color)),
      'diamond' => Transform.rotate(
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
        ),
      'oval' => ConstrainedBox(
          constraints: BoxConstraints.tight(Size(size, size * 0.68)),
          child: DecoratedBox(
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
        ),
      'rectangle' => ConstrainedBox(
          constraints: BoxConstraints.tight(Size(size, size * 0.64)),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(size * 0.16),
            ),
          ),
        ),
      'semicircle' => CustomPaint(
          size: Size(size, size * 0.66),
          painter: _SemicirclePainter(color),
        ),
      'hexagon' => CustomPaint(
          size: Size.square(size),
          painter: _PolygonPainter(color, sides: 6),
        ),
      'moon' => CustomPaint(
          size: Size.square(size),
          painter: _CrescentPainter(color),
        ),
      _ => const SizedBox.shrink(),
    };

    return Transform.rotate(
      angle: rotation,
      child: Transform.scale(
        scale: scale,
        child: Center(child: shape),
      ),
    );
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

class _SemicirclePainter extends CustomPainter {
  const _SemicirclePainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height * 2);
    final path = Path()
      ..moveTo(0, size.height)
      ..arcTo(rect, pi, pi, false)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PolygonPainter extends CustomPainter {
  const _PolygonPainter(this.color, {required this.sides});

  final Color color;
  final int sides;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2;
    final path = Path();
    for (var index = 0; index < sides; index++) {
      final angle = -pi / 2 + index * 2 * pi / sides;
      final point = Offset(
        center.dx + cos(angle) * radius,
        center.dy + sin(angle) * radius,
      );
      if (index == 0) {
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

class _CrescentPainter extends CustomPainter {
  const _CrescentPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final cutPaint = Paint()..blendMode = BlendMode.clear;
    final layer = Offset.zero & size;
    canvas.saveLayer(layer, Paint());
    canvas.drawCircle(
      Offset(size.width * 0.48, size.height * 0.5),
      size.shortestSide * 0.44,
      paint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.63, size.height * 0.42),
      size.shortestSide * 0.39,
      cutPaint,
    );
    canvas.restore();
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
