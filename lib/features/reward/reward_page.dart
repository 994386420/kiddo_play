import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/localization.dart';
import '../../app/route_args.dart';
import '../../app/router.dart';
import '../../core/app_controllers.dart';
import '../../core/game_models.dart';
import '../../core/progress_insights.dart';
import '../../core/sound/game_sound_controller.dart';
import '../../core/widgets/figma_game_icons.dart';
import '../../core/widgets/figma_home_icons.dart';
import '../../core/widgets/figma_playground_background.dart';
import '../../core/widgets/kid_badges.dart';
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
  final List<Timer> _toastTimers = [];
  List<_RewardToastItem> _toastQueue = const [];
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
      final previousBadges = deriveUnlockedAchievements(
        totalStars: progressController.totalStars,
        unlockedGames: progressController.unlockedGames,
        gameStats: parentDataController.gameStats,
        activityLog: parentDataController.activityLog,
      );

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

      final currentBadges = deriveUnlockedAchievements(
        totalStars: progressController.totalStars,
        unlockedGames: progressController.unlockedGames,
        gameStats: parentDataController.gameStats,
        activityLog: parentDataController.activityLog,
      );
      final newlyUnlockedBadges =
          currentBadges.difference(previousBadges).toList();

      if (newlyUnlockedGame != null) {
        unawaited(ref.read(gameSoundControllerProvider).playUnlock());
        _unlockTimer = Timer(const Duration(milliseconds: 1400), () {
          if (mounted) {
            _enqueueToast(
              _RewardToastItem.unlock(gameId: newlyUnlockedGame),
            );
          }
        });
      }

      for (var index = 0; index < newlyUnlockedBadges.length; index++) {
        final badgeId = newlyUnlockedBadges[index];
        final timer = Timer(
          Duration(milliseconds: 2000 + index * 800),
          () {
            if (!mounted) {
              return;
            }
            _enqueueToast(_RewardToastItem.badge(badgeId: badgeId));
          },
        );
        _toastTimers.add(timer);
      }
    });
  }

  @override
  void dispose() {
    _unlockTimer?.cancel();
    for (final timer in _toastTimers) {
      timer.cancel();
    }
    _celebrationController.dispose();
    _timelineController.dispose();
    super.dispose();
  }

  void _enqueueToast(_RewardToastItem item) {
    setState(() {
      _toastQueue = [..._toastQueue, item];
    });

    final timer = Timer(const Duration(milliseconds: 3400), () {
      if (!mounted) {
        return;
      }
      setState(() {
        _toastQueue =
            _toastQueue.where((toast) => toast.id != item.id).toList();
      });
    });
    _toastTimers.add(timer);
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
    final diffStars = widget.args.difficulty.index + 1;
    final topInset = MediaQuery.paddingOf(context).top;
    final heroAnimation = _stageAnimation(
      delayMs: 100,
      durationMs: 520,
      curve: Curves.elasticOut,
    );
    final headingAnimation = _stageAnimation(
      delayMs: 300,
      durationMs: 430,
      curve: Curves.elasticOut,
    );
    final pillAnimation = _stageAnimation(
      delayMs: 500,
      durationMs: 260,
    );
    final starsCardAnimation = _stageAnimation(
      delayMs: 600,
      durationMs: 340,
    );
    final replayButtonAnimation = _stageAnimation(
      delayMs: 800,
      durationMs: 320,
      curve: Curves.easeOutBack,
    );
    final secondaryButtonsAnimation = _stageAnimation(
      delayMs: 880,
      durationMs: 320,
      curve: Curves.easeOutBack,
    );
    final homeButtonAnimation = _stageAnimation(
      delayMs: 980,
      durationMs: 320,
      curve: Curves.easeOutBack,
    );

    return Scaffold(
      body: Stack(
        children: [
          FigmaPlaygroundBackground(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: 28 + MediaQuery.paddingOf(context).bottom,
              ),
              child: Column(
                children: [
                  _RewardHeroSection(
                    topInset: topInset,
                    medalAnimation: heroAnimation,
                    headingAnimation: headingAnimation,
                    pillAnimation: pillAnimation,
                    heading: _pickEncouragement(context),
                    gameId: gameId,
                    gameName: gameId.title(l10n),
                    diffStars: diffStars,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 390),
                        child: Column(
                          children: [
                            _StageEntrance(
                              animation: starsCardAnimation,
                              beginOffset: const Offset(0, 20),
                              beginScale: 0.96,
                              child: _RewardScoreCard(
                                earnedStars: widget.args.earnedStars,
                                totalRounds: widget.args.totalRounds,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _StageEntrance(
                              animation: replayButtonAnimation,
                              beginOffset: const Offset(0, 26),
                              beginScale: 0.96,
                              child: _RewardReplayButton(
                                gameId: gameId,
                                label: l10n.rewardPlayAgain,
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
                            const SizedBox(height: 12),
                            _StageEntrance(
                              animation: secondaryButtonsAnimation,
                              beginOffset: const Offset(0, 26),
                              beginScale: 0.96,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: _RewardSmallActionButton(
                                      label: l10n.rewardTryOtherDifficulty,
                                      icon: const FigmaSparkleStarIcon(
                                        size: 22,
                                      ),
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFFA5D6A7),
                                          Color(0xFF43A047),
                                        ],
                                      ),
                                      borderColor: const Color(0xFF1B5E20),
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
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _RewardSmallActionButton(
                                      label: l10n.rewardChooseOtherGame,
                                      icon: const FigmaGameGridIcon(
                                        size: 22,
                                      ),
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFFFFD54F),
                                          Color(0xFFFF8C42),
                                        ],
                                      ),
                                      borderColor: const Color(0xFFC85000),
                                      onPressed: () {
                                        AppRouter.showGameSelect(context);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            _StageEntrance(
                              animation: homeButtonAnimation,
                              beginOffset: const Offset(0, 26),
                              beginScale: 0.96,
                              child: _RewardHomeButton(
                                label: l10n.rewardBackHome,
                                onPressed: () {
                                  AppRouter.showHome(context);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 18,
            right: 16,
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (final toast in _toastQueue) ...[
                    _RewardToastCard(item: toast),
                    const SizedBox(height: 8),
                  ],
                ],
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
    );
  }
}

class _RewardToastItem {
  const _RewardToastItem._({
    required this.id,
    this.gameId,
    this.badgeId,
  });

  factory _RewardToastItem.unlock({required GameId gameId}) {
    return _RewardToastItem._(
      id: 'unlock-${gameId.name}-${DateTime.now().microsecondsSinceEpoch}',
      gameId: gameId,
    );
  }

  factory _RewardToastItem.badge({required KidAchievementId badgeId}) {
    return _RewardToastItem._(
      id: 'badge-${badgeId.name}-${DateTime.now().microsecondsSinceEpoch}',
      badgeId: badgeId,
    );
  }

  final String id;
  final GameId? gameId;
  final KidAchievementId? badgeId;
}

class _RewardHeroSection extends StatelessWidget {
  const _RewardHeroSection({
    required this.topInset,
    required this.medalAnimation,
    required this.headingAnimation,
    required this.pillAnimation,
    required this.heading,
    required this.gameId,
    required this.gameName,
    required this.diffStars,
  });

  final double topInset;
  final Animation<double> medalAnimation;
  final Animation<double> headingAnimation;
  final Animation<double> pillAnimation;
  final String heading;
  final GameId gameId;
  final String gameName;
  final int diffStars;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(20, topInset + 24, 20, 54),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFFF9AD5),
                  Color(0xFFB56CF5),
                  Color(0xFF5B9EF5),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                _StageEntrance(
                  animation: medalAnimation,
                  beginScale: 0,
                  beginOffset: const Offset(0, -32),
                  child: const _RewardMedal(size: 100),
                ),
                const SizedBox(height: 16),
                _StageEntrance(
                  animation: headingAnimation,
                  beginScale: 0.72,
                  child: Text(
                    heading,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Color(0x33000000),
                          offset: Offset(2, 2),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _StageEntrance(
                  animation: pillAnimation,
                  beginScale: 0.88,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.72),
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.10),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FigmaGameIcon(gameId: gameId, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          gameName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF7B3FC4),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(
                            3,
                            (index) => Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 1),
                              child: Opacity(
                                opacity: index < diffStars ? 1 : 0.3,
                                child: const FigmaSparkleStarIcon(size: 14),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Positioned.fill(
            child: IgnorePointer(
              child: _RewardHeroDecorations(),
            ),
          ),
          const Positioned(
            left: -10,
            right: -10,
            bottom: -1,
            child: _RewardWaveDivider(height: 42),
          ),
        ],
      ),
    );
  }
}

class _RewardHeroDecorations extends StatelessWidget {
  const _RewardHeroDecorations();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        Widget floater({
          required double left,
          required double top,
          required double size,
          required double delay,
          required FigmaFloatIconType type,
        }) {
          return Positioned(
            left: constraints.maxWidth * left,
            top: constraints.maxHeight * top,
            child: KidLoopAnimation(
              delay: Duration(milliseconds: (delay * 1000).round()),
              duration: Duration(milliseconds: (3000 + delay * 500).round()),
              builder: (context, value, child) {
                final y = sin((value + delay) * pi * 2) * 10;
                final angle = sin((value + delay) * pi * 2) * 0.14;
                return Transform.translate(
                  offset: Offset(0, y),
                  child: Transform.rotate(angle: angle, child: child),
                );
              },
              child: FigmaFloatIcon(type: type, size: size),
            ),
          );
        }

        return Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _RewardHeroDotPainter(),
              ),
            ),
            Positioned(
              top: -62,
              right: -50,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            floater(
              left: 0.06,
              top: 0.20,
              size: 22,
              delay: 0.0,
              type: FigmaFloatIconType.star,
            ),
            floater(
              left: 0.86,
              top: 0.16,
              size: 20,
              delay: 0.4,
              type: FigmaFloatIconType.heart,
            ),
            floater(
              left: 0.12,
              top: 0.62,
              size: 18,
              delay: 0.7,
              type: FigmaFloatIconType.sparkle,
            ),
            floater(
              left: 0.80,
              top: 0.58,
              size: 20,
              delay: 0.2,
              type: FigmaFloatIconType.flower,
            ),
            floater(
              left: 0.46,
              top: 0.08,
              size: 16,
              delay: 0.9,
              type: FigmaFloatIconType.diamond,
            ),
          ],
        );
      },
    );
  }
}

