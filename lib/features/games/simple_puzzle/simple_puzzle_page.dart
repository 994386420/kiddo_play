import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/localization.dart';
import '../../../app/route_args.dart';
import '../../../app/router.dart';
import '../../../core/game_models.dart';
import '../../../core/sound/game_sound_controller.dart';
import '../../../core/widgets/floating_sound_toggle.dart';
import '../../../core/widgets/kid_badges.dart';
import '../../../core/widgets/kid_motion.dart';
import '../../../core/widgets/pause_dialog.dart';
import '../../../core/widgets/round_back_button.dart';

final simplePuzzleViewModelProvider = ChangeNotifierProvider.autoDispose
    .family<SimplePuzzleViewModel, GameRouteArgs>((ref, args) {
  return SimplePuzzleViewModel(args);
});

class PuzzlePiece {
  const PuzzlePiece({
    required this.id,
    required this.emoji,
    required this.background,
    required this.color,
    required this.labelZh,
    required this.labelEn,
  });

  final String id;
  final String emoji;
  final Color background;
  final Color color;
  final String labelZh;
  final String labelEn;

  String label(BuildContext context) {
    return Localizations.localeOf(context).languageCode == 'zh'
        ? labelZh
        : labelEn;
  }
}

class PuzzleConfig {
  const PuzzleConfig({
    required this.nameZh,
    required this.nameEn,
    required this.pieces,
  });

  final String nameZh;
  final String nameEn;
  final List<PuzzlePiece> pieces;

  String name(BuildContext context) {
    return Localizations.localeOf(context).languageCode == 'zh'
        ? nameZh
        : nameEn;
  }
}

