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
import '../../../core/widgets/level_complete_overlay.dart';
import '../../../core/widgets/pause_dialog.dart';

const _findDifferentPalette = FigmaGamePalette(
  accent: Color(0xFF74E8D8),
  accentStrong: Color(0xFF118A86),
  accentSoft: Color(0xFFE7FFFB),
  progressTrack: Color(0xFFD6F6F0),
  progressBorder: Color(0xFF8BD8CF),
  progressGradient: LinearGradient(
    colors: [Color(0xFF74E8D8), Color(0xFF118A86)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  ),
  floaterIcon: FigmaFloatIconType.sparkle,
);

final findDifferentViewModelProvider = ChangeNotifierProvider.autoDispose
    .family<FindDifferentViewModel, GameRouteArgs>((ref, args) {
  return FindDifferentViewModel(args);
});

class FindDifferentCharacter {
  const FindDifferentCharacter({
    required this.id,
    required this.avatar,
    required this.background,
    required this.shadow,
  });

  final String id;
  final String avatar;
  final Color background;
  final Color shadow;
}

const _findDifferentCharacters = <FindDifferentCharacter>[
  FindDifferentCharacter(
    id: 'lion',
    avatar: '🦁',
    background: Color(0xFFFFD66D),
    shadow: Color(0xFFE6A700),
  ),
  FindDifferentCharacter(
    id: 'bear',
    avatar: '🐻',
    background: Color(0xFFD7C1FF),
    shadow: Color(0xFF7E57C2),
  ),
  FindDifferentCharacter(
    id: 'panda',
    avatar: '🐼',
    background: Color(0xFFFFE8A3),
    shadow: Color(0xFFF9A825),
  ),
  FindDifferentCharacter(
    id: 'fox',
    avatar: '🦊',
    background: Color(0xFFFFC7A8),
    shadow: Color(0xFFF97316),
  ),
  FindDifferentCharacter(
    id: 'frog',
    avatar: '🐸',
    background: Color(0xFFB8F0B5),
    shadow: Color(0xFF43A047),
  ),
  FindDifferentCharacter(
    id: 'chick',
    avatar: '🐥',
    background: Color(0xFFFFF59D),
    shadow: Color(0xFFF4A200),
  ),
];

const _hardPairs = <(String, String)>[
  ('lion', 'fox'),
  ('bear', 'panda'),
  ('chick', 'frog'),
];

enum FindDifferentAnswerState { idle, correct, wrong }

enum FindDifferentVariant { character, size, direction, aura }

class FindDifferentCell {
  const FindDifferentCell({
    required this.character,
    required this.isOdd,
    required this.scale,
    required this.rotation,
    required this.aura,
  });

  final FindDifferentCharacter character;
  final bool isOdd;
  final double scale;
  final double rotation;
  final Color? aura;

  String get key => '${character.id}-${isOdd ? 'odd' : 'same'}-'
      '${scale.toStringAsFixed(2)}-${rotation.toStringAsFixed(2)}-'
      '${aura?.toARGB32() ?? 0}';
}

class FindDifferentQuestion {
  const FindDifferentQuestion({
    required this.common,
    required this.odd,
    required this.options,
    required this.cols,
    required this.variant,
  });

  final FindDifferentCharacter common;
  final FindDifferentCharacter odd;
  final List<FindDifferentCell> options;
  final int cols;
  final FindDifferentVariant variant;
}

class FindDifferentViewModel extends ChangeNotifier {
  FindDifferentViewModel(this.args) {
    _question = _buildQuestion();
  }

  final GameRouteArgs args;
  final Random _random = Random();
  Timer? _timer;
  late FindDifferentQuestion _question;

  int round = 0;
  int stars = 0;
  bool firstAttempt = true;
  bool locked = false;
  int? correctIndex;
  int? wrongIndex;
  bool showLevelComplete = false;
  FindDifferentAnswerState answerState = FindDifferentAnswerState.idle;
  RewardRouteArgs? pendingRewardArgs;
  String? _pendingPreviousCommonId;

  DifficultyConfig get config => args.difficulty.config;
  FindDifferentQuestion get question => _question;
  int get questionsPerLevel => args.difficulty == GameDifficulty.easy ? 1 : 2;
  int get totalLevels => (config.rounds / questionsPerLevel).ceil();
  int get currentLevel => round ~/ questionsPerLevel + 1;

  void select(int index) {
    if (locked || showLevelComplete || pendingRewardArgs != null) {
      return;
    }

    final chosen = _question.options[index];
    if (chosen.isOdd) {
      locked = true;
      correctIndex = index;
      answerState = FindDifferentAnswerState.correct;
      if (firstAttempt) {
        stars += 1;
      }
      notifyListeners();

      _timer?.cancel();
      _timer = Timer(const Duration(milliseconds: 900), () {
        final nextRound = round + 1;
        if (nextRound >= config.rounds) {
          pendingRewardArgs = RewardRouteArgs(
            gameId: args.gameId,
            difficulty: args.difficulty,
            earnedStars: stars,
            totalRounds: config.rounds,
          );
        } else if (nextRound ~/ questionsPerLevel >
            round ~/ questionsPerLevel) {
          showLevelComplete = true;
          _pendingPreviousCommonId = _question.common.id;
        } else {
          _advanceToRound(nextRound, previousCommonId: _question.common.id);
        }
        notifyListeners();
      });
      return;
    }

    firstAttempt = false;
    locked = true;
    wrongIndex = index;
    answerState = FindDifferentAnswerState.wrong;
    notifyListeners();

    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 650), () {
      locked = false;
      wrongIndex = null;
      answerState = FindDifferentAnswerState.idle;
      notifyListeners();
    });
  }

  void reset() {
    _timer?.cancel();
    round = 0;
    stars = 0;
    firstAttempt = true;
    locked = false;
    correctIndex = null;
    wrongIndex = null;
    showLevelComplete = false;
    answerState = FindDifferentAnswerState.idle;
    pendingRewardArgs = null;
    _pendingPreviousCommonId = null;
    _question = _buildQuestion();
    notifyListeners();
  }

  void continueLevel() {
    if (!showLevelComplete) {
      return;
    }
    showLevelComplete = false;
    _advanceToRound(
      round + 1,
      previousCommonId: _pendingPreviousCommonId,
    );
    _pendingPreviousCommonId = null;
    notifyListeners();
  }

  void _advanceToRound(int nextRound, {String? previousCommonId}) {
    round = nextRound;
    firstAttempt = true;
    locked = false;
    correctIndex = null;
    wrongIndex = null;
    answerState = FindDifferentAnswerState.idle;
    _question = _buildQuestion(previousCommonId: previousCommonId);
  }

  FindDifferentQuestion _buildQuestion({String? previousCommonId}) {
    final grid = switch (args.difficulty) {
      GameDifficulty.easy => (count: 4, cols: 2),
      GameDifficulty.medium => (count: 6, cols: 3),
      GameDifficulty.hard => (count: 9, cols: 3),
    };

    late final FindDifferentCharacter common;
    late final FindDifferentCharacter odd;
    final variant = _pickVariant();

    if (args.difficulty == GameDifficulty.hard &&
        variant == FindDifferentVariant.character) {
      final pair = _hardPairs[_random.nextInt(_hardPairs.length)];
      final flipped = _random.nextBool();
      common = _characterById(flipped ? pair.$2 : pair.$1);
      odd = _characterById(flipped ? pair.$1 : pair.$2);
    } else {
      final pool = [..._findDifferentCharacters];
      if (previousCommonId != null && pool.length > 2) {
        pool.removeWhere((character) => character.id == previousCommonId);
      }
      pool.shuffle(_random);
      common = pool.first;
      odd = pool[1];
    }

    final oddIndex = _random.nextInt(grid.count);
    final options = List<FindDifferentCell>.generate(
      grid.count,
      (index) => _buildCell(
        character: index == oddIndex ? odd : common,
        isOdd: index == oddIndex,
        variant: variant,
      ),
    );
    return FindDifferentQuestion(
      common: common,
      odd: odd,
      options: options,
      cols: grid.cols,
      variant: variant,
    );
  }

  FindDifferentVariant _pickVariant() {
    final variants = switch (args.difficulty) {
      GameDifficulty.easy => const [
          FindDifferentVariant.character,
          FindDifferentVariant.character,
          FindDifferentVariant.aura,
        ],
      GameDifficulty.medium => const [
          FindDifferentVariant.character,
          FindDifferentVariant.size,
          FindDifferentVariant.direction,
          FindDifferentVariant.aura,
        ],
      GameDifficulty.hard => const [
          FindDifferentVariant.character,
          FindDifferentVariant.size,
          FindDifferentVariant.direction,
          FindDifferentVariant.aura,
        ],
    };
    return variants[_random.nextInt(variants.length)];
  }

  FindDifferentCell _buildCell({
    required FindDifferentCharacter character,
    required bool isOdd,
    required FindDifferentVariant variant,
  }) {
    final oddAura = const Color(0xFFFFC84A);
    final commonAura =
        args.difficulty == GameDifficulty.hard ? const Color(0xFFE0F7FA) : null;
    return switch (variant) {
      FindDifferentVariant.character => FindDifferentCell(
          character: character,
          isOdd: isOdd,
          scale: 1,
          rotation: 0,
          aura: null,
        ),
      FindDifferentVariant.size => FindDifferentCell(
          character: character,
          isOdd: isOdd,
          scale:
              isOdd ? (args.difficulty == GameDifficulty.easy ? 0.82 : 1.2) : 1,
          rotation: 0,
          aura: null,
        ),
      FindDifferentVariant.direction => FindDifferentCell(
          character: character,
          isOdd: isOdd,
          scale: 1,
          rotation: isOdd
              ? (args.difficulty == GameDifficulty.hard ? -0.38 : 0.32)
              : (args.difficulty == GameDifficulty.hard ? 0.05 : 0),
          aura: null,
        ),
      FindDifferentVariant.aura => FindDifferentCell(
          character: character,
          isOdd: isOdd,
          scale: 1,
          rotation: 0,
          aura: isOdd ? oddAura : commonAura,
        ),
    };
  }

  FindDifferentCharacter _characterById(String id) {
    return _findDifferentCharacters.firstWhere(
      (character) => character.id == id,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

class FindDifferentPage extends ConsumerStatefulWidget {
  const FindDifferentPage({required this.args, super.key});

  final GameRouteArgs args;

  @override
  ConsumerState<FindDifferentPage> createState() => _FindDifferentPageState();
}

class _FindDifferentPageState extends ConsumerState<FindDifferentPage> {
  bool _isPaused = false;
  late final GameSoundController _soundController;
  late final VoiceGuideController _voiceGuideController;
  late final ProviderSubscription<String> _questionVoiceSubscription;
  late final ProviderSubscription<bool> _voiceGuideSubscription;

  GameRouteArgs get args => widget.args;

  @override
  void initState() {
    super.initState();
    _soundController = ref.read(gameSoundControllerProvider);
    _voiceGuideController = ref.read(voiceGuideControllerProvider);
    _questionVoiceSubscription = ref.listenManual<String>(
      findDifferentViewModelProvider(args).select(
        (viewModel) => '${viewModel.round}-${viewModel.question.odd.id}-'
            '${viewModel.question.variant.name}-'
            '${viewModel.question.options.map((cell) => cell.key).join('|')}',
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

  void _handleBack(BuildContext context) {
    unawaited(_voiceGuideController.stop());
    AppRouter.showGameSelect(context);
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
    ref.read(findDifferentViewModelProvider(args)).reset();
    setState(() {
      _isPaused = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<RewardRouteArgs?>(
      findDifferentViewModelProvider(args)
          .select((viewModel) => viewModel.pendingRewardArgs),
      (_, next) {
        if (next != null) {
          unawaited(_voiceGuideController.stop());
          Navigator.pushReplacementNamed(
            context,
            AppRoutes.reward,
            arguments: next,
          );
        }
      },
    );
    ref.listen<FindDifferentAnswerState>(
      findDifferentViewModelProvider(args)
          .select((viewModel) => viewModel.answerState),
      (previous, next) {
        if (previous == next) {
          return;
        }
        if (next != FindDifferentAnswerState.idle) {
          unawaited(_voiceGuideController.stop());
        }
        final soundController = ref.read(gameSoundControllerProvider);
        if (next == FindDifferentAnswerState.correct) {
          unawaited(soundController.playCorrect());
        } else if (next == FindDifferentAnswerState.wrong) {
          unawaited(soundController.playWrong());
        }
      },
    );

    final l10n = context.l10n;
    final viewModel = ref.watch(findDifferentViewModelProvider(args));
    final progress = viewModel.round / viewModel.config.rounds;
    final promptText = args.difficulty == GameDifficulty.hard
        ? '仔细找，哪只不一样？'
        : l10n.findDifferentPrompt;
    final cellExtent = viewModel.question.cols == 2 ? 110.0 : 78.0;

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
        palette: _findDifferentPalette,
        roundLabel:
            '第${viewModel.currentLevel}关 · ${viewModel.round + 1}/${viewModel.config.rounds}题',
        difficulty: args.difficulty,
        stars: viewModel.stars,
        progress: progress,
        onPause: _openPause,
        backgroundColor: const Color(0xFFF6FFFC),
        showDots: true,
        includeYellowDots: true,
        pauseIcon: const FigmaPauseIcon(size: 18, color: Color(0xFF118A86)),
        pauseDialog: PauseDialog(
          isOpen: _isPaused,
          gameName: args.gameId.title(l10n),
          gameEmoji: args.gameId.emoji,
          onContinue: _closePause,
          onRestart: _restartGame,
          onQuit: () => _handleBack(context),
        ),
        floatingAction: Stack(
          children: [
            const FloatingSoundToggle(
              accentColor: Color(0xFF74E8D8),
              borderColor: Color(0xFF118A86),
            ),
            if (viewModel.showLevelComplete)
              LevelCompleteOverlay(
                level: viewModel.currentLevel,
                totalLevels: viewModel.totalLevels,
                stars: viewModel.stars,
                totalRounds: viewModel.config.rounds,
                accentColor: const Color(0xFF00838F),
                borderColor: const Color(0xFF006064),
                onContinue: () {
                  ref
                      .read(findDifferentViewModelProvider(args))
                      .continueLevel();
                },
              ),
          ],
        ),
        body: KidRoundSwitcher(
          switchKey: '${viewModel.round}-${viewModel.question.odd.id}-'
              '${viewModel.question.variant.name}',
          child: Column(
            children: [
              _FindDifferentPromptCard(
                question: viewModel.question,
                promptText: promptText,
                hardMode: args.difficulty == GameDifficulty.hard,
              ),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: viewModel.question.options.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: viewModel.question.cols,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  mainAxisExtent: cellExtent,
                ),
                itemBuilder: (context, index) {
                  final cell = viewModel.question.options[index];
                  return _FindDifferentTile(
                    cell: cell,
                    correct: viewModel.correctIndex == index,
                    wrong: viewModel.wrongIndex == index,
                    size: cellExtent - 28,
                    onTap: () => ref
                        .read(findDifferentViewModelProvider(args))
                        .select(index),
                  );
                },
              ),
              const SizedBox(height: 10),
              FigmaGameFeedbackBanner(
                visible: viewModel.answerState != FindDifferentAnswerState.idle,
                text: viewModel.answerState == FindDifferentAnswerState.correct
                    ? l10n.feedbackCorrect
                    : l10n.feedbackTryAgain,
                isPositive:
                    viewModel.answerState == FindDifferentAnswerState.correct,
                palette: _findDifferentPalette,
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

    await _voiceGuideController.speak(
      _findDifferentVoicePrompt(context),
      locale: Localizations.localeOf(context),
    );
  }
}

String _findDifferentVoicePrompt(BuildContext context) {
  return switch (Localizations.localeOf(context).languageCode) {
    'zh' => '请找出不一样的小动物。',
    'ko' => '다른 동물 하나를 찾아봐요.',
    _ => 'Find the one animal that looks different.',
  };
}

class _FindDifferentPromptCard extends StatelessWidget {
  const _FindDifferentPromptCard({
    required this.question,
    required this.promptText,
    required this.hardMode,
  });

  final FindDifferentQuestion question;
  final String promptText;
  final bool hardMode;

  @override
  Widget build(BuildContext context) {
    return FigmaGamePanel(
      palette: _findDifferentPalette,
      radius: 30,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
      child: Column(
        children: [
          Text(
            promptText,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Color(0xFF2C5B58),
            ),
          ),
          if (hardMode ||
              question.variant != FindDifferentVariant.character) ...[
            const SizedBox(height: 4),
            Text(
              _findDifferentVariantHint(context, question.variant),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF546E7A),
              ),
            ),
          ],
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF2FFFC),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: const Color(0xFFBCEEE6),
                width: 2.2,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _PromptMascotChip(
                  cell: _previewCell(question, isOdd: false),
                ),
                _PromptMascotChip(
                  cell: _previewCell(question, isOdd: false),
                ),
                _PromptMascotChip(
                  cell: _previewCell(question, isOdd: true),
                  highlighted: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _findDifferentVariantHint(
  BuildContext context,
  FindDifferentVariant variant,
) {
  return switch (variant) {
    FindDifferentVariant.character => switch (
          Localizations.localeOf(context).languageCode) {
        'zh' => '找出不一样的小动物',
        'ko' => '다른 동물을 찾아봐요',
        _ => 'Find the different animal',
      },
    FindDifferentVariant.size => switch (
          Localizations.localeOf(context).languageCode) {
        'zh' => '大小不一样也算不同',
        'ko' => '크기가 다른 친구를 찾아봐요',
        _ => 'Look for size changes',
      },
    FindDifferentVariant.direction => switch (
          Localizations.localeOf(context).languageCode) {
        'zh' => '方向不一样也算不同',
        'ko' => '방향이 다른 친구를 찾아봐요',
        _ => 'Look for rotation changes',
      },
    FindDifferentVariant.aura => switch (
          Localizations.localeOf(context).languageCode) {
        'zh' => '光环不一样也算不同',
        'ko' => '반짝임이 다른 친구를 찾아봐요',
        _ => 'Look for the different glow',
      },
  };
}

FindDifferentCell _previewCell(
  FindDifferentQuestion question, {
  required bool isOdd,
}) {
  return question.options.firstWhere(
    (cell) => cell.isOdd == isOdd,
    orElse: () => question.options.first,
  );
}

class _PromptMascotChip extends StatelessWidget {
  const _PromptMascotChip({
    required this.cell,
    this.highlighted = false,
  });

  final FindDifferentCell cell;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final character = cell.character;
    return Container(
      width: 76,
      height: 76,
      decoration: BoxDecoration(
        color: character.background.withValues(alpha: highlighted ? 1 : 0.8),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: highlighted ? const Color(0xFFFFC84A) : Colors.white,
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: character.shadow.withValues(alpha: 0.22),
            blurRadius: 0,
            offset: const Offset(4, 4),
          ),
        ],
      ),
      child: Center(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Transform.rotate(
              angle: cell.rotation,
              child: Transform.scale(
                scale: cell.scale,
                child: FigmaMascotAvatar(avatar: character.avatar, size: 42),
              ),
            ),
            if (highlighted)
              const Positioned(
                right: -8,
                top: -10,
                child: Text(
                  '✨',
                  style: TextStyle(fontSize: 20),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _FindDifferentTile extends StatelessWidget {
  const _FindDifferentTile({
    required this.cell,
    required this.correct,
    required this.wrong,
    required this.size,
    required this.onTap,
  });

  final FindDifferentCell cell;
  final bool correct;
  final bool wrong;
  final double size;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final item = cell.character;
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: correct || wrong ? 1 : 0),
      duration: Duration(milliseconds: wrong ? 420 : 260),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(wrong ? shakeOffset(value) : 0, 0),
          child: Transform.scale(
            scale: correct ? punchScale(value) : 1,
            child: child,
          ),
        );
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: onTap,
          child: Ink(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: correct
                    ? const Color(0xFFFFC84A)
                    : wrong
                        ? const Color(0xFFFF8A65)
                        : const Color(0xFF8BD8CF),
                width: correct || wrong ? 4.5 : 3,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1E118A86),
                  blurRadius: 0,
                  offset: Offset(4, 4),
                ),
              ],
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Positioned(
                  left: 10,
                  right: 10,
                  top: 10,
                  child: Container(
                    height: 16,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2FFFC),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                Center(
                  child: Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      color: item.background,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: cell.aura ?? Colors.white.withValues(alpha: 0.7),
                        width: cell.aura == null ? 2 : 4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (cell.aura ?? item.shadow).withValues(
                              alpha: cell.aura == null ? 0.2 : 0.35),
                          blurRadius: cell.aura == null ? 0 : 16,
                          offset: cell.aura == null
                              ? const Offset(3, 3)
                              : const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Transform.rotate(
                        angle: cell.rotation,
                        child: Transform.scale(
                          scale: cell.scale,
                          child: FigmaMascotAvatar(
                            avatar: item.avatar,
                            size: size - 26,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (correct)
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0x33FFD54F),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Center(
                      child: Text('✨', style: TextStyle(fontSize: 30)),
                    ),
                  ),
                if (wrong)
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0x22FF8A65),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Center(
                      child: Text('💨', style: TextStyle(fontSize: 28)),
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
