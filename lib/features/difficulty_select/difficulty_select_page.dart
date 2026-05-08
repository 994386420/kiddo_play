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
    _timer = Timer(const Duration(milliseconds: 600), () {
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
  int _replayEpoch = 0;
  ModalRoute<dynamic>? _route;

  bool get _isReplaying => _replayEpoch > 0;

  void _handleBack() {
    AppRouter.pushBackwardAndRemoveUntil(
      context,
      name: AppRoutes.gameSelect,
      predicate: (route) => route.settings.name == AppRoutes.home,
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
    final gameId = widget.args.gameId;
    final viewModel = ref.watch(difficultySelectViewModelProvider(gameId));
    final parentData = ref.watch(parentDataProvider);

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
              colors: [Color(0xFFE8F5FF), Color(0xFFFFF9E6)],
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
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            gradient: gameId.gradient,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: gameId.borderColor,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    gameId.borderColor.withValues(alpha: 0.2),
                                blurRadius: 14,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Text(
                                gameId.emoji,
                                style: const TextStyle(fontSize: 28),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  gameId.title(l10n),
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    shadows: [
                                      Shadow(
                                        color: Color(0x33000000),
                                        blurRadius: 4,
                                        offset: Offset(0, 1),
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
                const SizedBox(height: 28),
                KidDelayedReveal(
                  delay: const Duration(milliseconds: 80),
                  beginOffset: const Offset(0, -0.05),
                  child: Column(
                    children: [
                      Text(
                        l10n.difficultySelectTitle,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1A6FB0),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.difficultySelectSubtitle,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF78909C),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                for (final entry in [
                  (GameDifficulty.easy, 0),
                  (GameDifficulty.medium, 1),
                  (GameDifficulty.hard, 2),
                ]) ...[
                  Builder(
                    builder: (context) {
                      final difficulty = entry.$1;
                      final unlocked = parentData.isDifficultyUnlocked(
                        gameId: gameId,
                        difficulty: difficulty,
                      );
                      final nextToUnlock = parentData.isDifficultyNextToUnlock(
                        gameId: gameId,
                        difficulty: difficulty,
                      );

                      return KidDelayedReveal(
                        key: ValueKey(
                          'difficulty-card-$_replayEpoch-${difficulty.name}',
                        ),
                        delay: _isReplaying
                            ? Duration.zero
                            : Duration(milliseconds: entry.$2 * 100 + 140),
                        duration: _isReplaying
                            ? const Duration(milliseconds: 220)
                            : const Duration(milliseconds: 420),
                        beginOffset: const Offset(-0.08, 0),
                        child: _ShakingCard(
                          active: viewModel.lockedHintDifficulty == difficulty,
                          child: _DifficultyCard(
                            difficulty: difficulty,
                            unlocked: unlocked,
                            nextToUnlock: nextToUnlock,
                            showLockedHint:
                                viewModel.lockedHintDifficulty == difficulty,
                            onTap: () {
                              if (unlocked) {
                                Navigator.pushNamed(
                                  context,
                                  gameId.routeName,
                                  arguments: viewModel.buildArgs(difficulty),
                                );
                              } else {
                                ref
                                    .read(
                                      difficultySelectViewModelProvider(gameId),
                                    )
                                    .showLockedHint(difficulty);
                              }
                            },
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 18),
                ],
                KidDelayedReveal(
                  delay: const Duration(milliseconds: 520),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFFFD93D),
                        width: 2,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('⭐', style: TextStyle(fontSize: 24)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            l10n.difficultySelectHint,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF7B5800),
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
      ),
    );
  }
}

class _DifficultyCard extends StatelessWidget {
  const _DifficultyCard({
    required this.difficulty,
    required this.unlocked,
    required this.nextToUnlock,
    required this.showLockedHint,
    required this.onTap,
  });

  final GameDifficulty difficulty;
  final bool unlocked;
  final bool nextToUnlock;
  final bool showLockedHint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final config = difficulty.config;

    final style = switch (difficulty) {
      GameDifficulty.easy => const (
          gradient:
              LinearGradient(colors: [Color(0xFFC8E6C9), Color(0xFF81C784)]),
          border: Color(0xFF388E3C),
          text: Colors.white,
          shadow: Color(0xFF2E7D32),
        ),
      GameDifficulty.medium => const (
          gradient:
              LinearGradient(colors: [Color(0xFFFFF176), Color(0xFFFFD600)]),
          border: Color(0xFFF9A825),
          text: Color(0xFF7B5800),
          shadow: Color(0xFFF57F17),
        ),
      GameDifficulty.hard => const (
          gradient:
              LinearGradient(colors: [Color(0xFFFFAB91), Color(0xFFE64A19)]),
          border: Color(0xFFBF360C),
          text: Colors.white,
          shadow: Color(0xFF7F2800),
        ),
    };

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
                    ? style.gradient
                    : const LinearGradient(
                        colors: [Color(0xFFECEFF1), Color(0xFFCFD8DC)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: unlocked ? style.border : const Color(0xFFB0BEC5),
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (unlocked ? style.border : const Color(0xFFB0BEC5))
                        .withValues(alpha: unlocked ? 0.24 : 0.12),
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
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(24),
                          ),
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 18,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: unlocked
                                ? Colors.white.withValues(alpha: 0.3)
                                : Colors.black.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: Text(
                            difficulty.badgeEmoji,
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
                                    difficulty.label(l10n),
                                    style: TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w900,
                                      color: unlocked
                                          ? style.text
                                          : const Color(0xFF78909C),
                                      shadows: unlocked
                                          ? [
                                              Shadow(
                                                color: style.shadow.withValues(
                                                  alpha: 0.35,
                                                ),
                                                blurRadius: 4,
                                                offset: const Offset(0, 1),
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
                                        ? Colors.white.withValues(alpha: 0.35)
                                        : nextToUnlock
                                            ? const Color(0xFFFFF9C4)
                                            : const Color(0xFFB0BEC5),
                                    foreground: unlocked
                                        ? style.text
                                        : nextToUnlock
                                            ? const Color(0xFFF57F17)
                                            : Colors.white,
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: unlocked
                                          ? Colors.white.withValues(alpha: 0.35)
                                          : Colors.white
                                              .withValues(alpha: 0.74),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      '${config.optionCount}${l10n.difficultyOptionCountSuffix} · ${config.rounds}${l10n.difficultyRoundCountSuffix}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        color: unlocked
                                            ? style.text
                                            : const Color(0xFF78909C),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                unlocked
                                    ? difficulty.description(l10n)
                                    : l10n.difficultySelectLockedDescription,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: unlocked
                                      ? style.text.withValues(alpha: 0.88)
                                      : const Color(0xFF90A4AE),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        unlocked
                            ? Container(
                                width: 36,
                                height: 36,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.28),
                                  shape: BoxShape.circle,
                                ),
                                child: RotatedBox(
                                  quarterTurns: 2,
                                  child: Text(
                                    '‹',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900,
                                      color: style.text.withValues(alpha: 0.9),
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
                  key: ValueKey(difficulty),
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
                          l10n.difficultySelectLockedHint,
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