const _puzzles = <PuzzleConfig>[
  PuzzleConfig(
    nameZh: '小动物',
    nameEn: 'Cute Animals',
    pieces: [
      PuzzlePiece(
          id: 'dog',
          emoji: '🐶',
          background: Color(0xFFFFF9C4),
          color: Color(0xFFF9A825),
          labelZh: '小狗',
          labelEn: 'Dog'),
      PuzzlePiece(
          id: 'cat',
          emoji: '🐱',
          background: Color(0xFFFCE4EC),
          color: Color(0xFFE91E63),
          labelZh: '小猫',
          labelEn: 'Cat'),
      PuzzlePiece(
          id: 'rabbit',
          emoji: '🐰',
          background: Color(0xFFF8BBD9),
          color: Color(0xFFC2185B),
          labelZh: '小兔',
          labelEn: 'Rabbit'),
      PuzzlePiece(
          id: 'frog',
          emoji: '🐸',
          background: Color(0xFFC8E6C9),
          color: Color(0xFF388E3C),
          labelZh: '青蛙',
          labelEn: 'Frog'),
    ],
  ),
  PuzzleConfig(
    nameZh: '美味水果',
    nameEn: 'Sweet Fruits',
    pieces: [
      PuzzlePiece(
          id: 'apple',
          emoji: '🍎',
          background: Color(0xFFFFCDD2),
          color: Color(0xFFC62828),
          labelZh: '苹果',
          labelEn: 'Apple'),
      PuzzlePiece(
          id: 'banana',
          emoji: '🍌',
          background: Color(0xFFFFF9C4),
          color: Color(0xFFF9A825),
          labelZh: '香蕉',
          labelEn: 'Banana'),
      PuzzlePiece(
          id: 'grape',
          emoji: '🍇',
          background: Color(0xFFE1BEE7),
          color: Color(0xFF6A1B9A),
          labelZh: '葡萄',
          labelEn: 'Grape'),
      PuzzlePiece(
          id: 'orange',
          emoji: '🍊',
          background: Color(0xFFFFE0B2),
          color: Color(0xFFE64A19),
          labelZh: '橙子',
          labelEn: 'Orange'),
    ],
  ),
  PuzzleConfig(
    nameZh: '天气变化',
    nameEn: 'Weather Fun',
    pieces: [
      PuzzlePiece(
          id: 'sun',
          emoji: '☀️',
          background: Color(0xFFFFF9C4),
          color: Color(0xFFF9A825),
          labelZh: '晴天',
          labelEn: 'Sunny'),
      PuzzlePiece(
          id: 'rain',
          emoji: '🌧️',
          background: Color(0xFFBBDEFB),
          color: Color(0xFF1565C0),
          labelZh: '雨天',
          labelEn: 'Rainy'),
      PuzzlePiece(
          id: 'snow',
          emoji: '❄️',
          background: Color(0xFFE3F2FD),
          color: Color(0xFF0288D1),
          labelZh: '雪天',
          labelEn: 'Snowy'),
      PuzzlePiece(
          id: 'rainbow',
          emoji: '🌈',
          background: Color(0xFFFCE4EC),
          color: Color(0xFFE91E63),
          labelZh: '彩虹',
          labelEn: 'Rainbow'),
    ],
  ),
  PuzzleConfig(
    nameZh: '星空探险',
    nameEn: 'Space Trip',
    pieces: [
      PuzzlePiece(
          id: 'rocket',
          emoji: '🚀',
          background: Color(0xFFE8EAF6),
          color: Color(0xFF3949AB),
          labelZh: '火箭',
          labelEn: 'Rocket'),
      PuzzlePiece(
          id: 'star',
          emoji: '⭐',
          background: Color(0xFFFFF9C4),
          color: Color(0xFFF9A825),
          labelZh: '星星',
          labelEn: 'Star'),
      PuzzlePiece(
          id: 'moon',
          emoji: '🌙',
          background: Color(0xFFEDE7F6),
          color: Color(0xFF512DA8),
          labelZh: '月亮',
          labelEn: 'Moon'),
      PuzzlePiece(
          id: 'planet',
          emoji: '🪐',
          background: Color(0xFFFFE0B2),
          color: Color(0xFFE64A19),
          labelZh: '星球',
          labelEn: 'Planet'),
    ],
  ),
  PuzzleConfig(
    nameZh: '海洋世界',
    nameEn: 'Ocean World',
    pieces: [
      PuzzlePiece(
          id: 'fish',
          emoji: '🐠',
          background: Color(0xFFFFE0B2),
          color: Color(0xFFE64A19),
          labelZh: '小鱼',
          labelEn: 'Fish'),
      PuzzlePiece(
          id: 'octopus',
          emoji: '🐙',
          background: Color(0xFFE1BEE7),
          color: Color(0xFF6A1B9A),
          labelZh: '章鱼',
          labelEn: 'Octopus'),
      PuzzlePiece(
          id: 'crab',
          emoji: '🦀',
          background: Color(0xFFFFCDD2),
          color: Color(0xFFC62828),
          labelZh: '螃蟹',
          labelEn: 'Crab'),
      PuzzlePiece(
          id: 'dolphin',
          emoji: '🐬',
          background: Color(0xFFBBDEFB),
          color: Color(0xFF1565C0),
          labelZh: '海豚',
          labelEn: 'Dolphin'),
    ],
  ),
  PuzzleConfig(
    nameZh: '交通工具',
    nameEn: 'Vehicles',
    pieces: [
      PuzzlePiece(
          id: 'car',
          emoji: '🚗',
          background: Color(0xFFFFCDD2),
          color: Color(0xFFC62828),
          labelZh: '汽车',
          labelEn: 'Car'),
      PuzzlePiece(
          id: 'bus',
          emoji: '🚌',
          background: Color(0xFFFFF9C4),
          color: Color(0xFFF9A825),
          labelZh: '公交',
          labelEn: 'Bus'),
      PuzzlePiece(
          id: 'plane',
          emoji: '✈️',
          background: Color(0xFFBBDEFB),
          color: Color(0xFF1565C0),
          labelZh: '飞机',
          labelEn: 'Plane'),
      PuzzlePiece(
          id: 'ship',
          emoji: '🚢',
          background: Color(0xFFB2EBF2),
          color: Color(0xFF00838F),
          labelZh: '轮船',
          labelEn: 'Ship'),
    ],
  ),
  PuzzleConfig(
    nameZh: '蔬菜乐园',
    nameEn: 'Veggie Land',
    pieces: [
      PuzzlePiece(
          id: 'carrot',
          emoji: '🥕',
          background: Color(0xFFFFE0B2),
          color: Color(0xFFE64A19),
          labelZh: '胡萝卜',
          labelEn: 'Carrot'),
      PuzzlePiece(
          id: 'broccoli',
          emoji: '🥦',
          background: Color(0xFFC8E6C9),
          color: Color(0xFF388E3C),
          labelZh: '西兰花',
          labelEn: 'Broccoli'),
      PuzzlePiece(
          id: 'corn',
          emoji: '🌽',
          background: Color(0xFFFFF9C4),
          color: Color(0xFFF9A825),
          labelZh: '玉米',
          labelEn: 'Corn'),
      PuzzlePiece(
          id: 'tomato',
          emoji: '🍅',
          background: Color(0xFFFFCDD2),
          color: Color(0xFFC62828),
          labelZh: '西红柿',
          labelEn: 'Tomato'),
    ],
  ),
];

