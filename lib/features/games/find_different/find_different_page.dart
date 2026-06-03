import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/localization.dart';
import '../../../app/route_args.dart';
import '../../../app/router.dart';
import '../../../core/app_controllers.dart';
import '../../../core/game_models.dart';
import '../../../core/sound/game_sound_controller.dart';
import '../../../core/sound/voice_guide_controller.dart';
import '../../../core/widgets/floating_sound_toggle.dart';
import '../../../core/widgets/figma_game_icons.dart';
import '../../../core/widgets/figma_game_shell.dart';
import '../../../core/widgets/figma_home_icons.dart';
import '../../../core/widgets/kid_motion.dart';
import '../../../core/widgets/pause_dialog.dart';

const _findDifferentPalette = FigmaGamePalette(
  accent: Color(0xFF74E8D8),
  accentStrong: Color(0xFF118A86),
  accentSoft: Color(0xFFE7FFFB),
  progressTrack: Color(0xFFD6F6F0),
  progressBorder: Color(0xFF8BD8CF),
  progressGradient: LinearGradient(
    colors: [Color(0xFF74E8D8), Color(0xFF118A86)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  ),
  floaterIcon: FigmaFloatIconType.sparkle,
);

final findDifferentViewModelProvider = ChangeNotifierProvider.autoDispose
    .family<FindDifferentViewModel, GameRouteArgs>((ref, args) {
  return FindDifferentViewModel(args);
});

class FindDifferentCharacter {
  const FindDifferentCharacter({
    required this.id,
    required this.avatar,
    required this.background,
    required this.shadow,
  });

  final String id;
  final String avatar;
  final Color background;
  final Color shadow;
}

const _findDifferentCharacters = <FindDifferentCharacter>[
  FindDifferentCharacter(
    id: 'lion',
    avatar: '🦁',
    background: Color(0xFFFFD66D),
    shadow: Color(0xFFE6A700),
  ),
  FindDifferentCharacter(
    id: 'bear',
    avatar: '🐻',
    background: Color(0xFFD7C1FF),
    shadow: Color(0xFF7E57C2),
  ),
  FindDifferentCharacter(
    id: 'panda',
    avatar: '🐼',
    background: Color(0xFFFFE8A3),
    shadow: Color(0xFFF9A825),
  ),
  FindDifferentCharacter(
    id: 'fox',
    avatar: '🦊',
    background: Color(0xFFFFC7A8),
    shadow: Color(0xFFF97316),
  ),
  FindDifferentCharacter(
    id: 'frog',
    avatar: '🐸',
    background: Color(0xFFB8F0B5),
    shadow: Color(0xFF43A047),
  ),
];

enum FindDifferentAnswerState { idle, correct, wrong }

class FindDifferentQuestion {
  const FindDifferentQuestion({
    required this.common,
    required this.odd,
    required this.options,
  });

  final FindDifferentCharacter common;
  final FindDifferentCharacter odd;
  final List<FindDifferentCharacter> options;
}

class FindDifferentViewModel extends ChangeNotifier {
  FindDifferentViewModel(this.args) {
    _question = _buildQuestion();
  }

  final GameRouteArgs args;
  final Random _random = Random();
  Timer? _timer;
  late FindDifferentQuestion _question;

  int round = 0;
  int stars = 0;
  bool firstAttempt = true;
  bool locked = false;
  int? correctIndex;
  int? wrongIndex;
  FindDifferentAnswerState answerState = FindDifferentAnswerState.idle;
  RewardRouteArgs? pendingRewardArgs;

  DifficultyConfig get config => args.difficulty.config;
  FindDifferentQuestion get question => _question;

  void select(int index) {
    if (locked || pendingRewardArgs != null) {
      return;
    }

    final chosen = _question.options[index];
    if (chosen.id == _question.odd.id) {
      locked = true;
      correctIndex = index;
      answerState = FindDifferentAnswerState.correct;
      if (firstAttempt) {
        stars += 1;
      }
      notifyListeners();

      _timer?.cancel();
      _timer = Timer(const Duration(milliseconds: 900), () {
        if (round + 1 >= config.rounds) {
          pendingRewardArgs = RewardRouteArgs(
            gameId: args.gameId,
            difficulty: args.difficulty,
            earnedStars: stars,
            totalRounds: config.rounds,
          );
        } else {
          round += 1;
          firstAttempt = true;
          locked = false;
          correctIndex = null;
          wrongIndex = null;
          answerState = FindDifferentAnswerState.idle;
          _question = _buildQuestion(previousOddId: _question.odd.id);
        }
        notifyListeners();
      });
      return;
    }

    firstAttempt = false;
    locked = true;
    wrongIndex = index;
    answerState = FindDifferentAnswerState.wrong;
    notifyListeners();

    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 650), () {
      locked = false;
      wrongIndex = null;
      answerState = FindDifferentAnswerState.idle;
      notifyListeners();
    });
  }

  void reset() {
    _timer?.cancel();
    round = 0;
    stars = 0;
    firstAttempt = true;
    locked = false;
    correctIndex = null;
    wrongIndex = null;
    answerState = FindDifferentAnswerState.idle;
    pendingRewardArgs = null;
    _question = _buildQuestion();
    notifyListeners();
  }

  FindDifferentQuestion _buildQuestion({String? previousOddId}) {
    final pool = [..._findDifferentCharacters];
    if (previousOddId != null && pool.length > 2) {
      pool.removeWhere((character) => character.id == previousOddId);
    }
    pool.shuffle(_random);
    final common = pool.first;
    final odd = pool[1];
    final oddIndex = _random.nextInt(6);
    final options = List<FindDifferentCharacter>.generate(
      6,
      (index) => index == oddIndex ? odd : common,
    )..shuffle(_random);
    return FindDifferentQuestion(common: common, odd: odd, options: options);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

class FindDifferentPage extends ConsumerStatefulWidget {
  const FindDifferentPage({required this.args, super.key});

  final GameRouteArgs args;

  @override
  ConsumerState<FindDifferentPage> createState() => _FindDifferentPageState();
}

class _FindDifferentPageState extends ConsumerState<FindDifferentPage> {
  bool _isPaused = false;
  late final GameSoundController _soundController;
  late final VoiceGuideController _voiceGuideController;
  late final ProviderSubscription<String> _questionVoiceSubscription;
  late final ProviderSubscription<bool> _voiceGuideSubscription;

  GameRouteArgs get args => widget.args;

  @override
  void initState() {
    super.initState();
    _soundController = ref.read(gameSoundControllerProvider);
    _voiceGuideController = ref.read(voiceGuideControllerProvider);
    _questionVoiceSubscription = ref.listenManual<String>(
      findDifferentViewModelProvider(args).select(
          (viewModel) => '${viewModel.round}-${viewModel.question.odd.id}'),
      (_, __) {
        if (!mounted || _isPaused) {
          return;
        }
        unawaited(_speakCurrentPrompt());
      },
    );
    _voiceGuideSubscription = ref.listenManual<bool>(
      parentDataProvider.select((parentData) => parentData.voiceGuideEnabled),
      (_, enabled) {
        if (!mounted) {
          return;
        }
        if (!enabled) {
          unawaited(_voiceGuideController.stop());
          return;
        }
        if (!_isPaused) {
          unawaited(_speakCurrentPrompt());
        }
      },
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_soundController.startBgm());
      unawaited(_speakCurrentPrompt());
    });
  }

  @override
  void dispose() {
    _questionVoiceSubscription.close();
    _voiceGuideSubscription.close();
    unawaited(_voiceGuideController.stop());
    unawaited(_soundController.stopBgm());
    super.dispose();
  }

  void _handleBack(BuildContext context) {
    unawaited(_voiceGuideController.stop());
    AppRouter.showGameSelect(context);
  }

  void _openPause() {
    if (_isPaused) {
      return;
    }
    unawaited(ref.read(gameSoundControllerProvider).playClick());
    unawaited(_voiceGuideController.stop());
    setState(() {
      _isPaused = true;
    });
  }

  void _closePause() {
    unawaited(ref.read(gameSoundControllerProvider).playClick());
    setState(() {
      _isPaused = false;
    });
    unawaited(_speakCurrentPrompt());
  }

  void _restartGame() {
    unawaited(ref.read(gameSoundControllerProvider).playClick());
    unawaited(_voiceGuideController.stop());
    ref.read(findDifferentViewModelProvider(args)).reset();
    setState(() {
      _isPaused = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<RewardRouteArgs?>(
      findDifferentViewModelProvider(args)
          .select((viewModel) => viewModel.pendingRewardArgs),
      (_, next) {
        if (next != null) {
          unawaited(_voiceGuideController.stop());
          Navigator.pushReplacementNamed(
            context,
            AppRoutes.reward,
            arguments: next,
          );
        }
      },
    );
    ref.listen<FindDifferentAnswerState>(
      findDifferentViewModelProvider(args)
          .select((viewModel) => viewModel.answerState),
      (previous, next) {
        if (previous == next) {
          return;
        }
        if (next != FindDifferentAnswerState.idle) {
          unawaited(_voiceGuideController.stop());
        }
        final soundController = ref.read(gameSoundControllerProvider);
        if (next == FindDifferentAnswerState.correct) {
          unawaited(soundController.playCorrect());
        } else if (next == FindDifferentAnswerState.wrong) {
          unawaited(soundController.playWrong());
        }
      },
    );

    final l10n = context.l10n;
    final viewModel = ref.watch(findDifferentViewModelProvider(args));
    final progress = viewModel.round / viewModel.config.rounds;

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
        palette: _findDifferentPalette,
        roundLabel:
            l10n.roundCounter(viewModel.round + 1, viewModel.config.rounds),
        difficulty: args.difficulty,
        stars: viewModel.stars,
        progress: progress,
        onPause: _openPause,
        backgroundColor: const Color(0xFFF6FFFC),
        showDots: true,
        includeYellowDots: true,
        pauseIcon: const FigmaPauseIcon(size: 18, color: Color(0xFF118A86)),
        floatingAction: const FloatingSoundToggle(
          accentColor: Color(0xFF74E8D8),
          borderColor: Color(0xFF118A86),
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
          switchKey: '${viewModel.round}-${viewModel.question.odd.id}',
          child: Column(
            children: [
              _FindDifferentPromptCard(question: viewModel.question),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: viewModel.question.options.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  mainAxisExtent: 126,
                ),
                itemBuilder: (context, index) {
                  final item = viewModel.question.options[index];
                  return _FindDifferentTile(
                    item: item,
                    correct: viewModel.correctIndex == index,
                    wrong: viewModel.wrongIndex == index,
                    onTap: () => ref
                        .read(findDifferentViewModelProvider(args))
                        .select(index),
                  );
                },
              ),
              const SizedBox(height: 10),
              FigmaGameFeedbackBanner(
                visible: viewModel.answerState != FindDifferentAnswerState.idle,
                text: viewModel.answerState == FindDifferentAnswerState.correct
                    ? l10n.feedbackCorrect
                    : l10n.feedbackTryAgain,
                isPositive:
                    viewModel.answerState == FindDifferentAnswerState.correct,
                palette: _findDifferentPalette,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _speakCurrentPrompt() async {
    if (!mounted || _isPaused) {
      return;
    }

    await _voiceGuideController.speak(
      _findDifferentVoicePrompt(context),
      locale: Localizations.localeOf(context),
    );
  }
}

String _findDifferentVoicePrompt(BuildContext context) {
  return switch (Localizations.localeOf(context).languageCode) {
    'zh' => '请找出不一样的小动物。',
    'ko' => '다른 동물 하나를 찾아봐요.',
    _ => 'Find the one animal that looks different.',
  };
}

class _FindDifferentPromptCard extends StatelessWidget {
  const _FindDifferentPromptCard({required this.question});

  final FindDifferentQuestion question;

  @override
  Widget build(BuildContext context) {
    return FigmaGamePanel(
      palette: _findDifferentPalette,
      radius: 30,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
      child: Column(
        children: [
          Text(
            context.l10n.findDifferentPrompt,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Color(0xFF2C5B58),
            ),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF2FFFC),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: const Color(0xFFBCEEE6),
                width: 2.2,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _PromptMascotChip(character: question.common),
                _PromptMascotChip(character: question.common),
                _PromptMascotChip(character: question.odd, highlighted: true),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PromptMascotChip extends StatelessWidget {
  const _PromptMascotChip({
    required this.character,
    this.highlighted = false,
  });

  final FindDifferentCharacter character;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 76,
      height: 76,
      decoration: BoxDecoration(
        color: character.background.withValues(alpha: highlighted ? 1 : 0.8),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: highlighted ? const Color(0xFFFFC84A) : Colors.white,
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: character.shadow.withValues(alpha: 0.22),
            blurRadius: 0,
            offset: const Offset(4, 4),
          ),
        ],
      ),
      child: Center(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            FigmaMascotAvatar(avatar: character.avatar, size: 42),
            if (highlighted)
              const Positioned(
                right: -8,
                top: -10,
                child: Text(
                  '✨',
                  style: TextStyle(fontSize: 20),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _FindDifferentTile extends StatelessWidget {
  const _FindDifferentTile({
    required this.item,
    required this.correct,
    required this.wrong,
    required this.onTap,
  });

  final FindDifferentCharacter item;
  final bool correct;
  final bool wrong;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: correct || wrong ? 1 : 0),
      duration: Duration(milliseconds: wrong ? 420 : 260),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(wrong ? shakeOffset(value) : 0, 0),
          child: Transform.scale(
            scale: correct ? punchScale(value) : 1,
            child: child,
          ),
        );
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: onTap,
          child: Ink(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: correct
                    ? const Color(0xFFFFC84A)
                    : wrong
                        ? const Color(0xFFFF8A65)
                        : const Color(0xFF8BD8CF),
                width: correct || wrong ? 4.5 : 3,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1E118A86),
                  blurRadius: 0,
                  offset: Offset(4, 4),
                ),
              ],
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Positioned(
                  left: 10,
                  right: 10,
                  top: 10,
                  child: Container(
                    height: 16,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2FFFC),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                Center(
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: item.background,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: item.shadow.withValues(alpha: 0.2),
                          blurRadius: 0,
                          offset: const Offset(3, 3),
                        ),
                      ],
                    ),
                    child: Center(
                      child: FigmaMascotAvatar(avatar: item.avatar, size: 46),
                    ),
                  ),
                ),
                if (correct)
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0x33FFD54F),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Center(
                      child: Text('✨', style: TextStyle(fontSize: 30)),
                    ),
                  ),
                if (wrong)
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0x22FF8A65),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Center(
                      child: Text('💨', style: TextStyle(fontSize: 28)),
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
