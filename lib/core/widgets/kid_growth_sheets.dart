import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/localization.dart';
import '../growth_models.dart';
import 'figma_home_icons.dart';

class KidDailyTasksSheet extends StatelessWidget {
  const KidDailyTasksSheet({
    required this.dailyTasks,
    super.key,
  });

  final DailyTasksState dailyTasks;

  @override
  Widget build(BuildContext context) {
    final progress = dailyTasks.tasks.isEmpty
        ? 0.0
        : dailyTasks.completedCount / dailyTasks.tasks.length;
    final allDone = dailyTasks.allDone;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 430,
              maxHeight: MediaQuery.sizeOf(context).height * 0.86,
            ),
            child: Container(
              width: double.infinity,
              clipBehavior: Clip.antiAlias,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFFFF9E6), Colors.white, Colors.white],
                  stops: [0, 0.35, 1],
                ),
                borderRadius: BorderRadius.all(Radius.circular(32)),
                border: Border.fromBorderSide(
                  BorderSide(color: Color(0xFFFFD93D), width: 3),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _SheetHandle(),
                  Row(
                    children: [
                      const _DailyTaskBadgeIcon(size: 34),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _text(
                                context,
                                zh: '今日任务',
                                en: 'Daily Tasks',
                                ko: '오늘의 미션',
                              ),
                              style: GoogleFonts.baloo2(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                height: 1,
                                color: const Color(0xFFB45309),
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              _text(
                                context,
                                zh: '完成 ${dailyTasks.completedCount} / ${dailyTasks.tasks.length} 个',
                                en: '${dailyTasks.completedCount} / ${dailyTasks.tasks.length} done',
                                ko: '${dailyTasks.completedCount} / ${dailyTasks.tasks.length} 완료',
                              ),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF9E9E9E),
                              ),
                            ),
                          ],
                        ),
                      ),
                      _SheetCloseButton(onTap: () => Navigator.pop(context)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _SheetProgressBar(
                    value: progress,
                    borderColor: const Color(0xFFFFD93D),
                    gradient: allDone
                        ? const LinearGradient(
                            colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
                          )
                        : const LinearGradient(
                            colors: [Color(0xFFFFD54F), Color(0xFFFF8C42)],
                          ),
                  ),
                  const SizedBox(height: 16),
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: dailyTasks.tasks.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final task = dailyTasks.tasks[index];
                        return _DailyTaskTile(task: task, index: index);
                      },
                    ),
                  ),
                  if (allDone) ...[
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: const Color(0xFF1B5E20),
                          width: 2.5,
                        ),
                      ),
                      child: Text(
                        _text(
                          context,
                          zh: '全部完成！今天真棒！',
                          en: 'All done! Great job today!',
                          ko: '모두 완료! 오늘도 정말 멋져요!',
                        ),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class KidCollectionSheet extends StatelessWidget {
  const KidCollectionSheet({
    required this.collection,
    super.key,
  });

  final Map<MascotId, DateTime> collection;

  @override
  Widget build(BuildContext context) {
    final collectedCount = collection.length;
    final progress = collectedCount / mascotInfos.length;
    final allDone = collectedCount == mascotInfos.length;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 430,
              maxHeight: MediaQuery.sizeOf(context).height * 0.88,
            ),
            child: Container(
              width: double.infinity,
              clipBehavior: Clip.antiAlias,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFF3E5F5), Colors.white, Colors.white],
                  stops: [0, 0.32, 1],
                ),
                borderRadius: BorderRadius.all(Radius.circular(32)),
                border: Border.fromBorderSide(
                  BorderSide(color: Color(0xFFCE93D8), width: 3),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _SheetHandle(),
                  Row(
                    children: [
                      const _CollectionBookIcon(size: 34),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _text(
                                context,
                                zh: '动物图鉴',
                                en: 'Animal Album',
                                ko: '동물 도감',
                              ),
                              style: GoogleFonts.baloo2(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                height: 1,
                                color: const Color(0xFF7B1FA2),
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              _text(
                                context,
                                zh: '已收集 $collectedCount / ${mascotInfos.length} 种',
                                en: '$collectedCount / ${mascotInfos.length} collected',
                                ko: '$collectedCount / ${mascotInfos.length} 수집',
                              ),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF9E9E9E),
                              ),
                            ),
                          ],
                        ),
                      ),
                      _SheetCloseButton(onTap: () => Navigator.pop(context)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _SheetProgressBar(
                    value: progress,
                    borderColor: const Color(0xFFCE93D8),
                    gradient: const LinearGradient(
                      colors: [Color(0xFFCE93D8), Color(0xFF7B1FA2)],
                    ),
                  ),
                  if (allDone) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3E5F5),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: const Color(0xFF7B1FA2),
                          width: 2.5,
                        ),
                      ),
                      child: Text(
                        _text(
                          context,
                          zh: '全部收集完成！图鉴解锁！',
                          en: 'All animals collected!',
                          ko: '모든 동물을 모았어요!',
                        ),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF7B1FA2),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  Flexible(
                    child: GridView.builder(
                      shrinkWrap: true,
                      itemCount: mascotInfos.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 0.78,
                      ),
                      itemBuilder: (context, index) {
                        final info = mascotInfos[index];
                        final collected = collection.containsKey(info.id);
                        return _MascotCollectionTile(
                          info: info,
                          collected: collected,
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
    );
  }
}