class SimplePuzzleViewModel extends ChangeNotifier {
  SimplePuzzleViewModel(this.args) {
    _trayOrder = _buildTrayOrder();
  }

  final GameRouteArgs args;
  final Random _random = Random();
  Timer? _timer;

  int round = 0;
  int stars = 0;
  bool hadWrong = false;
  bool puzzleSolved = false;
  List<String?> slots = [null, null, null, null];
  late List<int> _trayOrder;
  String? selectedPieceId;
  int? shakingSlot;
  RewardRouteArgs? pendingRewardArgs;

  DifficultyConfig get config => args.difficulty.config;

  PuzzleConfig get puzzle => _puzzles[round % totalPuzzleCount];

  int get totalPuzzleCount {
    switch (args.difficulty) {
      case GameDifficulty.easy:
        return 3;
      case GameDifficulty.medium:
        return 5;
      case GameDifficulty.hard:
        return 7;
    }
  }

  bool get hideLabels => args.difficulty == GameDifficulty.hard;

  bool get hidePieceLabels => args.difficulty == GameDifficulty.hard;

  List<PuzzlePiece> get trayPieces {
    final placedIds = slots.whereType<String>().toSet();
    return _trayOrder
        .map((index) => puzzle.pieces[index])
        .where((piece) => !placedIds.contains(piece.id))
        .toList();
  }

  void selectPiece(String pieceId) {
    if (pendingRewardArgs != null || puzzleSolved) {
      return;
    }
    selectedPieceId = selectedPieceId == pieceId ? null : pieceId;
    notifyListeners();
  }

