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
import '../../../core/widgets/figma_game_icons.dart';
import '../../../core/widgets/figma_game_shell.dart';
import '../../../core/widgets/figma_home_icons.dart';
import '../../../core/widgets/kid_motion.dart';
import '../../../core/widgets/pause_dialog.dart';

const _simplePuzzlePalette = FigmaGamePalette(
  accent: Color(0xFFE3B3EE),
  accentStrong: Color(0xFF7B1FA2),
  accentSoft: Color(0xFFF7EDFB),
  progressTrack: Color(0xFFE1BEE7),
  progressBorder: Color(0xFFCE93D8),
  progressGradient: LinearGradient(
    colors: [Color(0xFFCE93D8), Color(0xFF7B1FA2)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  ),
  floaterIcon: FigmaFloatIconType.sparkle,
);

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
    required this.labelKo,
    required this.labelEn,
  });

  final String id;
  final String emoji;
  final Color background;
  final Color color;
  final String labelZh;
  final String labelKo;
  final String labelEn;

  String label(BuildContext context) {
    return switch (Localizations.localeOf(context).languageCode) {
      'zh' => labelZh,
      'ko' => labelKo,
      _ => labelEn,
    };
  }
}

class PuzzleConfig {
  const PuzzleConfig({
    required this.nameZh,
    required this.nameKo,
    required this.nameEn,
    required this.pieces,
  });

  final String nameZh;
  final String nameKo;
  final String nameEn;
  final List<PuzzlePiece> pieces;

  String name(BuildContext context) {
    return switch (Localizations.localeOf(context).languageCode) {
      'zh' => nameZh,
      'ko' => nameKo,
      _ => nameEn,
    };
  }
}

