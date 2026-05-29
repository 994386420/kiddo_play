import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/localization.dart';
import '../game_models.dart';
import 'figma_home_icons.dart';
import 'kid_motion.dart';

class FigmaGamePalette {
  const FigmaGamePalette({
    required this.accent,
    required this.accentStrong,
    required this.accentSoft,
    required this.progressTrack,
    required this.progressBorder,
    required this.progressGradient,
    required this.floaterIcon,
  });

  final Color accent;
  final Color accentStrong;
  final Color accentSoft;
  final Color progressTrack;
  final Color progressBorder;
  final Gradient progressGradient;
  final FigmaFloatIconType floaterIcon;
}

class FigmaGameScaffold extends StatelessWidget {
  const FigmaGameScaffold({
    required this.palette,
    required this.roundLabel,
    required this.difficulty,
    required this.stars,
    required this.progress,
    required this.onPause,
    required this.body,
    this.pauseDialog,
    this.floatingAction,
    this.pauseIcon,
    this.backgroundColor = const Color(0xFFFFF9F5),
    this.backgroundGradient,
    this.showDots = false,
    this.includeYellowDots = false,
    this.showDecorativeLayer = false,
    this.contentPadding = const EdgeInsets.fromLTRB(18, 18, 18, 96),
    this.progressHeight = 12,
    super.key,
  });

  final FigmaGamePalette palette;
  final String roundLabel;
  final GameDifficulty difficulty;
  final int stars;
  final double progress;
  final VoidCallback onPause;
  final Widget body;
  final Widget? pauseDialog;
  final Widget? floatingAction;
  final Widget? pauseIcon;
  final Color backgroundColor;
  final Gradient? backgroundGradient;
  final bool showDots;
  final bool includeYellowDots;
  final bool showDecorativeLayer;
  final EdgeInsets contentPadding;
  final double progressHeight;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Stack(
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    gradient: backgroundGradient,
                  ),
                ),
              ),
              if (showDots)
                Positioned.fill(
                  child: CustomPaint(
                    painter: _FigmaGameDotPainter(
                      includeYellowDots: includeYellowDots,
                    ),
                  ),
                ),
              if (showDecorativeLayer)
                Positioned.fill(
                  child: _FigmaGameDecorativeLayer(palette: palette),
                ),
              SafeArea(
                child: ListView(
                  padding: contentPadding,
                  children: [
                    FigmaGameHeader(
                      palette: palette,
                      roundLabel: roundLabel,
                      difficulty: difficulty,
                      stars: stars,
                      onPause: onPause,
                      pauseIcon: pauseIcon,
                    ),
                    const SizedBox(height: 12),
                    FigmaGameProgressBar(
                      value: progress,
                      palette: palette,
                      height: progressHeight,
                    ),
                    const SizedBox(height: 20),
                    body,
                  ],
                ),
              ),
            ],
          ),
          if (floatingAction != null) floatingAction!,
          if (pauseDialog != null) pauseDialog!,
        ],
      ),
    );
  }
}

class _FigmaGameDotPainter extends CustomPainter {
  const _FigmaGameDotPainter({
    required this.includeYellowDots,
  });

  final bool includeYellowDots;

