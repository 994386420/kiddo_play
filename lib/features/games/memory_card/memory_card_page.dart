import 'dart:async';
import 'dart:math' as math;

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

const _memoryCardPalette = FigmaGamePalette(
  accent: Color(0xFFF7A5D6),
  accentStrong: Color(0xFFE84AA5),
  accentSoft: Color(0xFFFFF2FA),
  progressTrack: Color(0xFFFFD9EE),
  progressBorder: Color(0xFFF6A8D2),
  progressGradient: LinearGradient(
    colors: [Color(0xFFF7A5D6), Color(0xFFE84AA5)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  ),
  floaterIcon: FigmaFloatIconType.heart,
);

final memoryCardViewModelProvider = ChangeNotifierProvider.autoDispose
    .family<MemoryCardViewModel, GameRouteArgs>((ref, args) {
  return MemoryCardViewModel(args);
});

class MemoryCardFace {
  const MemoryCardFace({
    required this.id,
    required this.iconType,
    required this.fill,
    required this.shadow,
  });

  final String id;
  final FigmaFloatIconType iconType;
  final Color fill;
  final Color shadow;
}

class MemoryCardEntry {
  const MemoryCardEntry({
    required this.instanceId,
    required this.face,
  });

  final int instanceId;
  final MemoryCardFace face;
}

enum MemoryCardFeedbackState { idle, correct, wrong }

class MemoryLevelDef {
  const MemoryLevelDef({
    required this.pairs,
    required this.cols,
  });

  final int pairs;
  final int cols;
}

const _memoryCardFaces = <MemoryCardFace>[
  MemoryCardFace(
    id: 'star',
    iconType: FigmaFloatIconType.star,
    fill: Color(0xFFFFF1A8),
    shadow: Color(0xFFF4A200),
  ),
  MemoryCardFace(
    id: 'heart',
    iconType: FigmaFloatIconType.heart,
    fill: Color(0xFFFFC5DD),
    shadow: Color(0xFFD63384),
  ),
  MemoryCardFace(
    id: 'sparkle',
    iconType: FigmaFloatIconType.sparkle,
    fill: Color(0xFFE5D4FF),
    shadow: Color(0xFF7E57C2),
  ),
  MemoryCardFace(
    id: 'flower',
    iconType: FigmaFloatIconType.flower,
    fill: Color(0xFFC7F0B9),
    shadow: Color(0xFF43A047),
  ),
  MemoryCardFace(
    id: 'diamond',
    iconType: FigmaFloatIconType.diamond,
    fill: Color(0xFFCDEEFF),
    shadow: Color(0xFF0288D1),
  ),
  MemoryCardFace(
    id: 'fire',
    iconType: FigmaFloatIconType.fire,
    fill: Color(0xFFFFD1B2),
    shadow: Color(0xFFF97316),
  ),
];

class MemoryCardViewModel extends ChangeNotifier {
  MemoryCardViewModel(this.args) {
    _setupLevel();
  }

  final GameRouteArgs args;
  final math.Random _random = math.Random();
  Timer? _resolveTimer;

  List<MemoryCardEntry> cards = const [];
  List<int> revealedIndices = const [];
  Set<int> matchedIndices = const {};
  bool locked = false;
  bool showLevelComplete = false;
  int levelIndex = 0;
  int attempts = 0;
  int matchedPairs = 0;
  int totalAttempts = 0;
  int totalPairs = 0;
  int starsEarned = 0;
  List<int> shakingCards = const [];
  MemoryCardFeedbackState feedbackState = MemoryCardFeedbackState.idle;
  RewardRouteArgs? pendingRewardArgs;

  List<MemoryLevelDef> get levels => switch (args.difficulty) {
        GameDifficulty.easy => const [
            MemoryLevelDef(pairs: 2, cols: 2),
            MemoryLevelDef(pairs: 3, cols: 3),
          ],
        GameDifficulty.medium => const [
            MemoryLevelDef(pairs: 4, cols: 4),
            MemoryLevelDef(pairs: 6, cols: 4),
          ],
        GameDifficulty.hard => const [
            MemoryLevelDef(pairs: 4, cols: 4),
            MemoryLevelDef(pairs: 6, cols: 4),
            MemoryLevelDef(pairs: 8, cols: 4),
          ],
      };

  MemoryLevelDef get currentLevel => levels[levelIndex];
  int get pairGoal => currentLevel.pairs;
  int get totalLevels => levels.length;
  int get totalRoundStars => levels.fold(0, (sum, level) => sum + level.pairs);

  Set<int> get visibleIndices => {
        ...matchedIndices,
        ...revealedIndices,
      };

  void tapCard(int index) {
    if (locked ||
        showLevelComplete ||
        pendingRewardArgs != null ||
        matchedIndices.contains(index) ||
        revealedIndices.contains(index)) {
      return;
    }

    revealedIndices = [...revealedIndices, index];
    notifyListeners();

    if (revealedIndices.length < 2) {
      return;
    }

    attempts += 1;
    locked = true;
    final left = cards[revealedIndices[0]];
    final right = cards[revealedIndices[1]];
    final isMatch = left.face.id == right.face.id;
    feedbackState = isMatch
        ? MemoryCardFeedbackState.correct
        : MemoryCardFeedbackState.wrong;
    notifyListeners();

    _resolveTimer?.cancel();
    if (isMatch) {
      _resolveTimer = Timer(const Duration(milliseconds: 600), () {
        matchedIndices = {...matchedIndices, ...revealedIndices};
        matchedPairs += 1;

        if (matchedPairs >= pairGoal) {
          _completeLevel();
        }

        revealedIndices = const [];
        feedbackState = MemoryCardFeedbackState.idle;
        locked = false;
        notifyListeners();
      });
      return;
    }

    if (args.difficulty == GameDifficulty.hard) {
      shakingCards = revealedIndices;
      _resolveTimer = Timer(const Duration(milliseconds: 500), () {
        shakingCards = const [];
        notifyListeners();
      });
    }

    _resolveTimer = Timer(
      Duration(
          milliseconds: args.difficulty == GameDifficulty.hard ? 1300 : 1100),
      () {
        revealedIndices = const [];
        feedbackState = MemoryCardFeedbackState.idle;
        locked = false;
        shakingCards = const [];
        notifyListeners();
      },
    );
  }

  void reset() {
    _resolveTimer?.cancel();
    levelIndex = 0;
    totalAttempts = 0;
    totalPairs = 0;
    starsEarned = 0;
    showLevelComplete = false;
    _setupLevel();
    notifyListeners();
  }

  void continueLevel() {
    if (!showLevelComplete) {
      return;
    }
    showLevelComplete = false;
    levelIndex += 1;
    _setupLevel();
    notifyListeners();
  }

  void _completeLevel() {
    final levelAttempts = attempts;
    final levelStars = math.max(
      1,
      math.min(pairGoal, pairGoal - (levelAttempts - pairGoal)),
    );
    totalAttempts += levelAttempts;
    totalPairs += pairGoal;
    starsEarned += levelStars;

    if (levelIndex + 1 >= levels.length) {
      final finalStars = math.max(
        1,
        math.min(3, 3 - ((totalAttempts - totalPairs) ~/ 3)),
      );
      _resolveTimer = Timer(const Duration(milliseconds: 900), () {
        pendingRewardArgs = RewardRouteArgs(
          gameId: args.gameId,
          difficulty: args.difficulty,
          earnedStars: finalStars,
          totalRounds: 3,
        );
        notifyListeners();
      });
    } else {
      showLevelComplete = true;
    }
  }

  void _setupLevel() {
    attempts = 0;
    matchedPairs = 0;
    feedbackState = MemoryCardFeedbackState.idle;
    pendingRewardArgs = null;
    matchedIndices = const {};
    revealedIndices = const [];
    shakingCards = const [];
    locked = false;

    final deck = <MemoryCardEntry>[];
    var instanceId = 0;
    final faces = [..._memoryCardFaces]..shuffle(_random);
    for (final face in faces.take(pairGoal)) {
      deck.add(MemoryCardEntry(instanceId: instanceId++, face: face));
      deck.add(MemoryCardEntry(instanceId: instanceId++, face: face));
    }
    deck.shuffle(_random);
    cards = deck;
  }

  @override
  void dispose() {
    _resolveTimer?.cancel();
    super.dispose();
  }
}

class MemoryCardPage extends ConsumerStatefulWidget {
  const MemoryCardPage({required this.args, super.key});

  final GameRouteArgs args;

  @override
  ConsumerState<MemoryCardPage> createState() => _MemoryCardPageState();
}

class _MemoryCardPageState extends ConsumerState<MemoryCardPage> {
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
      memoryCardViewModelProvider(args).select(
        (viewModel) => 'level-${viewModel.levelIndex}',
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
    ref.read(memoryCardViewModelProvider(args)).reset();
    setState(() {
      _isPaused = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<RewardRouteArgs?>(
      memoryCardViewModelProvider(args)
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
    ref.listen<MemoryCardFeedbackState>(
      memoryCardViewModelProvider(args)
          .select((viewModel) => viewModel.feedbackState),
      (previous, next) {
        if (previous == next || next == MemoryCardFeedbackState.idle) {
          return;
        }
        unawaited(_voiceGuideController.stop());
        final soundController = ref.read(gameSoundControllerProvider);
        if (next == MemoryCardFeedbackState.correct) {
          unawaited(soundController.playCorrect());
        } else {
          unawaited(soundController.playWrong());
        }
      },
    );

    final l10n = context.l10n;
    final viewModel = ref.watch(memoryCardViewModelProvider(args));
    final cardSize = switch (viewModel.currentLevel.cols) {
      2 => 112.0,
      3 => 96.0,
      _ => 74.0,
    };

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
        palette: _memoryCardPalette,
        roundLabel:
            '第${viewModel.levelIndex + 1}关 · ${viewModel.matchedPairs}/${viewModel.pairGoal}对',
        difficulty: args.difficulty,
        stars: viewModel.starsEarned,
        progress: viewModel.matchedPairs / viewModel.pairGoal,
        onPause: _openPause,
        backgroundColor: const Color(0xFFFFF8FC),
        showDots: true,
        pauseIcon: const FigmaPauseIcon(size: 18, color: Color(0xFFE84AA5)),
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
              accentColor: Color(0xFFF7A5D6),
              borderColor: Color(0xFFE84AA5),
            ),
            if (viewModel.showLevelComplete)
              LevelCompleteOverlay(
                level: viewModel.levelIndex + 1,
                totalLevels: viewModel.totalLevels,
                stars: viewModel.starsEarned,
                totalRounds: viewModel.totalRoundStars,
                accentColor: const Color(0xFFC2185B),
                borderColor: const Color(0xFF880E4F),
                onContinue: () {
                  ref.read(memoryCardViewModelProvider(args)).continueLevel();
                },
              ),
          ],
        ),
        body: Column(
          children: [
            GridView.builder(
              key: ValueKey('level-${viewModel.levelIndex}'),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: viewModel.cards.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: viewModel.currentLevel.cols,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                mainAxisExtent: cardSize,
              ),
              itemBuilder: (context, index) {
                final card = viewModel.cards[index];
                return _MemoryCardTile(
                  entry: card,
                  faceUp: viewModel.visibleIndices.contains(index),
                  matched: viewModel.matchedIndices.contains(index),
                  shaking: viewModel.shakingCards.contains(index),
                  size: cardSize,
                  onTap: () => ref
                      .read(memoryCardViewModelProvider(args))
                      .tapCard(index),
                );
              },
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              child: viewModel.matchedPairs == viewModel.pairGoal
                  ? Padding(
                      padding: const EdgeInsets.only(top: 22),
                      child: FigmaGameFeedbackBanner(
                        visible: true,
                        text: '全部找到啦！',
                        isPositive: true,
                        palette: _memoryCardPalette,
                      ),
                    )
                  : const SizedBox(height: 22),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _speakCurrentPrompt() async {
    if (!mounted || _isPaused) {
      return;
    }

    await _voiceGuideController.speak(
      _memoryCardVoicePrompt(context),
      locale: Localizations.localeOf(context),
    );
  }
}

String _memoryCardVoicePrompt(BuildContext context) {
  return switch (Localizations.localeOf(context).languageCode) {
    'zh' => '找到一样的图案，让它们配对！',
    'ko' => '같은 그림을 찾아 짝을 맞춰봐요.',
    _ => 'Find matching pictures and pair them.',
  };
}

class _MemoryCardTile extends StatelessWidget {
  const _MemoryCardTile({
    required this.entry,
    required this.faceUp,
    required this.matched,
    required this.shaking,
    required this.size,
    required this.onTap,
  });

  final MemoryCardEntry entry;
  final bool faceUp;
  final bool matched;
  final bool shaking;
  final double size;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(end: shaking ? 1 : 0),
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeInOut,
          builder: (context, shakeValue, child) {
            final dx = shaking ? shakeOffset(shakeValue) * 0.55 : 0.0;
            final rotate =
                shaking ? math.sin(shakeValue * math.pi * 8) * 0.04 : 0.0;
            return Transform.translate(
              offset: Offset(dx, 0),
              child: Transform.rotate(angle: rotate, child: child),
            );
          },
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(end: faceUp ? 1 : 0),
            duration: const Duration(milliseconds: 450),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              final showFront = value >= 0.5;
              final angle = value * math.pi;
              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY(angle),
                child: Transform(
                  alignment: Alignment.center,
                  transform: showFront
                      ? (Matrix4.identity()..rotateY(math.pi))
                      : Matrix4.identity(),
                  child: AnimatedScale(
                    scale: matched ? 0.96 : 1,
                    duration: const Duration(milliseconds: 220),
                    child: showFront
                        ? _CardFront(entry: entry, size: size)
                        : _CardBack(size: size),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _CardFront extends StatelessWidget {
  const _CardFront({
    required this.entry,
    required this.size,
  });

  final MemoryCardEntry entry;
  final double size;

  @override
  Widget build(BuildContext context) {
    final face = entry.face;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF6A8D2), width: 3),
        boxShadow: [
          BoxShadow(
            color: face.shadow.withValues(alpha: 0.18),
            blurRadius: 0,
            offset: const Offset(4, 4),
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: face.fill,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Center(
            child: FigmaFloatIcon(type: face.iconType, size: 30),
          ),
        ),
      ),
    );
  }
}

class _CardBack extends StatelessWidget {
  const _CardBack({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFB5DD),
            Color(0xFFE84AA5),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFC2185B), width: 3),
        boxShadow: const [
          BoxShadow(
            color: Color(0x26C2185B),
            blurRadius: 0,
            offset: Offset(4, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.28),
                  width: 1.8,
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: FigmaFloatIcon(
              type: FigmaFloatIconType.heart,
              size: size > 100
                  ? 44
                  : size > 90
                      ? 36
                      : 28,
            ),
          ),
          Positioned(
            left: 14,
            top: 12,
            child: Container(
              width: 22,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.28),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
