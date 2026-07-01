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

class MoleKind {
  const MoleKind({
    required this.id,
    required this.nameZh,
    required this.nameKo,
    required this.nameEn,
    required this.avatar,
  });

  final String id;
  final String nameZh;
  final String nameKo;
  final String nameEn;
  final String avatar;

  String name(BuildContext context) {
    return switch (Localizations.localeOf(context).languageCode) {
      'zh' => nameZh,
      'ko' => nameKo,
      _ => nameEn,
    };
  }
}

class WhackMoleParams {
  const WhackMoleParams({
    required this.duration,
    required this.popInterval,
    required this.popDuration,
    required this.targetGoal,
    required this.decoyChance,
    required this.burstChance,
    required this.maxMolesPerWave,
  });

  final int duration;
  final Duration popInterval;
  final Duration popDuration;
  final int targetGoal;
  final double decoyChance;
  final double burstChance;
  final int maxMolesPerWave;
}

class ActiveMole {
  const ActiveMole({
    required this.holeIndex,
    required this.kind,
    required this.isTarget,
    required this.expiresAt,
    required this.scale,
    required this.tilt,
  });

  final int holeIndex;
  final MoleKind kind;
  final bool isTarget;
  final DateTime expiresAt;
  final double scale;
  final double tilt;
}

class MoleHitFeedback {
  const MoleHitFeedback({
    required this.holeIndex,
    required this.outcome,
  });

  final int holeIndex;
  final MoleOutcome outcome;
}

const _moleKinds = <MoleKind>[
  MoleKind(
    id: 'lion',
    nameZh: '狮子',
    nameKo: '사자',
    nameEn: 'Lion',
    avatar: '🦁',
  ),
  MoleKind(
    id: 'fox',
    nameZh: '狐狸',
    nameKo: '여우',
    nameEn: 'Fox',
    avatar: '🦊',
  ),
  MoleKind(
    id: 'chick',
    nameZh: '小鸡',
    nameKo: '병아리',
    nameEn: 'Chick',
    avatar: '🐥',
  ),
  MoleKind(
    id: 'bear',
    nameZh: '小熊',
    nameKo: '곰',
    nameEn: 'Bear',
    avatar: '🐻',
  ),
  MoleKind(
    id: 'panda',
    nameZh: '熊猫',
    nameKo: '판다',
    nameEn: 'Panda',
    avatar: '🐼',
  ),
  MoleKind(
    id: 'frog',
    nameZh: '青蛙',
    nameKo: '개구리',
    nameEn: 'Frog',
    avatar: '🐸',
  ),
];

WhackMoleParams _paramsFor(GameDifficulty difficulty) {
  return switch (difficulty) {
    GameDifficulty.easy => const WhackMoleParams(
        duration: 30,
        popInterval: Duration(milliseconds: 1100),
        popDuration: Duration(milliseconds: 1500),
        targetGoal: 10,
        decoyChance: 0,
        burstChance: 0,
        maxMolesPerWave: 1,
      ),
    GameDifficulty.medium => const WhackMoleParams(
        duration: 30,
        popInterval: Duration(milliseconds: 850),
        popDuration: Duration(milliseconds: 1200),
        targetGoal: 16,
        decoyChance: 0.35,
        burstChance: 0.34,
        maxMolesPerWave: 2,
      ),
    GameDifficulty.hard => const WhackMoleParams(
        duration: 30,
        popInterval: Duration(milliseconds: 650),
        popDuration: Duration(milliseconds: 1000),
        targetGoal: 22,
        decoyChance: 0.5,
        burstChance: 0.58,
        maxMolesPerWave: 3,
      ),
  };
}

class WhackMoleViewModel extends ChangeNotifier {
  WhackMoleViewModel(this.args)
      : params = _paramsFor(args.difficulty),
        targetKind = _moleKinds[math.Random().nextInt(_moleKinds.length)],
        timeLeft = _paramsFor(args.difficulty).duration;

  final GameRouteArgs args;
  final WhackMoleParams params;
  final math.Random _random = math.Random();
  Timer? _countdownTimer;
  Timer? _spawnTimer;
  Timer? _cleanupTimer;
  Timer? _targetTimer;
  Timer? _finishTimer;
  Timer? _feedbackTimer;