  @override
  void paint(Canvas canvas, Size size) {
    final pink = Paint()..color = const Color(0x66FFA0C8);
    final blue = Paint()..color = const Color(0x598CBEFF);
    final yellow = Paint()..color = const Color(0x59FFDC64);
    const spacing = 32.0;

    for (double y = 0; y <= size.height + spacing; y += spacing) {
      for (double x = 0; x <= size.width + spacing; x += spacing) {
        canvas.drawCircle(Offset(x, y), 2.0, pink);
        canvas.drawCircle(Offset(x + 16, y + 16), 1.6, blue);
        if (includeYellowDots) {
          canvas.drawCircle(Offset(x + 8, y + 24), 1.8, yellow);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _FigmaGameDotPainter oldDelegate) {
    return oldDelegate.includeYellowDots != includeYellowDots;
  }
}

class FigmaGameHeader extends StatelessWidget {
  const FigmaGameHeader({
    required this.palette,
    required this.roundLabel,
    required this.difficulty,
    required this.stars,
    required this.onPause,
    this.pauseIcon,
    super.key,
  });

  final FigmaGamePalette palette;
  final String roundLabel;
  final GameDifficulty difficulty;
  final int stars;
  final VoidCallback onPause;
  final Widget? pauseIcon;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FigmaHeaderCircleButton(
          borderColor: palette.progressBorder,
          shadowColor: palette.accentStrong,
          onTap: onPause,
          child: pauseIcon ??
              Icon(
                Icons.pause_rounded,
                color: palette.accentStrong,
                size: 22,
              ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            children: [
              FigmaGameInfoPill(
                palette: palette,
                label: roundLabel,
                textColor: palette.accentStrong,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              const SizedBox(height: 4),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: difficulty.config.accentBackground,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: difficulty.config.accentText.withValues(alpha: 0.28),
                    width: 1.8,
                  ),
                ),
                child: Text(
                  '${difficulty.badgeEmoji} ${difficulty.label(context.l10n)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w900,
                    color: difficulty.config.accentText,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        _FigmaStarPill(stars: stars),
      ],
    );
  }
}

class _FigmaHeaderCircleButton extends StatelessWidget {
  const _FigmaHeaderCircleButton({
    required this.borderColor,
    required this.shadowColor,
    required this.onTap,
    required this.child,
  });

  final Color borderColor;
  final Color shadowColor;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Ink(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: borderColor, width: 2.8),
            boxShadow: [
              BoxShadow(
                color: shadowColor.withValues(alpha: 0.28),
                blurRadius: 0,
                offset: const Offset(3, 3),
              ),
            ],
          ),
          child: Center(child: child),
        ),
      ),
    );
  }
}

class FigmaGameInfoPill extends StatelessWidget {
  const FigmaGameInfoPill({
    required this.palette,
    required this.label,
    required this.textColor,
    this.borderColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    super.key,
  });

  final FigmaGamePalette palette;
  final String label;
  final Color textColor;
  final Color? borderColor;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final resolvedBorder = borderColor ?? palette.progressBorder;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: resolvedBorder, width: 2.8),
        boxShadow: [
          BoxShadow(
            color: resolvedBorder.withValues(alpha: 0.26),
            blurRadius: 0,
            offset: const Offset(3, 3),
          ),
        ],
      ),
      child: Padding(
        padding: padding,
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w900,
            color: textColor,
            letterSpacing: -0.15,
          ),
        ),
      ),
    );
  }
}

class FigmaGameProgressBar extends StatelessWidget {
  const FigmaGameProgressBar({
    required this.value,
    required this.palette,
    this.height = 14,
    super.key,
  });

  final double value;
  final FigmaGamePalette palette;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: palette.accentStrong.withValues(alpha: 0.12),
            blurRadius: 10,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: KidAnimatedProgressBar(
        value: value,
        backgroundColor: palette.progressTrack,
        borderColor: palette.progressBorder,
        gradient: palette.progressGradient,
        height: height,
      ),
    );
  }
}

class FigmaGamePanel extends StatelessWidget {
  const FigmaGamePanel({
    required this.palette,
    required this.child,
    this.padding = const EdgeInsets.all(22),
    this.radius = 34,
    this.tint,
    super.key,
  });

  final FigmaGamePalette palette;
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    final fill = tint ?? Colors.white;
    return Container(
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: palette.progressBorder, width: 3),
        boxShadow: [
          BoxShadow(
            color: palette.accentStrong.withValues(alpha: 0.16),
            blurRadius: 0,
            offset: const Offset(4, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: Container(
                height: 42,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.55),
                      Colors.white.withValues(alpha: 0),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(radius - 3.2),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: padding,
            child: child,
          ),
        ],
      ),
    );
  }
}

class FigmaGameFeedbackBanner extends StatelessWidget {
  const FigmaGameFeedbackBanner({
    required this.visible,
    required this.text,
    required this.isPositive,
    required this.palette,
    super.key,
  });

  final bool visible;
  final String text;
  final bool isPositive;
  final FigmaGamePalette palette;

  @override
  Widget build(BuildContext context) {
    final background =
        isPositive ? const Color(0xFFF0FFF5) : const Color(0xFFFFF4EC);
    final border =
        isPositive ? const Color(0xFF59C36A) : const Color(0xFFFFA25A);
    final textColor =
        isPositive ? const Color(0xFF1F8C37) : const Color(0xFFDB6A0F);

    return SizedBox(
      height: 72,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        switchInCurve: Curves.easeOutBack,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.18),
                end: Offset.zero,
              ).animate(animation),
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.92, end: 1).animate(animation),
                child: child,
              ),
            ),
          );
        },
        child: !visible
            ? const SizedBox.shrink()
            : Container(
                key: ValueKey('${isPositive}_$text'),
                decoration: BoxDecoration(
                  color: background,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: border, width: 2.6),
                  boxShadow: [
                    BoxShadow(
                      color: border.withValues(alpha: 0.14),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                child: Row(
                  children: [
                    _FeedbackDot(
                      color: isPositive ? const Color(0xFF59C36A) : border,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        text,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          color: textColor,
                          letterSpacing: -0.1,
                        ),
                      ),
                    ),
                    _FeedbackDot(
                      color: isPositive ? const Color(0xFF59C36A) : border,
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _FeedbackDot extends StatelessWidget {
  const _FeedbackDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.28),
            blurRadius: 8,
          ),
        ],
      ),
    );
  }
}