const _puzzles = <PuzzleConfig>[
  PuzzleConfig(
    nameZh: '小动物',
    nameKo: '귀여운 동물들',
    nameEn: 'Cute Animals',
    pieces: [
      PuzzlePiece(
        id: 'dog',
        emoji: '🐶',
        background: Color(0xFFFFF9C4),
        color: Color(0xFFF9A825),
        labelZh: '小狗',
        labelKo: '강아지',
        labelEn: 'Dog',
      ),
      PuzzlePiece(
        id: 'cat',
        emoji: '🐱',
        background: Color(0xFFFCE4EC),
        color: Color(0xFFE91E63),
        labelZh: '小猫',
        labelKo: '고양이',
        labelEn: 'Cat',
      ),
      PuzzlePiece(
        id: 'rabbit',
        emoji: '🐰',
        background: Color(0xFFF8BBD9),
        color: Color(0xFFC2185B),
        labelZh: '小兔',
        labelKo: '토끼',
        labelEn: 'Rabbit',
      ),
      PuzzlePiece(
        id: 'frog',
        emoji: '🐸',
        background: Color(0xFFC8E6C9),
        color: Color(0xFF388E3C),
        labelZh: '青蛙',
        labelKo: '개구리',
        labelEn: 'Frog',
      ),
    ],
  ),
  PuzzleConfig(
    nameZh: '美味水果',
    nameKo: '달콤한 과일',
    nameEn: 'Sweet Fruits',
    pieces: [
      PuzzlePiece(
        id: 'apple',
        emoji: '🍎',
        background: Color(0xFFFFCDD2),
        color: Color(0xFFC62828),
        labelZh: '苹果',
        labelKo: '사과',
        labelEn: 'Apple',
      ),
      PuzzlePiece(
        id: 'banana',
        emoji: '🍌',
        background: Color(0xFFFFF9C4),
        color: Color(0xFFF9A825),
        labelZh: '香蕉',
        labelKo: '바나나',
        labelEn: 'Banana',
      ),
      PuzzlePiece(
        id: 'grape',
        emoji: '🍇',
        background: Color(0xFFE1BEE7),
        color: Color(0xFF6A1B9A),
        labelZh: '葡萄',
        labelKo: '포도',
        labelEn: 'Grape',
      ),
      PuzzlePiece(
        id: 'orange',
        emoji: '🍊',
        background: Color(0xFFFFE0B2),
        color: Color(0xFFE64A19),
        labelZh: '橙子',
        labelKo: '오렌지',
        labelEn: 'Orange',
      ),
    ],
  ),
  PuzzleConfig(
    nameZh: '天气变化',
    nameKo: '날씨 놀이',
    nameEn: 'Weather Fun',
    pieces: [
      PuzzlePiece(
        id: 'sun',
        emoji: '☀️',
        background: Color(0xFFFFF9C4),
        color: Color(0xFFF9A825),
        labelZh: '晴天',
        labelKo: '맑음',
        labelEn: 'Sunny',
      ),
      PuzzlePiece(
        id: 'rain',
        emoji: '🌧️',
        background: Color(0xFFBBDEFB),
        color: Color(0xFF1565C0),
        labelZh: '雨天',
        labelKo: '비',
        labelEn: 'Rainy',
      ),
      PuzzlePiece(
        id: 'snow',
        emoji: '❄️',
        background: Color(0xFFE3F2FD),
        color: Color(0xFF0288D1),
        labelZh: '雪天',
        labelKo: '눈',
        labelEn: 'Snowy',
      ),
      PuzzlePiece(
        id: 'rainbow',
        emoji: '🌈',
        background: Color(0xFFFCE4EC),
        color: Color(0xFFE91E63),
        labelZh: '彩虹',
        labelKo: '무지개',
        labelEn: 'Rainbow',
      ),
    ],
  ),
  PuzzleConfig(
    nameZh: '星空探险',
    nameKo: '우주 여행',
    nameEn: 'Space Trip',
    pieces: [
      PuzzlePiece(
        id: 'rocket',
        emoji: '🚀',
        background: Color(0xFFE8EAF6),
        color: Color(0xFF3949AB),
        labelZh: '火箭',
        labelKo: '로켓',
        labelEn: 'Rocket',
      ),
      PuzzlePiece(
        id: 'star',
        emoji: '⭐',
        background: Color(0xFFFFF9C4),
        color: Color(0xFFF9A825),
        labelZh: '星星',
        labelKo: '별',
        labelEn: 'Star',
      ),
      PuzzlePiece(
        id: 'moon',
        emoji: '🌙',
        background: Color(0xFFEDE7F6),
        color: Color(0xFF512DA8),
        labelZh: '月亮',
        labelKo: '달',
        labelEn: 'Moon',
      ),
      PuzzlePiece(
        id: 'planet',
        emoji: '🪐',
        background: Color(0xFFFFE0B2),
        color: Color(0xFFE64A19),
        labelZh: '星球',
        labelKo: '행성',
        labelEn: 'Planet',
      ),
    ],
  ),
  PuzzleConfig(
    nameZh: '海洋世界',
    nameKo: '바다 세계',
    nameEn: 'Ocean World',
    pieces: [
      PuzzlePiece(
        id: 'fish',
        emoji: '🐠',
        background: Color(0xFFFFE0B2),
        color: Color(0xFFE64A19),
        labelZh: '小鱼',
        labelKo: '물고기',
        labelEn: 'Fish',
      ),
      PuzzlePiece(
        id: 'octopus',
        emoji: '🐙',
        background: Color(0xFFE1BEE7),
        color: Color(0xFF6A1B9A),
        labelZh: '章鱼',
        labelKo: '문어',
        labelEn: 'Octopus',
      ),
      PuzzlePiece(
        id: 'crab',
        emoji: '🦀',
        background: Color(0xFFFFCDD2),
        color: Color(0xFFC62828),
        labelZh: '螃蟹',
        labelKo: '게',
        labelEn: 'Crab',
      ),
      PuzzlePiece(
        id: 'dolphin',
        emoji: '🐬',
        background: Color(0xFFBBDEFB),
        color: Color(0xFF1565C0),
        labelZh: '海豚',
        labelKo: '돌고래',
        labelEn: 'Dolphin',
      ),
    ],
  ),
  PuzzleConfig(
    nameZh: '交通工具',
    nameKo: '탈것',
    nameEn: 'Vehicles',
    pieces: [
      PuzzlePiece(
        id: 'car',
        emoji: '🚗',
        background: Color(0xFFFFCDD2),
        color: Color(0xFFC62828),
        labelZh: '汽车',
        labelKo: '자동차',
        labelEn: 'Car',
      ),
      PuzzlePiece(
        id: 'bus',
        emoji: '🚌',
        background: Color(0xFFFFF9C4),
        color: Color(0xFFF9A825),
        labelZh: '公交',
        labelKo: '버스',
        labelEn: 'Bus',
      ),
      PuzzlePiece(
        id: 'plane',
        emoji: '✈️',
        background: Color(0xFFBBDEFB),
        color: Color(0xFF1565C0),
        labelZh: '飞机',
        labelKo: '비행기',
        labelEn: 'Plane',
      ),
      PuzzlePiece(
        id: 'ship',
        emoji: '🚢',
        background: Color(0xFFB2EBF2),
        color: Color(0xFF00838F),
        labelZh: '轮船',
        labelKo: '배',
        labelEn: 'Ship',
      ),
    ],
  ),
  PuzzleConfig(
    nameZh: '蔬菜乐园',
    nameKo: '채소 나라',
    nameEn: 'Veggie Land',
    pieces: [
      PuzzlePiece(
        id: 'carrot',
        emoji: '🥕',
        background: Color(0xFFFFE0B2),
        color: Color(0xFFE64A19),
        labelZh: '胡萝卜',
        labelKo: '당근',
        labelEn: 'Carrot',
      ),
      PuzzlePiece(
        id: 'broccoli',
        emoji: '🥦',
        background: Color(0xFFC8E6C9),
        color: Color(0xFF388E3C),
        labelZh: '西兰花',
        labelKo: '브로콜리',
        labelEn: 'Broccoli',
      ),
      PuzzlePiece(
        id: 'corn',
        emoji: '🌽',
        background: Color(0xFFFFF9C4),
        color: Color(0xFFF9A825),
        labelZh: '玉米',
        labelKo: '옥수수',
        labelEn: 'Corn',
      ),
      PuzzlePiece(
        id: 'tomato',
        emoji: '🍅',
        background: Color(0xFFFFCDD2),
        color: Color(0xFFC62828),
        labelZh: '西红柿',
        labelKo: '토마토',
        labelEn: 'Tomato',
      ),
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
    AppRouter.showGameSelect(context);
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
          Navigator.pushReplacementNamed(
            context,
            AppRoutes.reward,
            arguments: next,
          );
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
    final selectedPieceId = viewModel.selectedPieceId;
    final selectedPiece = selectedPieceId == null
        ? null
        : viewModel.puzzle.pieces.firstWhere(
            (piece) => piece.id == selectedPieceId,
          );

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
      child: FigmaGameScaffold(
        palette: _simplePuzzlePalette,
        roundLabel: l10n.puzzleRoundCounter(
            viewModel.round + 1, viewModel.totalPuzzleCount),
        difficulty: args.difficulty,
        stars: viewModel.stars,
        progress: viewModel.round / viewModel.totalPuzzleCount,
        onPause: _openPause,
        pauseIcon: const FigmaPauseIcon(
          size: 22,
          color: Color(0xFF7B1FA2),
        ),
        backgroundGradient: const LinearGradient(
          colors: [
            Color(0xFFF3E5F5),
            Color(0xFFEDE7F6),
            Color(0xFFFFF9E6),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        floatingAction: const FloatingSoundToggle(
          accentColor: Color(0xFFCE93D8),
          borderColor: Color(0xFF7B1FA2),
        ),
        pauseDialog: PauseDialog(
          isOpen: _isPaused,
          gameName: args.gameId.title(l10n),
          gameEmoji: args.gameId.emoji,
          onContinue: _closePause,
          onRestart: _restartGame,
          onQuit: () => _handleBack(context),
        ),
        body: KidRoundSwitcher(
          switchKey: '${viewModel.round}-${viewModel.puzzle.name(context)}',
          child: Column(
            children: [
              _PuzzleReferenceCard(
                puzzle: viewModel.puzzle,
                prompt: viewModel.hideLabels
                    ? l10n.puzzlePromptHard
                    : l10n.puzzlePrompt,
                selectedPiece: selectedPiece,
              ),
              const SizedBox(height: 20),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 320),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 4,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1,
                  ),
                  itemBuilder: (context, index) {
                    final placedPieceId = viewModel.slots[index];
                    final placedPiece = placedPieceId == null
                        ? null
                        : viewModel.puzzle.pieces.firstWhere(
                            (piece) => piece.id == placedPieceId,
                          );
                    final isHighlighted =
                        placedPiece == null && selectedPieceId != null;
                    final isShaking = viewModel.shakingSlot == index;

                    return TweenAnimationBuilder<double>(
                      key: ValueKey(
                        '$index-${placedPieceId ?? 'empty'}-${isShaking ? 1 : 0}-${isHighlighted ? 1 : 0}',
                      ),
                      tween: Tween<double>(end: isShaking ? 1 : 0),
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOutCubic,
                      builder: (context, effect, child) {
                        return Transform.translate(
                          offset: Offset(
                            isShaking ? shakeOffset(effect, amplitude: 10) : 0,
                            0,
                          ),
                          child: child,
                        );
                      },
                      child: _PuzzleBoardSlot(
                        piece: placedPiece,
                        slotIndex: index,
                        highlighted: isHighlighted,
                        hideLabel: viewModel.hideLabels,
                        solved: viewModel.puzzleSolved,
                        onTap: () {
                          if (placedPiece != null) {
                            unawaited(
                              ref.read(gameSoundControllerProvider).playClick(),
                            );
                            ref
                                .read(simplePuzzleViewModelProvider(args))
                                .tapPlacedPiece(index);
                            return;
                          }

                          final currentSelected = ref
                              .read(simplePuzzleViewModelProvider(args))
                              .selectedPieceId;
                          final correctPieceId = ref
                              .read(simplePuzzleViewModelProvider(args))
                              .puzzle
                              .pieces[index]
                              .id;
                          if (currentSelected != null &&
                              currentSelected == correctPieceId) {
                            unawaited(
                              ref.read(gameSoundControllerProvider).playClick(),
                            );
                          }
                          ref
                              .read(simplePuzzleViewModelProvider(args))
                              .tapSlot(index);
                        },
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 22),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  l10n.puzzleTrayTitle,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF9C27B0),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (final piece in viewModel.trayPieces)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: _PuzzleTrayPiece(
                        piece: piece,
                        selected: selectedPieceId == piece.id,
                        hideLabel: viewModel.hidePieceLabels,
                        onTap: () {
                          unawaited(
                            ref.read(gameSoundControllerProvider).playClick(),
                          );
                          ref
                              .read(simplePuzzleViewModelProvider(args))
                              .selectPiece(piece.id);
                        },
                      ),
                    ),
                  for (var i = 0; i < 4 - viewModel.trayPieces.length; i++)
                    const SizedBox(width: 84),
                ],
              ),
              const SizedBox(height: 18),
              _PuzzleFeedbackBanner(
                selectedPieceId: selectedPieceId,
                shakingSlot: viewModel.shakingSlot,
                correct: viewModel.puzzleSolved,
                hasRemainingPieces: viewModel.trayPieces.isNotEmpty,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PuzzleReferenceCard extends StatelessWidget {
  const _PuzzleReferenceCard({
    required this.puzzle,
    required this.prompt,
    required this.selectedPiece,
  });

  final PuzzleConfig puzzle;
  final String prompt;
  final PuzzlePiece? selectedPiece;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFCE93D8), width: 3),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7B1FA2).withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.puzzleReference,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF9C27B0),
                ),
              ),
              const SizedBox(height: 4),
              SizedBox(
                width: 68,
                height: 68,
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 4,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 3,
                    mainAxisSpacing: 3,
                  ),
                  itemBuilder: (context, index) {
                    final piece = puzzle.pieces[index];
                    return DecoratedBox(
                      decoration: BoxDecoration(
                        color: piece.background,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          piece.emoji,
                          style: const TextStyle(fontSize: 22),
                        ),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🧩 ${puzzle.name(context)}',
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF6A1B9A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  prompt,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF9E9E9E),
                  ),
                ),
                if (selectedPiece != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3E5F5),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          selectedPiece!.emoji,
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          context.l10n.puzzlePieceSelected,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF7B1FA2),
                          ),
                        ),
                      ],
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