  MoleKind targetKind;
  List<ActiveMole?> moles = List<ActiveMole?>.filled(6, null);
  int score = 0;
  int misses = 0;
  int timeLeft;
  bool _started = false;
  bool paused = false;
  bool finished = false;
  bool targetJustChanged = true;
  MoleOutcome outcome = MoleOutcome.idle;
  MoleHitFeedback? hitFeedback;
  RewardRouteArgs? pendingRewardArgs;

  double get progress => (score / params.targetGoal).clamp(0, 1).toDouble();

  void startIfNeeded() {
    if (_started || pendingRewardArgs != null) {
      return;
    }
    _started = true;
    _startTimers();
  }

  void hitHole(int index) {
    if (paused || finished || pendingRewardArgs != null) {
      return;
    }

    final mole = moles[index];
    if (mole == null) {
      return;
    }

    moles = [
      for (var i = 0; i < moles.length; i++) i == index ? null : moles[i],
    ];
    if (mole.isTarget) {
      score += 1;
      outcome = MoleOutcome.hit;
      hitFeedback = MoleHitFeedback(holeIndex: index, outcome: MoleOutcome.hit);
    } else {
      misses += 1;
      outcome = MoleOutcome.miss;
      hitFeedback =
          MoleHitFeedback(holeIndex: index, outcome: MoleOutcome.miss);
    }
    _scheduleFeedbackClear();
    notifyListeners();
  }

  void pause() {
    paused = true;
    notifyListeners();
  }

  void resume() {
    paused = false;
    notifyListeners();
  }

  void reset() {
    _stopTimers();
    targetKind = _randomKind();
    moles = List<ActiveMole?>.filled(6, null);
    score = 0;
    misses = 0;
    timeLeft = params.duration;
    _started = false;
    paused = false;
    finished = false;
    outcome = MoleOutcome.idle;
    hitFeedback = null;
    targetJustChanged = true;
    pendingRewardArgs = null;
    notifyListeners();
    startIfNeeded();
  }