class _FigmaStarPill extends StatelessWidget {
  const _FigmaStarPill({required this.stars});

  final int stars;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4C7),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFFFC933), width: 2.8),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFC933).withValues(alpha: 0.26),
            blurRadius: 0,
            offset: const Offset(3, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const FigmaSparkleStarIcon(size: 17),
            const SizedBox(width: 6),
            Text(
              '$stars',
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w900,
                color: Color(0xFF9C6800),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FigmaGameDecorativeLayer extends StatelessWidget {
  const _FigmaGameDecorativeLayer({required this.palette});

  final FigmaGamePalette palette;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            Positioned(
              left: -44,
              top: 86,
              child: _SoftBlob(
                size: 150,
                color: palette.accentSoft.withValues(alpha: 0.68),
              ),
            ),
            Positioned(
              right: -56,
              top: 220,
              child: _SoftBlob(
                size: 170,
                color: palette.progressTrack.withValues(alpha: 0.74),
              ),
            ),
            Positioned(
              right: 34,
              bottom: 120,
              child: _SoftBlob(
                size: 108,
                color: palette.accent.withValues(alpha: 0.14),
              ),
            ),
            for (final spec in _decorativeSpecs)
              Positioned(
                left: constraints.maxWidth * spec.leftFactor,
                top: constraints.maxHeight * spec.topFactor,
                child: KidLoopAnimation(
                  duration: const Duration(milliseconds: 2800),
                  delay: Duration(milliseconds: (spec.phase * 1000).round()),
                  builder: (context, value, child) {
                    final t = (value + spec.phase) % 1;
                    final offset = math.sin(t * math.pi * 2) * 6;
                    final rotate = math.sin(t * math.pi * 2) * 0.16;
                    return Transform.translate(
                      offset: Offset(0, offset),
                      child: Transform.rotate(
                        angle: rotate,
                        child: child,
                      ),
                    );
                  },
                  child: Opacity(
                    opacity: 0.92,
                    child: FigmaFloatIcon(
                      type: spec.icon ?? palette.floaterIcon,
                      size: spec.size,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _SoftBlob extends StatelessWidget {
  const _SoftBlob({
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
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color,
            color.withValues(alpha: 0),
          ],
        ),
      ),
    );
  }
}

class _DecorativeSpec {
  const _DecorativeSpec({
    required this.leftFactor,
    required this.topFactor,
    required this.size,
    required this.phase,
    this.icon,
  });

  final double leftFactor;
  final double topFactor;
  final double size;
  final double phase;
  final FigmaFloatIconType? icon;
}

const _decorativeSpecs = <_DecorativeSpec>[
  _DecorativeSpec(
    leftFactor: 0.06,
    topFactor: 0.12,
    size: 18,
    phase: 0.0,
    icon: FigmaFloatIconType.heart,
  ),
  _DecorativeSpec(
    leftFactor: 0.84,
    topFactor: 0.14,
    size: 18,
    phase: 0.16,
    icon: FigmaFloatIconType.star,
  ),
  _DecorativeSpec(
    leftFactor: 0.12,
    topFactor: 0.52,
    size: 16,
    phase: 0.28,
    icon: FigmaFloatIconType.sparkle,
  ),
  _DecorativeSpec(
    leftFactor: 0.84,
    topFactor: 0.56,
    size: 20,
    phase: 0.34,
    icon: FigmaFloatIconType.flower,
  ),
  _DecorativeSpec(
    leftFactor: 0.28,
    topFactor: 0.84,
    size: 16,
    phase: 0.21,
    icon: FigmaFloatIconType.diamond,
  ),
  _DecorativeSpec(
    leftFactor: 0.72,
    topFactor: 0.82,
    size: 16,
    phase: 0.42,
    icon: FigmaFloatIconType.fire,
  ),
];
