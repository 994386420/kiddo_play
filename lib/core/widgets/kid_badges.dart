import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../progress_insights.dart';
import 'figma_home_icons.dart';
import 'kid_motion.dart';

class KidStarCounterBadge extends StatelessWidget {
  const KidStarCounterBadge({
    required this.count,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    this.iconSize = 22,
    this.textSize = 20,
    super.key,
  });

  final int count;
  final EdgeInsetsGeometry padding;
  final double iconSize;
  final double textSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: const Color(0xFFFFD93D),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFF4B400), width: 3),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF4B400).withValues(alpha: 0.26),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: iconSize + 4,
            height: iconSize + 4,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.star_rounded,
                  size: iconSize + 3,
                  color: const Color(0xFFF4A200),
                ),
                Icon(
                  Icons.star_rounded,
                  size: iconSize,
                  color: const Color(0xFFFFD54F),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '$count',
            style: TextStyle(
              fontSize: textSize,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF854D0E),
            ),
          ),
        ],
      ),
    );
  }
}

class KidBadgeSummaryCard extends StatelessWidget {
  const KidBadgeSummaryCard({
    required this.unlockedAchievements,
    required this.onTap,
    this.title,
    super.key,
  });

  final Set<KidAchievementId> unlockedAchievements;
  final VoidCallback onTap;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final label = title ?? kidBadgeWallTitle(context);

    return Material(
      color: const Color(0xFFFFF9C4),
      borderRadius: BorderRadius.circular(28),
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0xFFFFD93D), width: 2.5),
          ),
          child: Row(
            children: [
              const FigmaTrophyIcon(size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.baloo2(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        height: 1,
                        color: const Color(0xFF7B5800),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      kidBadgeProgressText(
                        context,
                        unlockedAchievements.length,
                        kidAchievements.length,
                      ),
                      style: GoogleFonts.baloo2(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                        color: const Color(0xFF9E9E9E),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final achievement in kidAchievements.take(4))
                    Padding(
                      padding: const EdgeInsets.only(left: 2),
                      child: _BadgePreviewIcon(
                        achievementId: achievement.id,
                        unlocked: unlockedAchievements.contains(achievement.id),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 6),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFFF9A825),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class KidBadgeWallSheet extends StatelessWidget {
  const KidBadgeWallSheet({
    required this.unlockedAchievements,
    this.title,
    super.key,
  });

  final Set<KidAchievementId> unlockedAchievements;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.sizeOf(context);
    final label = title ?? kidBadgeWallTitle(context);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 430,
              maxHeight: media.height * 0.86,
            ),
            child: Container(
              width: double.infinity,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFFFF9E6), Colors.white, Colors.white],
                  stops: [0, 0.3, 1],
                ),
                borderRadius: BorderRadius.circular(32),
                border: const Border(
                  top: BorderSide(color: Color(0xFFFFD93D), width: 3),
                  left: BorderSide(color: Color(0xFFFFD93D), width: 3),
                  right: BorderSide(color: Color(0xFFFFD93D), width: 3),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0E0E0),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                label,
                                style: GoogleFonts.baloo2(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  height: 1,
                                  color: const Color(0xFFB45309),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                kidBadgeProgressText(
                                  context,
                                  unlockedAchievements.length,
                                  kidAchievements.length,
                                ),
                                style: GoogleFonts.baloo2(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  height: 1.2,
                                  color: const Color(0xFF9E9E9E),
                                ),
                              ),
                            ],
                          ),
                        ),
                        _KidBadgeCloseButton(
                          onTap: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      height: 10,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: const Color(0xFFFFD93D),
                          width: 2,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: TweenAnimationBuilder<double>(
                          tween: Tween<double>(
                            begin: 0,
                            end: kidAchievements.isEmpty
                                ? 0
                                : unlockedAchievements.length /
                                    kidAchievements.length,
                          ),
                          duration: const Duration(milliseconds: 900),
                          curve: Curves.easeOut,
                          builder: (context, value, child) {
                            return Align(
                              alignment: Alignment.centerLeft,
                              child: FractionallySizedBox(
                                widthFactor: value,
                                child: child,
                              ),
                            );
                          },
                          child: Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color(0xFFFFD93D),
                                  Color(0xFFF4A200),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: GridView.builder(
                        padding: const EdgeInsets.only(bottom: 12),
                        itemCount: kidAchievements.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 1.24,
                        ),
                        itemBuilder: (context, index) {
                          final achievement = kidAchievements[index];
                          return KidDelayedReveal(
                            delay: Duration(milliseconds: 50 * index),
                            beginScale: 0.88,
                            child: KidBadgeTile(
                              achievement: achievement,
                              unlocked:
                                  unlockedAchievements.contains(achievement.id),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class KidBadgeTile extends StatelessWidget {
  const KidBadgeTile({
    required this.achievement,
    required this.unlocked,
    super.key,
  });

  final KidAchievement achievement;
  final bool unlocked;

  @override
  Widget build(BuildContext context) {
    final accentColor = Color(achievement.color);

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        color:
            unlocked ? Color(achievement.background) : const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: unlocked
              ? accentColor.withValues(alpha: 0.33)
              : const Color(0xFFE0E0E0),
          width: 2.5,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (unlocked)
            Positioned(
              top: -16,
              left: 0,
              right: 0,
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      accentColor.withValues(alpha: 0.53),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ColorFiltered(
                      colorFilter: unlocked
                          ? const ColorFilter.mode(
                              Colors.transparent,
                              BlendMode.srcOver,
                            )
                          : const ColorFilter.matrix(_greyMatrix),
                      child: Opacity(
                        opacity: unlocked ? 1 : 0.35,
                        child: kidAchievementIcon(achievement.id, 36),
                      ),
                    ),
                    if (!unlocked)
                      const Positioned(
                        right: -4,
                        bottom: -2,
                        child: FigmaLockIcon(size: 16),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  achievement.name,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.baloo2(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    height: 1,
                    color: unlocked ? accentColor : const Color(0xFF9E9E9E),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  achievement.description,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: GoogleFonts.baloo2(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                    color: unlocked
                        ? const Color(0xFF78909C)
                        : const Color(0xFFBDBDBD),
                  ),
                ),
                if (unlocked) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 1.5,
                    ),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.13),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: accentColor.withValues(alpha: 0.33),
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      kidBadgeEarnedText(context),
                      style: GoogleFonts.baloo2(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        height: 1,
                        color: accentColor,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BadgePreviewIcon extends StatelessWidget {
  const _BadgePreviewIcon({
    required this.achievementId,
    required this.unlocked,
  });

  final KidAchievementId achievementId;
  final bool unlocked;

  @override
  Widget build(BuildContext context) {
    final child = kidAchievementIcon(achievementId, 20);
    if (unlocked) {
      return child;
    }

    return ColorFiltered(
      colorFilter: const ColorFilter.matrix(_greyMatrix),
      child: Opacity(
        opacity: 0.3,
        child: child,
      ),
    );
  }
}

class _KidBadgeCloseButton extends StatefulWidget {
  const _KidBadgeCloseButton({required this.onTap});

  final VoidCallback onTap;

  @override
  State<_KidBadgeCloseButton> createState() => _KidBadgeCloseButtonState();
}

class _KidBadgeCloseButtonState extends State<_KidBadgeCloseButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.9 : 1,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFE0E0E0), width: 2),
          ),
          alignment: Alignment.center,
          child: const Icon(
            Icons.close_rounded,
            size: 20,
            color: Color(0xFF546E7A),
          ),
        ),
      ),
    );
  }
}