class _RewardHeroDotPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.18);
    const spacing = 30.0;
    for (double y = 0; y <= size.height + spacing; y += spacing) {
      for (double x = 0; x <= size.width + spacing; x += spacing) {
        canvas.drawCircle(Offset(x, y), 2.4, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RewardWaveDivider extends StatelessWidget {
  const _RewardWaveDivider({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: CustomPaint(
        painter: _RewardWavePainter(),
        size: Size.infinite,
      ),
    );
  }
}

class _RewardWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFFFFF9F5);
    final path = Path()
      ..moveTo(0, size.height * 0.35)
      ..cubicTo(
        size.width * 0.12,
        size.height * 0.88,
        size.width * 0.25,
        size.height * 0.10,
        size.width * 0.38,
        size.height * 0.48,
      )
      ..cubicTo(
        size.width * 0.50,
        size.height * 0.86,
        size.width * 0.64,
        size.height * 0.18,
        size.width * 0.78,
        size.height * 0.56,
      )
      ..cubicTo(
        size.width * 0.88,
        size.height * 0.78,
        size.width * 0.95,
        size.height * 0.40,
        size.width,
        size.height * 0.44,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RewardScoreCard extends StatelessWidget {
  const _RewardScoreCard({
    required this.earnedStars,
    required this.totalRounds,
  });

  final int earnedStars;
  final int totalRounds;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFF0C8E0), width: 4),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFFF0C8E0),
            offset: Offset(6, 6),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: List.generate(
              totalRounds,
              (index) => Opacity(
                opacity: index < earnedStars ? 1 : 0.2,
                child: FigmaSparkleStarIcon(
                  size: index < earnedStars ? 46 : 36,
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFFFD54F),
                  Color(0xFFFF9A3D),
                ],
              ),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: const Color(0xFFC85000), width: 3),
              boxShadow: const [
                BoxShadow(
                  color: Color(0xFFC85000),
                  offset: Offset(3, 3),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const FigmaSparkleStarIcon(size: 18),
                const SizedBox(width: 8),
                Text(
                  '$earnedStars / $totalRounds',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RewardReplayButton extends StatelessWidget {
  const _RewardReplayButton({
    required this.gameId,
    required this.label,
    required this.onPressed,
  });

  final GameId gameId;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(28);

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFF6CAE),
            Color(0xFFC455F5),
          ],
        ),
        borderRadius: radius,
        border: Border.all(color: const Color(0xFF8B11CC), width: 4),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFF8B11CC),
            offset: Offset(6, 7),
            blurRadius: 0,
          ),
        ],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: radius,
          onTap: onPressed,
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: BoxDecoration(borderRadius: radius),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const FigmaReplayIcon(size: 28, color: Colors.white),
                const SizedBox(width: 12),
                FigmaGameIcon(gameId: gameId, size: 28),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
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