class KidMascotIcon extends StatelessWidget {
  const KidMascotIcon({
    required this.mascotId,
    required this.size,
    super.key,
  });

  final MascotId mascotId;
  final double size;

  @override
  Widget build(BuildContext context) {
    return switch (mascotId) {
      MascotId.lion => FigmaLionMascotIcon(size: size),
      MascotId.fox => FigmaFoxMascotIcon(size: size),
      MascotId.chick => FigmaChickMascotIcon(size: size),
      MascotId.bear => FigmaMascotAvatar(avatar: '🐻', size: size),
      MascotId.panda => FigmaMascotAvatar(avatar: '🐼', size: size),
      MascotId.frog => FigmaMascotAvatar(avatar: '🐸', size: size),
    };
  }
}

class _DailyTaskTile extends StatelessWidget {
  const _DailyTaskTile({
    required this.task,
    required this.index,
  });

  final DailyTask task;
  final int index;

  @override
  Widget build(BuildContext context) {
    final done = task.completed;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 260 + index * 60),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset((1 - value) * -14, 0),
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: done ? const Color(0xFFF1F8E9) : const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: done ? const Color(0xFFA5D6A7) : const Color(0xFFEEEEEE),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: done
                    ? const LinearGradient(
                        colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
                      )
                    : null,
                color: done ? null : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color:
                      done ? const Color(0xFF2E7D32) : const Color(0xFFE0E0E0),
                  width: 2.5,
                ),
                boxShadow: done
                    ? const [
                        BoxShadow(
                          color: Color(0xFF2E7D32),
                          offset: Offset(2, 2),
                          blurRadius: 0,
                        ),
                      ]
                    : null,
              ),
              child: done
                  ? const Icon(Icons.check_rounded,
                      color: Colors.white, size: 17)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                dailyTaskDescription(task, context.l10n),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                  color:
                      done ? const Color(0xFF9E9E9E) : const Color(0xFF4E3B00),
                  decoration: done ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
            if (done) const FigmaSparkleStarIcon(size: 20),
          ],
        ),
      ),
    );
  }
}

class _MascotCollectionTile extends StatelessWidget {
  const _MascotCollectionTile({
    required this.info,
    required this.collected,
  });

