// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => '키드도 플레이';

  @override
  String get homeTitle => '키드도 플레이랜드';

  @override
  String get homeSubtitle => '오늘도 함께 배우고 놀아요!';

  @override
  String get homeStartGame => '게임 시작';

  @override
  String get homeChooseGame => '게임 선택';

  @override
  String get homeParentEntry => '부모 센터';

  @override
  String get homeParentComingSoon => '부모 센터는 곧 만나볼 수 있어요.';

  @override
  String get homeWelcomeSubtitle => '오늘 새로운 걸 함께 발견해요!';

  @override
  String homeGreeting(String name) {
    return '$name님, 오늘도 차근차근 배워봐요!';
  }

  @override
  String homeWelcomeTitle(String name) {
    return '안녕, $name님! 👋';
  }

  @override
  String get homeParentProtected => 'PIN 보호';

  @override
  String get splashSubtitle => '반짝이는 마음, 행복한 성장';

  @override
  String get gameSelectTitle => '게임 선택';

  @override
  String get gameSelectSubtitle => '앞 게임을 완료하면 다음 게임이 열려요!';

  @override
  String get gameSelectUnlocked => '해제됨';

  @override
  String get gameSelectUnlockSoon => '곧 열림';

  @override
  String get gameSelectLocked => '잠김';

  @override
  String get gameSelectLockedDescription => '앞 게임을 완료하면 이 게임이 열려요!';

  @override
  String get gameSelectLockedHint => '먼저 앞 게임을 끝내고 이 스테이지를 열어봐요!';

  @override
  String get difficultyEasy => '쉬움';

  @override
  String get difficultyMedium => '보통';

  @override
  String get difficultyHard => '어려움';

  @override
  String get difficultyEasySummary => '2개 선택지 · 3라운드';

  @override
  String get difficultyMediumSummary => '4개 선택지 · 5라운드';

  @override
  String get difficultyHardSummary => '4개 선택지 · 7라운드';

  @override
  String get difficultyEasyDescription => '처음 배우는 친구에게 부드럽고 재미있어요!';

  @override
  String get difficultyMediumDescription => '오늘의 적당한 도전이에요!';

  @override
  String get difficultyHardDescription => '우리 작은 고수들을 위한 더 큰 도전이에요!';

  @override
  String get difficultySelectTitle => '난이도 선택';

  @override
  String get difficultySelectSubtitle => '가장 잘 맞는 도전을 골라봐요!';

  @override
  String get difficultySelectHint =>
      '처음 시도에 맞추면 별 1개를 받아요. 난이도가 높을수록 더 많이 빛날 기회가 있어요!';

  @override
  String get difficultySelectLockedDescription => '앞 난이도를 끝내면 열려요!';

  @override
  String get difficultySelectLockedHint => '먼저 앞 난이도를 끝내고 다시 도전해요!';

  @override
  String get difficultyOptionCountSuffix => '개 선택지';

  @override
  String get difficultyRoundCountSuffix => '라운드';

  @override
  String get gameColorMatchTitle => '색깔 맞추기';

  @override
  String get gameColorMatchDescription => '색깔을 배우고 같은 색을 찾아봐요!';

  @override
  String get gameNumberTitle => '숫자 놀이';

  @override
  String get gameNumberDescription => '차근차근 세고 맞는 숫자를 골라봐요!';

  @override
  String get gameShapeTitle => '모양 맞추기';

  @override
  String get gameShapeDescription => '원, 삼각형, 별 등을 찾아봐요!';

  @override
  String get gameAnimalTitle => '동물 소리';

  @override
  String get gameAnimalDescription => '소리를 잘 듣고 동물을 맞혀봐요!';

  @override
  String get gamePuzzleTitle => '간단 퍼즐';

  @override
  String get gamePuzzleDescription => '조각을 제자리에 놓아 그림을 완성해요!';

  @override
  String get gameFindDifferentTitle => '다른 그림 찾기';

  @override
  String get gameFindDifferentDescription => '다른 하나를 찾아보며 관찰력을 키워요!';

  @override
  String get gameWhackMoleTitle => '두더지 잡기';

  @override
  String get gameWhackMoleDescription => '쏙 올라오는 두더지를 빠르게 눌러봐요!';

  @override
  String get gameMemoryCardTitle => '메모리 카드';

  @override
  String get gameMemoryCardDescription => '카드 위치를 기억하고 같은 짝을 찾아요!';

  @override
  String roundCounter(int round, int total) {
    return '$round / $total 라운드';
  }

  @override
  String puzzleRoundCounter(int round, int total) {
    return '$round / $total 레벨';
  }

  @override
  String get colorMatchPrompt => '이 색을 찾아볼 수 있나요?';

  @override
  String get findDifferentPrompt => '다른 하나를 찾아봐요';

  @override
  String get memoryCardPrompt => '같은 카드 두 장을 뒤집어봐요';

  @override
  String get memoryCardPairsLabel => '짝';

  @override
  String get memoryCardFlipsLabel => '뒤집기';

  @override
  String get memoryCardPreviewHint => '카드 위치를 먼저 기억해봐요. 곧 시작해요!';

  @override
  String get whackMolePrompt => '올라오는 두더지를 바로 눌러봐요';

  @override
  String get whackMoleHitsLabel => '성공';

  @override
  String get whackMoleMissesLabel => '놓침';

  @override
  String get whackMoleGoalLabel => '목표';

  @override
  String get feedbackCorrect => '대단해요! 맞혔어요!';

  @override
  String get feedbackTryAgain => '다시 해봐요, 할 수 있어요!';

  @override
  String get pauseStatus => '게임이 일시정지되었어요';

  @override
  String get pauseContinue => '계속하기';

  @override
  String get pauseRestart => '다시 시작';

  @override
  String get pauseQuit => '게임 목록으로 나가기';

  @override
  String get pauseTapOutsideHint => '대화상자 바깥을 눌러도 계속할 수 있어요';

  @override
  String get soundOnTooltip => '소리 켜기';

  @override
  String get soundOffTooltip => '소리 끄기';

  @override
  String get numberPrompt => '몇 개가 보이나요?';

  @override
  String get numberCorrect => '멋져요! 정답이에요!';

  @override
  String get numberWrong => '다시 차근차근 세어봐요!';

  @override
  String get shapePrompt => '이건 어떤 모양인가요?';

  @override
  String get shapePromptHard => '힌트 없이 이 모양의 이름을 맞혀봐요?';

  @override
  String get shapeCorrect => '모양을 찾았어요! 잘했어요!';

  @override
  String get shapeWrong => '거의 다 왔어요, 다른 걸 골라봐요!';

  @override
  String get shapeHardModeHint => '이름 힌트 없음';

  @override
  String get animalPrompt => '소리를 듣고 누군지 맞혀봐요?';

  @override
  String get animalPromptHard => '한 번만 듣고 동물을 맞혀봐요?';

  @override
  String get animalPlaySound => '소리 듣기';

  @override
  String get animalReplay => '다시 듣기';

  @override
  String get animalReplayBlocked => '어려움 모드: 한 번만 들을 수 있어요!';

  @override
  String get animalCorrect => '맞혔어요! 정말 대단해요!';

  @override
  String get animalWrong => '머릿속으로 다시 들어보고 한 번 더 도전해요!';

  @override
  String get animalHardModeHint => '한 번만 듣기';

  @override
  String get puzzleReference => '참고 그림';

  @override
  String get puzzlePrompt => '각 조각을 제자리에 놓아봐요.';

  @override
  String get puzzlePromptHard => '위치 힌트 없이 참고 그림과 맞춰봐요.';

  @override
  String get puzzlePieceSelected => '조각이 선택되었어요. 칸을 눌러 넣어봐요';

  @override
  String puzzleSlotLabel(int slot) {
    return '$slot번 칸';
  }

  @override
  String get puzzleTrayTitle => '조각 상자 - 조각을 누르고, 그다음 칸을 눌러요:';

  @override
  String get puzzleHardModeHint => '위치 힌트 없음';

  @override
  String get puzzleCorrect => '퍼즐 완성! 훌륭해요!';

  @override
  String get puzzleWrong => '그 조각은 맞지 않아요. 다른 곳을 골라봐요!';

  @override
  String get puzzleSelectHint => '먼저 조각을 고르고, 그다음 칸을 눌러요.';

  @override
  String get puzzleTapSlotHint => '좋아요, 이제 맞는 칸을 눌러봐요.';

  @override
  String get rewardEncouragement1 => '정말 잘했어요!';

  @override
  String get rewardEncouragement2 => '최고였어요!';

  @override
  String get rewardEncouragement3 => '슈퍼스타 같아요!';

  @override
  String get rewardEncouragement4 => '작은 천재예요!';

  @override
  String get rewardEncouragement5 => '정말 잘하고 있어요!';

  @override
  String rewardCompleted(String gameName) {
    return '$gameName을(를) 완료했어요!';
  }

  @override
  String rewardDifficultyLabel(String difficulty) {
    return '난이도: $difficulty';
  }

  @override
  String rewardStarsResult(int earned, int total) {
    return '별 $earned / $total개를 받았어요!';
  }

  @override
  String get rewardUnlockedTitle => '새 게임이 열렸어요!';

  @override
  String rewardUnlockedDescription(String emoji, String gameName) {
    return '$emoji $gameName 이제 다음 도전을 시작해요!';
  }

  @override
  String get rewardPlayAgain => '다시 플레이';

  @override
  String get rewardTryOtherDifficulty => '다른 난이도 도전';

  @override
  String get rewardChooseOtherGame => '다른 게임 선택';

  @override
  String get rewardBackHome => '홈으로';

  @override
  String get parentDashboardHeaderTag => '부모 센터';

  @override
  String get parentDashboardTitle => '부모 센터 👨‍👩‍👧';

  @override
  String get parentTabOverview => '개요';

  @override
  String get parentTabProgress => '진행';

  @override
  String get parentTabSettings => '설정';

  @override
  String get parentOverviewStars => '총 별';

  @override
  String get parentOverviewUnlockedGames => '해제된 게임';

  @override
  String get parentOverviewPlayed => '총 플레이 횟수';

  @override
  String get parentOverviewTodayStars => '오늘의 별';

  @override
  String get parentOverviewProfileTitle => '우리 작은 학습자';

  @override
  String parentOverviewTotalStars(int count) {
    return '총 $count개의 별을 받았어요';
  }

  @override
  String get parentOverviewRecentTitle => '📋 최근 활동';

  @override
  String get parentOverviewNoActivity => '아직 플레이 기록이 없어요';

  @override
  String parentProgressSummary(int total, int unlocked) {
    return '$total개 게임 중 $unlocked개가 열렸어요';
  }

  @override
  String get parentProgressUnlocked => '🔓 해제됨';

  @override
  String get parentProgressLocked => '🔒 잠김';

  @override
  String get parentProgressNotStarted => '아직 플레이하지 않았어요';

  @override
  String get parentProgressLockedHint => '앞 게임을 완료하면 열려요';

  @override
  String parentProgressPlayedCount(int count) {
    return '$count번 플레이했어요';
  }

  @override
  String parentProgressDifficultyTag(String difficulty) {
    return '최근: $difficulty';
  }

  @override
  String get parentProgressUnknownDifficulty => '알 수 없음';

  @override
  String get parentProgressBestRate => '최고 별 획득률';

  @override
  String parentProgressLastPlayed(String time) {
    return '📅 마지막 플레이: $time';
  }

  @override
  String get parentSettingsProfileSection => '👶 아이 프로필';

  @override
  String get parentSettingsAvatarTitle => '아바타';

  @override
  String get parentSettingsAvatarSubtitle => '아바타를 눌러 바꿔요';

  @override
  String get parentSettingsNameHint => '아이 별명';

  @override
  String get parentSettingsSave => '저장';

  @override
  String get parentSettingsAppSection => '⚙️ 앱 설정';

  @override
  String get parentSettingsSoundTitle => '게임 소리';

  @override
  String get parentSettingsSoundOn => '켜짐';

  @override
  String get parentSettingsSoundOff => '꺼짐';

  @override
  String get parentSettingsSecuritySection => '🔒 보안';

  @override
  String get parentSettingsChangePinTitle => 'PIN 변경';

  @override
  String get parentSettingsChangePinSubtitle => '4자리 부모 PIN을 변경해요';

  @override
  String get parentSettingsDangerSection => '⚠️ 위험 구역';

  @override
  String get parentSettingsResetWarning =>
      '초기화하면 모든 별, 플레이 기록, 해제 진행이 지워져요. 되돌릴 수 없어요.';

  @override
  String get parentSettingsResetButton => '모든 학습 진행 초기화';

  @override
  String get parentSettingsResetDone => '초기화가 완료되었어요!';

  @override
  String get parentSettingsResetConfirmTitle => '모두 초기화할까요?';

  @override
  String get parentSettingsResetConfirmBody =>
      '모든 별, 플레이 기록, 해제된 게임 진행이 삭제돼요. 이 작업은 되돌릴 수 없어요.';

  @override
  String get parentSettingsCancel => '취소';

  @override
  String get parentSettingsConfirmReset => '초기화 확인';

  @override
  String parentTimeToday(String time) {
    return '오늘 $time';
  }

  @override
  String parentTimeYesterday(String time) {
    return '어제 $time';
  }

  @override
  String parentTimeDate(int month, int day, String time) {
    return '$month월 $day일 $time';
  }

  @override
  String get parentPinErrorWrong => 'PIN이 올바르지 않아요. 다시 시도해요.';

  @override
  String get parentPinErrorMismatch => '두 PIN이 일치하지 않아요. 다시 설정해요.';

  @override
  String get parentPinTitleVerify => '부모 인증';

  @override
  String get parentPinTitleSetup => 'PIN 설정';

  @override
  String get parentPinTitleConfirm => 'PIN 확인';

  @override
  String get parentPinTitleChange => '새 PIN 설정';

  @override
  String get parentPinTitleChangeConfirm => '새 PIN 확인';

  @override
  String get parentPinSubtitleVerify => '4자리 PIN을 입력해 부모 센터를 열어요';

  @override
  String get parentPinSubtitleSetup => '부모 센터용 4자리 PIN을 만들어봐요';

  @override
  String get parentPinSubtitleConfirm => '같은 4자리 PIN을 다시 입력해요';

  @override
  String get parentPinSubtitleChange => '새로운 4자리 PIN을 입력해요';

  @override
  String get parentPinSubtitleChangeConfirm => '같은 새 PIN을 다시 입력해요';

  @override
  String get parentPinSuccess => '✅ 인증되었어요. 부모 센터를 여는 중…';

  @override
  String parentPinDefaultHint(String pin) {
    return '잊으셨나요? 기본 PIN은 $pin이에요';
  }

  @override
  String get parentPinSetupHint =>
      '💡 이 PIN은 아이가 실수로 부모 센터에 들어가는 걸 막아줘요. 간단한 보호 단계예요.';
}
