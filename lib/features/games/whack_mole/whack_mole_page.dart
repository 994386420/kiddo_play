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

const _whackMolePalette = FigmaGamePalette(
  accent: Color(0xFFFFC771),
  accentStrong: Color(0xFFF97316),
  accentSoft: Color(0xFFFFF5E8),
  progressTrack: Color(0xFFFFE4C5),
  progressBorder: Color(0xFFFFC48A),
  progressGradient: LinearGradient(
    colors: [Color(0xFFFFC771), Color(0xFFF97316)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  ),
  floaterIcon: FigmaFloatIconType.fire,
);

final whackMoleViewModelProvider = ChangeNotifierProvider.autoDispose
    .family<WhackMoleViewModel, GameRouteArgs>((ref, args) {
  return WhackMoleViewModel(args);
});

enum MoleOutcome { idle, hit, miss }

class WhackMoleViewModel extends ChangeNotifier {
  WhackMoleViewModel(this.args);

  final GameRouteArgs args;
  final math.Random _random = math.Random();
  Timer? _waveTimer;
  Timer? _transitionTimer;
  DateTime? _deadline;
  Duration _remainingWave = Duration.zero;

  int round = 0;
  int stars = 0;
  int hits = 0;
  int misses = 0;
  int? activeHole;
  bool locked = false;
  bool _started = false;
  MoleOutcome outcome = MoleOutcome.idle;
  RewardRouteArgs? pendingRewardArgs;

  DifficultyConfig get config => args.difficulty.config;

  double get progress => round / config.rounds;

  void startIfNeeded() {
    if (_started || pendingRewardArgs != null) {
      return;
    }
    _started = true;
    _launchNextWave();
  }

  void hitHole(int index) {
    if (locked || activeHole != index || pendingRewardArgs != null) {
      return;
    }

    _cancelWaveTimer();
    locked = true;
    outcome = MoleOutcome.hit;
    hits += 1;
    stars += 1;
    round += 1;
    notifyListeners();
    _queueNextWave();
  }

  void pause() {
    if (pendingRewardArgs != null || activeHole == null || locked) {
      return;
    }
    final remaining = _deadline?.difference(DateTime.now());
    _remainingWave = remaining == null || remaining.isNegative
        ? const Duration(milliseconds: 80)
        : remaining;
    _cancelWaveTimer();
  }

  void resume() {
    if (pendingRewardArgs != null || activeHole == null || locked) {
      return;
    }
    _scheduleWaveTimer(
        _remainingWave == Duration.zero ? _waveDuration : _remainingWave);
  }

  void reset() {
    _waveTimer?.cancel();
    _transitionTimer?.cancel();
    _deadline = null;
    _remainingWave = Duration.zero;
    round = 0;
    stars = 0;
    hits = 0;
    misses = 0;
    activeHole = null;
    locked = false;
    _started = false;
    outcome = MoleOutcome.idle;
    pendingRewardArgs = null;
    notifyListeners();
    startIfNeeded();
  }

  void _launchNextWave() {
    if (round >= config.rounds) {
      pendingRewardArgs = RewardRouteArgs(
        gameId: args.gameId,
        difficulty: args.difficulty,
        earnedStars: stars,
        totalRounds: config.rounds,
      );
      activeHole = null;
      notifyListeners();
      return;
    }

    final previousHole = activeHole;
    activeHole = _nextHole(previousHole);
    outcome = MoleOutcome.idle;
    locked = false;
    _scheduleWaveTimer(_waveDuration);
    notifyListeners();
  }

  int _nextHole(int? previousHole) {
    final holes = List<int>.generate(6, (index) => index);
    if (previousHole != null && holes.length > 1) {
      holes.remove(previousHole);
    }
    return holes[_random.nextInt(holes.length)];
  }

  Duration get _waveDuration => switch (args.difficulty) {
        GameDifficulty.easy => const Duration(milliseconds: 1500),
        GameDifficulty.medium => const Duration(milliseconds: 1180),
        GameDifficulty.hard => const Duration(milliseconds: 900),
      };

  void _scheduleWaveTimer(Duration duration) {
    _cancelWaveTimer();
    _remainingWave = duration;
    _deadline = DateTime.now().add(duration);
    _waveTimer = Timer(duration, _markMiss);
  }

  void _markMiss() {
    if (locked || activeHole == null || pendingRewardArgs != null) {
      return;
    }
    locked = true;
    outcome = MoleOutcome.miss;
    misses += 1;
    round += 1;
    notifyListeners();
    _queueNextWave();
  }

  void _queueNextWave() {
    _transitionTimer?.cancel();
    _transitionTimer =
        Timer(const Duration(milliseconds: 420), _launchNextWave);
  }

  void _cancelWaveTimer() {
    _waveTimer?.cancel();
    _waveTimer = null;
    _deadline = null;
  }

  @override
  void dispose() {
    _waveTimer?.cancel();
    _transitionTimer?.cancel();
    super.dispose();
  }
}

class WhackMolePage extends ConsumerStatefulWidget {
  const WhackMolePage({required this.args, super.key});

  final GameRouteArgs args;

  @override
  ConsumerState<WhackMolePage> createState() => _WhackMolePageState();
}

class _WhackMolePageState extends ConsumerState<WhackMolePage> {
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
      whackMoleViewModelProvider(args).select((viewModel) =>
          '${viewModel.round}-${viewModel.activeHole}-${viewModel.outcome}'),
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
      ref.read(whackMoleViewModelProvider(args)).startIfNeeded();
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
    ref.read(whackMoleViewModelProvider(args)).pause();
    unawaited(_voiceGuideController.stop());
    setState(() {
      _isPaused = true;
    });
  }

  void _closePause() {
    unawaited(ref.read(gameSoundControllerProvider).playClick());
    ref.read(whackMoleViewModelProvider(args)).resume();
    setState(() {
      _isPaused = false;
    });
    unawaited(_speakCurrentPrompt());
  }

  void _restartGame() {
    unawaited(ref.read(gameSoundControllerProvider).playClick());
    unawaited(_voiceGuideController.stop());
    ref.read(whackMoleViewModelProvider(args)).reset();
    setState(() {
      _isPaused = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<RewardRouteArgs?>(
      whackMoleViewModelProvider(args)
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
    ref.listen<MoleOutcome>(
      whackMoleViewModelProvider(args).select((viewModel) => viewModel.outcome),
      (previous, next) {
        if (previous == next || next == MoleOutcome.idle) {
          return;
        }
        final soundController = ref.read(gameSoundControllerProvider);
        if (next == MoleOutcome.hit) {
          unawaited(soundController.playCorrect());
        } else if (next == MoleOutcome.miss) {
          unawaited(soundController.playWrong());
        }
      },
    );

    final l10n = context.l10n;
    final viewModel = ref.watch(whackMoleViewModelProvider(args));

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
        palette: _whackMolePalette,
        roundLabel:
            l10n.roundCounter(viewModel.round + 1, viewModel.config.rounds),
        difficulty: args.difficulty,
        stars: viewModel.stars,
        progress: viewModel.progress,
        onPause: _openPause,
        backgroundColor: const Color(0xFFFFFBF4),
        showDots: true,
        includeYellowDots: true,
        pauseIcon: const FigmaPauseIcon(size: 18, color: Color(0xFFF97316)),
        floatingAction: const FloatingSoundToggle(
          accentColor: Color(0xFFFFC771),
          borderColor: Color(0xFFF97316),
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
              palette: _whackMolePalette,
              radius: 30,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
              child: Column(
                children: [
                  Text(
                    l10n.whackMolePrompt,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF925428),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF5E8),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: const Color(0xFFFFD5A3),
                        width: 2.4,
                      ),
                    ),
                    child: Row(
                      children: [
                        const _TargetMoleBadge(),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            l10n.whackMolePrompt,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF9A5C2E),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 6,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                mainAxisExtent: 122,
              ),
              itemBuilder: (context, index) {
                return _MoleHoleTile(
                  active: viewModel.activeHole == index,
                  outcome: viewModel.activeHole == index
                      ? viewModel.outcome
                      : MoleOutcome.idle,
                  onTap: () =>
                      ref.read(whackMoleViewModelProvider(args)).hitHole(index),
                );
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FigmaGameInfoPill(
                    palette: _whackMolePalette,
                    label: '${l10n.whackMoleHitsLabel} ${viewModel.hits}',
                    textColor: const Color(0xFF2E7D32),
                    borderColor: const Color(0xFF9CCC65),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FigmaGameInfoPill(
                    palette: _whackMolePalette,
                    label: '${l10n.whackMoleMissesLabel} ${viewModel.misses}',
                    textColor: const Color(0xFFE65100),
                    borderColor: const Color(0xFFFFB74D),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FigmaGameInfoPill(
                    palette: _whackMolePalette,
                    label:
                        '${l10n.whackMoleGoalLabel} ${viewModel.config.rounds}',
                    textColor: const Color(0xFFF97316),
                    borderColor: const Color(0xFFFFC48A),
                  ),
                ),
              ],
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
    final viewModel = ref.read(whackMoleViewModelProvider(args));
    if (viewModel.pendingRewardArgs != null || viewModel.activeHole == null) {
      return;
    }
    await _voiceGuideController.speak(
      switch (Localizations.localeOf(context).languageCode) {
        'zh' => '快点中冒出来的小地鼠。',
        'ko' => '올라오는 두더지를 바로 눌러봐요.',
        _ => 'Tap the mole as soon as it pops up.',
      },
      locale: Localizations.localeOf(context),
    );
  }
}

class _TargetMoleBadge extends StatelessWidget {
  const _TargetMoleBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 68,
      height: 68,
      decoration: BoxDecoration(
        color: const Color(0xFFFFE3BC),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFFFC48A),
          width: 3,
        ),
      ),
      child: const Center(child: _MoleFace(size: 34)),
    );
  }
}

