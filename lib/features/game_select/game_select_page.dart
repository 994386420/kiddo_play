import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/localization.dart';
import '../../app/route_args.dart';
import '../../app/router.dart';
import '../../core/app_controllers.dart';
import '../../core/game_models.dart';
import '../../core/widgets/kid_motion.dart';
import '../../core/widgets/round_back_button.dart';

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
    _timer = Timer(const Duration(milliseconds: 600), () {
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
  int _replayEpoch = 0;
  ModalRoute<dynamic>? _route;

  bool get _isReplaying => _replayEpoch > 0;

  void _handleBack() {
    AppRouter.pushBackwardAndRemoveUntil(
      context,
      name: AppRoutes.home,
      predicate: (_) => false,
    );
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
    final l10n = context.l10n;
    final progress = ref.watch(gameProgressProvider);
    final viewModel = ref.watch(gameSelectViewModelProvider);

    return PopScope<void>(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        final route = ModalRoute.of(context);
        if (didPop || route?.isCurrent != true) {
          return;
        }
        _handleBack();
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFE0F4FF), Color(0xFFFFF9E6)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
              children: [
                KidDelayedReveal(
                  child: Row(
                    children: [
                      KidRoundBackButton(
                        iconColor: const Color(0xFF1976D2),
                        onTap: _handleBack,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.gameSelectTitle,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF1A6FB0),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              l10n.gameSelectSubtitle,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF5BA4CF),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                for (var index = 0; index < orderedGameIds.length; index++) ...[
                  KidDelayedReveal(
                    key: ValueKey('game-select-card-$_replayEpoch-$index'),
                    delay: _isReplaying
                        ? Duration.zero
                        : Duration(milliseconds: index * 80),
                    duration: _isReplaying
                        ? const Duration(milliseconds: 220)
                        : const Duration(milliseconds: 420),
                    beginOffset: const Offset(-0.08, 0),
                    child: _ShakingCard(
                      active:
                          viewModel.lockedHintGameId == orderedGameIds[index],
                      child: _GameCard(
                        gameId: orderedGameIds[index],
                        unlocked: progress.isUnlocked(orderedGameIds[index]),
                        nextToUnlock:
                            !progress.isUnlocked(orderedGameIds[index]) &&
                                index > 0 &&
                                progress.isUnlocked(orderedGameIds[index - 1]),
                        showLockedHint:
                            viewModel.lockedHintGameId == orderedGameIds[index],
                        onTap: () {
                          final gameId = orderedGameIds[index];
                          if (progress.isUnlocked(gameId)) {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.difficulty,
                              arguments: DifficultyRouteArgs(gameId: gameId),
                            );
                          } else {
                            ref
                                .read(gameSelectViewModelProvider)
                                .showLockedHint(gameId);
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GameCard extends StatelessWidget {
  const _GameCard({
    required this.gameId,
    required this.unlocked,
    required this.nextToUnlock,
    required this.showLockedHint,
    required this.onTap,
  });

  final GameId gameId;
  final bool unlocked;
  final bool nextToUnlock;
  final bool showLockedHint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(30),
            onTap: onTap,
            child: Ink(
              decoration: BoxDecoration(
                gradient: unlocked
                    ? gameId.gradient as LinearGradient
                    : const LinearGradient(
                        colors: [Color(0xFFECEFF1), Color(0xFFCFD8DC)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color:
                      unlocked ? gameId.borderColor : const Color(0xFFB0BEC5),
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (unlocked
                            ? gameId.borderColor
                            : const Color(0xFFB0BEC5))
                        .withValues(alpha: unlocked ? 0.22 : 0.12),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  if (unlocked)
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.14),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(26),
                          ),
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: unlocked
                                ? Colors.white.withValues(alpha: 0.28)
                                : Colors.black.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: Text(
                            gameId.emoji,
                            style: TextStyle(
                              fontSize: 36,
                              color: unlocked ? null : Colors.grey.shade500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Text(
                                    gameId.title(l10n),
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900,
                                      color: unlocked
                                          ? Colors.white
                                          : const Color(0xFF78909C),
                                      shadows: unlocked
                                          ? const [
                                              Shadow(
                                                color: Color(0x33000000),
                                                blurRadius: 3,
                                                offset: Offset(0, 1),
                                              ),
                                            ]
                                          : null,
                                    ),
                                  ),
                                  _StatusBadge(
                                    label: unlocked
                                        ? l10n.gameSelectUnlocked
                                        : nextToUnlock
                                            ? l10n.gameSelectUnlockSoon
                                            : l10n.gameSelectLocked,
                                    background: unlocked
                                        ? Colors.white.withValues(alpha: 0.3)
                                        : nextToUnlock
                                            ? const Color(0xFFFFF9C4)
                                            : const Color(0xFFB0BEC5),
                                    foreground: unlocked
                                        ? Colors.white
                                        : nextToUnlock
                                            ? const Color(0xFFF57F17)
                                            : Colors.white,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                unlocked
                                    ? gameId.description(l10n)
                                    : l10n.gameSelectLockedDescription,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: unlocked
                                      ? Colors.white.withValues(alpha: 0.88)
                                      : const Color(0xFF90A4AE),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        unlocked
                            ? Container(
                                width: 36,
                                height: 36,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.25),
                                  shape: BoxShape.circle,
                                ),
                                child: const RotatedBox(
                                  quarterTurns: 2,
                                  child: Text(
                                    '‹',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              )
                            : const Text(
                                '🔒',
                                style: TextStyle(fontSize: 28),
                              ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: SizeTransition(
                sizeFactor: animation,
                axisAlignment: -1,
                child: child,
              ),
            );
          },
          child: !showLockedHint
              ? const SizedBox.shrink()
              : Container(
                  key: ValueKey(gameId),
                  margin: const EdgeInsets.only(top: 10),
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: const Color(0xFFFF8C42),
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Text('💪', style: TextStyle(fontSize: 18)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n.gameSelectLockedHint,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFE65100),
                          ),
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

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.label,
    required this.background,
    required this.foreground,
  });

  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: foreground,
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
      duration: Duration(milliseconds: active ? 400 : 1),
      builder: (context, value, builtChild) {
        final shake = active ? math.sin(value * math.pi * 5) * 10 : 0.0;
        return Transform.translate(
          offset: Offset(shake, 0),
          child: builtChild,
        );
      },
      child: child,
    );
  }
}
