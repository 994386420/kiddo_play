import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/localization.dart';
import '../../app/route_args.dart';
import '../../app/router.dart';
import '../../core/app_controllers.dart';
import '../../core/game_models.dart';
import '../../core/progress_insights.dart';
import '../../core/widgets/figma_home_icons.dart';
import '../../core/widgets/kid_motion.dart';

final homeViewModelProvider = Provider<HomeViewModel>((ref) {
  final progress = ref.watch(gameProgressProvider);
  final parentData = ref.watch(parentDataProvider);
  final lastPlayedGameId = parentData.activityLog.isEmpty
      ? null
      : parentData.activityLog.first.gameId;
  final quickStartGameId =
      lastPlayedGameId != null && progress.isUnlocked(lastPlayedGameId)
          ? lastPlayedGameId
          : GameId.colorMatch;
  final unlockedAchievements = deriveUnlockedAchievements(
    totalStars: progress.totalStars,
    unlockedGames: progress.unlockedGames,
    gameStats: parentData.gameStats,
    activityLog: parentData.activityLog,
  );

  return HomeViewModel(
    totalStars: progress.totalStars,
    childAvatar: parentData.childAvatar,
    quickStartGameId: quickStartGameId,
    lastPlayedGameId: lastPlayedGameId,
    hasRecentGame:
        lastPlayedGameId != null && quickStartGameId == lastPlayedGameId,
    streak: computeCurrentStreak(parentData.activityLog),
    unlockedBadgeCount: unlockedAchievements.length,
    unlockedAchievements: unlockedAchievements,
  );
});

class HomeViewModel {
  const HomeViewModel({
    required this.totalStars,
    required this.childAvatar,
    required this.quickStartGameId,
    required this.lastPlayedGameId,
    required this.hasRecentGame,
    required this.streak,
    required this.unlockedBadgeCount,
    required this.unlockedAchievements,
  });