class _PuzzleBoardSlot extends StatelessWidget {
  const _PuzzleBoardSlot({
    required this.piece,
    required this.slotIndex,
    required this.highlighted,
    required this.hideLabel,
    required this.solved,
    required this.onTap,
  });

  final PuzzlePiece? piece;
  final int slotIndex;
  final bool highlighted;
  final bool hideLabel;
  final bool solved;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        height: 120,
        decoration: BoxDecoration(
          color: piece?.background ??
              (highlighted ? const Color(0xFFF3E5F5) : const Color(0xFFEDE7F6)),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: piece != null
                ? piece!.color
                : highlighted
                    ? const Color(0xFFAB47BC)
                    : const Color(0xFFCE93D8),
            width: 4,
          ),
          boxShadow: [
            if (piece != null)
              BoxShadow(
                color: piece!.color.withValues(alpha: 0.25),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
          ],
        ),
        child: Stack(
          children: [
            Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 260),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(
                      scale: Tween<double>(
                        begin: 0.72,
                        end: 1,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: piece != null
                    ? Column(
                        key: ValueKey(piece!.id),
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            piece!.emoji,
                            style: const TextStyle(fontSize: 48),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            piece!.label(context),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: piece!.color,
                            ),
                          ),
                        ],
                      )
                    : _PuzzleEmptySlot(
                        slotIndex: slotIndex,
                        highlighted: highlighted,
                        hideLabels: hideLabel,
                      ),
              ),
            ),
            if (piece != null && solved)
              const Positioned(
                top: 6,
                right: 6,
                child: Text(
                  '⭐',
                  style: TextStyle(fontSize: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PuzzleEmptySlot extends StatelessWidget {
  const _PuzzleEmptySlot({
    required this.slotIndex,
    required this.highlighted,
    required this.hideLabels,
  });

  final int slotIndex;
  final bool highlighted;
  final bool hideLabels;

  @override
  Widget build(BuildContext context) {
    final content = Column(
      key: const ValueKey('empty-slot'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('🧩', style: TextStyle(fontSize: 28)),
        if (!hideLabels) ...[
          const SizedBox(height: 6),
          Text(
            _slotLabel(context, slotIndex),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: highlighted
                  ? const Color(0xFFAB47BC)
                  : const Color(0xFFB0BEC5),
            ),
          ),
        ],
      ],
    );

    if (!highlighted) {
      return content;
    }

    return KidLoopAnimation(
      duration: const Duration(milliseconds: 1200),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 1 + (wave(value, min: -1, max: 1) * 0.04),
          child: child,
        );
      },
      child: content,
    );
  }
}