  final MascotInfo info;
  final bool collected;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final name = locale == 'zh' ? info.nameZh : info.nameEn;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Opacity(
          opacity: value.clamp(0.0, 1.0),
          child: Transform.scale(scale: 0.88 + value * 0.12, child: child),
        );
      },
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 12, 8, 10),
        decoration: BoxDecoration(
          color: collected ? info.background : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: collected
                ? info.color.withValues(alpha: 0.35)
                : const Color(0xFFE0E0E0),
            width: 2.5,
          ),
        ),
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Opacity(
                  opacity: collected ? 1 : 0.38,
                  child: ColorFiltered(
                    colorFilter: collected
                        ? const ColorFilter.mode(
                            Colors.transparent, BlendMode.dst)
                        : const ColorFilter.matrix(<double>[
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
                          ]),
                    child: KidMascotIcon(mascotId: info.id, size: 52),
                  ),
                ),
                if (!collected)
                  const Positioned(
                    right: -5,
                    bottom: -4,
                    child: FigmaLockIcon(size: 18),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              collected ? name : '???',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                height: 1,
                color: collected ? info.color : const Color(0xFF9E9E9E),
              ),
            ),
            const SizedBox(height: 7),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: collected
                    ? info.color.withValues(alpha: 0.12)
                    : Colors.white,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: collected
                      ? info.color.withValues(alpha: 0.28)
                      : const Color(0xFFE0E0E0),
                  width: 1.4,
                ),
              ),
              child: Text(
                collected
                    ? _text(context, zh: '已收集', en: 'Found', ko: '수집')
                    : _text(context,
                        zh: '玩游戏遇见', en: 'Play to find', ko: '게임에서 만나요'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: collected ? info.color : const Color(0xFFBDBDBD),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetProgressBar extends StatefulWidget {
  const _SheetProgressBar({
    required this.value,
    required this.borderColor,
    required this.gradient,
  });

  final double value;
  final Color borderColor;
  final Gradient gradient;

  @override
  State<_SheetProgressBar> createState() => _SheetProgressBarState();
}

class _SheetProgressBarState extends State<_SheetProgressBar> {
  double _displayValue = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _displayValue = widget.value.clamp(0.0, 1.0);
      });
    });
  }

  @override
  void didUpdateWidget(covariant _SheetProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    final nextValue = widget.value.clamp(0.0, 1.0);
    if (nextValue != _displayValue) {
      setState(() {
        _displayValue = nextValue;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 12,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: widget.borderColor, width: 2),
      ),
      clipBehavior: Clip.antiAlias,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: _displayValue),
        duration: const Duration(milliseconds: 850),
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
            gradient: widget.gradient,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ),
    );
  }
}

class _SheetHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 4,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFE0E0E0),
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}

class _SheetCloseButton extends StatelessWidget {
  const _SheetCloseButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF5F5F5),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: const SizedBox(
          width: 36,
          height: 36,
          child: Icon(Icons.close_rounded, color: Color(0xFF546E7A), size: 18),
        ),
      ),
    );
  }
}

class _DailyTaskBadgeIcon extends StatelessWidget {
  const _DailyTaskBadgeIcon({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFF59D), Color(0xFFFFB300)],
              ),
              borderRadius: BorderRadius.circular(size * 0.22),
              border: Border.all(color: const Color(0xFFC85000), width: 2.2),
            ),
          ),
          Icon(Icons.checklist_rounded, size: size * 0.62, color: Colors.white),
        ],
      ),
    );
  }
}

class _CollectionBookIcon extends StatelessWidget {
  const _CollectionBookIcon({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFF3E5F5), Color(0xFFCE93D8)],
              ),
              borderRadius: BorderRadius.circular(size * 0.22),
              border: Border.all(color: const Color(0xFF7B1FA2), width: 2.2),
              boxShadow: const [
                BoxShadow(
                  color: Color(0xFF7B1FA2),
                  offset: Offset(2, 2),
                  blurRadius: 0,
                ),
              ],
            ),
          ),
          Icon(Icons.auto_stories_rounded,
              size: size * 0.62, color: const Color(0xFF4A148C)),
        ],
      ),
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