Widget kidAchievementIcon(KidAchievementId id, double size) {
  return switch (id) {
    KidAchievementId.firstGame => FigmaGameGridIcon(size: size),
    KidAchievementId.firstPerfect => FigmaSparkleStarIcon(size: size),
    KidAchievementId.stars50 => FigmaFloatIcon(
        type: FigmaFloatIconType.star,
        size: size,
      ),
    KidAchievementId.stars100 => FigmaFloatIcon(
        type: FigmaFloatIconType.sparkle,
        size: size,
      ),
    KidAchievementId.allGamesPlayed => FigmaRainbowIcon(size: size),
    KidAchievementId.allUnlocked => FigmaTrophyIcon(size: size),
    KidAchievementId.hardPerfect => FigmaTargetIcon(size: size),
    KidAchievementId.streak7 => FigmaFloatIcon(
        type: FigmaFloatIconType.fire,
        size: size,
      ),
  };
}

String kidBadgeWallTitle(BuildContext context) {
  return switch (Localizations.localeOf(context).languageCode) {
    'zh' => '我的徽章',
    'ko' => '내 배지',
    _ => 'My Badges',
  };
}

String kidBadgeProgressText(BuildContext context, int unlocked, int total) {
  return switch (Localizations.localeOf(context).languageCode) {
    'zh' => '已解锁 $unlocked / $total 个',
    'ko' => '$total개 중 $unlocked개 해제',
    _ => 'Unlocked $unlocked / $total',
  };
}

String kidBadgeEarnedText(BuildContext context) {
  return switch (Localizations.localeOf(context).languageCode) {
    'zh' => '已获得 ✓',
    'ko' => '획득 ✓',
    _ => 'Earned ✓',
  };
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