  final int totalStars;
  final String childAvatar;
  final GameId quickStartGameId;
  final GameId? lastPlayedGameId;
  final bool hasRecentGame;
  final int streak;
  final int unlockedBadgeCount;
  final Set<KidAchievementId> unlockedAchievements;
}

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with SingleTickerProviderStateMixin, RouteAware {
  static const _replayCurve = Curves.easeOutBack;
  late final AnimationController _loopController = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 8),
  )..repeat();
  int _replayEpoch = 0;
  ModalRoute<dynamic>? _route;

  bool get _isReplaying => _replayEpoch > 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null && route != _route) {
      if (_route != null) {
        appRouteObserver.unsubscribe(this);
      }
      _route = route;
      appRouteObserver.subscribe(this, route);
    }
  }

  @override
  void didPopNext() {
    setState(() {
      _replayEpoch += 1;
    });
  }

  @override
  void dispose() {
    appRouteObserver.unsubscribe(this);
    _loopController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.watch(homeViewModelProvider);
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: _FigmaHomePalette.pageBackground,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWidePreview = constraints.maxWidth >= 560;
            final shellRadius = isWidePreview ? 40.0 : 0.0;
            final shellPadding =
                isWidePreview ? const EdgeInsets.all(18) : EdgeInsets.zero;
            final maxCanvasWidth = isWidePreview ? 430.0 : constraints.maxWidth;
            final mediaPadding = MediaQuery.paddingOf(context);
            final topInset = 0.0;
            final bottomInset = mediaPadding.bottom + 24;

            return Padding(
              padding: shellPadding,
              child: Center(
                child: SizedBox(
                  width: maxCanvasWidth,
                  height: constraints.maxHeight - shellPadding.vertical,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(shellRadius),
                      boxShadow: isWidePreview
                          ? const [
                              BoxShadow(
                                color: Color(0x14000000),
                                blurRadius: 28,
                                offset: Offset(0, 16),
                              ),
                            ]
                          : null,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(shellRadius),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: CustomPaint(
                              painter: _PolkaDotBackgroundPainter(
                                backgroundColor:
                                    _FigmaHomePalette.pageBackground,
                                pink: const Color(0x80FFA0C8),
                                blue: const Color(0x738CBEFF),
                                yellow: const Color(0x73FFDC64),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: topInset),
                            child: SingleChildScrollView(
                              padding: EdgeInsets.only(bottom: bottomInset),
                              child: Column(
                                children: [
                                  _HeroSection(
                                    viewModel: viewModel,
                                    loop: _loopController,
                                    speechText: _homeSpeechText(context),
                                    badgesLabel: _badgesLabel(context),
                                    replayEpoch: _replayEpoch,
                                    isReplaying: _isReplaying,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      20,
                                      24,
                                      20,
                                      0,
                                    ),
                                    child: Column(
                                      children: [
                                        KidDelayedReveal(
                                          key: ValueKey(
                                            'home-start-$_replayEpoch',
                                          ),
                                          delay: _isReplaying
                                              ? const Duration(
                                                  milliseconds: 80,
                                                )
                                              : const Duration(
                                                  milliseconds: 350,
                                                ),
                                          duration: _isReplaying
                                              ? const Duration(
                                                  milliseconds: 420,
                                                )
                                              : const Duration(
                                                  milliseconds: 440,
                                                ),
                                          beginOffset: const Offset(0, 0.24),
                                          beginScale: 1,
                                          curve: _replayCurve,
                                          child: _PressableCard(
                                            radius: 28,
                                            gradient: const LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [
                                                Color(0xFFFF6CAE),
                                                Color(0xFFC455F5),
                                              ],
                                            ),
                                            borderColor:
                                                _FigmaHomePalette.startBorder,
                                            shadowColor:
                                                _FigmaHomePalette.startBorder,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 24,
                                              vertical: 20,
                                            ),
                                            shadowOffset: const Offset(6, 7),
                                            pulseAnimation: _loopController,
                                            onTap: () {
                                              Navigator.pushNamed(
                                                context,
                                                AppRoutes.difficulty,
                                                arguments: DifficultyRouteArgs(
                                                  gameId: viewModel
                                                      .quickStartGameId,
                                                ),
                                              );
                                            },
                                            child: Row(
                                              children: [
                                                _LoopTransform(
                                                  animation: _loopController,
                                                  phase: 0.03,
                                                  translateY: 4,
                                                  rotationAngle: 0.14,
                                                  scaleDelta: 0.06,
                                                  child: const FigmaRocketIcon(
                                                    size: 54,
                                                  ),
                                                ),
                                                const SizedBox(width: 16),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        l10n.homeStartGame,
                                                        style: _titleStyle(
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                      if (viewModel
                                                          .hasRecentGame) ...[
                                                        const SizedBox(
                                                          height: 4,
                                                        ),
                                                        Row(
                                                          children: [
                                                            Text(
                                                              _recentGamePrefix(
                                                                context,
                                                              ),
                                                              style:
                                                                  _subtitleStyle(
                                                                color: Colors
                                                                    .white
                                                                    .withValues(
                                                                  alpha: 0.88,
                                                                ),
                                                              ),
                                                            ),
                                                            if (viewModel
                                                                    .lastPlayedGameId !=
                                                                null) ...[
                                                              FigmaGameIcon(
                                                                gameId: viewModel
                                                                    .lastPlayedGameId!,
                                                                size: 20,
                                                              ),
                                                              const SizedBox(
                                                                width: 6,
                                                              ),
                                                              Expanded(
                                                                child: Text(
                                                                  viewModel
                                                                      .lastPlayedGameId!
                                                                      .title(
                                                                          l10n),
                                                                  maxLines: 1,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  style:
                                                                      _subtitleStyle(
                                                                    color: Colors
                                                                        .white
                                                                        .withValues(
                                                                      alpha:
                                                                          0.88,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ],
                                                        ),
                                                      ],
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        KidDelayedReveal(
                                          key: ValueKey(
                                            'home-choose-$_replayEpoch',
                                          ),
                                          delay: _isReplaying
                                              ? const Duration(
                                                  milliseconds: 160,
                                                )
                                              : const Duration(
                                                  milliseconds: 450,
                                                ),
                                          duration: _isReplaying
                                              ? const Duration(
                                                  milliseconds: 420,
                                                )
                                              : const Duration(
                                                  milliseconds: 440,
                                                ),
                                          beginOffset: const Offset(0, 0.24),
                                          beginScale: 1,
                                          curve: _replayCurve,
                                          child: _PressableCard(
                                            radius: 28,
                                            gradient: const LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [
                                                Color(0xFFFFD54F),
                                                Color(0xFFFF8C42),
                                              ],
                                            ),
                                            borderColor:
                                                _FigmaHomePalette.chooseBorder,
                                            shadowColor:
                                                _FigmaHomePalette.chooseBorder,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 24,
                                              vertical: 20,
                                            ),
                                            shadowOffset: const Offset(6, 7),
                                            onTap: () {
                                              Navigator.pushNamed(
                                                context,
                                                AppRoutes.gameSelect,
                                              );
                                            },
                                            child: Row(
                                              children: [
                                                _LoopTransform(
                                                  animation: _loopController,
                                                  phase: 0.18,
                                                  translateY: 4,
                                                  rotationAngle: 0.1,
                                                  child:
                                                      const FigmaGameGridIcon(
                                                    size: 54,
                                                  ),
                                                ),
                                                const SizedBox(width: 16),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        l10n.homeChooseGame,
                                                        style: _titleStyle(
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Row(
                                                        children: [
                                                          for (final gameId
                                                              in orderedGameIds
                                                                  .take(4))
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                right: 8,
                                                              ),
                                                              child:
                                                                  FigmaGameIcon(
                                                                gameId: gameId,
                                                                size: 22,
                                                              ),
                                                            ),
                                                          Text(
                                                            '…',
                                                            style:
                                                                _subtitleStyle(
                                                              color: Colors
                                                                  .white
                                                                  .withValues(
                                                                alpha: 0.72,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        KidDelayedReveal(
                                          key: ValueKey(
                                            'home-bottom-$_replayEpoch',
                                          ),
                                          delay: _isReplaying
                                              ? const Duration(
                                                  milliseconds: 240,
                                                )
                                              : const Duration(
                                                  milliseconds: 550,
                                                ),
                                          duration: _isReplaying
                                              ? const Duration(
                                                  milliseconds: 420,
                                                )
                                              : const Duration(
                                                  milliseconds: 440,
                                                ),
                                          beginOffset: const Offset(0, 0.24),
                                          beginScale: 1,
                                          curve: _replayCurve,
                                          child: IntrinsicHeight(
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.stretch,
                                              children: [
                                                Expanded(
                                                  child: _PressableCard(
                                                    radius: 24,
                                                    gradient:
                                                        const LinearGradient(
                                                      begin: Alignment.topLeft,
                                                      end:
                                                          Alignment.bottomRight,
                                                      colors: [
                                                        Color(0xFFFFF8E1),
                                                        Color(0xFFFFD54F),
                                                      ],
                                                    ),
                                                    borderColor: const Color(
                                                      0xFFE6A800,
                                                    ),
                                                    shadowColor: const Color(
                                                      0xFFE6A800,
                                                    ),
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                      horizontal: 12,
                                                      vertical: 20,
                                                    ),
                                                    shadowOffset:
                                                        const Offset(5, 5),
                                                    pressedScale: 0.92,
                                                    pressedOffsetY: 4,
                                                    onTap: () {
                                                      _showBadgesDialog(
                                                        context,
                                                        viewModel,
                                                      );
                                                    },
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        _LoopTransform(
                                                          animation:
                                                              _loopController,
                                                          phase: 0.28,
                                                          scaleDelta: 0.08,
                                                          rotationAngle: 0.16,
                                                          child:
                                                              const FigmaTrophyIcon(
                                                            size: 50,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          height: 8,
                                                        ),
                                                        Text(
                                                          _badgesLabel(
                                                            context,
                                                          ),
                                                          textAlign:
                                                              TextAlign.center,
                                                          style:
                                                              _miniCardTitleStyle(
                                                            color: const Color(
                                                              0xFF6D4C00,
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          height: 2,
                                                        ),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            const FigmaSparkleStarIcon(
                                                              size: 16,
                                                            ),
                                                            const SizedBox(
                                                              width: 4,
                                                            ),
                                                            Text(
                                                              '${viewModel.unlockedBadgeCount} / ${kidAchievements.length}',
                                                              style:
                                                                  _miniCardMetaStyle(
                                                                color:
                                                                    const Color(
                                                                  0xFFA07000,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: _PressableCard(
                                                    radius: 24,
                                                    gradient:
                                                        const LinearGradient(
                                                      begin: Alignment.topLeft,
                                                      end:
                                                          Alignment.bottomRight,
                                                      colors: [
                                                        Color(0xFFF3E5F5),
                                                        Color(0xFFCE93D8),
                                                      ],
                                                    ),
                                                    borderColor: const Color(
                                                      0xFF7B1FA2,
                                                    ),
                                                    shadowColor: const Color(
                                                      0xFF7B1FA2,
                                                    ),
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                      horizontal: 12,
                                                      vertical: 20,
                                                    ),
                                                    shadowOffset:
                                                        const Offset(5, 5),
                                                    pressedScale: 0.92,
                                                    pressedOffsetY: 4,
                                                    onTap: () {
                                                      Navigator.pushNamed(
                                                        context,
                                                        AppRoutes.parentPin,
                                                      );
                                                    },
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        _LoopTransform(
                                                          animation:
                                                              _loopController,
                                                          phase: 0.46,
                                                          translateY: 3,
                                                          child:
                                                              const FigmaHomeIcon(
                                                            size: 50,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          height: 8,
                                                        ),
                                                        Text(
                                                          l10n.homeParentEntry,
                                                          textAlign:
                                                              TextAlign.center,
                                                          style:
                                                              _miniCardTitleStyle(
                                                            color: const Color(
                                                              0xFF4A148C,
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          height: 2,
                                                        ),
                                                        Text(
                                                          l10n.homeParentProtected,
                                                          style:
                                                              _miniCardMetaStyle(
                                                            color: const Color(
                                                              0xFF7B1FA2,
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
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showBadgesDialog(BuildContext context, HomeViewModel viewModel) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (sheetContext) => _BadgeWallSheet(viewModel: viewModel),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({
    required this.viewModel,
    required this.loop,
    required this.speechText,
    required this.badgesLabel,
    required this.replayEpoch,
    required this.isReplaying,
  });

  final HomeViewModel viewModel;
  final Animation<double> loop;
  final String speechText;
  final String badgesLabel;
  final int replayEpoch;
  final bool isReplaying;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 348,
      child: Stack(
        children: [
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 2,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Color(0x66D98AF3),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: [0, 0.4, 1],
                  colors: [
                    Color(0xFFFF9AD5),
                    Color(0xFFB56CF5),
                    Color(0xFF5B9EF5),
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: CustomPaint(
              painter: _HeroDotOverlayPainter(),
            ),
          ),
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: [
                    for (final floater in _heroFloaters)
                      Positioned(
                        left: constraints.maxWidth * floater.leftFactor,
                        top: 24 + (constraints.maxHeight * floater.topFactor),
                        child: AnimatedBuilder(
                          animation: loop,
                          builder: (context, child) {
                            final value = (loop.value + floater.phase) % 1;
                            final dy = math.sin(value * math.pi * 2) * 7;
                            final rotate = math.sin(value * math.pi * 2) * 0.18;
                            return Transform.translate(
                              offset: Offset(0, dy),
                              child: Transform.rotate(
                                angle: rotate,
                                child: child,
                              ),
                            );
                          },
                          child: FigmaFloatIcon(
                            type: floater.icon,
                            size: floater.size,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 48, 24, 0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _StatusPill(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const FigmaSparkleStarIcon(size: 26),
                            const SizedBox(width: 6),
                            Text(
                              '${viewModel.totalStars}',
                              style: _statusValueStyle(
                                color: const Color(0xFFB56CF5),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      if (viewModel.streak > 0) ...[
                        _StatusPill(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _LoopTransform(
                                animation: loop,
                                phase: 0.12,
                                scaleDelta: 0.08,
                                child: const FigmaFloatIcon(
                                  type: FigmaFloatIconType.fire,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${viewModel.streak} ${_dayUnit(context)}',
                                style: _streakValueStyle(),
                              ),
                            ],
                          ),
                        ),
                      ],
                      if (viewModel.streak > 0 &&
                          viewModel.unlockedBadgeCount > 0)
                        const SizedBox(width: 8),
                      if (viewModel.unlockedBadgeCount > 0)
                        GestureDetector(
                          onTap: () {
                            final state = context
                                .findAncestorStateOfType<_HomePageState>();
                            state?._showBadgesDialog(context, viewModel);
                          },
                          behavior: HitTestBehavior.opaque,
                          child: _StatusPill(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const FigmaTrophyIcon(size: 22),
                                const SizedBox(width: 4),
                                Text(
                                  '${viewModel.unlockedBadgeCount}/${kidAchievements.length}',
                                  style: _badgeCounterStyle(),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                KidDelayedReveal(
                  key: ValueKey('hero-avatar-$replayEpoch'),
                  delay: isReplaying
                      ? const Duration(milliseconds: 40)
                      : const Duration(milliseconds: 100),
                  duration: const Duration(milliseconds: 520),
                  beginOffset: Offset.zero,
                  beginScale: 0.7,
                  curve: Curves.easeOutBack,
                  child: SizedBox(
                    width: 148,
                    height: 148,
                    child: AnimatedBuilder(
                      animation: loop,
                      builder: (context, child) {
                        final ringRotation = loop.value * math.pi * 2;
                        final bobOffset =
                            math.sin(loop.value * math.pi * 4) * 7;

                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            Transform.rotate(
                              angle: ringRotation,
                              child: Container(
                                width: 148,
                                height: 148,
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
                              width: 136,
                              height: 136,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.18),
                              ),
                            ),
                            Transform.translate(
                              offset: Offset(0, bobOffset),
                              child: Text(
                                viewModel.childAvatar,
                                style: const TextStyle(
                                  fontSize: 96,
                                  height: 1,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                KidDelayedReveal(
                  key: ValueKey('hero-bubble-$replayEpoch'),
                  delay: isReplaying
                      ? const Duration(milliseconds: 180)
                      : const Duration(milliseconds: 500),
                  duration: const Duration(milliseconds: 420),
                  beginOffset: Offset.zero,
                  beginScale: 0.05,
                  curve: Curves.easeOutBack,
                  child: _SpeechBubble(text: speechText),
                ),
              ],
            ),
          ),
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SizedBox(
              height: 42,
              child: CustomPaint(
                painter: _HeroWavePainter(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.7),
          width: 3,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F000000),
            offset: Offset(3, 3),
            blurRadius: 0,
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SpeechBubble extends StatelessWidget {
  const _SpeechBubble({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return UnconstrainedBox(
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            top: -15,
            child: SizedBox(
              width: 20,
              height: 16,
              child: Stack(
                alignment: Alignment.topCenter,
                clipBehavior: Clip.none,
                children: const [
                  _SpeechTriangle(
                    width: 20,
                    height: 16,
                    color: Color(0xFFB56CF5),
                  ),
                  Positioned(
                    top: 7,
                    child: _SpeechTriangle(
                      width: 14,
                      height: 11,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFB56CF5),
                width: 3.5,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0xFFB56CF5),
                  offset: Offset(5, 5),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: _bubbleTextStyle(),
            ),
          ),
        ],
      ),
    );
  }
}

class _SpeechTriangle extends StatelessWidget {
  const _SpeechTriangle({
    required this.width,
    required this.height,
    required this.color,
  });

  final double width;
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: _TrianglePainter(color: color),
    );
  }
}

class _PressableCard extends StatefulWidget {
  const _PressableCard({
    required this.child,
    required this.onTap,
    required this.radius,
    required this.gradient,
    required this.borderColor,
    required this.shadowColor,
    required this.padding,
    this.shadowOffset = const Offset(6, 7),
    this.pressedScale = 0.93,
    this.pressedOffsetY = 6,
    this.pulseAnimation,
  });

  final Widget child;
  final VoidCallback onTap;
  final double radius;
  final Gradient gradient;
  final Color borderColor;
  final Color shadowColor;
  final EdgeInsets padding;
  final Offset shadowOffset;
  final double pressedScale;
  final double pressedOffsetY;
  final Animation<double>? pulseAnimation;

  @override
  State<_PressableCard> createState() => _PressableCardState();
}

class _PressableCardState extends State<_PressableCard> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) {
      return;
    }
    setState(() {
      _pressed = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final innerCard = Container(
      decoration: BoxDecoration(
        gradient: widget.gradient,
        borderRadius: BorderRadius.circular(widget.radius),
        border: Border.all(
          color: widget.borderColor,
          width: 4,
        ),
        boxShadow: [
          BoxShadow(
            color: widget.shadowColor,
            offset: widget.shadowOffset,
            blurRadius: 0,
          ),
        ],
      ),
      padding: widget.padding,
      child: widget.child,
    );

    final content = SizedBox(width: double.infinity, child: innerCard);

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _pressed ? widget.pressedScale : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          transform: Matrix4.translationValues(
            0,
            _pressed ? widget.pressedOffsetY : 0,
            0,
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              if (widget.pulseAnimation case final animation?)
                Positioned.fill(
                  child: IgnorePointer(
                    child: AnimatedBuilder(
                      animation: animation,
                      builder: (context, child) {
                        final t = animation.value;
                        final spread = t * 14;
                        final alpha = (1 - t) * 0.28;
                        return DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(widget.radius - 4),
                            boxShadow: [
                              BoxShadow(
                                color: widget.borderColor.withValues(
                                  alpha: alpha,
                                ),
                                blurRadius: 18 + (t * 12),
                                spreadRadius: spread,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              content,
            ],
          ),
        ),
      ),
    );
  }
}

class _LoopTransform extends StatelessWidget {
  const _LoopTransform({
    required this.animation,
    required this.child,
    this.phase = 0,
    this.translateY = 0,
    this.rotationAngle = 0,
    this.scaleDelta = 0,
  });

  final Animation<double> animation;
  final Widget child;
  final double phase;
  final double translateY;
  final double rotationAngle;
  final double scaleDelta;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final value = (animation.value + phase) % 1;
        final wave = math.sin(value * math.pi * 2);
        return Transform.translate(
          offset: Offset(0, wave * translateY),
          child: Transform.rotate(
            angle: wave * rotationAngle,
            child: Transform.scale(
              scale: 1 + (wave * scaleDelta),
              child: child,
            ),
          ),
        );
      },
    );
  }
}

class _BadgeTile extends StatelessWidget {
  const _BadgeTile({
    required this.achievement,
    required this.unlocked,
  });

  final KidAchievement achievement;
  final bool unlocked;

  @override
  Widget build(BuildContext context) {
    final accentColor = Color(achievement.color);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color:
            unlocked ? Color(achievement.background) : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: unlocked
              ? accentColor.withValues(alpha: 0.33)
              : const Color(0xFFE0E0E0),
          width: 2.5,
        ),
      ),
      child: Stack(
        children: [
          if (unlocked)
            Positioned(
              top: -16,
              left: 0,
              right: 0,
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      accentColor.withValues(alpha: 0.53),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  ColorFiltered(
                    colorFilter: unlocked
                        ? const ColorFilter.mode(
                            Colors.transparent,
                            BlendMode.srcOver,
                          )
                        : const ColorFilter.matrix(_greyMatrix),
                    child: Opacity(
                      opacity: unlocked ? 1 : 0.35,
                      child: _achievementIcon(achievement.id, 44),
                    ),
                  ),
                  if (!unlocked)
                    const Positioned(
                      right: -6,
                      bottom: -4,
                      child: FigmaLockIcon(size: 18),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                achievement.name,
                textAlign: TextAlign.center,
                style: _miniCardTitleStyle(
                  color: unlocked ? accentColor : const Color(0xFF9E9E9E),
                  size: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                achievement.description,
                textAlign: TextAlign.center,
                style: _miniCardMetaStyle(
                  color: unlocked
                      ? const Color(0xFF78909C)
                      : const Color(0xFFBDBDBD),
                  size: 11,
                ),
              ),
              if (unlocked) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.13),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: accentColor.withValues(alpha: 0.33),
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    '已获得 ✓',
                    style: _miniCardMetaStyle(
                      color: accentColor,
                      size: 10,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _BadgeWallSheet extends StatelessWidget {
  const _BadgeWallSheet({required this.viewModel});

  final HomeViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.sizeOf(context);

    return SafeArea(
      top: false,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 430,
            maxHeight: media.height * 0.88,
          ),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFFFF9E6),
                  Colors.white,
                  Colors.white,
                ],
                stops: [0, 0.3, 1],
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              border: Border.all(
                color: const Color(0xFFFFD93D),
                width: 3,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0E0E0),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _badgesLabel(context),
                              style: _dialogTitleStyle(
                                color: const Color(0xFFB45309),
                                size: 22,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '已解锁 ${viewModel.unlockedBadgeCount} / ${kidAchievements.length} 个',
                              style: _miniCardMetaStyle(
                                color: const Color(0xFF9E9E9E),
                                size: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _BadgeCloseButton(
                        onTap: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    height: 10,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: const Color(0xFFFFD93D),
                        width: 2,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(
                          begin: 0,
                          end: kidAchievements.isEmpty
                              ? 0
                              : viewModel.unlockedBadgeCount /
                                  kidAchievements.length,
                        ),
                        duration: const Duration(milliseconds: 900),
                        curve: Curves.easeOut,
                        builder: (context, value, child) {
                          return Align(
                            alignment: Alignment.centerLeft,
                            child: FractionallySizedBox(
                              widthFactor: value,
                              child: child,
                            ),
                          );
                        },
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFFFFD93D),
                                Color(0xFFF4A200),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Flexible(
                    child: SingleChildScrollView(
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: kidAchievements.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.92,
                        ),
                        itemBuilder: (context, index) {
                          final achievement = kidAchievements[index];
                          return TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.88, end: 1),
                            duration:
                                Duration(milliseconds: 260 + (index * 50)),
                            curve: Curves.easeOutBack,
                            builder: (context, value, child) {
                              return Opacity(
                                opacity: ((value - 0.88) / 0.12).clamp(0, 1),
                                child: Transform.scale(
                                  scale: value,
                                  child: child,
                                ),
                              );
                            },
                            child: _BadgeTile(
                              achievement: achievement,
                              unlocked: viewModel.unlockedAchievements
                                  .contains(achievement.id),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BadgeCloseButton extends StatefulWidget {
  const _BadgeCloseButton({required this.onTap});

  final VoidCallback onTap;

  @override
  State<_BadgeCloseButton> createState() => _BadgeCloseButtonState();
}

class _BadgeCloseButtonState extends State<_BadgeCloseButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.9 : 1,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFFE0E0E0),
              width: 2,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            'X',
            style: _dialogTitleStyle(
              color: const Color(0xFF546E7A),
              size: 18,
            ),
          ),
        ),
      ),
    );
  }
}

class _PolkaDotBackgroundPainter extends CustomPainter {
  _PolkaDotBackgroundPainter({
    required this.backgroundColor,
    required this.pink,
    required this.blue,
    required this.yellow,
  });

  final Color backgroundColor;
  final Color pink;
  final Color blue;
  final Color yellow;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..color = backgroundColor);

    final pinkPaint = Paint()..color = pink;
    final bluePaint = Paint()..color = blue;
    final yellowPaint = Paint()..color = yellow;
    const spacing = 36.0;

    for (double y = 0; y <= size.height + spacing; y += spacing) {
      for (double x = 0; x <= size.width + spacing; x += spacing) {
        canvas.drawCircle(Offset(x, y), 2.5, pinkPaint);
        canvas.drawCircle(Offset(x + 18, y + 18), 2, bluePaint);
        canvas.drawCircle(Offset(x + 9, y + 27), 2, yellowPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _HeroDotOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.18);
    const spacing = 30.0;
    for (double y = 0; y <= size.height + spacing; y += spacing) {
      for (double x = 0; x <= size.width + spacing; x += spacing) {
        canvas.drawCircle(Offset(x, y), 2.5, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TrianglePainter extends CustomPainter {
  const _TrianglePainter({required this.color});

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

class _HeroWavePainter extends CustomPainter {
  const _HeroWavePainter();

  @override
  void paint(Canvas canvas, Size size) {
    double sx(double value) => (value / 430) * size.width;
    double sy(double value) => (value / 42) * size.height;

    final path = Path()
      ..moveTo(sx(0), sy(14))
      ..cubicTo(sx(54), sy(34), sx(108), sy(6), sx(162), sy(22))
      ..cubicTo(sx(216), sy(38), sx(270), sy(8), sx(324), sy(24))
      ..cubicTo(sx(364), sy(34), sx(400), sy(14), sx(430), sy(18))
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(
      path,
      Paint()..color = _FigmaHomePalette.pageBackground,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

Widget _achievementIcon(KidAchievementId id, double size) {
  return switch (id) {
    KidAchievementId.firstGame => FigmaGameGridIcon(size: size),
    KidAchievementId.firstPerfect => FigmaSparkleStarIcon(size: size),
    KidAchievementId.stars50 => FigmaFloatIcon(
        type: FigmaFloatIconType.star,
        size: size,
      ),
    KidAchievementId.stars100 => FigmaFloatIcon(
        type: FigmaFloatIconType.sparkle,
        size: size,
      ),
    KidAchievementId.allGamesPlayed => FigmaGameIcon(
        gameId: GameId.colorMatch,
        size: size,
      ),
    KidAchievementId.allUnlocked => FigmaTrophyIcon(size: size),
    KidAchievementId.hardPerfect => FigmaFloatIcon(
        type: FigmaFloatIconType.diamond,
        size: size,
      ),
    KidAchievementId.streak7 => FigmaFloatIcon(
        type: FigmaFloatIconType.fire,
        size: size,
      ),
  };
}

TextStyle _titleStyle({required Color color}) {
  return GoogleFonts.baloo2(
    fontSize: 24,
    fontWeight: FontWeight.w800,
    height: 1,
    color: color,
    shadows: _buttonTitleShadows,
  );
}

TextStyle _subtitleStyle({required Color color}) {
  return GoogleFonts.baloo2(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    height: 1.05,
    color: color,
  );
}

TextStyle _miniCardTitleStyle({
  required Color color,
  double size = 15,
}) {
  return GoogleFonts.baloo2(
    fontSize: size,
    fontWeight: FontWeight.w800,
    height: 1,
    color: color,
  );
}

TextStyle _miniCardMetaStyle({
  required Color color,
  double size = 12,
}) {
  return GoogleFonts.baloo2(
    fontSize: size,
    fontWeight: FontWeight.w700,
    height: 1.1,
    color: color,
  );
}

TextStyle _bubbleTextStyle() {
  return GoogleFonts.baloo2(
    fontSize: 17,
    fontWeight: FontWeight.w800,
    height: 1,
    color: const Color(0xFF7B3FC4),
  );
}

TextStyle _statusValueStyle({required Color color}) {
  return GoogleFonts.baloo2(
    fontSize: 20,
    fontWeight: FontWeight.w800,
    height: 1,
    color: color,
  );
}

TextStyle _streakValueStyle() {
  return GoogleFonts.baloo2(
    fontSize: 14,
    fontWeight: FontWeight.w800,
    height: 1,
    color: const Color(0xFFE65100),
  );
}

TextStyle _badgeCounterStyle() {
  return GoogleFonts.baloo2(
    fontSize: 13,
    fontWeight: FontWeight.w800,
    height: 1,
    color: const Color(0xFF6D4C00),
  );
}

TextStyle _dialogTitleStyle({
  required Color color,
  double size = 20,
}) {
  return GoogleFonts.baloo2(
    fontSize: size,
    fontWeight: FontWeight.w800,
    height: 1,
    color: color,
  );
}

String _homeSpeechText(BuildContext context) {
  return switch (Localizations.localeOf(context).languageCode) {
    'zh' => '你好！一起来玩游戏吧',
    'ko' => '안녕! 같이 게임하자',
    _ => 'Hi! Let\'s play together',
  };
}

String _badgesLabel(BuildContext context) {
  return switch (Localizations.localeOf(context).languageCode) {
    'zh' => '我的徽章',
    'ko' => '내 배지',
    _ => 'My Badges',
  };
}

String _recentGamePrefix(BuildContext context) {
  return switch (Localizations.localeOf(context).languageCode) {
    'zh' => '上次：',
    'ko' => '최근:',
    _ => 'Last:',
  };
}

String _dayUnit(BuildContext context) {
  return switch (Localizations.localeOf(context).languageCode) {
    'zh' => '天',
    'ko' => '일',
    _ => 'days',
  };
}

const _buttonTitleShadows = <Shadow>[
  Shadow(
    offset: Offset(-1, -1),
    color: Color(0x33000000),
  ),
  Shadow(
    offset: Offset(1, 1),
    color: Color(0x33000000),
  ),
];

const _greyMatrix = <double>[
  0.2126,
  0.7152,
  0.0722,
  0,
  0,
  0.2126,
  0.7152,
  0.0722,
  0,
  0,
  0.2126,
  0.7152,
  0.0722,
  0,
  0,
  0,
  0,
  0,
  1,
  0,
];

class _HeroFloaterSpec {
  const _HeroFloaterSpec({
    required this.icon,
    required this.leftFactor,
    required this.topFactor,
    required this.size,
    required this.phase,
  });

  final FigmaFloatIconType icon;
  final double leftFactor;
  final double topFactor;
  final double size;
  final double phase;
}

const _heroFloaters = <_HeroFloaterSpec>[
  _HeroFloaterSpec(
    icon: FigmaFloatIconType.heart,
    leftFactor: 0.06,
    topFactor: 0.18,
    size: 22,
    phase: 0,
  ),
  _HeroFloaterSpec(
    icon: FigmaFloatIconType.star,
    leftFactor: 0.88,
    topFactor: 0.15,
    size: 20,
    phase: 0.14,
  ),
  _HeroFloaterSpec(
    icon: FigmaFloatIconType.sparkle,
    leftFactor: 0.10,
    topFactor: 0.60,
    size: 18,
    phase: 0.24,
  ),
  _HeroFloaterSpec(
    icon: FigmaFloatIconType.flower,
    leftFactor: 0.82,
    topFactor: 0.55,
    size: 20,
    phase: 0.08,
  ),
  _HeroFloaterSpec(
    icon: FigmaFloatIconType.diamond,
    leftFactor: 0.50,
    topFactor: 0.10,
    size: 16,
    phase: 0.31,
  ),
  _HeroFloaterSpec(
    icon: FigmaFloatIconType.star,
    leftFactor: 0.30,
    topFactor: 0.75,
    size: 18,
    phase: 0.17,
  ),
  _HeroFloaterSpec(
    icon: FigmaFloatIconType.heart,
    leftFactor: 0.70,
    topFactor: 0.72,
    size: 16,
    phase: 0.37,
  ),
];

abstract final class _FigmaHomePalette {
  static const pageBackground = Color(0xFFFFF9F5);
  static const startBorder = Color(0xFF8B11CC);
  static const chooseBorder = Color(0xFFC85000);
}
