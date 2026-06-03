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
    _setupDeck();
  }

  static const _pairGoal = 6;

  final GameRouteArgs args;
  final math.Random _random = math.Random();
  Timer? _previewTimer;
  Timer? _resolveTimer;

  List<MemoryCardEntry> cards = const [];
  List<int> revealedIndices = const [];
  Set<int> matchedIndices = const {};
  bool previewing = false;
  bool locked = false;
  int stars = 0;
  int flips = 0;
  int matchedPairs = 0;
  MemoryCardFeedbackState feedbackState = MemoryCardFeedbackState.idle;
  RewardRouteArgs? pendingRewardArgs;

  int get pairGoal => _pairGoal;

  Set<int> get visibleIndices => {
        ...matchedIndices,
        ...revealedIndices,
        if (previewing)
          for (var index = 0; index < cards.length; index++) index,
      };

  void tapCard(int index) {
    if (previewing ||
        locked ||
        pendingRewardArgs != null ||
        matchedIndices.contains(index) ||
        revealedIndices.contains(index)) {
      return;
    }

    flips += 1;
    revealedIndices = [...revealedIndices, index];
    notifyListeners();

    if (revealedIndices.length < 2) {
      return;
    }

    locked = true;
    final left = cards[revealedIndices[0]];
    final right = cards[revealedIndices[1]];
    final isMatch = left.face.id == right.face.id;
    feedbackState = isMatch
        ? MemoryCardFeedbackState.correct
        : MemoryCardFeedbackState.wrong;
    notifyListeners();

    _resolveTimer?.cancel();
    _resolveTimer = Timer(
      Duration(milliseconds: isMatch ? 520 : 760),
      () {
        if (isMatch) {
          matchedIndices = {...matchedIndices, ...revealedIndices};
          matchedPairs += 1;
          stars += 1;
          if (matchedPairs >= pairGoal) {
            pendingRewardArgs = RewardRouteArgs(
              gameId: args.gameId,
              difficulty: args.difficulty,
              earnedStars: stars,
              totalRounds: pairGoal,
            );
          }
        }

        revealedIndices = const [];
        feedbackState = MemoryCardFeedbackState.idle;
        locked = false;
        notifyListeners();
      },
    );
  }

  void reset() {
    _previewTimer?.cancel();
    _resolveTimer?.cancel();
    _setupDeck();
    notifyListeners();
  }

  void _setupDeck() {
    stars = 0;
    flips = 0;
    matchedPairs = 0;
    feedbackState = MemoryCardFeedbackState.idle;
    pendingRewardArgs = null;
    matchedIndices = const {};
    revealedIndices = const [];
    locked = false;

    final deck = <MemoryCardEntry>[];
    var instanceId = 0;
    for (final face in _memoryCardFaces) {
      deck.add(MemoryCardEntry(instanceId: instanceId++, face: face));
      deck.add(MemoryCardEntry(instanceId: instanceId++, face: face));
    }
    deck.shuffle(_random);
    cards = deck;

    previewing = args.difficulty != GameDifficulty.hard;
    if (previewing) {
      _previewTimer = Timer(_previewDuration, () {
        previewing = false;
        notifyListeners();
      });
    }
  }

  Duration get _previewDuration => switch (args.difficulty) {
        GameDifficulty.easy => const Duration(milliseconds: 2200),
        GameDifficulty.medium => const Duration(milliseconds: 1400),
        GameDifficulty.hard => Duration.zero,
      };

  @override
  void dispose() {
    _previewTimer?.cancel();
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
        (viewModel) =>
            '${viewModel.previewing}-${viewModel.matchedPairs}-${viewModel.revealedIndices.length}',
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
    unawaited(_speakCurrentPrompt());
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
            '${viewModel.matchedPairs} / ${viewModel.pairGoal} ${l10n.memoryCardPairsLabel}',
        difficulty: args.difficulty,
        stars: viewModel.stars,
        progress: viewModel.matchedPairs / viewModel.pairGoal,
        onPause: _openPause,
        backgroundColor: const Color(0xFFFFF8FC),
        showDots: true,
        pauseIcon: const FigmaPauseIcon(size: 18, color: Color(0xFFE84AA5)),
        floatingAction: const FloatingSoundToggle(
          accentColor: Color(0xFFF7A5D6),
          borderColor: Color(0xFFE84AA5),
        ),
        pauseDialog: PauseDialog(
          isOpen: _isPaused,
          gameName: args.gameId.title(l10n),
          gameEmoji: args.gameId.emoji,
          onContinue: _closePause,
          onRestart: _restartGame,
          onQuit: () => _handleBack(context),
        ),
        body: Column(
          children: [
            FigmaGamePanel(
              palette: _memoryCardPalette,
              radius: 30,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
              child: Column(
                children: [
                  Text(
                    l10n.memoryCardPrompt,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF8E3A68),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: FigmaGameInfoPill(
                          palette: _memoryCardPalette,
                          label:
                              '${viewModel.matchedPairs} / ${viewModel.pairGoal} ${l10n.memoryCardPairsLabel}',
                          textColor: const Color(0xFFBE185D),
                          borderColor: const Color(0xFFF7A5D6),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FigmaGameInfoPill(
                          palette: _memoryCardPalette,
                          label:
                              '${l10n.memoryCardFlipsLabel} ${viewModel.flips}',
                          textColor: const Color(0xFF9D174D),
                          borderColor: const Color(0xFFF7A5D6),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  FigmaGameFeedbackBanner(
                    visible: viewModel.previewing ||
                        viewModel.feedbackState != MemoryCardFeedbackState.idle,
                    text: viewModel.previewing
                        ? l10n.memoryCardPreviewHint
                        : viewModel.feedbackState ==
                                MemoryCardFeedbackState.correct
                            ? l10n.feedbackCorrect
                            : l10n.feedbackTryAgain,
                    isPositive: viewModel.previewing ||
                        viewModel.feedbackState ==
                            MemoryCardFeedbackState.correct,
                    palette: _memoryCardPalette,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: viewModel.cards.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                mainAxisExtent: 104,
              ),
              itemBuilder: (context, index) {
                final card = viewModel.cards[index];
                return _MemoryCardTile(
                  entry: card,
                  faceUp: viewModel.visibleIndices.contains(index),
                  matched: viewModel.matchedIndices.contains(index),
                  onTap: () => ref
                      .read(memoryCardViewModelProvider(args))
                      .tapCard(index),
                );
              },
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

    final viewModel = ref.read(memoryCardViewModelProvider(args));
    await _voiceGuideController.speak(
      _memoryCardVoicePrompt(context, previewing: viewModel.previewing),
      locale: Localizations.localeOf(context),
    );
  }
}

String _memoryCardVoicePrompt(BuildContext context,
    {required bool previewing}) {
  return switch (Localizations.localeOf(context).languageCode) {
    'zh' => previewing ? '先记住卡片位置哦。' : '翻出两张一样的卡片吧。',
    'ko' => previewing ? '카드 위치를 먼저 기억해봐요.' : '같은 카드 두 장을 찾아봐요.',
    _ =>
      previewing ? 'Remember where the cards are.' : 'Find two matching cards.',
  };
}

class _MemoryCardTile extends StatelessWidget {
  const _MemoryCardTile({
    required this.entry,
    required this.faceUp,
    required this.matched,
    required this.onTap,
  });

  final MemoryCardEntry entry;
  final bool faceUp;
  final bool matched;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(end: faceUp ? 1 : 0),
          duration: const Duration(milliseconds: 260),
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
                  child:
                      showFront ? _CardFront(entry: entry) : const _CardBack(),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CardFront extends StatelessWidget {
  const _CardFront({required this.entry});

  final MemoryCardEntry entry;

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
  const _CardBack();

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
          const Align(
            alignment: Alignment.center,
            child: FigmaFloatIcon(
              type: FigmaFloatIconType.heart,
              size: 28,
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