class _PuzzleTrayPiece extends StatelessWidget {
  const _PuzzleTrayPiece({
    required this.piece,
    required this.selected,
    required this.hideLabel,
    required this.onTap,
  });

  final PuzzlePiece piece;
  final bool selected;
  final bool hideLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: selected ? 1 : 0),
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      builder: (context, effect, child) {
        return Transform.translate(
          offset: Offset(0, selected ? lerpValue(0, -6, effect) : 0),
          child: Transform.scale(
            scale: selected ? lerpValue(1, 1.05, effect) : 1,
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 72,
          height: hideLabel ? 72 : 82,
          decoration: BoxDecoration(
            color: piece.background,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color:
                  selected ? piece.color : piece.color.withValues(alpha: 0.4),
              width: selected ? 4 : 3,
            ),
            boxShadow: [
              BoxShadow(
                color: selected
                    ? piece.color.withValues(alpha: 0.35)
                    : piece.color.withValues(alpha: 0.18),
                blurRadius: selected ? 16 : 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(piece.emoji, style: const TextStyle(fontSize: 36)),
                    if (!hideLabel) ...[
                      const SizedBox(height: 2),
                      Text(
                        piece.label(context),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: piece.color,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (selected)
                Positioned(
                  top: 0,
                  right: 0,
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
    );
  }
}

class _PuzzleFeedbackBanner extends StatelessWidget {
  const _PuzzleFeedbackBanner({
    required this.selectedPieceId,
    required this.shakingSlot,
    required this.correct,
    required this.hasRemainingPieces,
  });

  final String? selectedPieceId;
  final int? shakingSlot;
  final bool correct;
  final bool hasRemainingPieces;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    if (correct) {
      return _PuzzleMessage(
        emojiLeft: '🌟',
        emojiRight: '🌟',
        backgroundColor: const Color(0xFFE8F5E9),
        borderColor: const Color(0xFF4CAF50),
        textColor: const Color(0xFF2E7D32),
        text: l10n.puzzleCorrect,
      );
    }

    if (shakingSlot != null) {
      return _PuzzleMessage(
        emojiLeft: '💪',
        emojiRight: '💪',
        backgroundColor: const Color(0xFFFFF3E0),
        borderColor: const Color(0xFFFF8C42),
        textColor: const Color(0xFFE65100),
        text: l10n.puzzleWrong,
      );
    }

    if (selectedPieceId == null && hasRemainingPieces) {
      return _PuzzleMessage(
        emojiLeft: '👆',
        emojiRight: '👆',
        backgroundColor: const Color(0xFFEDE7F6),
        borderColor: const Color(0xFFCE93D8),
        textColor: const Color(0xFF7B1FA2),
        text: _puzzleHint(context),
      );
    }

    return const SizedBox(height: 56);
  }
}

class _PuzzleMessage extends StatelessWidget {
  const _PuzzleMessage({
    required this.emojiLeft,
    required this.emojiRight,
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
    required this.text,
  });

  final String emojiLeft;
  final String emojiRight;
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;
  final String text;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 2.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emojiLeft, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: textColor,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(emojiRight, style: const TextStyle(fontSize: 24)),
        ],
      ),
    );
  }
}

String _slotLabel(BuildContext context, int index) {
  return switch (Localizations.localeOf(context).languageCode) {
    'zh' => const ['左上', '右上', '左下', '右下'][index],
    'ko' => const ['왼쪽 위', '오른쪽 위', '왼쪽 아래', '오른쪽 아래'][index],
    _ => const ['Top Left', 'Top Right', 'Bottom Left', 'Bottom Right'][index],
  };
}

String _puzzleHint(BuildContext context) {
  return switch (Localizations.localeOf(context).languageCode) {
    'zh' => '先点选碎片，再点格子放入',
    'ko' => '먼저 조각을 누르고, 그다음 칸을 눌러 넣어요',
    _ => 'Tap a piece first, then tap a slot to place it',
  };
}
