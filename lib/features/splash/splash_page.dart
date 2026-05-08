import 'dart:async';

import 'package:flutter/material.dart';

import '../../app/localization.dart';
import '../../app/router.dart';
import '../../core/widgets/kid_motion.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 2800), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/branding/splash_background.png',
            fit: BoxFit.cover,
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withValues(alpha: 0.06),
                  Colors.white.withValues(alpha: 0.02),
                  const Color(0xCCFFFFFF),
                ],
                stops: const [0, 0.55, 1],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 36),
              child: Column(
                children: [
                  const Spacer(),
                  KidDelayedReveal(
                    duration: const Duration(milliseconds: 800),
                    beginOffset: const Offset(0, 0.08),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 18,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.84),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: const Color(0x66FFFFFF),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0x1F2F80ED),
                            blurRadius: 30,
                            offset: const Offset(0, 14),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            l10n.homeTitle,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF1967B3),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.splashSubtitle,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF5F7291),
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  KidDelayedReveal(
                    delay: const Duration(milliseconds: 500),
                    beginScale: 0.9,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        _LoadingDot(delayMs: 0),
                        SizedBox(width: 8),
                        _LoadingDot(delayMs: 180),
                        SizedBox(width: 8),
                        _LoadingDot(delayMs: 360),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingDot extends StatelessWidget {
  const _LoadingDot({required this.delayMs});

  final int delayMs;

  @override
  Widget build(BuildContext context) {
    return KidLoopAnimation(
      delay: Duration(milliseconds: delayMs),
      duration: const Duration(milliseconds: 900),
      builder: (context, value, child) {
        final scale = lerpValue(0.9, 1.35, value);
        final opacity = lerpValue(0.45, 1, value);
        return Opacity(
          opacity: opacity,
          child: Transform.scale(scale: scale, child: child),
        );
      },
      child: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: const Color(0xFF2F80ED).withValues(alpha: 0.82),
          shape: BoxShape.circle,
          boxShadow: const [
            BoxShadow(
              color: Color(0x332F80ED),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
      ),
    );
  }
}