  void _startTimers() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (paused || finished) {
        return;
      }
      if (timeLeft <= 1) {
        timeLeft = 0;
        _finish();
        return;
      }
      timeLeft -= 1;
      notifyListeners();
    });

    _spawnTimer = Timer.periodic(params.popInterval, (_) {
      if (paused || finished) {
        return;
      }
      _spawnMole();
    });

    _cleanupTimer = Timer.periodic(const Duration(milliseconds: 150), (_) {
      if (paused || finished) {
        return;
      }
      _cleanupExpiredMoles();
    });

    if (args.difficulty != GameDifficulty.easy) {
      _targetTimer = Timer.periodic(
        args.difficulty == GameDifficulty.hard
            ? const Duration(seconds: 5)
            : const Duration(seconds: 7),
        (_) {
          if (paused || finished) {
            return;
          }
          targetKind = _randomKind(exceptId: targetKind.id);
          targetJustChanged = true;
          outcome = MoleOutcome.idle;
          notifyListeners();
        },
      );
    }
  }

  void _spawnMole() {
    final now = DateTime.now();
    final next = [
      for (final mole in moles)
        if (mole != null && mole.expiresAt.isAfter(now)) mole else null,
    ];
    final emptyHoles = <int>[
      for (var i = 0; i < next.length; i++)
        if (next[i] == null) i,
    ];
    if (emptyHoles.isEmpty) {
      moles = next;
      notifyListeners();
      return;
    }

    final waveCount = _waveCount(emptyHoles.length);
    emptyHoles.shuffle(_random);
    for (var waveIndex = 0; waveIndex < waveCount; waveIndex++) {
      final holeIndex = emptyHoles[waveIndex];
      final forceTarget = waveIndex == 0 && score < params.targetGoal;
      final isTarget = forceTarget || _random.nextDouble() > params.decoyChance;
      final kind = isTarget ? targetKind : _randomKind(exceptId: targetKind.id);
      next[holeIndex] = ActiveMole(
        holeIndex: holeIndex,
        kind: kind,
        isTarget: isTarget,
        expiresAt: now.add(params.popDuration),
        scale: 0.92 + _random.nextDouble() * 0.18,
        tilt: (_random.nextDouble() * 0.22) - 0.11,
      );
    }
    moles = next;
    if (targetJustChanged) {
      targetJustChanged = false;
    }
    notifyListeners();
  }

  int _waveCount(int emptyCount) {
    if (params.maxMolesPerWave <= 1 ||
        _random.nextDouble() > params.burstChance) {
      return 1;
    }
    return math.min(
      emptyCount,
      2 + _random.nextInt(params.maxMolesPerWave - 1),
    );
  }

  void _cleanupExpiredMoles() {
    final now = DateTime.now();
    final next = [
      for (final mole in moles)
        if (mole != null && mole.expiresAt.isAfter(now)) mole else null,
    ];
    if (!_sameMoles(next, moles)) {
      moles = next;
      notifyListeners();
    }
  }

  bool _sameMoles(List<ActiveMole?> a, List<ActiveMole?> b) {
    if (a.length != b.length) {
      return false;
    }
    for (var i = 0; i < a.length; i++) {
      if (a[i]?.expiresAt != b[i]?.expiresAt ||
          a[i]?.kind.id != b[i]?.kind.id ||
          a[i]?.isTarget != b[i]?.isTarget) {
        return false;
      }
    }
    return true;
  }

  void _finish() {
    if (finished) {
      return;
    }
    finished = true;
    moles = List<ActiveMole?>.filled(6, null);
    _stopTimers(keepFinishTimer: true);
    final stars = score >= params.targetGoal
        ? 3
        : score >= (params.targetGoal * 0.6).floor()
            ? 2
            : score > 0
                ? 1
                : 0;
    _finishTimer = Timer(const Duration(milliseconds: 1200), () {
      pendingRewardArgs = RewardRouteArgs(
        gameId: args.gameId,
        difficulty: args.difficulty,
        earnedStars: stars,
        totalRounds: 3,
      );
      notifyListeners();
    });
    notifyListeners();
  }

  void _scheduleFeedbackClear() {
    _feedbackTimer?.cancel();
    _feedbackTimer = Timer(const Duration(milliseconds: 400), () {
      hitFeedback = null;
      outcome = MoleOutcome.idle;
      notifyListeners();
    });
  }

  MoleKind _randomKind({String? exceptId}) {
    final pool = exceptId == null
        ? _moleKinds
        : _moleKinds.where((kind) => kind.id != exceptId).toList();
    return pool[_random.nextInt(pool.length)];
  }

  void _stopTimers({bool keepFinishTimer = false}) {
    _countdownTimer?.cancel();
    _spawnTimer?.cancel();
    _cleanupTimer?.cancel();
    _targetTimer?.cancel();
    _feedbackTimer?.cancel();
    if (!keepFinishTimer) {
      _finishTimer?.cancel();
    }
  }

  @override
  void dispose() {
    _stopTimers();
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
      whackMoleViewModelProvider(args)
          .select((viewModel) => viewModel.targetKind.id),
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
    final targetName = viewModel.targetKind.name(context);

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
        roundLabel: '⏱ ${viewModel.timeLeft}s',
        difficulty: args.difficulty,
        stars: viewModel.score,
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
            _TargetBanner(
              targetKind: viewModel.targetKind,
              targetName: targetName,
              score: viewModel.score,
              targetGoal: viewModel.params.targetGoal,
              justChanged: viewModel.targetJustChanged,
            ),
            const SizedBox(height: 18),
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
                final mole = viewModel.moles[index];
                final feedback = viewModel.hitFeedback?.holeIndex == index
                    ? viewModel.hitFeedback?.outcome
                    : MoleOutcome.idle;
                return _MoleHoleTile(
                  mole: mole,
                  feedback: feedback ?? MoleOutcome.idle,
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
                    label: '${l10n.whackMoleHitsLabel} ${viewModel.score}',
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
                        '${l10n.whackMoleGoalLabel} ${viewModel.params.targetGoal}',
                    textColor: const Color(0xFFF97316),
                    borderColor: const Color(0xFFFFC48A),
                  ),
                ),
              ],
            ),
            if (viewModel.finished) ...[
              const SizedBox(height: 18),
              FigmaGameFeedbackBanner(
                visible: true,
                text: '时间到！',
                isPositive: true,
                palette: _whackMolePalette,
              ),
            ],
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
    if (viewModel.pendingRewardArgs != null || viewModel.finished) {
      return;
    }
    await _voiceGuideController.speak(
      switch (Localizations.localeOf(context).languageCode) {
        'zh' => '快拍${viewModel.targetKind.name(context)}！',
        'ko' => '${viewModel.targetKind.name(context)}를 빠르게 눌러봐요!',
        _ => 'Tap the ${viewModel.targetKind.name(context)}!',
      },
      locale: Localizations.localeOf(context),
    );
  }
}

