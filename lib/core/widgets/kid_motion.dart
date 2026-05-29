import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

class KidDelayedReveal extends StatefulWidget {
  const KidDelayedReveal({
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 420),
    this.beginOffset = const Offset(0, 0.05),
    this.beginScale = 0.96,
    this.beginRotation = 0,
    this.alignment = Alignment.center,
    this.curve = Curves.easeOutCubic,
    super.key,
  });

  final Widget child;
  final Duration delay;
  final Duration duration;
  final Offset beginOffset;
  final double beginScale;
  final double beginRotation;
  final Alignment alignment;
  final Curve curve;

  @override
  State<KidDelayedReveal> createState() => _KidDelayedRevealState();
}

class _KidDelayedRevealState extends State<KidDelayedReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      _timer = Timer(widget.delay, () {
        if (mounted) {
          _controller.forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final animation = CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    );

    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: widget.beginOffset,
          end: Offset.zero,
        ).animate(animation),
        child: RotationTransition(
          turns: Tween<double>(
            begin: widget.beginRotation / (math.pi * 2),
            end: 0,
          ).animate(animation),
          alignment: widget.alignment,
          child: ScaleTransition(
            scale: Tween<double>(
              begin: widget.beginScale,
              end: 1,
            ).animate(animation),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

class KidLoopAnimation extends StatefulWidget {
  const KidLoopAnimation({
    required this.builder,
    this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(seconds: 2),
    this.reverse = true,
    this.curve = Curves.easeInOut,
    super.key,
  });

  final Widget? child;
  final Widget Function(BuildContext context, double value, Widget? child)
      builder;
  final Duration delay;
  final Duration duration;
  final bool reverse;
  final Curve curve;

  @override
  State<KidLoopAnimation> createState() => _KidLoopAnimationState();
}

class _KidLoopAnimationState extends State<KidLoopAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _timer = Timer(widget.delay, () {
      if (mounted) {
        _controller.repeat(reverse: widget.reverse);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final animation = CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return widget.builder(context, animation.value, child);
      },
      child: widget.child,
    );
  }
}

class KidRoundSwitcher extends StatelessWidget {
  const KidRoundSwitcher({
    required this.switchKey,
    required this.child,
    this.duration = const Duration(milliseconds: 450),
    super.key,
  });

  final Object switchKey;
  final Widget child;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      layoutBuilder: (currentChild, previousChildren) {
        return Stack(
          alignment: Alignment.topCenter,
          children: [
            ...previousChildren,
            if (currentChild != null) currentChild,
          ],
        );
      },
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
              begin: const Offset(0, 0.06),
              end: Offset.zero,
            ).animate(curved),
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.9, end: 1).animate(curved),
              child: child,
            ),
          ),
        );
      },
      child: KeyedSubtree(
        key: ValueKey(switchKey),
        child: child,
      ),
    );
  }
}

class KidAnimatedProgressBar extends StatelessWidget {
  const KidAnimatedProgressBar({
    required this.value,
    required this.backgroundColor,
    required this.borderColor,
    required this.gradient,
    this.height = 12,
    super.key,
  });

  final double value;
  final Color backgroundColor;
  final Color borderColor;
  final Gradient gradient;
  final double height;

  @override
  Widget build(BuildContext context) {
    final clampedValue = value.clamp(0.0, 1.0).toDouble();

    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: borderColor, width: 2),
        ),
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(end: clampedValue),
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutCubic,
          builder: (context, animatedValue, child) {
            return Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: animatedValue,
                heightFactor: 1,
                child: child,
              ),
            );
          },
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(999),
            ),
            child: const SizedBox.expand(),
          ),
        ),
      ),
    );
  }
}

double lerpValue(double begin, double end, double t) {
  return begin + (end - begin) * t;
}

double wave(double value, {double min = -1, double max = 1}) {
  final radians = value * math.pi * 2;
  final normalized = math.sin(radians);
  return lerpValue(min, max, (normalized + 1) / 2);
}

double shakeOffset(double value, {double amplitude = 12, int shakes = 5}) {
  final dampened = (1 - value).clamp(0.0, 1.0).toDouble();
  return math.sin(value * math.pi * shakes) * amplitude * dampened;
}

double punchScale(double value, {double amount = 0.12}) {
  return 1 + math.sin(value * math.pi) * amount;
}
