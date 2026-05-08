import 'dart:ui';

import 'package:flutter/material.dart';

import '../../app/localization.dart';
import 'kid_motion.dart';

class PauseDialog extends StatelessWidget {
  const PauseDialog({
    required this.isOpen,
    required this.gameName,
    required this.onContinue,
    required this.onRestart,
    required this.onQuit,
    this.gameEmoji = '🎮',
    super.key,
  });

  final bool isOpen;
  final String gameName;
  final String gameEmoji;
  final VoidCallback onContinue;
  final VoidCallback onRestart;
  final VoidCallback onQuit;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !isOpen,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        opacity: isOpen ? 1 : 0,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onContinue,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: ColoredBox(
              color: const Color(0x85141E33),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(end: isOpen ? 1 : 0),
                    duration: const Duration(milliseconds: 260),
                    curve: Curves.easeOutBack,
                    builder: (context, value, child) {
                      final clampedOpacity = value.clamp(0.0, 1.0).toDouble();
                      return Transform.translate(
                        offset: Offset(0, lerpDouble(24, 0, value) ?? 0),
                        child: Transform.scale(
                          scale: lerpDouble(0.72, 1, value) ?? 1,
                          child: Opacity(
                            opacity: clampedOpacity,
                            child: child,
                          ),
                        ),
                      );
                    },
                    child: GestureDetector(
                      onTap: () {},
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 320),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.22),
                                blurRadius: 28,
                                offset: const Offset(0, 16),
                              ),
                            ],
                          ),
                          foregroundDecoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: const Color(0xFF4FC3F7),
                              width: 4,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.fromLTRB(
                                    24,
                                    28,
                                    24,
                                    18,
                                  ),
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xFFE0F4FF),
                                        Color(0xFFFFF9E6),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      KidLoopAnimation(
                                        duration:
                                            const Duration(milliseconds: 1800),
                                        builder: (context, value, child) {
                                          final turns = lerpDouble(
                                            -0.028,
                                            0.028,
                                            wave(value),
                                          );
                                          return Transform.rotate(
                                            angle: (turns ?? 0) * 3.14159,
                                            child: child,
                                          );
                                        },
                                        child: Text(
                                          gameEmoji,
                                          style: const TextStyle(fontSize: 60),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        gameName,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w900,
                                          color: Color(0xFF1A6FB0),
                                        ),
                                      ),
                                      const SizedBox(height: 14),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFFD93D),
                                          borderRadius:
                                              BorderRadius.circular(999),
                                          border: Border.all(
                                            color: const Color(0xFFF4A200),
                                            width: 2.5,
                                          ),
                                        ),
                                        child: Text(
                                          '⏸️ ${context.l10n.pauseStatus}',
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w900,
                                            color: Color(0xFF854D0E),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    24,
                                    28,
                                    24,
                                    14,
                                  ),
                                  child: Column(
                                    children: [
                                      _PauseButton(
                                        onTap: onContinue,
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFF4FC3F7),
                                            Color(0xFF1976D2),
                                          ],
                                        ),
                                        borderColor: const Color(0xFF0D47A1),
                                        icon: Icons.play_arrow_rounded,
                                        iconColor: Colors.white,
                                        textColor: Colors.white,
                                        label: context.l10n.pauseContinue,
                                        height: 56,
                                      ),
                                      const SizedBox(height: 18),
                                      _PauseButton(
                                        onTap: onRestart,
                                        backgroundColor:
                                            const Color(0xFFFFF3E0),
                                        borderColor: const Color(0xFFFF8C42),
                                        icon: Icons.restart_alt_rounded,
                                        iconColor: const Color(0xFFE64A19),
                                        textColor: const Color(0xFFE64A19),
                                        label: context.l10n.pauseRestart,
                                        height: 52,
                                      ),
                                      const SizedBox(height: 18),
                                      _PauseButton(
                                        onTap: onQuit,
                                        backgroundColor:
                                            const Color(0xFFF5F5F5),
                                        borderColor: const Color(0xFFBDBDBD),
                                        icon: Icons.logout_rounded,
                                        iconColor: const Color(0xFF757575),
                                        textColor: const Color(0xFF757575),
                                        label: context.l10n.pauseQuit,
                                        height: 52,
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(20, 0, 20, 16),
                                  child: Text(
                                    context.l10n.pauseTapOutsideHint,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFFB0BEC5),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PauseButton extends StatelessWidget {
  const _PauseButton({
    required this.onTap,
    required this.borderColor,
    required this.icon,
    required this.iconColor,
    required this.textColor,
    required this.label,
    required this.height,
    this.gradient,
    this.backgroundColor,
  });

  final VoidCallback onTap;
  final Gradient? gradient;
  final Color? backgroundColor;
  final Color borderColor;
  final IconData icon;
  final Color iconColor;
  final Color textColor;
  final String label;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          height: height,
          decoration: BoxDecoration(
            color: backgroundColor,
            gradient: gradient,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
                color: borderColor, width: gradient != null ? 3 : 2.5),
            boxShadow: gradient == null
                ? null
                : [
                    BoxShadow(
                      color: borderColor.withValues(alpha: 0.24),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: iconColor, size: 22),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: gradient != null ? 18 : 17,
                  fontWeight: FontWeight.w900,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