  void tapSlot(int slotIndex) {
    if (pendingRewardArgs != null || puzzleSolved || selectedPieceId == null) {
      return;
    }

    final correctPieceId = puzzle.pieces[slotIndex].id;
    if (selectedPieceId == correctPieceId) {
      slots = [...slots]..[slotIndex] = selectedPieceId;
      selectedPieceId = null;
      notifyListeners();

      if (slots.every((slot) => slot != null)) {
        final earnedStar = hadWrong ? 0 : 1;
        stars += earnedStar;
        puzzleSolved = true;
        notifyListeners();
        _timer?.cancel();
        _timer = Timer(const Duration(milliseconds: 1500), () {
          if (round + 1 >= totalPuzzleCount) {
            pendingRewardArgs = RewardRouteArgs(
              gameId: args.gameId,
              difficulty: args.difficulty,
              earnedStars: stars,
              totalRounds: totalPuzzleCount,
            );
          } else {
            round += 1;
            slots = [null, null, null, null];
            _trayOrder = _buildTrayOrder();
            selectedPieceId = null;
            shakingSlot = null;
            hadWrong = false;
            puzzleSolved = false;
          }
          notifyListeners();
        });
      }
      return;
    }

    hadWrong = true;
    shakingSlot = slotIndex;
    selectedPieceId = null;
    notifyListeners();
    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 650), () {
      shakingSlot = null;
      notifyListeners();
    });
  }

  void tapPlacedPiece(int slotIndex) {
    final pieceId = slots[slotIndex];
    if (pieceId == null || pendingRewardArgs != null || puzzleSolved) {
      return;
    }
    slots = [...slots]..[slotIndex] = null;
    selectedPieceId = pieceId;
    notifyListeners();
  }

  List<int> _buildTrayOrder() {
    final order = [0, 1, 2, 3];
    order.shuffle(_random);
    return order;
  }

  void reset() {
    _timer?.cancel();
    round = 0;
    stars = 0;
    hadWrong = false;
    puzzleSolved = false;
    slots = [null, null, null, null];
    _trayOrder = _buildTrayOrder();
    selectedPieceId = null;
    shakingSlot = null;
    pendingRewardArgs = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

class SimplePuzzlePage extends ConsumerStatefulWidget {
  const SimplePuzzlePage({required this.args, super.key});

  final GameRouteArgs args;

  @override
  ConsumerState<SimplePuzzlePage> createState() => _SimplePuzzlePageState();
}

class _SimplePuzzlePageState extends ConsumerState<SimplePuzzlePage> {
  bool _isPaused = false;
  late final GameSoundController _soundController;

  GameRouteArgs get args => widget.args;

  void _handleBack(BuildContext context) {
    AppRouter.pushBackwardAndRemoveUntil(
      context,
      name: AppRoutes.gameSelect,
      predicate: (route) => route.settings.name == AppRoutes.home,
    );
  }

  @override
  void initState() {
    super.initState();
    _soundController = ref.read(gameSoundControllerProvider);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_soundController.startBgm());
    });
  }

  @override
  void dispose() {
    unawaited(_soundController.stopBgm());
    super.dispose();
  }

  void _openPause() {
    if (_isPaused) {
      return;
    }
    unawaited(ref.read(gameSoundControllerProvider).playClick());
    setState(() {
      _isPaused = true;
    });
  }

  void _closePause() {
    unawaited(ref.read(gameSoundControllerProvider).playClick());
    setState(() {
      _isPaused = false;
    });
  }

  void _restartGame() {
    unawaited(ref.read(gameSoundControllerProvider).playClick());
    ref.read(simplePuzzleViewModelProvider(args)).reset();
    setState(() {
      _isPaused = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<RewardRouteArgs?>(
      simplePuzzleViewModelProvider(args)
          .select((viewModel) => viewModel.pendingRewardArgs),
      (_, next) {
        if (next != null) {
          Navigator.pushReplacementNamed(context, AppRoutes.reward,
              arguments: next);
        }
      },
    );
    ref.listen<bool>(
      simplePuzzleViewModelProvider(args)
          .select((viewModel) => viewModel.puzzleSolved),
      (previous, next) {
        if (previous == next || !next) {
          return;
        }
        unawaited(ref.read(gameSoundControllerProvider).playStar());
      },
    );
    ref.listen<int?>(
      simplePuzzleViewModelProvider(args)
          .select((viewModel) => viewModel.shakingSlot),
      (previous, next) {
        if (next == null || previous == next) {
          return;
        }
        unawaited(ref.read(gameSoundControllerProvider).playWrong());
      },
    );

    final l10n = context.l10n;
    final viewModel = ref.watch(simplePuzzleViewModelProvider(args));

    return PopScope<void>(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        final route = ModalRoute.of(context);
        if (didPop || route?.isCurrent != true) {
          return;
        }
        if (_isPaused) {
          _closePause();
        } else {
          _openPause();
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFF3E5F5),
                    Color(0xFFEDE7F6),
                    Color(0xFFFFF9E6),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: SafeArea(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                  children: [
                    _PuzzleHeader(
                      title: l10n.puzzleRoundCounter(
                          viewModel.round + 1, viewModel.totalPuzzleCount),
                      difficulty: args.difficulty,
                      stars: viewModel.stars,
                      hideLabels: viewModel.hideLabels,
                      onBack: _openPause,
                    ),
                    const SizedBox(height: 16),
                    KidAnimatedProgressBar(
                      value: viewModel.round / viewModel.totalPuzzleCount,
                      backgroundColor: const Color(0xFFE1BEE7),
                      borderColor: const Color(0xFFCE93D8),
                      gradient: const LinearGradient(
                        colors: [Color(0xFFCE93D8), Color(0xFF7B1FA2)],
                      ),
                    ),
                    const SizedBox(height: 20),
                    KidRoundSwitcher(
                      switchKey:
                          '${viewModel.round}-${viewModel.puzzle.nameZh}',
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(
                                  color: const Color(0xFFCE93D8), width: 3),
                            ),
                            child: Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l10n.puzzleReference,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF9C27B0),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    SizedBox(
                                      width: 72,
                                      height: 72,
                                      child: GridView.builder(
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount: 4,
                                        gridDelegate:
                                            const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          crossAxisSpacing: 4,
                                          mainAxisSpacing: 4,
                                        ),
                                        itemBuilder: (context, index) {
                                          final piece =
                                              viewModel.puzzle.pieces[index];
                                          return DecoratedBox(
                                            decoration: BoxDecoration(
                                              color: piece.background,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Center(
                                              child: Text(piece.emoji,
                                                  style: const TextStyle(
                                                      fontSize: 22)),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '🧩 ${viewModel.puzzle.name(context)}',
                                        style: const TextStyle(
                                          fontSize: 19,
                                          fontWeight: FontWeight.w900,
                                          color: Color(0xFF6A1B9A),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        viewModel.hideLabels
                                            ? l10n.puzzlePromptHard
                                            : l10n.puzzlePrompt,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF9E9E9E),
                                        ),
                                      ),
                                      if (viewModel.selectedPieceId !=
                                          null) ...[
                                        const SizedBox(height: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF3E5F5),
                                            borderRadius:
                                                BorderRadius.circular(999),
                                          ),
                                          child: Text(
                                            l10n.puzzlePieceSelected,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w800,
                                              color: Color(0xFF7B1FA2),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: 4,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 14,
                              mainAxisSpacing: 14,
                              childAspectRatio: 1,
                            ),
                            itemBuilder: (context, index) {
                              final placedPieceId = viewModel.slots[index];
                              final placedPiece = placedPieceId == null
                                  ? null
                                  : viewModel.puzzle.pieces.firstWhere(
                                      (piece) => piece.id == placedPieceId);
                              final isHighlighted = placedPiece == null &&
                                  viewModel.selectedPieceId != null;
                              final isShaking = viewModel.shakingSlot == index;

                              return TweenAnimationBuilder<double>(
                                key: ValueKey(
                                    '$index-${isShaking ? 1 : 0}-${placedPieceId ?? 'empty'}-${isHighlighted ? 1 : 0}'),
                                tween: Tween<double>(end: isShaking ? 1 : 0),
                                duration: const Duration(milliseconds: 420),
                                curve: Curves.easeOutCubic,
                                builder: (context, effect, child) {
                                  final dx =
                                      isShaking ? shakeOffset(effect) : 0.0;
                                  return Transform.translate(
                                    offset: Offset(dx, 0),
                                    child: child,
                                  );
                                },
                                child: GestureDetector(
                                  onTap: () {
                                    if (placedPiece != null) {
                                      unawaited(ref
                                          .read(gameSoundControllerProvider)
                                          .playClick());
                                      ref
                                          .read(simplePuzzleViewModelProvider(
                                              args))
                                          .tapPlacedPiece(index);
                                    } else {
                                      final selectedPieceId = ref
                                          .read(simplePuzzleViewModelProvider(
                                              args))
                                          .selectedPieceId;
                                      final correctPieceId = ref
                                          .read(simplePuzzleViewModelProvider(
                                              args))
                                          .puzzle
                                          .pieces[index]
                                          .id;
                                      if (selectedPieceId != null &&
                                          selectedPieceId == correctPieceId) {
                                        unawaited(ref
                                            .read(gameSoundControllerProvider)
                                            .playClick());
                                      }
                                      ref
                                          .read(simplePuzzleViewModelProvider(
                                              args))
                                          .tapSlot(index);
                                    }
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 220),
                                    curve: Curves.easeOut,
                                    decoration: BoxDecoration(
                                      color: placedPiece?.background ??
                                          (isHighlighted
                                              ? const Color(0xFFF3E5F5)
                                              : const Color(0xFFEDE7F6)),
                                      borderRadius: BorderRadius.circular(28),
                                      border: Border.all(
                                        color: placedPiece != null
                                            ? placedPiece.color
                                            : isShaking
                                                ? const Color(0xFFF44336)
                                                : isHighlighted
                                                    ? const Color(0xFFAB47BC)
                                                    : const Color(0xFFCE93D8),
                                        width: placedPiece != null ? 4 : 3,
                                      ),
                                      boxShadow: [
                                        if (placedPiece != null)
                                          BoxShadow(
                                            color: placedPiece.color
                                                .withValues(alpha: 0.18),
                                            blurRadius: 14,
                                            offset: const Offset(0, 8),
                                          ),
                                      ],
                                    ),
                                    child: Stack(
                                      children: [
                                        Center(
                                          child: AnimatedSwitcher(
                                            duration: const Duration(
                                                milliseconds: 260),
                                            transitionBuilder:
                                                (child, animation) {
                                              return FadeTransition(
                                                opacity: animation,
                                                child: ScaleTransition(
                                                  scale: Tween<double>(
                                                    begin: 0.75,
                                                    end: 1,
                                                  ).animate(animation),
                                                  child: child,
                                                ),
                                              );
                                            },
                                            child: placedPiece == null
                                                ? Column(
                                                    key:
                                                        const ValueKey('empty'),
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      const Text('🧩',
                                                          style: TextStyle(
                                                              fontSize: 28)),
                                                      if (!viewModel
                                                          .hideLabels) ...[
                                                        const SizedBox(
                                                            height: 6),
                                                        Text(
                                                          l10n.puzzleSlotLabel(
                                                              index + 1),
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.w800,
                                                            color: isHighlighted
                                                                ? const Color(
                                                                    0xFFAB47BC)
                                                                : const Color(
                                                                    0xFFB0BEC5),
                                                          ),
                                                        ),
                                                      ],
                                                    ],
                                                  )
                                                : Column(
                                                    key: ValueKey(
                                                        placedPiece.id),
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(placedPiece.emoji,
                                                          style:
                                                              const TextStyle(
                                                                  fontSize:
                                                                      48)),
                                                      if (!viewModel
                                                          .hidePieceLabels) ...[
                                                        const SizedBox(
                                                            height: 6),
                                                        Text(
                                                          placedPiece
                                                              .label(context),
                                                          style: TextStyle(
                                                            fontSize: 13,
                                                            fontWeight:
                                                                FontWeight.w900,
                                                            color: placedPiece
                                                                .color,
                                                          ),
                                                        ),
                                                      ],
                                                    ],
                                                  ),
                                          ),
                                        ),
                                        if (placedPiece != null &&
                                            viewModel.puzzleSolved)
                                          const Positioned(
                                            top: 8,
                                            right: 8,
                                            child: Text('⭐',
                                                style: TextStyle(fontSize: 16)),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 20),
                          Text(
                            l10n.puzzleTrayTitle,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF9C27B0),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            alignment: WrapAlignment.center,
                            children: [
                              for (final piece in viewModel.trayPieces)
                                TweenAnimationBuilder<double>(
                                  tween: Tween<double>(
                                    end: viewModel.selectedPieceId == piece.id
                                        ? 1
                                        : 0,
                                  ),
                                  duration: const Duration(milliseconds: 240),
                                  curve: Curves.easeOutCubic,
                                  builder: (context, effect, child) {
                                    final dy =
                                        viewModel.selectedPieceId == piece.id
                                            ? lerpValue(0, -6, effect)
                                            : 0.0;
                                    final scale =
                                        viewModel.selectedPieceId == piece.id
                                            ? lerpValue(1, 1.06, effect)
                                            : 1.0;
                                    return Transform.translate(
                                      offset: Offset(0, dy),
                                      child: Transform.scale(
                                        scale: scale,
                                        child: child,
                                      ),
                                    );
                                  },
                                  child: GestureDetector(
                                    onTap: () {
                                      unawaited(ref
                                          .read(gameSoundControllerProvider)
                                          .playClick());
                                      ref
                                          .read(simplePuzzleViewModelProvider(
                                              args))
                                          .selectPiece(piece.id);
                                    },
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 200),
                                      width: 78,
                                      height:
                                          viewModel.hidePieceLabels ? 78 : 88,
                                      decoration: BoxDecoration(
                                        color: piece.background,
                                        borderRadius: BorderRadius.circular(22),
                                        border: Border.all(
                                          color: viewModel.selectedPieceId ==
                                                  piece.id
                                              ? piece.color
                                              : piece.color
                                                  .withValues(alpha: 0.6),
                                          width: viewModel.selectedPieceId ==
                                                  piece.id
                                              ? 4
                                              : 3,
                                        ),
                                        boxShadow: [
                                          if (viewModel.selectedPieceId ==
                                              piece.id)
                                            BoxShadow(
                                              color: piece.color
                                                  .withValues(alpha: 0.22),
                                              blurRadius: 16,
                                              offset: const Offset(0, 8),
                                            ),
                                        ],
                                      ),
                                      child: Stack(
                                        children: [
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(piece.emoji,
                                                  style: const TextStyle(
                                                      fontSize: 34)),
                                              if (!viewModel
                                                  .hidePieceLabels) ...[
                                                const SizedBox(height: 4),
                                                Text(
                                                  piece.label(context),
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w800,
                                                    color: piece.color,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ],
                                            ],
                                          ),
                                          if (viewModel.selectedPieceId ==
                                              piece.id)
                                            Positioned(
                                              top: 2,
                                              right: 2,
                                              child: Container(
                                                width: 18,
                                                height: 18,
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                  color: piece.color,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Text(
                                                  '✓',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w900,
                                                    color: Colors.white,
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
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    _PuzzleFeedbackBanner(
                      selectedPieceId: viewModel.selectedPieceId,
                      shakingSlot: viewModel.shakingSlot,
                      correct: viewModel.puzzleSolved,
                    ),
                  ],
                ),
              ),
            ),
            const FloatingSoundToggle(),
            PauseDialog(
              isOpen: _isPaused,
              gameName: args.gameId.title(l10n),
              gameEmoji: args.gameId.emoji,
              onContinue: _closePause,
              onRestart: _restartGame,
              onQuit: () => _handleBack(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _PuzzleHeader extends StatelessWidget {
  const _PuzzleHeader({
    required this.title,
    required this.difficulty,
    required this.stars,
    required this.hideLabels,
    required this.onBack,
  });

  final String title;
  final GameDifficulty difficulty;
  final int stars;
  final bool hideLabels;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        KidRoundBackButton(
          iconColor: const Color(0xFF7B1FA2),
          borderColor: const Color(0xFFCE93D8),
          icon: Icons.pause_rounded,
          onTap: onBack,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(999),
                  border:
                      Border.all(color: const Color(0xFFCE93D8), width: 2.5),
                ),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF7B1FA2),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                hideLabels
                    ? '${difficulty.badgeEmoji} ${difficulty.label(context.l10n)} · ${context.l10n.puzzleHardModeHint}'
                    : '${difficulty.badgeEmoji} ${difficulty.label(context.l10n)}',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF546E7A),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        KidStarCounterBadge(
          count: stars,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          iconSize: 20,
          textSize: 18,
        ),
      ],
    );
  }
}

class _PuzzleFeedbackBanner extends StatelessWidget {
  const _PuzzleFeedbackBanner({
    required this.selectedPieceId,
    required this.shakingSlot,
    required this.correct,
  });

  final String? selectedPieceId;
  final int? shakingSlot;
  final bool correct;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    late final Widget currentBanner;

    if (correct) {
      currentBanner = _buildBanner(
        key: const ValueKey('correct'),
        color: const Color(0xFFE8F5E9),
        borderColor: const Color(0xFF4CAF50),
        textColor: const Color(0xFF2E7D32),
        text: l10n.puzzleCorrect,
      );
    } else if (shakingSlot != null) {
      currentBanner = _buildBanner(
        key: const ValueKey('wrong'),
        color: const Color(0xFFFFF3E0),
        borderColor: const Color(0xFFFF8C42),
        textColor: const Color(0xFFE65100),
        text: l10n.puzzleWrong,
      );
    } else if (selectedPieceId == null) {
      currentBanner = _buildBanner(
        key: const ValueKey('select'),
        color: const Color(0xFFEDE7F6),
        borderColor: const Color(0xFFCE93D8),
        textColor: const Color(0xFF7B1FA2),
        text: l10n.puzzleSelectHint,
      );
    } else {
      currentBanner = _buildBanner(
        key: const ValueKey('place'),
        color: const Color(0xFFF3E5F5),
        borderColor: const Color(0xFFAB47BC),
        textColor: const Color(0xFF7B1FA2),
        text: l10n.puzzleTapSlotHint,
      );
    }

    return SizedBox(
      height: 68,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        switchInCurve: Curves.easeOutBack,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.25),
                end: Offset.zero,
              ).animate(animation),
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.88, end: 1).animate(animation),
                child: child,
              ),
            ),
          );
        },
        child: currentBanner,
      ),
    );
  }

  Widget _buildBanner({
    Key? key,
    required Color color,
    required Color borderColor,
    required Color textColor,
    required String text,
  }) {
    return Container(
      key: key,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor, width: 2.5),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: textColor,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
