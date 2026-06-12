import 'dart:async';
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
import '../../core/widgets/figma_home_icons.dart';
import '../../core/widgets/kid_motion.dart';
import '../../l10n/app_localizations.dart';

final difficultySelectViewModelProvider = ChangeNotifierProvider.autoDispose
    .family<DifficultySelectViewModel, GameId>(
  (ref, gameId) {
    return DifficultySelectViewModel(gameId);
  },
);

class DifficultySelectViewModel extends ChangeNotifier {
  DifficultySelectViewModel(this.gameId);

  final GameId gameId;
  Timer? _timer;
  GameDifficulty? lockedHintDifficulty;

  GameRouteArgs buildArgs(GameDifficulty difficulty) {
    return GameRouteArgs(gameId: gameId, difficulty: difficulty);
  }

  void showLockedHint(GameDifficulty difficulty) {
    lockedHintDifficulty = difficulty;
    notifyListeners();
    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 700), () {
      lockedHintDifficulty = null;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

class DifficultySelectPage extends ConsumerStatefulWidget {
  const DifficultySelectPage({required this.args, super.key});

  final DifficultyRouteArgs args;

  @override
  ConsumerState<DifficultySelectPage> createState() =>
      _DifficultySelectPageState();
}

class _DifficultySelectPageState extends ConsumerState<DifficultySelectPage>
    with RouteAware {
  static const _contentHorizontalInset = 32.0;
  static const _replayCurve = Curves.easeOutBack;
  static const _cardBeginRotation = -3 * math.pi / 180;
  int _replayEpoch = 0;
  ModalRoute<dynamic>? _route;

  bool get _isReplaying => _replayEpoch > 0;

  void _handleBack() {
    AppRouter.popCurrentOrShowHome(context);
  }

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
  void dispose() {
    appRouteObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    setState(() {
      _replayEpoch += 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final gameId = widget.args.gameId;
    final viewModel = ref.watch(difficultySelectViewModelProvider(gameId));
    final parentData = ref.watch(parentDataProvider);
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return PopScope<void>(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          _handleBack();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFFF9F5),
        body: AnnotatedRegion<SystemUiOverlayStyle>(
          value: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.dark,
          ),
          child: Stack(
            children: [
              const Positioned.fill(
                child: CustomPaint(
                  painter: _PolkaDotPainter(),
                ),
              ),
              Positioned.fill(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                    top: _DifficultyHeader.heightFor(context) + 24,
                    bottom: bottomInset + 24,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      _contentHorizontalInset,
                      0,
                      _contentHorizontalInset,
                      0,
                    ),
                    child: Column(
                      children: [
                        for (var index = 0;
                            index < GameDifficulty.values.length;
                            index++) ...[
                          Builder(
                            builder: (context) {
                              final difficulty = GameDifficulty.values[index];
                              final unlocked = parentData.isDifficultyUnlocked(
                                gameId: gameId,
                                difficulty: difficulty,
                              );

                              return KidDelayedReveal(
                                key: ValueKey(
                                  'difficulty-$_replayEpoch-${difficulty.name}',
                                ),
                                delay: _isReplaying
                                    ? Duration(milliseconds: index * 100)
                                    : Duration(milliseconds: index * 100),
                                duration: _isReplaying
                                    ? const Duration(milliseconds: 420)
                                    : const Duration(milliseconds: 460),
                                beginOffset: _isReplaying
                                    ? const Offset(-0.11, 0)
                                    : const Offset(-0.11, 0),
                                beginScale: 1,
                                beginRotation: _cardBeginRotation,
                                curve: _replayCurve,
                                child: _ShakingCard(
                                  active: viewModel.lockedHintDifficulty ==
                                      difficulty,
                                  child: _DifficultyStickerCard(
                                    difficulty: difficulty,
                                    unlocked: unlocked,
                                    onTap: () {
                                      if (unlocked) {
                                        Navigator.pushNamed(
                                          context,
                                          gameId.routeName,
                                          arguments: viewModel.buildArgs(
                                            difficulty,
                                          ),
                                        );
                                      } else {
                                        ref
                                            .read(
                                              difficultySelectViewModelProvider(
                                                gameId,
                                              ),
                                            )
                                            .showLockedHint(difficulty);
                                      }
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                          if (index != GameDifficulty.values.length - 1)
                            const SizedBox(height: 16),
                        ],
                        const SizedBox(height: 18),
                        KidDelayedReveal(
                          key: ValueKey('difficulty-tip-$_replayEpoch'),
                          delay: _isReplaying
                              ? const Duration(milliseconds: 280)
                              : const Duration(milliseconds: 520),
                          duration: _isReplaying
                              ? const Duration(milliseconds: 360)
                              : const Duration(milliseconds: 400),
                          beginOffset: Offset.zero,
                          beginScale: 0.9,
                          curve: _replayCurve,
                          child: _DifficultyTipCard(
                            text: context.l10n.difficultySelectHint,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: _DifficultyHeader.heightFor(context),
                child: _DifficultyHeader(
                  gameId: gameId,
                  onBack: _handleBack,
                  replayEpoch: _replayEpoch,
                  isReplaying: _isReplaying,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DifficultyHeader extends StatelessWidget {
  const _DifficultyHeader({
    required this.gameId,
    required this.onBack,
    required this.replayEpoch,
    required this.isReplaying,
  });

  final GameId gameId;
  final VoidCallback onBack;
  final int replayEpoch;
  final bool isReplaying;

  static const _baseHeight = 166.0;
  static const _contentTopOffset = 42.0;
  static const _horizontalInset = 32.0;

  static double heightFor(BuildContext context) {
    return _baseHeight + MediaQuery.paddingOf(context).top;
  }

  @override
  Widget build(BuildContext context) {
    final statusBarTop = MediaQuery.paddingOf(context).top;
    return SizedBox(
      height: heightFor(context),
      child: Stack(
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
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
          const Positioned.fill(
            child: CustomPaint(
              painter: _HeroDotOverlayPainter(),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              _horizontalInset,
              statusBarTop + _contentTopOffset,
              _horizontalInset,
              0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _RoundBackButton(onTap: onBack),
                    const SizedBox(width: 12),
                    Expanded(
                      child: KidDelayedReveal(
                        key: ValueKey(
                            'difficulty-pill-$replayEpoch-${gameId.name}'),
                        delay: isReplaying
                            ? const Duration(milliseconds: 40)
                            : const Duration(milliseconds: 80),
                        duration: const Duration(milliseconds: 380),
                        beginOffset: Offset.zero,
                        beginScale: 0.8,
                        curve: Curves.easeOutBack,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.92),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.78),
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
                          child: Row(
                            children: [
                              KidLoopAnimation(
                                duration: const Duration(milliseconds: 2000),
                                builder: (context, value, child) {
                                  final wave = math.sin(value * math.pi * 2);
                                  return Transform.rotate(
                                    angle: wave * 0.18,
                                    child: child,
                                  );
                                },
                                child: FigmaGameIcon(gameId: gameId, size: 32),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  gameId.title(context.l10n),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: _gamePillTextStyle(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      context.l10n.difficultySelectTitle,
                      style: _heroTitleStyle(),
                    ),
                    const SizedBox(width: 8),
                    KidLoopAnimation(
                      duration: const Duration(milliseconds: 900),
                      reverse: false,
                      builder: (context, value, child) {
                        final wave = math.sin(value * math.pi * 2);
                        return Transform.translate(
                          offset: Offset(0, wave.abs() * 7),
                          child: child,
                        );
                      },
                      child: const FigmaDownArrowIcon(size: 22),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SizedBox(
              height: 38,
              child: CustomPaint(
                painter: _HeaderWavePainter(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DifficultyStickerCard extends StatefulWidget {
  const _DifficultyStickerCard({
    required this.difficulty,
    required this.unlocked,
    required this.onTap,
  });

  final GameDifficulty difficulty;
  final bool unlocked;
  final VoidCallback onTap;

  @override
  State<_DifficultyStickerCard> createState() => _DifficultyStickerCardState();
}

class _DifficultyStickerCardState extends State<_DifficultyStickerCard> {
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
    final l10n = context.l10n;
    final spec = _DifficultyPresentation.of(widget.difficulty, l10n);
    final textColor =
        widget.unlocked ? spec.textColor : const Color(0xFF7A8FA0);

    final card = AnimatedScale(
      duration: const Duration(milliseconds: 120),
      scale: _pressed && widget.unlocked ? 0.94 : 1,
      curve: Curves.easeOut,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(
            0, _pressed && widget.unlocked ? 6 : 0, 0),
        decoration: BoxDecoration(
          gradient: widget.unlocked
              ? spec.gradient
              : const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFE8EEF5),
                    Color(0xFFC8D4E0),
                  ],
                ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: widget.unlocked ? spec.borderColor : const Color(0xFF8CA0B4),
            width: 4,
          ),
          boxShadow: [
            BoxShadow(
              color:
                  widget.unlocked ? spec.borderColor : const Color(0xFF8CA0B4),
              offset: const Offset(6, 7),
              blurRadius: 0,
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 58,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(
                    alpha: widget.unlocked ? 0.22 : 0.1,
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 10,
              right: 12,
              child: widget.unlocked
                  ? FigmaFloatIcon(
                      type: spec.cornerIcon,
                      size: 20,
                    )
                  : const FigmaLockIcon(size: 28),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
              child: Row(
                children: [
                  Container(
                    width: 82,
                    height: 82,
                    decoration: BoxDecoration(
                      color: widget.unlocked
                          ? Colors.white.withValues(alpha: 0.38)
                          : Colors.white.withValues(alpha: 0.26),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.55),
                        width: 3,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x1A000000),
                          offset: Offset(3, 4),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Opacity(
                        opacity: widget.unlocked ? 1 : 0.56,
                        child: ColorFiltered(
                          colorFilter: widget.unlocked
                              ? const ColorFilter.mode(
                                  Colors.transparent,
                                  BlendMode.srcOver,
                                )
                              : const ColorFilter.matrix(_greyMatrix),
                          child: KidLoopAnimation(
                            duration: Duration(
                              milliseconds:
                                  2100 + (widget.difficulty.index * 240),
                            ),
                            builder: (context, value, child) {
                              final wave = math.sin(value * math.pi * 2);
                              return Transform.translate(
                                offset:
                                    Offset(0, widget.unlocked ? wave * 7 : 0),
                                child: Transform.rotate(
                                  angle: widget.unlocked ? wave * 0.12 : 0,
                                  child: child,
                                ),
                              );
                            },
                            child: spec.mascotBuilder(),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          spec.title,
                          style: _difficultyTitleStyle(
                            color: textColor,
                            shadowColor: spec.borderColor,
                            shadowed: widget.unlocked,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          spec.subtitle,
                          style: _difficultySubtitleStyle(color: textColor),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            for (var index = 0; index < 3; index++)
                              Padding(
                                padding: const EdgeInsets.only(right: 2),
                                child: Opacity(
                                  opacity: index < spec.starCount ? 1 : 0.24,
                                  child: KidLoopAnimation(
                                    duration: Duration(
                                      milliseconds: 1500 + (index * 200),
                                    ),
                                    builder: (context, value, child) {
                                      final scale = index < spec.starCount
                                          ? 1 +
                                              (math.sin(value * math.pi * 2) *
                                                  0.12)
                                          : 1.0;
                                      return Transform.scale(
                                        scale: scale,
                                        child: child,
                                      );
                                    },
                                    child: const FigmaSparkleStarIcon(size: 22),
                                  ),
                                ),
                              ),
                            const SizedBox(width: 6),
                            Text(
                              '${spec.roundCount}${l10n.difficultyRoundCountSuffix}',
                              style: _roundCountStyle(color: textColor),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.38),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.55),
                        width: 2.5,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x16000000),
                          offset: Offset(2, 2),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Transform.rotate(
                      angle: math.pi,
                      child: FigmaBackChevronIcon(
                        size: 22,
                        color: textColor.withValues(alpha: 0.92),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: widget.unlocked ? (_) => _setPressed(true) : null,
      onTapUp: widget.unlocked ? (_) => _setPressed(false) : null,
      onTapCancel: widget.unlocked ? () => _setPressed(false) : null,
      behavior: HitTestBehavior.opaque,
      child: card,
    );
  }
}

class _DifficultyTipCard extends StatelessWidget {
  const _DifficultyTipCard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFF0C8E0),
          width: 3,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFFF0C8E0),
            offset: Offset(4, 5),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          KidLoopAnimation(
            duration: const Duration(milliseconds: 2000),
            builder: (context, value, child) {
              final wave = math.sin(value * math.pi * 2);
              return Transform.rotate(
                angle: wave * 0.22,
                child: child,
              );
            },
            child: const FigmaLightbulbIcon(size: 28),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: _tipTextStyle(),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundBackButton extends StatefulWidget {
  const _RoundBackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  State<_RoundBackButton> createState() => _RoundBackButtonState();
}

class _RoundBackButtonState extends State<_RoundBackButton> {
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
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      child: AnimatedScale(
        scale: _pressed ? 0.88 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.92),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.78),
              width: 3.5,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x26000000),
                offset: Offset(3, 4),
                blurRadius: 0,
              ),
            ],
          ),
          alignment: Alignment.center,
          child: const FigmaBackChevronIcon(size: 24),
        ),
      ),
    );
  }
}

class _ShakingCard extends StatelessWidget {
  const _ShakingCard({
    required this.active,
    required this.child,
  });

  final bool active;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: ValueKey(active),
      tween: Tween(begin: 0, end: active ? 1 : 0),
      duration: Duration(milliseconds: active ? 450 : 1),
      builder: (context, value, builtChild) {
        final shake = active ? math.sin(value * math.pi * 5) * 12 : 0.0;
        return Transform.translate(
          offset: Offset(shake, 0),
          child: builtChild,
        );
      },
      child: child,
    );
  }
}

class _DifficultyPresentation {
  const _DifficultyPresentation({
    required this.title,
    required this.subtitle,
    required this.starCount,
    required this.roundCount,
    required this.gradient,
    required this.borderColor,
    required this.textColor,
    required this.cornerIcon,
    required this.mascotBuilder,
  });

  final String title;
  final String subtitle;
  final int starCount;
  final int roundCount;
  final LinearGradient gradient;
  final Color borderColor;
  final Color textColor;
  final FigmaFloatIconType cornerIcon;
  final Widget Function() mascotBuilder;

  static _DifficultyPresentation of(
    GameDifficulty difficulty,
    AppLocalizations l10n,
  ) {
    switch (difficulty) {
      case GameDifficulty.easy:
        return _DifficultyPresentation(
          title: l10n.difficultyEasy,
          subtitle: l10n.difficultyEasySummary,
          starCount: 1,
          roundCount: difficulty.config.rounds,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFA5D6A7),
              Color(0xFF43A047),
            ],
          ),
          borderColor: const Color(0xFF1B5E20),
          textColor: Colors.white,
          cornerIcon: FigmaFloatIconType.heart,
          mascotBuilder: () => const FigmaChickMascotIcon(size: 64),
        );
      case GameDifficulty.medium:
        return _DifficultyPresentation(
          title: l10n.difficultyMedium,
          subtitle: l10n.difficultyMediumSummary,
          starCount: 2,
          roundCount: difficulty.config.rounds,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFE082),
              Color(0xFFFFB300),
            ],
          ),
          borderColor: const Color(0xFFC85000),
          textColor: const Color(0xFF3A1800),
          cornerIcon: FigmaFloatIconType.star,
          mascotBuilder: () => const FigmaFoxMascotIcon(size: 64),
        );
      case GameDifficulty.hard:
        return _DifficultyPresentation(
          title: l10n.difficultyHard,
          subtitle: l10n.difficultyHardSummary,
          starCount: 3,
          roundCount: difficulty.config.rounds,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFF8A65),
              Color(0xFFE53935),
            ],
          ),
          borderColor: const Color(0xFF7F0000),
          textColor: Colors.white,
          cornerIcon: FigmaFloatIconType.sparkle,
          mascotBuilder: () => const FigmaLionMascotIcon(size: 64),
        );
    }
  }
}

TextStyle _heroTitleStyle() {
  return GoogleFonts.baloo2(
    fontSize: 26,
    fontWeight: FontWeight.w800,
    color: Colors.white,
    shadows: const [
      Shadow(
        color: Color(0x33000000),
        offset: Offset(-1, -1),
        blurRadius: 0,
      ),
      Shadow(
        color: Color(0x33000000),
        offset: Offset(1, 1),
        blurRadius: 0,
      ),
    ],
  );
}

TextStyle _gamePillTextStyle() {
  return GoogleFonts.baloo2(
    fontSize: 18,
    fontWeight: FontWeight.w800,
    color: const Color(0xFF7B3FC4),
    height: 1,
  );
}

TextStyle _difficultyTitleStyle({
  required Color color,
  required Color shadowColor,
  required bool shadowed,
}) {
  return GoogleFonts.baloo2(
    fontSize: 30,
    fontWeight: FontWeight.w800,
    color: color,
    height: 1,
    shadows: shadowed
        ? [
            Shadow(
              color: shadowColor.withValues(alpha: 0.32),
              offset: const Offset(1, 1),
              blurRadius: 0,
            ),
          ]
        : null,
  );
}

TextStyle _difficultySubtitleStyle({required Color color}) {
  return GoogleFonts.baloo2(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: color.withValues(alpha: 0.92),
    height: 1.1,
  );
}

TextStyle _roundCountStyle({required Color color}) {
  return GoogleFonts.baloo2(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: color.withValues(alpha: 0.86),
    height: 1,
  );
}

TextStyle _tipTextStyle() {
  return GoogleFonts.baloo2(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: const Color(0xFF7B3FC4),
    height: 1.2,
  );
}

class _PolkaDotPainter extends CustomPainter {
  const _PolkaDotPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final background = Paint()..color = const Color(0xFFFFF9F5);
    canvas.drawRect(Offset.zero & size, background);

    final pink = Paint()..color = const Color(0x80FFA0C8);
    final blue = Paint()..color = const Color(0x738CBEFF);
    final yellow = Paint()..color = const Color(0x73FFDC64);
    const spacing = 36.0;

    for (double y = 0; y <= size.height + spacing; y += spacing) {
      for (double x = 0; x <= size.width + spacing; x += spacing) {
        canvas.drawCircle(Offset(x, y), 2.5, pink);
        canvas.drawCircle(Offset(x + 18, y + 18), 2.0, blue);
        canvas.drawCircle(Offset(x + 9, y + 27), 2.0, yellow);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _HeroDotOverlayPainter extends CustomPainter {
  const _HeroDotOverlayPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final dotPaint = Paint()..color = Colors.white.withValues(alpha: 0.18);
    const spacing = 30.0;
    for (double y = 0; y <= size.height + spacing; y += spacing) {
      for (double x = 0; x <= size.width + spacing; x += spacing) {
        canvas.drawCircle(Offset(x, y), 2.5, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _HeaderWavePainter extends CustomPainter {
  const _HeaderWavePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 12)
      ..cubicTo(
          size.width * 0.126, 32, size.width * 0.251, 4, size.width * 0.377, 20)
      ..cubicTo(
          size.width * 0.502, 36, size.width * 0.628, 8, size.width * 0.753, 22)
      ..cubicTo(size.width * 0.847, 32, size.width * 0.93, 14, size.width, 18)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(
      path,
      Paint()..color = const Color(0xFFFFF9F5),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

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
