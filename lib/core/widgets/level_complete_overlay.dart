import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

import 'figma_home_icons.dart';
import 'kid_motion.dart';

class LevelCompleteOverlay extends StatefulWidget {
  const LevelCompleteOverlay({
    required this.level,
    required this.totalLevels,
    required this.stars,
    required this.totalRounds,
    required this.accentColor,
    required this.borderColor,
    required this.onContinue,
    super.key,
  });

  final int level;
  final int totalLevels;
  final int stars;
  final int totalRounds;
  final Color accentColor;
  final Color borderColor;
  final VoidCallback onContinue;

  @override
  State<LevelCompleteOverlay> createState() => _LevelCompleteOverlayState();
}

class _LevelCompleteOverlayState extends State<LevelCompleteOverlay> {
  Timer? _timer;
  bool _continued = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 2), _continue);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _continue() {
    if (_continued) {
      return;
    }
    _continued = true;
    widget.onContinue();
  }

  @override
  Widget build(BuildContext context) {
    final remaining = (widget.totalLevels - widget.level).clamp(0, 99);

    return Positioned.fill(
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
          child: ColoredBox(
            color: Colors.black.withValues(alpha: 0.55),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const _FloatingRewardIcon(
                  left: 0.10,
                  top: 0.20,
                  icon: FigmaFloatIconType.star,
                  size: 22,
                  delay: Duration.zero,
                ),
                const _FloatingRewardIcon(
                  left: 0.84,
                  top: 0.18,
                  icon: FigmaFloatIconType.heart,
                  size: 20,
                  delay: Duration(milliseconds: 150),
                ),
                const _FloatingRewardIcon(
                  left: 0.08,
                  top: 0.70,
                  icon: FigmaFloatIconType.sparkle,
                  size: 18,
                  delay: Duration(milliseconds: 300),
                ),
                const _FloatingRewardIcon(
                  left: 0.80,
                  top: 0.65,
                  icon: FigmaFloatIconType.star,
                  size: 20,
                  delay: Duration(milliseconds: 100),
                ),
                const _FloatingRewardIcon(
                  left: 0.48,
                  top: 0.12,
                  icon: FigmaFloatIconType.heart,
                  size: 16,
                  delay: Duration(milliseconds: 250),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 460),
                    curve: Curves.easeOutBack,
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value.clamp(0, 1).toDouble(),
                        child: Transform.translate(
                          offset: Offset(0, (1 - value) * 40),
                          child: Transform.scale(
                            scale: 0.5 + value * 0.5,
                            child: child,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 340),
                      padding: const EdgeInsets.fromLTRB(34, 30, 34, 28),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(
                          color: widget.accentColor,
                          width: 5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: widget.borderColor,
                            blurRadius: 0,
                            offset: const Offset(8, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  widget.accentColor,
                                  widget.borderColor,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(999),
                              boxShadow: [
                                BoxShadow(
                                  color: widget.borderColor,
                                  blurRadius: 0,
                                  offset: const Offset(4, 4),
                                ),
                              ],
                            ),
                            child: Text(
                              '第 ${widget.level} 关 通过！',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 8,
                            runSpacing: 8,
                            children: List.generate(widget.totalRounds, (i) {
                              final earned = i < widget.stars;
                              return KidDelayedReveal(
                                delay: Duration(milliseconds: 300 + i * 80),
                                beginScale: 0,
                                beginRotation: -0.35,
                                child: Opacity(
                                  opacity: earned ? 1 : 0.22,
                                  child: FigmaFloatIcon(
                                    type: FigmaFloatIconType.star,
                                    size: earned ? 34 : 28,
                                  ),
                                ),
                              );
                            }),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            '继续加油！',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: widget.accentColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '还有 $remaining 关',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF9E9E9E),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(18),
                              onTap: _continue,
                              child: Ink(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 30,
                                  vertical: 13,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      widget.accentColor,
                                      widget.borderColor,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: widget.borderColor,
                                    width: 3,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: widget.borderColor,
                                      blurRadius: 0,
                                      offset: const Offset(4, 4),
                                    ),
                                  ],
                                ),
                                child: const Text(
                                  '下一关 →',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
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
      ),
    );
  }
}

class _FloatingRewardIcon extends StatelessWidget {
  const _FloatingRewardIcon({
    required this.left,
    required this.top,
    required this.icon,
    required this.size,
    required this.delay,
  });

  final double left;
  final double top;
  final FigmaFloatIconType icon;
  final double size;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: MediaQuery.sizeOf(context).width * left,
      top: MediaQuery.sizeOf(context).height * top,
      child: KidLoopAnimation(
        delay: delay,
        duration: const Duration(seconds: 2),
        builder: (context, value, child) {
          final y = wave(value) * -10;
          return Transform.translate(
            offset: Offset(0, y),
            child: Opacity(opacity: value.clamp(0, 1), child: child),
          );
        },
        child: FigmaFloatIcon(type: icon, size: size),
      ),
    );
  }
}