class _MoleHoleTile extends StatelessWidget {
  const _MoleHoleTile({
    required this.active,
    required this.outcome,
    required this.onTap,
  });

  final bool active;
  final MoleOutcome outcome;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFFF5E8),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: active ? const Color(0xFFFFC48A) : const Color(0xFFFFE4C5),
            width: 3,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              left: 12,
              right: 12,
              bottom: 18,
              child: Container(
                height: 30,
                decoration: BoxDecoration(
                  color: const Color(0xFF7C3F17),
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x22000000),
                      blurRadius: 12,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
              ),
            ),
            AnimatedSlide(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutBack,
              offset: active ? Offset.zero : const Offset(0, 0.8),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 180),
                opacity: active ? 1 : 0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (outcome == MoleOutcome.hit)
                      const Text('⭐', style: TextStyle(fontSize: 22))
                    else if (outcome == MoleOutcome.miss)
                      const Text('💨', style: TextStyle(fontSize: 20))
                    else
                      const SizedBox(height: 22),
                    const _MoleFace(size: 42),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MoleFace extends StatelessWidget {
  const _MoleFace({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: size * 0.1,
            right: size * 0.1,
            bottom: 0,
            child: Container(
              height: size * 0.82,
              decoration: BoxDecoration(
                color: const Color(0xFFB7774E),
                borderRadius: BorderRadius.circular(size * 0.34),
              ),
            ),
          ),
          Positioned(
            left: size * 0.08,
            top: size * 0.1,
            child: Container(
              width: size * 0.24,
              height: size * 0.24,
              decoration: const BoxDecoration(
                color: Color(0xFFD9A27B),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: size * 0.08,
            top: size * 0.1,
            child: Container(
              width: size * 0.24,
              height: size * 0.24,
              decoration: const BoxDecoration(
                color: Color(0xFFD9A27B),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: size * 0.24,
            top: size * 0.34,
            child: Container(
              width: size * 0.12,
              height: size * 0.12,
              decoration: const BoxDecoration(
                color: Color(0xFF2F1F18),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: size * 0.24,
            top: size * 0.34,
            child: Container(
              width: size * 0.12,
              height: size * 0.12,
              decoration: const BoxDecoration(
                color: Color(0xFF2F1F18),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: size * 0.24,
            right: size * 0.24,
            bottom: size * 0.16,
            child: Container(
              height: size * 0.18,
              decoration: BoxDecoration(
                color: const Color(0xFFEFC29B),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Center(
                child: Container(
                  width: size * 0.16,
                  height: size * 0.16,
                  decoration: const BoxDecoration(
                    color: Color(0xFF8B4D2E),
                    shape: BoxShape.circle,
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
