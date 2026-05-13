import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/localization.dart';
import '../../app/route_args.dart';
import '../../app/router.dart';
import '../../core/app_controllers.dart';
import '../../core/game_models.dart';
import '../../core/widgets/kid_badges.dart';
import '../../core/widgets/kid_button.dart';
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

  return HomeViewModel(
    totalStars: progress.totalStars,
    childName: parentData.childName,
    childAvatar: parentData.childAvatar,
    quickStartGameId: quickStartGameId,
    hasRecentGame:
        lastPlayedGameId != null && quickStartGameId == lastPlayedGameId,
  );
});

class HomeViewModel {
  const HomeViewModel({
    required this.totalStars,
    required this.childName,
    required this.childAvatar,
    required this.quickStartGameId,
    required this.hasRecentGame,
  });

  final int totalStars;
  final String childName;
  final String childAvatar;
  final GameId quickStartGameId;
  final bool hasRecentGame;
}

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  static const _primaryButtonGap = 24.0;
  static const _parentButtonGap = 26.0;

  String _quickStartLabel(BuildContext context, HomeViewModel viewModel) {
    if (!viewModel.hasRecentGame) {
      return context.l10n.homeStartGame;
    }

    final prefix = switch (Localizations.localeOf(context).languageCode) {
      'zh' => '继续：',
      'ko' => '계속: ',
      _ => 'Continue: ',
    };
    final gameId = viewModel.quickStartGameId;
    return '$prefix${gameId.emoji} ${gameId.title(context.l10n)}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final viewModel = ref.watch(homeViewModelProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF2F2C2C),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = MediaQuery.sizeOf(context).width;
          final isWidePreview = screenWidth >= 560;
          final framePadding = isWidePreview
              ? const EdgeInsets.symmetric(horizontal: 20, vertical: 18)
              : EdgeInsets.zero;
          final canvasWidth = isWidePreview
              ? (constraints.maxWidth - (framePadding.horizontal))
                  .clamp(0.0, 620.0)
              : constraints.maxWidth;
          final canvasHeight = constraints.maxHeight - framePadding.vertical;
          final contentMaxWidth = isWidePreview ? 560.0 : 430.0;
          final buttonMaxWidth = isWidePreview ? 500.0 : 390.0;
          final welcomeCardMaxWidth = isWidePreview ? 380.0 : 340.0;
          final shellRadius = isWidePreview ? 42.0 : 0.0;
          final shellPadding = isWidePreview
              ? const EdgeInsets.fromLTRB(34, 28, 34, 36)
              : const EdgeInsets.fromLTRB(24, 20, 24, 32);

          return Padding(
            padding: framePadding,
            child: Center(
              child: SizedBox(
                width: canvasWidth,
                height: canvasHeight,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(shellRadius),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFFE0F4FF), Color(0xFFFFF9E6)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                      const Positioned(
                        top: -60,
                        left: -60,
                        child: _DecorCircle(
                          size: 230,
                          color: Color(0x4D67C9F8),
                        ),
                      ),
                      const Positioned(
                        bottom: -90,
                        right: -90,
                        child: _DecorCircle(
                          size: 300,
                          color: Color(0x33FFB347),
                        ),
                      ),
                      const Positioned(
                        top: 230,
                        right: -55,
                        child: _DecorCircle(
                          size: 150,
                          color: Color(0x33A8E063),
                        ),
                      ),
                      Positioned(
                        bottom: isWidePreview ? 44 : 32,
                        left: isWidePreview ? 34 : 24,
                        child: const Opacity(
                          opacity: 0.34,
                          child: Text('☁️', style: TextStyle(fontSize: 32)),
                        ),
                      ),
                      Positioned(
                        bottom: isWidePreview ? 86 : 72,
                        right: isWidePreview ? 42 : 32,
                        child: const Opacity(
                          opacity: 0.26,
                          child: Text('☁️', style: TextStyle(fontSize: 24)),
                        ),
                      ),
                      SafeArea(
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: SingleChildScrollView(
                            padding: shellPadding,
                            child: ConstrainedBox(
                              constraints:
                                  BoxConstraints(maxWidth: contentMaxWidth),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: KidDelayedReveal(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                l10n.homeTitle,
                                                style: const TextStyle(
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.w900,
                                                  color: Color(0xFF1A6FB0),
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                l10n.homeGreeting(
                                                  viewModel.childName,
                                                ),
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xFF5BA4CF),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      KidDelayedReveal(
                                        delay: const Duration(milliseconds: 80),
                                        beginOffset: const Offset(0.06, -0.05),
                                        child: KidStarCounterBadge(
                                          count: viewModel.totalStars,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 8,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 18),
                                  KidDelayedReveal(
                                    delay: const Duration(milliseconds: 120),
                                    beginOffset: const Offset(0, 0.08),
                                    child: _HeroSection(
                                      childName: viewModel.childName,
                                      childAvatar: viewModel.childAvatar,
                                      cardMaxWidth: welcomeCardMaxWidth,
                                    ),
                                  ),
                                  const SizedBox(height: 34),
                                  Center(
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                        maxWidth: buttonMaxWidth,
                                      ),
                                      child: Column(
                                        children: [
                                          KidDelayedReveal(
                                            delay: const Duration(
                                              milliseconds: 260,
                                            ),
                                            child: KidPrimaryButton(
                                              label: _quickStartLabel(
                                                context,
                                                viewModel,
                                              ),
                                              icon: viewModel.hasRecentGame
                                                  ? null
                                                  : '🎮',
                                              gradient: const LinearGradient(
                                                colors: [
                                                  Color(0xFF4FC3F7),
                                                  Color(0xFF1976D2),
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                              borderColor:
                                                  const Color(0xFF0D47A1),
                                              radius: 30,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                vertical: 20,
                                              ),
                                              onPressed: () {
                                                Navigator.pushNamed(
                                                  context,
                                                  AppRoutes.difficulty,
                                                  arguments:
                                                      DifficultyRouteArgs(
                                                    gameId: viewModel
                                                        .quickStartGameId,
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                          const SizedBox(
                                            height: _primaryButtonGap,
                                          ),
                                          KidDelayedReveal(
                                            delay: const Duration(
                                              milliseconds: 360,
                                            ),
                                            child: KidPrimaryButton(
                                              label: l10n.homeChooseGame,
                                              icon: '🗂️',
                                              gradient: const LinearGradient(
                                                colors: [
                                                  Color(0xFFFFD93D),
                                                  Color(0xFFF4A200),
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                              borderColor:
                                                  const Color(0xFFB77B00),
                                              radius: 28,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                vertical: 17,
                                              ),
                                              onPressed: () {
                                                Navigator.pushNamed(
                                                  context,
                                                  AppRoutes.gameSelect,
                                                );
                                              },
                                            ),
                                          ),
                                          const SizedBox(
                                            height: _parentButtonGap,
                                          ),
                                          KidDelayedReveal(
                                            delay: const Duration(
                                              milliseconds: 460,
                                            ),
                                            child: _ParentCenterButton(
                                              label: l10n.homeParentEntry,
                                              secureLabel:
                                                  l10n.homeParentProtected,
                                              onTap: () {
                                                Navigator.pushNamed(
                                                  context,
                                                  AppRoutes.parentPin,
                                                );
                                              },
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
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({
    required this.childName,
    required this.childAvatar,
    required this.cardMaxWidth,
  });

  final String childName;
  final String childAvatar;
  final double cardMaxWidth;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      children: [
        KidLoopAnimation(
          duration: const Duration(seconds: 3),
          builder: (context, value, child) {
            final dy = lerpValue(0, -10, value);
            return Transform.translate(
              offset: Offset(0, dy),
              child: child,
            );
          },
          child: Text(
            childAvatar,
            style: const TextStyle(fontSize: 100),
          ),
        ),
        const SizedBox(height: 2),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (final entry in [
              ('🌸', 0),
              ('⭐', 1),
              ('🎈', 2),
              ('⭐', 3),
              ('🌸', 4),
            ]) ...[
              KidLoopAnimation(
                delay: Duration(milliseconds: entry.$2 * 250),
                duration: const Duration(milliseconds: 1500),
                builder: (context, value, child) {
                  final scale = lerpValue(1, 1.3, value);
                  return Transform.scale(scale: scale, child: child);
                },
                child: Text(
                  entry.$1,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
              if (entry.$2 != 4) const SizedBox(width: 10),
            ],
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          constraints: BoxConstraints(maxWidth: cardMaxWidth),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: const Color(0xFF67C9F8), width: 3),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF67C9F8).withValues(alpha: 0.18),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                l10n.homeWelcomeTitle(childName),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A6FB0),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.homeWelcomeSubtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF5BA4CF),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DecorCircle extends StatelessWidget {
  const _DecorCircle({
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
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _ParentCenterButton extends StatelessWidget {
  const _ParentCenterButton({
    required this.label,
    required this.secureLabel,
    required this.onTap,
  });

  final String label;
  final String secureLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: const Color(0xFFCE93D8), width: 2.5),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFCE93D8).withValues(alpha: 0.16),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(28),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F3FF),
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(
                        color: const Color(0xFFE1DAF8),
                        width: 1.5,
                      ),
                    ),
                    child: const Icon(
                      Icons.groups_2_rounded,
                      size: 21,
                      color: Color(0xFF7E57C2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF7B1FA2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDE7F6),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '🔒 $secureLabel',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF7B1FA2),
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