class _RewardSmallActionButton extends StatelessWidget {
  const _RewardSmallActionButton({
    required this.label,
    required this.icon,
    required this.gradient,
    required this.borderColor,
    required this.onPressed,
  });

  final String label;
  final Widget icon;
  final Gradient gradient;
  final Color borderColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(24);

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: radius,
        border: Border.all(color: borderColor, width: 3.5),
        boxShadow: [
          BoxShadow(
            color: borderColor,
            offset: const Offset(5, 5),
            blurRadius: 0,
          ),
        ],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: radius,
          onTap: onPressed,
          child: Ink(
            height: 98,
            decoration: BoxDecoration(borderRadius: radius),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                icon,
                const SizedBox(height: 6),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
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

class _RewardHomeButton extends StatelessWidget {
  const _RewardHomeButton({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(24);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: radius,
        border: Border.all(color: const Color(0xFFF0C8E0), width: 3.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFFF0C8E0),
            offset: Offset(5, 5),
            blurRadius: 0,
          ),
        ],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: radius,
          onTap: onPressed,
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: BoxDecoration(borderRadius: radius),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const FigmaHomeIcon(size: 28),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF7B3FC4),
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

class _RewardToastCard extends StatelessWidget {
  const _RewardToastCard({required this.item});

  final _RewardToastItem item;

  @override
  Widget build(BuildContext context) {
    final unlockGameId = item.gameId;
    final badgeId = item.badgeId;
    late final Gradient gradient;
    late final Color borderColor;
    late final String title;
    late final String subtitle;
    late final Widget icon;

    if (unlockGameId != null) {
      gradient = const LinearGradient(
        colors: [
          Color(0xFFFFF9C4),
          Color(0xFFFFD54F),
        ],
      );
      borderColor = const Color(0xFFE6A800);
      title = '新游戏解锁啦！';
      subtitle = unlockGameId.title(context.l10n);
      icon = const FigmaSparkleStarIcon(size: 26);
    } else {
      final achievement = achievementById(badgeId!);
      gradient = LinearGradient(
        colors: [
          Color(achievement.background),
          Color(achievement.background).withValues(alpha: 0.9),
        ],
      );
      borderColor = Color(achievement.color);
      title = '新徽章解锁！';
      subtitle = achievement.name;
      icon = kidAchievementIcon(badgeId, 24);
    }

    return TweenAnimationBuilder<double>(
      key: ValueKey(item.id),
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 360),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Opacity(
          opacity: value.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(lerpValue(64, 0, value), 0),
            child: Transform.scale(
              scale: lerpValue(0.82, 1, value),
              child: child,
            ),
          ),
        );
      },
      child: Container(
        constraints: const BoxConstraints(maxWidth: 230),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor, width: 3.5),
          boxShadow: [
            BoxShadow(
              color: borderColor,
              offset: const Offset(4, 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            icon,
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: borderColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF6E6E6E),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RewardMedal extends StatelessWidget {
  const _RewardMedal({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size + 44,
      height: size + 44,
      child: Stack(
        alignment: Alignment.center,
        children: [
          KidLoopAnimation(
            reverse: false,
            duration: const Duration(milliseconds: 6000),
            builder: (context, value, child) {
              return Transform.rotate(
                angle: value * pi * 2,
                child: child,
              );
            },
            child: Container(
              width: size + 36,
              height: size + 36,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: SweepGradient(
                  colors: [
                    Color(0xFFFF9AD5),
                    Color(0xFFFFE234),
                    Color(0xFF4BC96A),
                    Color(0xFF42D4FF),
                    Color(0xFFB56CF5),
                    Color(0xFFFF9AD5),
                  ],
                ),
              ),
            ),
          ),
          Container(
            width: size + 12,
            height: size + 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.22),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.45),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFC857).withValues(alpha: 0.20),
                  blurRadius: 28,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
          ),
          KidLoopAnimation(
            duration: const Duration(milliseconds: 2500),
            builder: (context, value, child) {
              final scale = lerpValue(1, 1.08, wave(value, min: 0, max: 1));
              final angle = sin(value * pi * 4) * 0.08;
              return Transform.rotate(
                angle: angle,
                child: Transform.scale(scale: scale, child: child),
              );
            },
            child: FigmaTrophyIcon(size: size * 0.72),
          ),
        ],
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
  });

  final Animation<double> animation;
  final Widget child;
  final Offset beginOffset;
  final double beginScale;

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
            child: Transform.scale(
              scale: lerpValue(beginScale, 1, progress),
              child: child,
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
