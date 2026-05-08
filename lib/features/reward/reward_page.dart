import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/localization.dart';
import '../../app/route_args.dart';
import '../../app/router.dart';
import '../../core/app_controllers.dart';
import '../../core/game_models.dart';
import '../../core/sound/game_sound_controller.dart';
import '../../core/widgets/kid_button.dart';
import '../../core/widgets/kid_motion.dart';

class RewardPage extends ConsumerStatefulWidget {
  const RewardPage({required this.args, super.key});

  final RewardRouteArgs args;

  @override
  ConsumerState<RewardPage> createState() => _RewardPageState();
}

class _RewardPageState extends ConsumerState<RewardPage>
    with TickerProviderStateMixin {
  static const double _timelineTotalMs = 1500;
  static const double _celebrationLoopMs = 2500;
  static const List<Color> _confettiColors = [
    Color(0xFF4FC3F7),
    Color(0xFFFFD93D),
    Color(0xFFFF8C42),
    Color(0xFFA855F7),
    Color(0xFF4BC96A),
    Color(0xFFFF70A6),
  ];

  late final AnimationController _timelineController;
  late final AnimationController _celebrationController;
  late final List<_CelebrationParticle> _celebrationParticles;
  late final double _celebrationTotalMs;

  Timer? _unlockTimer;
  GameId? _newlyUnlockedGame;
  late final String _encouragement;

  @override
  void initState() {
    super.initState();

    _timelineController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: _timelineTotalMs.toInt()),
    )..forward();
    _celebrationParticles = _buildCelebrationParticles();
    _celebrationTotalMs = _celebrationParticles.fold<double>(
      0,
      (latest, particle) => max(latest, particle.spawnMs + particle.lifeMs),
    );
    _celebrationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: _celebrationTotalMs.ceil()),
    )..forward();

    _encouragement =
        '${widget.args.gameId.index}${widget.args.difficulty.index}${Random().nextInt(999)}';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      unawaited(ref.read(gameSoundControllerProvider).playStar());

      final progressController = ref.read(gameProgressProvider);
      final parentDataController = ref.read(parentDataProvider);

      final newlyUnlockedGame = progressController.completeGame(
        gameId: widget.args.gameId,
        earnedStars: widget.args.earnedStars,
      );

      parentDataController.recordGameCompletion(
        gameId: widget.args.gameId,
        stars: widget.args.earnedStars,
        totalRounds: widget.args.totalRounds,
        difficulty: widget.args.difficulty,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _newlyUnlockedGame = newlyUnlockedGame;
      });

      if (newlyUnlockedGame != null) {
        unawaited(ref.read(gameSoundControllerProvider).playUnlock());
        _unlockTimer = Timer(const Duration(milliseconds: 1400), () {
          if (mounted) {
            setState(() {});
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _unlockTimer?.cancel();
    _celebrationController.dispose();
    _timelineController.dispose();
    super.dispose();
  }

  String _pickEncouragement(BuildContext context) {
    final all = [
      context.l10n.rewardEncouragement1,
      context.l10n.rewardEncouragement2,
      context.l10n.rewardEncouragement3,
      context.l10n.rewardEncouragement4,
      context.l10n.rewardEncouragement5,
    ];
    final seed = _encouragement.codeUnits.fold<int>(0, (sum, e) => sum + e);
    return all[seed % all.length];
  }

  Animation<double> _stageAnimation({
    required double delayMs,
    double durationMs = 420,
    Curve curve = Curves.easeOutCubic,
  }) {
    final start = (delayMs / _timelineTotalMs).clamp(0.0, 1.0);
    final end = ((delayMs + durationMs) / _timelineTotalMs).clamp(0.0, 1.0);

    return CurvedAnimation(
      parent: _timelineController,
      curve: Interval(start, end, curve: curve),
    );
  }

  List<_CelebrationParticle> _buildCelebrationParticles() {
    final seed = widget.args.gameId.index * 1000 +
        widget.args.difficulty.index * 100 +
        widget.args.earnedStars * 10 +
        widget.args.totalRounds;
    final random = Random(seed);
    final particles = <_CelebrationParticle>[];

    for (double burstMs = 0; burstMs <= _celebrationLoopMs; burstMs += 34) {
      _addDirectionalBurst(
        particles,
        random,
        spawnMs: burstMs,
        origin: const Offset(-0.02, 0.75),
        angleBase: -pi / 3,
      );
      _addDirectionalBurst(
        particles,
        random,
        spawnMs: burstMs,
        origin: const Offset(1.02, 0.75),
        angleBase: -2 * pi / 3,
      );
    }

    _addCenterBurst(
      particles,
      random,
      spawnMs: 300,
      origin: const Offset(0.50, 0.54),
      angleBase: -pi / 2,
    );
    return particles;
  }

  void _addDirectionalBurst(
    List<_CelebrationParticle> particles,
    Random random, {
    required double spawnMs,
    required Offset origin,
    required double angleBase,
  }) {
    final count = 5 + random.nextInt(2);

    for (var index = 0; index < count; index++) {
      final shape = random.nextDouble() < 0.62
          ? _CelebrationShape.star
          : _CelebrationShape.circle;
      final angle = angleBase + _randomRange(random, -0.48, 0.48);
      final speed = _randomRange(random, 600, 920);
      final originJitter = Offset(
        _randomRange(random, -0.018, 0.018),
        _randomRange(random, -0.018, 0.016),
      );
      final mainSize = shape == _CelebrationShape.star
          ? _randomRange(random, 9, 16)
          : _randomRange(random, 6, 11);

      particles.add(
        _CelebrationParticle(
          origin: origin + originJitter,
          velocity: Offset(cos(angle) * speed, sin(angle) * speed),
          gravity: _randomRange(random, 820, 1080),
          spawnMs: spawnMs + _randomRange(random, 0, 18),
          lifeMs: _randomRange(random, 1380, 1680),
          color: _confettiColors[random.nextInt(_confettiColors.length)],
          shape: shape,
          mainSize: mainSize,
          rotation: _randomRange(random, -pi, pi),
          rotationSpeed: _randomRange(random, -5.4, 5.4),
          sway: _randomRange(random, 10, 24),
          wobbleFrequency: _randomRange(random, 7.8, 11.6),
          drag: _randomRange(random, 0.12, 0.22),
        ),
      );
    }
  }

  void _addCenterBurst(
    List<_CelebrationParticle> particles,
    Random random, {
    required double spawnMs,
    required Offset origin,
    required double angleBase,
  }) {
    for (var index = 0; index < 120; index++) {
      final angle = angleBase + _randomRange(random, -0.87, 0.87);
      final speed = _randomRange(random, 280, 620);
      final mainSize = _randomRange(random, 10, 16);
      final originJitter = Offset(
        _randomRange(random, -0.014, 0.014),
        _randomRange(random, -0.010, 0.008),
      );

      particles.add(
        _CelebrationParticle(
          origin: origin + originJitter,
          velocity: Offset(cos(angle) * speed, sin(angle) * speed),
          gravity: _randomRange(random, 640, 900),
          spawnMs: spawnMs + _randomRange(random, 0, 72),
          lifeMs: _randomRange(random, 1040, 1420),
          color: _confettiColors[random.nextInt(_confettiColors.length)],
          shape: _CelebrationShape.star,
          mainSize: mainSize,
          rotation: _randomRange(random, -pi, pi),
          rotationSpeed: _randomRange(random, -6.0, 6.0),
          sway: _randomRange(random, 3, 10),
          wobbleFrequency: _randomRange(random, 9.2, 13.0),
          drag: _randomRange(random, 0.06, 0.16),
        ),
      );
    }
  }

  double _randomRange(Random random, double min, double max) {
    return min + random.nextDouble() * (max - min);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final gameId = widget.args.gameId;
    final showUnlockBanner =
        _newlyUnlockedGame != null && !(_unlockTimer?.isActive ?? false);
    final isCompactHeight = MediaQuery.sizeOf(context).height < 900;
    final screenPadding = isCompactHeight ? 10.0 : 20.0;
    final topGap = isCompactHeight ? 4.0 : 8.0;
    final titleGap = isCompactHeight ? 4.0 : 6.0;
    final badgeGap = isCompactHeight ? 6.0 : 10.0;
    final starsSectionGap = isCompactHeight ? 16.0 : 22.0;
    final cardPadding = isCompactHeight ? 18.0 : 24.0;
    final unlockTopMargin = isCompactHeight ? 12.0 : 18.0;
    final unlockPadding = isCompactHeight ? 16.0 : 18.0;
    final buttonGap = isCompactHeight ? 8.0 : 12.0;
    final buttonVerticalPadding = isCompactHeight ? 12.0 : 16.0;
    final homeButtonVerticalPadding = isCompactHeight ? 10.0 : 14.0;
    final bottomGap = isCompactHeight ? 10.0 : 16.0;
    final scrollBottomPadding = isCompactHeight ? 16.0 : 28.0;
    final trophySize = isCompactHeight ? 80.0 : 86.0;
    final trophyAnimation = _stageAnimation(
      delayMs: 100,
      durationMs: 520,
      curve: Curves.elasticOut,
    );
    final headingAnimation = _stageAnimation(
      delayMs: 300,
      durationMs: 430,
      curve: Curves.elasticOut,
    );
    final descriptionAnimation = _stageAnimation(
      delayMs: 500,
      durationMs: 220,
    );
    final badgeAnimation = _stageAnimation(
      delayMs: 600,
      durationMs: 260,
      curve: Curves.easeOutBack,
    );
    final starsCardAnimation = _stageAnimation(
      delayMs: 350,
      durationMs: 340,
    );
    final starsSummaryAnimation = _stageAnimation(
      delayMs: 1100,
      durationMs: 220,
    );
    final replayButtonAnimation = _stageAnimation(
      delayMs: 800,
      durationMs: 320,
      curve: Curves.easeOutBack,
    );
    final difficultyButtonAnimation = _stageAnimation(
      delayMs: 880,
      durationMs: 320,
      curve: Curves.easeOutBack,
    );
    final gameSelectButtonAnimation = _stageAnimation(
      delayMs: 960,
      durationMs: 320,
      curve: Curves.easeOutBack,
    );
    final homeButtonAnimation = _stageAnimation(
      delayMs: 1040,
      durationMs: 320,
      curve: Curves.easeOutBack,
    );

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFFDE7), Color(0xFFE3F2FD), Color(0xFFF3E5F5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            const Positioned(
              top: -60,
              left: -60,
              child: _Blob(size: 200, color: Color(0x4DFFD93D)),
            ),
            const Positioned(
              bottom: -70,
              right: -70,
              child: _Blob(size: 250, color: Color(0x33A855F7)),
            ),
            const Positioned(
              top: 180,
              right: -40,
              child: _Blob(size: 150, color: Color(0x334FC3F7)),
            ),
            for (final entry in [
              ('🎉', 0.10, 0.06, 28.0, 0),
              ('🌟', 0.25, 0.84, 36.0, 200),
              ('🎈', 0.42, 0.12, 32.0, 400),
              ('✨', 0.62, 0.88, 28.0, 600),
              ('🏆', 0.78, 0.18, 34.0, 800),
            ])
              Positioned(
                top: MediaQuery.sizeOf(context).height * entry.$2,
                left: MediaQuery.sizeOf(context).width * entry.$3,
                child: KidLoopAnimation(
                  delay: Duration(milliseconds: entry.$5),
                  duration: Duration(milliseconds: 2500 + entry.$5),
                  builder: (context, value, child) {
                    final dy = lerpValue(0, -12, value);
                    final angle = lerpValue(-0.18, 0.18, value);
                    return Transform.translate(
                      offset: Offset(0, dy),
                      child: Transform.rotate(angle: angle, child: child),
                    );
                  },
                  child: Text(
                    entry.$1,
                    style: TextStyle(
                      fontSize: entry.$4,
                      color: Colors.black.withValues(alpha: 0.65),
                    ),
                  ),
                ),
              ),
            SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  screenPadding,
                  screenPadding,
                  screenPadding,
                  scrollBottomPadding,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 390),
                    child: Column(
                      children: [
                        SizedBox(height: topGap),
                        _StageEntrance(
                          animation: trophyAnimation,
                          beginScale: 0,
                          beginOffset: const Offset(0, -40),
                          child: Text(
                            '🏆',
                            style: TextStyle(fontSize: trophySize),
                          ),
                        ),
                        SizedBox(height: topGap),
                        _StageEntrance(
                          animation: headingAnimation,
                          beginScale: 0.7,
                          child: Text(
                            _pickEncouragement(context),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFFB45309),
                            ),
                          ),
                        ),
                        SizedBox(height: titleGap),
                        _StageEntrance(
                          animation: descriptionAnimation,
                          child: Text(
                            l10n.rewardCompleted(gameId.title(l10n)),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF546E7A),
                            ),
                          ),
                        ),
                        SizedBox(height: badgeGap),
                        _StageEntrance(
                          animation: badgeAnimation,
                          beginScale: 0.8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.75),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: const Color(0xFFFFD93D),
                                width: 2,
                              ),
                            ),
                            child: Text(
                              l10n.rewardDifficultyLabel(
                                widget.args.difficulty.label(l10n),
                              ),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF7B5800),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: starsSectionGap),
                        _StageEntrance(
                          animation: starsCardAnimation,
                          beginOffset: const Offset(0, 20),
                          beginScale: 0.98,
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                              horizontal: cardPadding,
                              vertical: cardPadding,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: const Color(0xFFFFD93D),
                                width: 4,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFFFD93D)
                                      .withValues(alpha: 0.16),
                                  blurRadius: 22,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Wrap(
                                  alignment: WrapAlignment.center,
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: List.generate(
                                    widget.args.totalRounds,
                                    (index) => _StageEntrance(
                                      animation: _stageAnimation(
                                        delayMs: 400 + index * 100,
                                        durationMs: 480,
                                        curve: Curves.elasticOut,
                                      ),
                                      beginScale: 0,
                                      beginRotation: -0.55,
                                      child: Text(
                                        '⭐',
                                        style: TextStyle(
                                          fontSize:
                                              index < widget.args.earnedStars
                                                  ? 40
                                                  : 32,
                                          color: index < widget.args.earnedStars
                                              ? null
                                              : Colors.black.withValues(
                                                  alpha: 0.22,
                                                ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _StageEntrance(
                                  animation: starsSummaryAnimation,
                                  child: Text(
                                    l10n.rewardStarsResult(
                                      widget.args.earnedStars,
                                      widget.args.totalRounds,
                                    ),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFFB45309),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 420),
                          transitionBuilder: (child, animation) {
                            final curved = CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeOutBack,
                              reverseCurve: Curves.easeInCubic,
                            );

                            return FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0, 0.08),
                                  end: Offset.zero,
                                ).animate(curved),
                                child: ScaleTransition(
                                  scale: Tween<double>(
                                    begin: 0.7,
                                    end: 1,
                                  ).animate(curved),
                                  child: child,
                                ),
                              ),
                            );
                          },
                          child: !showUnlockBanner
                              ? const SizedBox(
                                  key: ValueKey('unlock_placeholder'),
                                  height: 18,
                                )
                              : Container(
                                  key: ValueKey(_newlyUnlockedGame),
                                  margin: EdgeInsets.only(top: unlockTopMargin),
                                  width: double.infinity,
                                  padding: EdgeInsets.all(unlockPadding),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFFFFF9C4),
                                        Color(0xFFFFD54F),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(28),
                                    border: Border.all(
                                      color: const Color(0xFFF9A825),
                                      width: 3,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFF9A825)
                                            .withValues(alpha: 0.16),
                                        blurRadius: 18,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      const Text(
                                        '🎊',
                                        style: TextStyle(fontSize: 36),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              l10n.rewardUnlockedTitle,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w900,
                                                color: Color(0xFF7B5800),
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              l10n.rewardUnlockedDescription(
                                                _newlyUnlockedGame!.emoji,
                                                _newlyUnlockedGame!.title(l10n),
                                              ),
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFFA16207),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Text(
                                        '🔓',
                                        style: TextStyle(fontSize: 28),
                                      ),
                                    ],
                                  ),
                                ),
                        ),
                        SizedBox(height: bottomGap),
                        Column(
                          children: [
                            _StageEntrance(
                              animation: replayButtonAnimation,
                              beginOffset: const Offset(0, 30),
                              beginScale: 0.97,
                              child: KidPrimaryButton(
                                label: l10n.rewardPlayAgain,
                                icon: '🔄',
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF4FC3F7),
                                    Color(0xFF1976D2),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderColor: const Color(0xFF0D47A1),
                                padding: EdgeInsets.symmetric(
                                  vertical: buttonVerticalPadding,
                                ),
                                onPressed: () {
                                  Navigator.pushReplacementNamed(
                                    context,
                                    gameId.routeName,
                                    arguments: GameRouteArgs(
                                      gameId: gameId,
                                      difficulty: widget.args.difficulty,
                                    ),
                                  );
                                },
                              ),
                            ),
                            SizedBox(height: buttonGap),
                            _StageEntrance(
                              animation: difficultyButtonAnimation,
                              beginOffset: const Offset(0, 30),
                              beginScale: 0.97,
                              child: KidPrimaryButton(
                                label: l10n.rewardTryOtherDifficulty,
                                icon: '🎯',
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFCE93D8),
                                    Color(0xFF7B1FA2),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderColor: const Color(0xFF4A148C),
                                padding: EdgeInsets.symmetric(
                                  vertical: buttonVerticalPadding,
                                ),
                                onPressed: () {
                                  Navigator.pushReplacementNamed(
                                    context,
                                    AppRoutes.difficulty,
                                    arguments: DifficultyRouteArgs(
                                      gameId: gameId,
                                    ),
                                  );
                                },
                              ),
                            ),
                            SizedBox(height: buttonGap),
                            _StageEntrance(
                              animation: gameSelectButtonAnimation,
                              beginOffset: const Offset(0, 30),
                              beginScale: 0.97,
                              child: KidPrimaryButton(
                                label: l10n.rewardChooseOtherGame,
                                icon: '🎮',
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFFFD93D),
                                    Color(0xFFF4A200),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderColor: const Color(0xFFB77B00),
                                padding: EdgeInsets.symmetric(
                                  vertical: buttonVerticalPadding,
                                ),
                                onPressed: () {
                                  Navigator.pushNamedAndRemoveUntil(
                                    context,
                                    AppRoutes.gameSelect,
                                    (route) => route.isFirst,
                                  );
                                },
                              ),
                            ),
                            SizedBox(height: buttonGap),
                            _StageEntrance(
                              animation: homeButtonAnimation,
                              beginOffset: const Offset(0, 30),
                              beginScale: 0.97,
                              child: OutlinedButton(
                                onPressed: () {
                                  AppRouter.pushBackwardAndRemoveUntil(
                                    context,
                                    name: AppRoutes.home,
                                    predicate: (_) => false,
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF1976D2),
                                  side: const BorderSide(
                                    color: Color(0xFF90CAF9),
                                    width: 2.5,
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    vertical: homeButtonVerticalPadding,
                                    horizontal: 20,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(26),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      '🏠',
                                      style: TextStyle(fontSize: 20),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      l10n.rewardBackHome,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: _celebrationController,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: _CelebrationPainter(
                        particles: _celebrationParticles,
                        elapsedMs:
                            _celebrationController.value * _celebrationTotalMs,
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({
    required this.size,
    required this.color,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _StageEntrance extends StatelessWidget {
  const _StageEntrance({
    required this.animation,
    required this.child,
    this.beginOffset = Offset.zero,
    this.beginScale = 1,
    this.beginRotation = 0,
  });

  final Animation<double> animation;
  final Widget child;
  final Offset beginOffset;
  final double beginScale;
  final double beginRotation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) {
        final progress = animation.value;
        final opacity = progress.clamp(0.0, 1.0).toDouble();

        return Opacity(
          opacity: opacity,
          child: Transform.translate(
            offset: Offset(
              lerpValue(beginOffset.dx, 0, progress),
              lerpValue(beginOffset.dy, 0, progress),
            ),
            child: Transform.rotate(
              angle: lerpValue(beginRotation, 0, progress),
              child: Transform.scale(
                scale: lerpValue(beginScale, 1, progress),
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }
}

enum _CelebrationShape {
  star,
  circle,
}

class _CelebrationParticle {
  const _CelebrationParticle({
    required this.origin,
    required this.velocity,
    required this.gravity,
    required this.spawnMs,
    required this.lifeMs,
    required this.color,
    required this.shape,
    required this.mainSize,
    required this.rotation,
    required this.rotationSpeed,
    required this.sway,
    required this.wobbleFrequency,
    required this.drag,
  });

  final Offset origin;
  final Offset velocity;
  final double gravity;
  final double spawnMs;
  final double lifeMs;
  final Color color;
  final _CelebrationShape shape;
  final double mainSize;
  final double rotation;
  final double rotationSpeed;
  final double sway;
  final double wobbleFrequency;
  final double drag;
}

class _CelebrationPainter extends CustomPainter {
  const _CelebrationPainter({
    required this.particles,
    required this.elapsedMs,
  });

  final List<_CelebrationParticle> particles;
  final double elapsedMs;

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final localMs = elapsedMs - particle.spawnMs;
      if (localMs <= 0 || localMs >= particle.lifeMs) {
        continue;
      }

      final timeSeconds = localMs / 1000;
      final lifeProgress = (localMs / particle.lifeMs).clamp(0.0, 1.0);
      final fadeInProgress = Curves.easeOut.transform(
        (localMs / 90).clamp(0.0, 1.0),
      );
      final disappearProgress = ((lifeProgress - 0.52) / 0.48).clamp(0.0, 1.0);
      final fadeOutProgress = 1 - Curves.easeIn.transform(disappearProgress);
      final twinkle = particle.shape == _CelebrationShape.star
          ? 0.9 + sin(timeSeconds * 10 + particle.rotation) * 0.10
          : 1.0;
      final opacity =
          (fadeInProgress * fadeOutProgress * twinkle).clamp(0.0, 1.0);
      if (opacity <= 0) {
        continue;
      }

      final origin = Offset(
        size.width * particle.origin.dx,
        size.height * particle.origin.dy,
      );
      final dragFactor = lerpValue(1, 1 - particle.drag, lifeProgress);
      final x = origin.dx +
          particle.velocity.dx * timeSeconds * dragFactor +
          sin(timeSeconds * particle.wobbleFrequency + particle.rotation) *
              particle.sway;
      final y = origin.dy +
          particle.velocity.dy * timeSeconds * dragFactor +
          0.5 * particle.gravity * timeSeconds * timeSeconds +
          72 * Curves.easeIn.transform(disappearProgress);
      final scale = lerpValue(0.58, 1.08, fadeInProgress) *
          lerpValue(1.02, 0.78, disappearProgress);
      final paint = Paint()
        ..color = particle.color.withValues(alpha: opacity)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(particle.rotation + particle.rotationSpeed * timeSeconds);
      canvas.scale(scale);

      switch (particle.shape) {
        case _CelebrationShape.star:
          canvas.drawPath(_drawStarParticle(particle.mainSize), paint);
        case _CelebrationShape.circle:
          canvas.drawCircle(Offset.zero, particle.mainSize / 2, paint);
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _CelebrationPainter oldDelegate) {
    return oldDelegate.elapsedMs != elapsedMs ||
        oldDelegate.particles != particles;
  }
}

Path _drawStarParticle(double size) {
  double degToRad(double deg) => deg * (pi / 180.0);

  const numberOfPoints = 5;
  final halfWidth = size / 2;
  final halfHeight = size / 2;
  final externalRadius = halfWidth;
  final internalRadius = externalRadius / 2.4;
  final degreesPerStep = degToRad(360 / numberOfPoints);
  final halfDegreesPerStep = degreesPerStep / 2;
  final path = Path()..moveTo(size, halfHeight);

  for (double step = 0; step < degToRad(360); step += degreesPerStep) {
    path.lineTo(
      halfWidth + externalRadius * cos(step),
      halfHeight + externalRadius * sin(step),
    );
    path.lineTo(
      halfWidth + internalRadius * cos(step + halfDegreesPerStep),
      halfHeight + internalRadius * sin(step + halfDegreesPerStep),
    );
  }

  path.close();
  return path;
}