class _TargetBanner extends StatelessWidget {
  const _TargetBanner({
    required this.targetKind,
    required this.targetName,
    required this.score,
    required this.targetGoal,
    required this.justChanged,
  });

  final MoleKind targetKind;
  final String targetName;
  final int score;
  final int targetGoal;
  final bool justChanged;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: justChanged ? 1 : 0),
      duration: const Duration(milliseconds: 360),
      curve: Curves.easeOutBack,
      builder: (context, pulse, child) {
        return Transform.scale(
          scale: 1 + pulse * 0.025,
          child: child,
        );
      },
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
        decoration: BoxDecoration(
          color: justChanged ? const Color(0xFFFFF7D7) : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color:
                justChanged ? const Color(0xFFFF8C42) : const Color(0xFFFFD54F),
            width: 4,
          ),
          boxShadow: [
            BoxShadow(
              color: (justChanged
                      ? const Color(0xFFFF8C42)
                      : const Color(0xFFBF360C))
                  .withValues(alpha: justChanged ? 0.5 : 1),
              blurRadius: justChanged ? 16 : 0,
              offset: const Offset(6, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              child: justChanged
                  ? Container(
                      key: const ValueKey('target-changed'),
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF8C42),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text(
                        '目标切换啦！',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(key: ValueKey('target-steady')),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '快拍',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFBF360C),
                  ),
                ),
                const SizedBox(width: 16),
                KidLoopAnimation(
                  duration: const Duration(seconds: 1),
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(0, wave(value) * -6),
                      child: child,
                    );
                  },
                  child: FigmaMascotAvatar(
                    avatar: targetKind.avatar,
                    size: 52,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  '$targetName！',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFBF360C),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  '目标 $targetGoal 分',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFF57F17),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    height: 10,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: const Color(0xFFFFD54F),
                        width: 1.5,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween<double>(
                          end: (score / targetGoal).clamp(0, 1).toDouble(),
                        ),
                        duration: const Duration(milliseconds: 360),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, child) {
                          return Align(
                            alignment: Alignment.centerLeft,
                            child: FractionallySizedBox(
                              widthFactor: value,
                              heightFactor: 1,
                              child: child,
                            ),
                          );
                        },
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: score >= targetGoal
                                  ? const [
                                      Color(0xFF4CAF50),
                                      Color(0xFF81C784),
                                    ]
                                  : const [
                                      Color(0xFFFFD54F),
                                      Color(0xFFFF8C42),
                                    ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '$score/$targetGoal',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFBF360C),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MoleHoleTile extends StatelessWidget {
  const _MoleHoleTile({
    required this.mole,
    required this.feedback,
    required this.onTap,
  });

  final ActiveMole? mole;
  final MoleOutcome feedback;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final active = mole != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFFA1887F),
              Color(0xFF6D4C41),
              Color(0xFF3E2723),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0, 0.4, 1],
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: const Color(0xFF4E342E),
            width: 4,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0xFF3E2723),
              blurRadius: 0,
              offset: Offset(4, 5),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: 26,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3E2723), Color(0xFF1B0000)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            AnimatedSlide(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutBack,
              offset: active ? const Offset(0, 0.06) : const Offset(0, 0.8),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 180),
                opacity: active ? 1 : 0,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 28),
                  child: Transform.rotate(
                    angle: mole?.tilt ?? 0,
                    child: Transform.scale(
                      scale: mole?.scale ?? 1,
                      child: FigmaMascotAvatar(
                        avatar: mole?.kind.avatar ?? '🦁',
                        size: 60,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (feedback == MoleOutcome.hit)
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: 1),
                duration: const Duration(milliseconds: 400),
                builder: (context, value, child) {
                  return Opacity(
                    opacity: (1 - value).clamp(0, 1).toDouble(),
                    child: Transform.scale(
                      scale: 0.2 + value * 1.4,
                      child: child,
                    ),
                  );
                },
                child: const Center(
                  child: FigmaFloatIcon(
                    type: FigmaFloatIconType.star,
                    size: 50,
                  ),
                ),
              ),
            if (feedback == MoleOutcome.miss)
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: 1),
                duration: const Duration(milliseconds: 400),
                builder: (context, value, child) {
                  return Opacity(
                    opacity: (1 - value).clamp(0, 1).toDouble(),
                    child: child,
                  );
                },
                child: Container(
                  color: Colors.red.withValues(alpha: 0.25),
                  child: const Center(
                    child: Text(
                      '×',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black54,
                            offset: Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
