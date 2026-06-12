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

final gameSelectViewModelProvider =
    ChangeNotifierProvider.autoDispose<GameSelectViewModel>((ref) {
  return GameSelectViewModel();
});

class GameSelectViewModel extends ChangeNotifier {
  Timer? _timer;
  GameId? lockedHintGameId;

  void showLockedHint(GameId gameId) {
    lockedHintGameId = gameId;
    notifyListeners();
    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 700), () {
      lockedHintGameId = null;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

class GameSelectPage extends ConsumerStatefulWidget {
  const GameSelectPage({super.key});

  @override
  ConsumerState<GameSelectPage> createState() => _GameSelectPageState();
}

class _GameSelectPageState extends ConsumerState<GameSelectPage>
    with RouteAware {
  static const _cardRotations = [-2.5, 2.0, -1.5, 2.5, -1.0];
  static const _cornerIcons = [
    FigmaFloatIconType.star,
    FigmaFloatIconType.heart,
    FigmaFloatIconType.sparkle,
    FigmaFloatIconType.diamond,
    FigmaFloatIconType.flower,
  ];
  static const _replayCurve = Curves.easeOutBack;

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
    final progress = ref.watch(gameProgressProvider);
    final viewModel = ref.watch(gameSelectViewModelProvider);
    final l10n = context.l10n;
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
                    top: _GameSelectHeader.heightFor(context) + 24,
                    bottom: bottomInset + 24,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        const spacing = 20.0;
                        final cardWidth = (constraints.maxWidth - spacing) / 2;

                        return Wrap(
                          spacing: spacing,
                          runSpacing: 20,
                          children: [
                            for (var index = 0;
                                index < orderedGameIds.length;
                                index++)
                              SizedBox(
                                width: cardWidth,
                                child: KidDelayedReveal(
                                  key: ValueKey(
                                    'game-select-$_replayEpoch-${orderedGameIds[index].name}',
                                  ),
                                  delay: _isReplaying
                                      ? Duration(milliseconds: index * 80)
                                      : Duration(milliseconds: index * 80),
                                  duration: _isReplaying
                                      ? const Duration(milliseconds: 420)
                                      : const Duration(milliseconds: 440),
                                  beginOffset: Offset.zero,
                                  beginScale: _gameCardBeginScale(
                                    _isReplaying,
                                  ),
                                  beginRotation: _gameCardBeginRotation(
                                    rotationDegrees: _cardRotations[
                                        index % _cardRotations.length],
                                    unlocked: progress.isUnlocked(
                                      orderedGameIds[index],
                                    ),
                                    replaying: _isReplaying,
                                  ),
                                  curve: _replayCurve,
                                  child: _ShakingCard(
                                    active: viewModel.lockedHintGameId ==
                                        orderedGameIds[index],
                                    child: _GameStickerCard(
                                      gameId: orderedGameIds[index],
                                      rotationDegrees: _cardRotations[
                                          index % _cardRotations.length],
                                      cornerIcon: _cornerIcons[
                                          index % _cornerIcons.length],
                                      unlocked: progress.isUnlocked(
                                        orderedGameIds[index],
                                      ),
                                      nextToUnlock: !progress.isUnlocked(
                                            orderedGameIds[index],
                                          ) &&
                                          index > 0 &&
                                          progress.isUnlocked(
                                            orderedGameIds[index - 1],
                                          ),
                                      showLockedHint:
                                          viewModel.lockedHintGameId ==
                                              orderedGameIds[index],
                                      onTap: () {
                                        final gameId = orderedGameIds[index];
                                        if (progress.isUnlocked(gameId)) {
                                          Navigator.pushNamed(
                                            context,
                                            AppRoutes.difficulty,
                                            arguments: DifficultyRouteArgs(
                                              gameId: gameId,
                                            ),
                                          );
                                        } else {
                                          ref
                                              .read(
                                                gameSelectViewModelProvider,
                                              )
                                              .showLockedHint(gameId);
                                        }
                                      },
                                      lockedHintText: l10n.gameSelectLockedHint,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: _GameSelectHeader.heightFor(context),
                child: _GameSelectHeader(
                  onBack: _handleBack,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static double _gameCardBeginScale(bool replaying) {
    return 0.7;
  }

  static double _gameCardBeginRotation({
    required double rotationDegrees,
    required bool unlocked,
    required bool replaying,
  }) {
    if (!unlocked) {
      return 0;
    }

    final baseRadians = rotationDegrees * math.pi / 180;
    return replaying ? baseRadians : baseRadians * 2;
  }
}

class _GameSelectHeader extends StatelessWidget {
  const _GameSelectHeader({required this.onBack});

  final VoidCallback onBack;

  static double heightFor(BuildContext context) {
    return 152 + MediaQuery.paddingOf(context).top;
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
            padding: EdgeInsets.fromLTRB(20, statusBarTop + 48, 20, 0),
            child: Row(
              children: [
                _RoundBackButton(onTap: onBack),
                const SizedBox(width: 14),
                Text(
                  context.l10n.gameSelectTitle,
                  style: _heroTitleStyle(),
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

class _GameStickerCard extends StatefulWidget {
  const _GameStickerCard({
    required this.gameId,
    required this.rotationDegrees,
    required this.cornerIcon,
    required this.unlocked,
    required this.nextToUnlock,
    required this.showLockedHint,
    required this.onTap,
    required this.lockedHintText,
  });

  final GameId gameId;
  final double rotationDegrees;
  final FigmaFloatIconType cornerIcon;
  final bool unlocked;
  final bool nextToUnlock;
  final bool showLockedHint;
  final VoidCallback onTap;
  final String lockedHintText;

  @override
  State<_GameStickerCard> createState() => _GameStickerCardState();
}

class _GameStickerCardState extends State<_GameStickerCard> {
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
    final rotation = widget.unlocked ? widget.rotationDegrees : 0.0;
    final textColor = widget.unlocked ? Colors.white : const Color(0xFF7A8FA0);

    final card = Transform.rotate(
      angle: rotation * math.pi / 180,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 120),
        scale: _pressed && widget.unlocked ? 0.9 : 1,
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          transform: Matrix4.translationValues(
            0,
            _pressed && widget.unlocked ? 5 : 0,
            0,
          ),
          child: Container(
            constraints: const BoxConstraints(minHeight: 168),
            decoration: BoxDecoration(
              gradient: widget.unlocked
                  ? widget.gameId.gradient
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
                color: widget.unlocked
                    ? widget.gameId.borderColor
                    : const Color(0xFF8CA0B4),
                width: 4,
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.unlocked
                      ? widget.gameId.borderColor
                      : const Color(0xFF8CA0B4),
                  offset: const Offset(6, 7),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 54,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(
                        alpha: widget.unlocked ? 0.24 : 0.12,
                      ),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                    ),
                  ),
                ),
                if (widget.unlocked)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: FigmaFloatIcon(
                      type: widget.cornerIcon,
                      size: 18,
                    ),
                  ),
                if (!widget.unlocked)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: widget.nextToUnlock
                        ? KidLoopAnimation(
                            duration: const Duration(milliseconds: 1400),
                            builder: (context, value, child) {
                              final wave = math.sin(value * math.pi * 2);
                              return Transform.scale(
                                scale: 1 + (wave.abs() * 0.28),
                                child: Transform.rotate(
                                  angle: wave * 0.18,
                                  child: child,
                                ),
                              );
                            },
                            child: const FigmaFloatIcon(
                              type: FigmaFloatIconType.star,
                              size: 24,
                            ),
                          )
                        : const FigmaLockIcon(size: 28),
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 28, 12, 20),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 78,
                        child: Center(
                          child: KidLoopAnimation(
                            duration: Duration(
                              milliseconds: 2200 + (widget.gameId.index * 160),
                            ),
                            builder: (context, value, child) {
                              final wave = math.sin(value * math.pi * 2);
                              return Transform.translate(
                                offset:
                                    Offset(0, widget.unlocked ? wave * 6 : 0),
                                child: child,
                              );
                            },
                            child: Opacity(
                              opacity: widget.unlocked ? 1 : 0.55,
                              child: ColorFiltered(
                                colorFilter: widget.unlocked
                                    ? const ColorFilter.mode(
                                        Colors.transparent,
                                        BlendMode.srcOver,
                                      )
                                    : const ColorFilter.matrix(_greyMatrix),
                                child: FigmaGameIcon(
                                  gameId: widget.gameId,
                                  size: 68,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: widget.unlocked
                              ? Colors.white.withValues(alpha: 0.28)
                              : Colors.black.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(999),
                          border: widget.unlocked
                              ? Border.all(
                                  color: Colors.white.withValues(alpha: 0.45),
                                  width: 2,
                                )
                              : null,
                        ),
                        child: Text(
                          widget.gameId.title(l10n),
                          textAlign: TextAlign.center,
                          style: _gameCardTitleStyle(
                            color: textColor,
                            shadowed: widget.unlocked,
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
      ),
    );

    return Column(
      children: [
        GestureDetector(
          onTap: widget.onTap,
          onTapDown: widget.unlocked ? (_) => _setPressed(true) : null,
          onTapUp: widget.unlocked ? (_) => _setPressed(false) : null,
          onTapCancel: widget.unlocked ? () => _setPressed(false) : null,
          behavior: HitTestBehavior.opaque,
          child: card,
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          switchInCurve: Curves.easeOutBack,
          switchOutCurve: Curves.easeInCubic,
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
                  begin: const Offset(0, -0.14),
                  end: Offset.zero,
                ).animate(curved),
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.9, end: 1).animate(curved),
                  child: SizeTransition(
                    sizeFactor: animation,
                    axisAlignment: -1,
                    child: child,
                  ),
                ),
              ),
            );
          },
          child: !widget.showLockedHint
              ? const SizedBox.shrink()
              : Container(
                  key: ValueKey(widget.gameId),
                  margin: const EdgeInsets.only(top: 10),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: const Color(0xFFFFAB40),
                      width: 3,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0xFFFFAB40),
                        offset: Offset(3, 3),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const FigmaPunchFistIcon(size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.lockedHintText,
                          style: _hintTextStyle(),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ],
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

TextStyle _heroTitleStyle() {
  return GoogleFonts.baloo2(
    fontSize: 28,
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

TextStyle _gameCardTitleStyle({
  required Color color,
  required bool shadowed,
}) {
  return GoogleFonts.baloo2(
    fontSize: 14,
    fontWeight: FontWeight.w800,
    color: color,
    letterSpacing: 0.3,
    height: 1,
    shadows: shadowed
        ? const [
            Shadow(
              color: Color(0x26000000),
              offset: Offset(1, 1),
              blurRadius: 0,
            ),
          ]
        : null,
  );
}

TextStyle _hintTextStyle() {
  return GoogleFonts.baloo2(
    fontSize: 12,
    fontWeight: FontWeight.w800,
    color: const Color(0xFFE65100),
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
