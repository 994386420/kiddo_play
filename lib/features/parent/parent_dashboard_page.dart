import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/localization.dart';
import '../../app/route_args.dart';
import '../../app/router.dart';
import '../../core/app_controllers.dart';
import '../../core/game_models.dart';
import '../../core/progress_insights.dart';
import '../../core/widgets/kid_badges.dart';
import '../../core/widgets/kid_motion.dart';

enum _ParentTab { overview, progress, settings }

const _avatarOptions = [
  '🦁',
  '🐻',
  '🐼',
  '🦊',
  '🐸',
  '🐷',
  '🐱',
  '🐶',
  '🐰',
  '🐧',
  '🐯',
  '🐨',
];

class ParentDashboardPage extends ConsumerStatefulWidget {
  const ParentDashboardPage({super.key});

  @override
  ConsumerState<ParentDashboardPage> createState() =>
      _ParentDashboardPageState();
}

class _ParentDashboardPageState extends ConsumerState<ParentDashboardPage> {
  _ParentTab _activeTab = _ParentTab.overview;

  void _showBadgeWall() {
    final progress = ref.read(gameProgressProvider);
    final parentData = ref.read(parentDataProvider);
    final unlockedAchievements = deriveUnlockedAchievements(
      totalStars: progress.totalStars,
      unlockedGames: progress.unlockedGames,
      gameStats: parentData.gameStats,
      activityLog: parentData.activityLog,
    );

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      isScrollControlled: true,
      builder: (sheetContext) {
        return KidBadgeWallSheet(
          unlockedAchievements: unlockedAchievements,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final parentData = ref.watch(parentDataProvider);

    return Scaffold(
      body: Container(
        color: const Color(0xFFF8F5FD),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 54, 20, 18),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF7B1FA2), Color(0xFF4A148C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x404A148C),
                    blurRadius: 20,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  _HeaderCircleButton(
                    onTap: () => AppRouter.showHome(context),
                    child: const Icon(
                      Icons.chevron_left_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.parentDashboardHeaderTag,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xB3FFFFFF),
                            letterSpacing: 0.05,
                          ),
                        ),
                        Text(
                          l10n.parentDashboardTitle,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 42,
                    height: 42,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      parentData.childAvatar,
                      style: const TextStyle(fontSize: 26),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              color: Colors.white,
              child: Row(
                children: [
                  for (final tab in _ParentTab.values)
                    Expanded(
                      child: _TabButton(
                        label: switch (tab) {
                          _ParentTab.overview => l10n.parentTabOverview,
                          _ParentTab.progress => l10n.parentTabProgress,
                          _ParentTab.settings => l10n.parentTabSettings,
                        },
                        icon: switch (tab) {
                          _ParentTab.overview => '📊',
                          _ParentTab.progress => '📈',
                          _ParentTab.settings => '⚙️',
                        },
                        active: _activeTab == tab,
                        onTap: () => setState(() => _activeTab = tab),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.04),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: switch (_activeTab) {
                    _ParentTab.overview => _OverviewTab(
                        key: ValueKey('overview'),
                        onShowBadges: _showBadgeWall,
                      ),
                    _ParentTab.progress => const _ProgressTab(
                        key: ValueKey('progress'),
                      ),
                    _ParentTab.settings => const _SettingsTab(
                        key: ValueKey('settings'),
                      ),
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OverviewTab extends ConsumerWidget {
  const _OverviewTab({
    required this.onShowBadges,
    super.key,
  });

  final VoidCallback onShowBadges;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final progress = ref.watch(gameProgressProvider);
    final parentData = ref.watch(parentDataProvider);
    final streak = computeCurrentStreak(parentData.activityLog);
    final weekDays = lastSevenPlayDays(parentData.activityLog);
    final unlockedAchievements = deriveUnlockedAchievements(
      totalStars: progress.totalStars,
      unlockedGames: progress.unlockedGames,
      gameStats: parentData.gameStats,
      activityLog: parentData.activityLog,
    );

    final statsCards = [
      (
        l10n.parentOverviewStars,
        '${progress.totalStars}',
        '⭐',
        const Color(0xFFF9A825),
        const Color(0xFFFFF9C4)
      ),
      (
        l10n.parentOverviewUnlockedGames,
        '${progress.unlockedGames.length}/${orderedGameIds.length}',
        '🔓',
        const Color(0xFF7B1FA2),
        const Color(0xFFF3E5F5),
      ),
      (
        l10n.parentOverviewPlayed,
        '${parentData.totalPlayed}',
        '🎮',
        const Color(0xFF1565C0),
        const Color(0xFFE3F2FD)
      ),
      (
        l10n.parentOverviewTodayStars,
        '${parentData.todayStars}',
        '🌟',
        const Color(0xFFE64A19),
        const Color(0xFFFFF3E0)
      ),
    ];

    final recentEntries = parentData.activityLog.take(6).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        KidDelayedReveal(
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFCE93D8), Color(0xFF7B1FA2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: const Color(0xFF4A148C), width: 3),
            ),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    parentData.childAvatar,
                    style: const TextStyle(fontSize: 40),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.parentOverviewProfileTitle,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xCCFFFFFF),
                        ),
                      ),
                      Text(
                        parentData.childName,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Wrap(
                        spacing: 12,
                        runSpacing: 4,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('⭐', style: TextStyle(fontSize: 16)),
                              const SizedBox(width: 4),
                              Text(
                                l10n.parentOverviewTotalStars(
                                  progress.totalStars,
                                ),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFFFD93D),
                                ),
                              ),
                            ],
                          ),
                          if (streak > 0)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('🔥',
                                    style: TextStyle(fontSize: 15)),
                                const SizedBox(width: 4),
                                Text(
                                  _streakText(context, streak),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFFFFD93D),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        KidDelayedReveal(
          delay: const Duration(milliseconds: 60),
          child: _WeeklyHeatmapCard(
            weekDays: weekDays,
            streak: streak,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: statsCards.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.28,
          ),
          itemBuilder: (context, index) {
            final card = statsCards[index];
            return KidDelayedReveal(
              delay: Duration(milliseconds: 70 * index),
              child: Container(
                decoration: BoxDecoration(
                  color: card.$5,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: card.$4.withValues(alpha: 0.28),
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(card.$3, style: const TextStyle(fontSize: 26)),
                    const SizedBox(height: 6),
                    Text(
                      card.$2,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: card.$4,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      card.$1,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF78909C),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 18),
        KidDelayedReveal(
          delay: const Duration(milliseconds: 160),
          child: KidBadgeSummaryCard(
            unlockedAchievements: unlockedAchievements,
            onTap: onShowBadges,
            title: _text(
              context,
              zh: '成就徽章',
              en: 'Achievement Badges',
              ko: '성취 배지',
            ),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          l10n.parentOverviewRecentTitle,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: Color(0xFF4A148C),
          ),
        ),
        const SizedBox(height: 10),
        if (recentEntries.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: const Color(0xFFE0E0E0),
                width: 2,
              ),
            ),
            child: Column(
              children: [
                const Text('🎮', style: TextStyle(fontSize: 32)),
                const SizedBox(height: 6),
                Text(
                  l10n.parentOverviewNoActivity,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF9E9E9E),
                  ),
                ),
              ],
            ),
          )
        else
          Column(
            children: [
              for (var i = 0; i < recentEntries.length; i++) ...[
                KidDelayedReveal(
                  delay: Duration(milliseconds: i * 40),
                  child: _ActivityCard(entry: recentEntries[i]),
                ),
                if (i != recentEntries.length - 1) const SizedBox(height: 10),
              ],
            ],
          ),
      ],
    );
  }
}

class _ProgressTab extends ConsumerWidget {
  const _ProgressTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final progress = ref.watch(gameProgressProvider);
    final parentData = ref.watch(parentDataProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.parentProgressSummary(
            orderedGameIds.length,
            progress.unlockedGames.length,
          ),
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF78909C),
          ),
        ),
        const SizedBox(height: 12),
        for (var i = 0; i < orderedGameIds.length; i++) ...[
          KidDelayedReveal(
            delay: Duration(milliseconds: i * 70),
            child: _ProgressCard(
              gameId: orderedGameIds[i],
              unlocked: progress.isUnlocked(orderedGameIds[i]),
              stats: parentData.gameStats[orderedGameIds[i]],
            ),
          ),
          if (i != orderedGameIds.length - 1) const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _SettingsTab extends ConsumerStatefulWidget {
  const _SettingsTab({super.key});

  @override
  ConsumerState<_SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends ConsumerState<_SettingsTab> {
  late final TextEditingController _nameController;
  late final FocusNode _nameFocusNode;
  bool _avatarPickerOpen = false;
  bool _nameSaved = false;
  bool _showResetConfirm = false;
  bool _resetDone = false;
  Timer? _savedTimer;
  Timer? _resetTimer;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: ref.read(parentDataProvider).childName,
    );
    _nameFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _savedTimer?.cancel();
    _resetTimer?.cancel();
    _nameController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  Future<void> _saveName() async {
    await ref.read(parentDataProvider).setChildName(_nameController.text);
    setState(() => _nameSaved = true);
    _savedTimer?.cancel();
    _savedTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _nameSaved = false);
      }
    });
  }

  Future<void> _handleReset() async {
    await ref.read(gameProgressProvider).resetProgress();
    await ref.read(parentDataProvider).resetLearningData();
    setState(() => _resetDone = true);
    _resetTimer?.cancel();
    _resetTimer = Timer(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _showResetConfirm = false;
          _resetDone = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final parentData = ref.watch(parentDataProvider);

    if (_nameController.text != parentData.childName &&
        !_nameFocusNode.hasFocus) {
      _nameController.text = parentData.childName;
    }

    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SettingsSection(
              title: l10n.parentSettingsProfileSection,
              child: Column(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(
                              () => _avatarPickerOpen = !_avatarPickerOpen);
                        },
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 72,
                              height: 72,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3E5F5),
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(
                                  color: const Color(0xFFCE93D8),
                                  width: 3,
                                ),
                              ),
                              child: Text(
                                parentData.childAvatar,
                                style: const TextStyle(fontSize: 44),
                              ),
                            ),
                            Positioned(
                              right: -2,
                              bottom: -2,
                              child: Container(
                                width: 22,
                                height: 22,
                                alignment: Alignment.center,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF7B1FA2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.edit_rounded,
                                  size: 12,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.parentSettingsAvatarTitle,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF4A148C),
                              ),
                            ),
                            Text(
                              l10n.parentSettingsAvatarSubtitle,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF9E9E9E),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    child: !_avatarPickerOpen
                        ? const SizedBox.shrink()
                        : Padding(
                            key: const ValueKey('avatar-picker'),
                            padding: const EdgeInsets.only(top: 14),
                            child: GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _avatarOptions.length,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 6,
                                mainAxisSpacing: 8,
                                crossAxisSpacing: 8,
                                childAspectRatio: 1,
                              ),
                              itemBuilder: (context, index) {
                                final avatar = _avatarOptions[index];
                                final selected =
                                    avatar == parentData.childAvatar;
                                return Material(
                                  color: selected
                                      ? const Color(0xFFEDE7F6)
                                      : const Color(0xFFF5F5F5),
                                  borderRadius: BorderRadius.circular(14),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(14),
                                    onTap: () async {
                                      await ref
                                          .read(parentDataProvider)
                                          .setChildAvatar(avatar);
                                      if (mounted) {
                                        setState(
                                            () => _avatarPickerOpen = false);
                                      }
                                    },
                                    child: Ink(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                          color: selected
                                              ? const Color(0xFF7B1FA2)
                                              : const Color(0xFFE0E0E0),
                                          width: selected ? 2.5 : 2,
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          avatar,
                                          style: const TextStyle(fontSize: 28),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _nameController,
                          focusNode: _nameFocusNode,
                          maxLength: 10,
                          buildCounter: (_,
                                  {required currentLength,
                                  required isFocused,
                                  required maxLength}) =>
                              null,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFFF3E5F5),
                            hintText: l10n.parentSettingsNameHint,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: const BorderSide(
                                color: Color(0xFFCE93D8),
                                width: 2.5,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: const BorderSide(
                                color: Color(0xFFCE93D8),
                                width: 2.5,
                              ),
                            ),
                          ),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF4A148C),
                          ),
                          onSubmitted: (_) => _saveName(),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Material(
                        color: _nameSaved
                            ? const Color(0xFFE8F5E9)
                            : const Color(0xFF7B1FA2),
                        borderRadius: BorderRadius.circular(18),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: _saveName,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 14,
                            ),
                            child: _nameSaved
                                ? const Icon(
                                    Icons.check_rounded,
                                    color: Color(0xFF2E7D32),
                                    size: 18,
                                  )
                                : Text(
                                    l10n.parentSettingsSave,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _SettingsSection(
              title: l10n.parentSettingsAppSection,
              child: Column(
                children: [
                  _ToggleRow(
                    icon: Icon(
                      parentData.soundEnabled
                          ? Icons.volume_up_rounded
                          : Icons.volume_off_rounded,
                      color: parentData.soundEnabled
                          ? const Color(0xFF1565C0)
                          : const Color(0xFF9E9E9E),
                    ),
                    label: l10n.parentSettingsSoundTitle,
                    subtitle: parentData.soundEnabled
                        ? l10n.parentSettingsSoundOn
                        : l10n.parentSettingsSoundOff,
                    value: parentData.soundEnabled,
                    onTap: () => ref
                        .read(parentDataProvider)
                        .setSoundEnabled(!parentData.soundEnabled),
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1, color: Color(0xFFF5F5F5)),
                  const SizedBox(height: 12),
                  _ToggleRow(
                    icon: Icon(
                      parentData.voiceGuideEnabled
                          ? Icons.mic_rounded
                          : Icons.mic_off_rounded,
                      color: parentData.voiceGuideEnabled
                          ? const Color(0xFF1565C0)
                          : const Color(0xFF9E9E9E),
                    ),
                    label: _text(
                      context,
                      zh: '语音引导',
                      en: 'Voice Guide',
                      ko: '음성 안내',
                    ),
                    subtitle: parentData.voiceGuideEnabled
                        ? _text(
                            context,
                            zh: '自动朗读题目',
                            en: 'Reads prompts automatically',
                            ko: '문제를 자동으로 읽어줘요',
                          )
                        : _text(
                            context,
                            zh: '已关闭',
                            en: 'Disabled',
                            ko: '꺼짐',
                          ),
                    value: parentData.voiceGuideEnabled,
                    onTap: () => ref
                        .read(parentDataProvider)
                        .setVoiceGuideEnabled(!parentData.voiceGuideEnabled),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _SettingsSection(
              title: _text(
                context,
                zh: '⏱️ 游戏时间管理',
                en: '⏱️ Play Time Limits',
                ko: '⏱️ 놀이 시간 관리',
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TimeLimitGroup(
                    title: _text(
                      context,
                      zh: '单次游戏时长',
                      en: 'Session time',
                      ko: '한 번 놀이 시간',
                    ),
                    values: const [0, 15, 20, 30],
                    selectedValue: parentData.sessionTimeLimitMinutes,
                    onSelected: (value) => ref
                        .read(parentDataProvider)
                        .setSessionTimeLimitMinutes(value),
                  ),
                  if (parentData.sessionTimeLimitMinutes > 0) ...[
                    const SizedBox(height: 6),
                    Text(
                      _text(
                        context,
                        zh: '超时后会温和提示宝宝休息，可选择继续或回首页',
                        en: 'A gentle reminder appears when time is up.',
                        ko: '시간이 되면 쉬라는 안내가 나와요.',
                      ),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF78909C),
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  const Divider(height: 1, color: Color(0xFFF5F5F5)),
                  const SizedBox(height: 14),
                  _TimeLimitGroup(
                    title: _text(
                      context,
                      zh: '每日游戏总时长',
                      en: 'Daily total time',
                      ko: '하루 총 놀이 시간',
                    ),
                    values: const [0, 30, 45, 60, 90],
                    selectedValue: parentData.dailyTimeLimitMinutes,
                    onSelected: (value) => ref
                        .read(parentDataProvider)
                        .setDailyTimeLimitMinutes(value),
                  ),
                  if (parentData.dailyTimeLimitMinutes > 0) ...[
                    const SizedBox(height: 6),
                    Text(
                      _text(
                        context,
                        zh: '超过每日上限后会提示宝宝今天的游戏时间结束了',
                        en: 'The app reminds kids when today’s play time is over.',
                        ko: '하루 한도를 넘기면 오늘 놀이가 끝났다고 알려줘요.',
                      ),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF78909C),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            _SettingsSection(
              title: l10n.parentSettingsSecuritySection,
              child: Material(
                color: const Color(0xFFEDE7F6),
                borderRadius: BorderRadius.circular(18),
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () => Navigator.pushNamed(
                    context,
                    AppRoutes.parentPin,
                    arguments: const ParentPinRouteArgs(changeMode: true),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.lock_outline_rounded,
                          color: Color(0xFF7B1FA2),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.parentSettingsChangePinTitle,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF4A148C),
                                ),
                              ),
                              Text(
                                l10n.parentSettingsChangePinSubtitle,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF9E9E9E),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: Color(0xFFCE93D8),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _SettingsSection(
              title: l10n.parentSettingsDangerSection,
              danger: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.parentSettingsResetWarning,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFFE53935),
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Material(
                    color: const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(18),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () => setState(() => _showResetConfirm = true),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.refresh_rounded,
                              color: Color(0xFFC62828),
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              l10n.parentSettingsResetButton,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFFC62828),
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
          ],
        ),
        if (_showResetConfirm)
          Positioned.fill(
            child: GestureDetector(
              onTap: _resetDone
                  ? null
                  : () => setState(() => _showResetConfirm = false),
              child: Container(
                color: Colors.black.withValues(alpha: 0.45),
                alignment: Alignment.bottomCenter,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxWidth: 390),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: _resetDone
                        ? Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                '✅',
                                style: TextStyle(fontSize: 48),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                l10n.parentSettingsResetDone,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF2E7D32),
                                ),
                              ),
                            ],
                          )
                        : Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                '⚠️',
                                style: TextStyle(fontSize: 48),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                l10n.parentSettingsResetConfirmTitle,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFFC62828),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                l10n.parentSettingsResetConfirmBody,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF546E7A),
                                  height: 1.6,
                                ),
                              ),
                              const SizedBox(height: 18),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () => setState(
                                        () => _showResetConfirm = false,
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor:
                                            const Color(0xFF546E7A),
                                        side: const BorderSide(
                                          color: Color(0xFFE0E0E0),
                                          width: 2,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 14,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(18),
                                        ),
                                      ),
                                      child: Text(
                                        l10n.parentSettingsCancel,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Material(
                                      color: const Color(0xFFFFEBEE),
                                      borderRadius: BorderRadius.circular(18),
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(18),
                                        onTap: _handleReset,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 14,
                                          ),
                                          child: Center(
                                            child: Text(
                                              l10n.parentSettingsConfirmReset,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w800,
                                                color: Color(0xFFC62828),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _HeaderCircleButton extends StatelessWidget {
  const _HeaderCircleButton({
    required this.onTap,
    required this.child,
  });

  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.2),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Center(child: child),
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  final String label;
  final String icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 62,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(icon, style: const TextStyle(fontSize: 20)),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                      color: active
                          ? const Color(0xFF7B1FA2)
                          : const Color(0xFF9E9E9E),
                    ),
                  ),
                ],
              ),
              if (active)
                const Positioned(
                  left: 16,
                  right: 16,
                  bottom: 0,
                  child: SizedBox(
                    height: 3,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Color(0xFF7B1FA2),
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(999),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({
    required this.entry,
  });

  final ActivityEntry entry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFEDE7F6), width: 2),
      ),
      child: Row(
        children: [
          Text(entry.gameId.emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.gameId.title(l10n),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF311B92),
                  ),
                ),
                const SizedBox(height: 2),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    Text(
                      '⭐ ${entry.stars}/${entry.total}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFF9A825),
                      ),
                    ),
                    Text(
                      entry.difficulty.label(l10n),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF78909C),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            _formatTimestamp(context, entry.timestamp),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF9E9E9E),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({
    required this.gameId,
    required this.unlocked,
    required this.stats,
  });

  final GameId gameId;
  final bool unlocked;
  final ParentGameStats? stats;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final starPercent = stats == null || stats!.bestTotal == 0
        ? 0.0
        : stats!.bestStars / stats!.bestTotal;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: unlocked ? const Color(0xFFEDE7F6) : const Color(0xFFECEFF1),
          width: 2.5,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              gradient: unlocked
                  ? gameId.gradient as LinearGradient
                  : const LinearGradient(
                      colors: [Color(0xFFECEFF1), Color(0xFFCFD8DC)],
                    ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(19),
              ),
            ),
            child: Row(
              children: [
                Text(
                  gameId.emoji,
                  style: TextStyle(
                    fontSize: 28,
                    color: unlocked ? null : Colors.grey.shade500,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    gameId.title(l10n),
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: unlocked
                        ? Colors.white.withValues(alpha: 0.3)
                        : const Color(0xFFB0BEC5),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    unlocked
                        ? l10n.parentProgressUnlocked
                        : l10n.parentProgressLocked,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: stats == null
                ? Text(
                    unlocked
                        ? l10n.parentProgressNotStarted
                        : l10n.parentProgressLockedHint,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF9E9E9E),
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            l10n.parentProgressPlayedCount(stats!.played),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF546E7A),
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEDE7F6),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              l10n.parentProgressDifficultyTag(
                                stats!.lastDifficulty?.label(l10n) ??
                                    l10n.parentProgressUnknownDifficulty,
                              ),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF7B1FA2),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Text(
                            l10n.parentProgressBestRate,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF78909C),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '⭐ ${stats!.bestStars}/${stats!.bestTotal}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFFF9A825),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          minHeight: 8,
                          value: starPercent,
                          backgroundColor: const Color(0xFFF5F5F5),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            starPercent >= 0.8
                                ? const Color(0xFFF9A825)
                                : starPercent >= 0.5
                                    ? const Color(0xFF66BB6A)
                                    : const Color(0xFF90CAF9),
                          ),
                        ),
                      ),
                      if (stats!.lastPlayed != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          l10n.parentProgressLastPlayed(
                            _formatTimestamp(context, stats!.lastPlayed!),
                          ),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF9E9E9E),
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

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.title,
    required this.child,
    this.danger = false,
  });

  final String title;
  final Widget child;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: danger ? const Color(0xFFE53935) : const Color(0xFF7B1FA2),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: danger ? const Color(0xFFFFF8F8) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: danger ? const Color(0xFFFFCDD2) : const Color(0xFFEDE7F6),
              width: 2,
            ),
          ),
          child: child,
        ),
      ],
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onTap,
  });

  final Widget icon;
  final String label;
  final String subtitle;
  final bool value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: icon,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF311B92),
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF9E9E9E),
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 50,
            height: 28,
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: value ? const Color(0xFF7B1FA2) : const Color(0xFFE0E0E0),
              borderRadius: BorderRadius.circular(999),
            ),
            alignment: value ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x33000000),
                    blurRadius: 4,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _WeeklyHeatmapCard extends StatelessWidget {
  const _WeeklyHeatmapCard({
    required this.weekDays,
    required this.streak,
  });

  final List<PlayDayStatus> weekDays;
  final int streak;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFEDE7F6), width: 2),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _text(
                    context,
                    zh: '📅 本周学习记录',
                    en: '📅 Weekly Learning',
                    ko: '📅 이번 주 학습 기록',
                  ),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF4A148C),
                  ),
                ),
              ),
              if (streak > 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF8C42), Color(0xFFE64A19)],
                    ),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '🔥 ${_streakText(context, streak)}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              for (var index = 0; index < weekDays.length; index++) ...[
                Expanded(
                  child: _WeekDayBubble(
                    status: weekDays[index],
                    isToday: index == weekDays.length - 1,
                    delay: Duration(milliseconds: 45 * index),
                  ),
                ),
                if (index != weekDays.length - 1) const SizedBox(width: 4),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _WeekDayBubble extends StatelessWidget {
  const _WeekDayBubble({
    required this.status,
    required this.isToday,
    required this.delay,
  });

  final PlayDayStatus status;
  final bool isToday;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    return KidDelayedReveal(
      delay: delay,
      beginOffset: const Offset(0, 0.08),
      child: Column(
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: status.played
                  ? const LinearGradient(
                      colors: [Color(0xFFFF8C42), Color(0xFFE64A19)],
                    )
                  : null,
              color: status.played
                  ? null
                  : isToday
                      ? const Color(0xFFF3E5F5)
                      : const Color(0xFFF5F5F5),
              shape: BoxShape.circle,
              border: Border.all(
                color: isToday
                    ? const Color(0xFFCE93D8)
                    : status.played
                        ? const Color(0xFFBF360C)
                        : const Color(0xFFE0E0E0),
                width: isToday || status.played ? 2.5 : 2,
              ),
            ),
            child: status.played
                ? const Text('🔥', style: TextStyle(fontSize: 16))
                : Text(
                    '○',
                    style: TextStyle(
                      fontSize: 12,
                      color: isToday
                          ? const Color(0xFF7B1FA2)
                          : const Color(0xFFBDBDBD),
                    ),
                  ),
          ),
          const SizedBox(height: 6),
          Text(
            _weekdayLabel(context, status.date, isToday),
            style: TextStyle(
              fontSize: 11,
              fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
              color:
                  isToday ? const Color(0xFF7B1FA2) : const Color(0xFF9E9E9E),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeLimitGroup extends StatelessWidget {
  const _TimeLimitGroup({
    required this.title,
    required this.values,
    required this.selectedValue,
    required this.onSelected,
  });

  final String title;
  final List<int> values;
  final int selectedValue;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFF311B92),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final value in values)
              Material(
                color: selectedValue == value
                    ? const Color(0xFF7B1FA2)
                    : const Color(0xFFF3E5F5),
                borderRadius: BorderRadius.circular(18),
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () => onSelected(value),
                  child: Ink(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: selectedValue == value
                            ? const Color(0xFF4A148C)
                            : const Color(0xFFCE93D8),
                        width: 2,
                      ),
                    ),
                    child: Text(
                      _minutesLabel(context, value),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: selectedValue == value
                            ? Colors.white
                            : const Color(0xFF7B1FA2),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

String _text(
  BuildContext context, {
  required String zh,
  required String en,
  required String ko,
}) {
  return switch (Localizations.localeOf(context).languageCode) {
    'zh' => zh,
    'ko' => ko,
    _ => en,
  };
}

String _streakText(BuildContext context, int days) {
  return switch (Localizations.localeOf(context).languageCode) {
    'zh' => '连续 $days 天',
    'ko' => '$days일 연속',
    _ => '$days day streak',
  };
}

String _minutesLabel(BuildContext context, int value) {
  if (value == 0) {
    return _text(
      context,
      zh: '无限制',
      en: 'Unlimited',
      ko: '제한 없음',
    );
  }
  return switch (Localizations.localeOf(context).languageCode) {
    'zh' => '$value 分钟',
    'ko' => '$value분',
    _ => '$value min',
  };
}

String _weekdayLabel(BuildContext context, DateTime date, bool isToday) {
  if (isToday) {
    return _text(
      context,
      zh: '今',
      en: 'Today',
      ko: '오늘',
    );
  }

  const zh = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
  const en = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  const ko = ['월', '화', '수', '목', '금', '토', '일'];
  final index = (date.weekday - 1).clamp(0, 6);
  return switch (Localizations.localeOf(context).languageCode) {
    'zh' => zh[index],
    'ko' => ko[index],
    _ => en[index],
  };
}

String _formatTimestamp(BuildContext context, DateTime timestamp) {
  final l10n = context.l10n;
  final now = DateTime.now();
  final time = MaterialLocalizations.of(context).formatTimeOfDay(
    TimeOfDay.fromDateTime(timestamp),
    alwaysUse24HourFormat: true,
  );

  final today = DateTime(now.year, now.month, now.day);
  final date = DateTime(timestamp.year, timestamp.month, timestamp.day);
  if (date == today) {
    return l10n.parentTimeToday(time);
  }
  if (date == today.subtract(const Duration(days: 1))) {
    return l10n.parentTimeYesterday(time);
  }
  return l10n.parentTimeDate(timestamp.month, timestamp.day, time);
}
