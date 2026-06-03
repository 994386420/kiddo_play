// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '儿童益智乐园';

  @override
  String get homeTitle => '儿童益智乐园';

  @override
  String get homeSubtitle => '今天也要认真学习哦！';

  @override
  String get homeStartGame => '开始游戏';

  @override
  String get homeChooseGame => '选择游戏';

  @override
  String get homeParentEntry => '家长中心';

  @override
  String get homeParentComingSoon => '家长入口即将上线。';

  @override
  String get homeWelcomeSubtitle => '今天一起来学习新知识吧！';

  @override
  String homeGreeting(String name) {
    return '$name，今天也要认真学习哦！';
  }

  @override
  String homeWelcomeTitle(String name) {
    return '$name，你好！👋';
  }

  @override
  String get homeParentProtected => '密码保护';

  @override
  String get splashSubtitle => '智慧启航 · 快乐成长';

  @override
  String get gameSelectTitle => '选择游戏';

  @override
  String get gameSelectSubtitle => '通关前一个游戏来解锁新关卡！';

  @override
  String get gameSelectUnlocked => '已解锁';

  @override
  String get gameSelectUnlockSoon => '即将解锁';

  @override
  String get gameSelectLocked => '未解锁';

  @override
  String get gameSelectLockedDescription => '通关上一个游戏来解锁！';

  @override
  String get gameSelectLockedHint => '先完成上一个游戏来解锁这一关吧！';

  @override
  String get difficultyEasy => '简单';

  @override
  String get difficultyMedium => '中等';

  @override
  String get difficultyHard => '困难';

  @override
  String get difficultyEasySummary => '2个选项 · 3道题';

  @override
  String get difficultyMediumSummary => '4个选项 · 5道题';

  @override
  String get difficultyHardSummary => '4个选项 · 7道题';

  @override
  String get difficultyEasyDescription => '轻松有趣，适合初学小朋友！';

  @override
  String get difficultyMediumDescription => '标准难度，正常挑战等你！';

  @override
  String get difficultyHardDescription => '加油，你是最强小天才！';

  @override
  String get difficultySelectTitle => '选择难度';

  @override
  String get difficultySelectSubtitle => '选一个适合你的挑战等级吧！';

  @override
  String get difficultySelectHint => '每道题第一次答对得 1 颗星星，难度越高、获得星星越多！';

  @override
  String get difficultySelectLockedDescription => '通关上一个难度来解锁！';

  @override
  String get difficultySelectLockedHint => '先完成上一个难度，再来挑战这里吧！';

  @override
  String get difficultyOptionCountSuffix => '个选项';

  @override
  String get difficultyRoundCountSuffix => '道题';

  @override
  String get gameColorMatchTitle => '颜色配对';

  @override
  String get gameColorMatchDescription => '认识各种颜色，找到正确的颜色吧！';

  @override
  String get gameNumberTitle => '数字认知';

  @override
  String get gameNumberDescription => '数一数有几个，挑战数数游戏！';

  @override
  String get gameShapeTitle => '形状匹配';

  @override
  String get gameShapeDescription => '认识圆形、三角形、五角星等形状！';

  @override
  String get gameAnimalTitle => '动物声音';

  @override
  String get gameAnimalDescription => '听声音猜动物，认识可爱的小动物！';

  @override
  String get gamePuzzleTitle => '简单拼图';

  @override
  String get gamePuzzleDescription => '把拼图碎片放到正确位置，还原图案！';

  @override
  String get gameFindDifferentTitle => '找不同';

  @override
  String get gameFindDifferentDescription => '找出不一样的那个，练练观察力！';

  @override
  String get gameWhackMoleTitle => '打地鼠';

  @override
  String get gameWhackMoleDescription => '盯紧冒出来的小地鼠，快速点中它！';

  @override
  String get gameMemoryCardTitle => '记忆卡片';

  @override
  String get gameMemoryCardDescription => '记住卡片位置，翻出相同的一对！';

  @override
  String roundCounter(int round, int total) {
    return '第 $round / $total 题';
  }

  @override
  String puzzleRoundCounter(int round, int total) {
    return '第 $round / $total 关';
  }

  @override
  String get colorMatchPrompt => '请找到这个颜色';

  @override
  String get findDifferentPrompt => '找出不一样的那个';

  @override
  String get memoryCardPrompt => '翻出两张一样的卡片';

  @override
  String get memoryCardPairsLabel => '配对';

  @override
  String get memoryCardFlipsLabel => '翻牌';

  @override
  String get memoryCardPreviewHint => '先记住卡片位置，马上开始！';

  @override
  String get whackMolePrompt => '快点中冒出来的小地鼠';

  @override
  String get whackMoleHitsLabel => '击中';

  @override
  String get whackMoleMissesLabel => '漏掉';

  @override
  String get whackMoleGoalLabel => '目标';

  @override
  String get feedbackCorrect => '太棒了！答对啦！';

  @override
  String get feedbackTryAgain => '再试试，你可以的！';

  @override
  String get pauseStatus => '游戏暂停中';

  @override
  String get pauseContinue => '继续游戏';

  @override
  String get pauseRestart => '重新开始';

  @override
  String get pauseQuit => '退出到游戏列表';

  @override
  String get pauseTapOutsideHint => '点击空白处也可继续游戏';

  @override
  String get soundOnTooltip => '开启音效';

  @override
  String get soundOffTooltip => '关闭音效';

  @override
  String get numberPrompt => '数一数，一共有几个？';

  @override
  String get numberCorrect => '数对了！太棒了！';

  @override
  String get numberWrong => '再数一数，你可以的！';

  @override
  String get shapePrompt => '这是什么形状？';

  @override
  String get shapePromptHard => '不用提示，猜猜这是什么形状？';

  @override
  String get shapeCorrect => '形状找到了！棒棒哒！';

  @override
  String get shapeWrong => '再试试，你可以的！';

  @override
  String get shapeHardModeHint => '无名称提示';

  @override
  String get animalPrompt => '听声音，猜猜我是谁？';

  @override
  String get animalPromptHard => '听一次声音，猜猜我是谁？';

  @override
  String get animalPlaySound => '播放声音';

  @override
  String get animalReplay => '再听一次';

  @override
  String get animalReplayBlocked => '困难模式：仅可听一次，加油！';

  @override
  String get animalCorrect => '猜对了！真聪明！';

  @override
  String get animalWrong => '再听听，你可以的！';

  @override
  String get animalHardModeHint => '仅听一次';

  @override
  String get puzzleReference => '参考图';

  @override
  String get puzzlePrompt => '按参考图，把碎片放到正确位置！';

  @override
  String get puzzlePromptHard => '按参考图拼好，没有位置提示哦！';

  @override
  String get puzzlePieceSelected => '已选中碎片，点格子放入';

  @override
  String puzzleSlotLabel(int slot) {
    return '位置 $slot';
  }

  @override
  String get puzzleTrayTitle => '碎片区 — 点击选中，再点格子放入：';

  @override
  String get puzzleHardModeHint => '无位置提示';

  @override
  String get puzzleCorrect => '拼好了！太厉害了！';

  @override
  String get puzzleWrong => '放错啦，再试试其他位置！';

  @override
  String get puzzleSelectHint => '先点选碎片，再点格子放入';

  @override
  String get puzzleTapSlotHint => '很好，接着点一个正确位置吧';

  @override
  String get rewardEncouragement1 => '太厉害了！';

  @override
  String get rewardEncouragement2 => '你真的太棒了！';

  @override
  String get rewardEncouragement3 => '超级无敌棒！';

  @override
  String get rewardEncouragement4 => '小天才！';

  @override
  String get rewardEncouragement5 => '你是最棒的！';

  @override
  String rewardCompleted(String gameName) {
    return '你完成了 $gameName 挑战！';
  }

  @override
  String rewardDifficultyLabel(String difficulty) {
    return '难度：$difficulty';
  }

  @override
  String rewardStarsResult(int earned, int total) {
    return '获得 $earned / $total 颗星星！';
  }

  @override
  String get rewardUnlockedTitle => '新游戏已解锁！';

  @override
  String rewardUnlockedDescription(String emoji, String gameName) {
    return '$emoji $gameName — 快去挑战吧！';
  }

  @override
  String get rewardPlayAgain => '再玩一次';

  @override
  String get rewardTryOtherDifficulty => '换个难度再挑战';

  @override
  String get rewardChooseOtherGame => '选其他游戏';

  @override
  String get rewardBackHome => '返回首页';

  @override
  String get parentDashboardHeaderTag => 'PARENT CENTER';

  @override
  String get parentDashboardTitle => '家长中心 👨‍👩‍👧';

  @override
  String get parentTabOverview => '概览';

  @override
  String get parentTabProgress => '进度';

  @override
  String get parentTabSettings => '设置';

  @override
  String get parentOverviewStars => '累计星星';

  @override
  String get parentOverviewUnlockedGames => '已解锁游戏';

  @override
  String get parentOverviewPlayed => '总游玩次数';

  @override
  String get parentOverviewTodayStars => '今日获星';

  @override
  String get parentOverviewProfileTitle => '你的小宝贝';

  @override
  String parentOverviewTotalStars(int count) {
    return '共获得 $count 颗星星';
  }

  @override
  String get parentOverviewRecentTitle => '📋 近期游玩记录';

  @override
  String get parentOverviewNoActivity => '还没有游玩记录哦';

  @override
  String parentProgressSummary(int total, int unlocked) {
    return '共 $total 个游戏 · 已解锁 $unlocked 个';
  }

  @override
  String get parentProgressUnlocked => '🔓 已解锁';

  @override
  String get parentProgressLocked => '🔒 未解锁';

  @override
  String get parentProgressNotStarted => '还未开始游玩';

  @override
  String get parentProgressLockedHint => '通关前一个游戏来解锁';

  @override
  String parentProgressPlayedCount(int count) {
    return '已游玩 $count 次';
  }

  @override
  String parentProgressDifficultyTag(String difficulty) {
    return '最近：$difficulty';
  }

  @override
  String get parentProgressUnknownDifficulty => '未知';

  @override
  String get parentProgressBestRate => '最佳得星率';

  @override
  String parentProgressLastPlayed(String time) {
    return '📅 最后游玩：$time';
  }

  @override
  String get parentSettingsProfileSection => '👶 宝宝档案';

  @override
  String get parentSettingsAvatarTitle => '宝宝头像';

  @override
  String get parentSettingsAvatarSubtitle => '点击头像更换';

  @override
  String get parentSettingsNameHint => '宝宝的昵称';

  @override
  String get parentSettingsSave => '保存';

  @override
  String get parentSettingsAppSection => '⚙️ 应用设置';

  @override
  String get parentSettingsSoundTitle => '游戏音效';

  @override
  String get parentSettingsSoundOn => '已开启';

  @override
  String get parentSettingsSoundOff => '已关闭';

  @override
  String get parentSettingsSecuritySection => '🔒 安全';

  @override
  String get parentSettingsChangePinTitle => '修改密码';

  @override
  String get parentSettingsChangePinSubtitle => '更改家长中心的4位密码';

  @override
  String get parentSettingsDangerSection => '⚠️ 危险区域';

  @override
  String get parentSettingsResetWarning => '重置后，宝宝的所有游玩记录、星星、解锁进度将被清除，且无法恢复。';

  @override
  String get parentSettingsResetButton => '重置全部学习进度';

  @override
  String get parentSettingsResetDone => '已成功重置！';

  @override
  String get parentSettingsResetConfirmTitle => '确定要重置吗？';

  @override
  String get parentSettingsResetConfirmBody => '这将清除宝宝的所有星星、游玩记录和解锁进度，操作不可撤销。';

  @override
  String get parentSettingsCancel => '取消';

  @override
  String get parentSettingsConfirmReset => '确认重置';

  @override
  String parentTimeToday(String time) {
    return '今天 $time';
  }

  @override
  String parentTimeYesterday(String time) {
    return '昨天 $time';
  }

  @override
  String parentTimeDate(int month, int day, String time) {
    return '$month月$day日 $time';
  }

  @override
  String get parentPinErrorWrong => '密码错误，请重试';

  @override
  String get parentPinErrorMismatch => '两次输入不一致，请重新设置';

  @override
  String get parentPinTitleVerify => '家长验证';

  @override
  String get parentPinTitleSetup => '设置密码';

  @override
  String get parentPinTitleConfirm => '确认密码';

  @override
  String get parentPinTitleChange => '设置新密码';

  @override
  String get parentPinTitleChangeConfirm => '确认新密码';

  @override
  String get parentPinSubtitleVerify => '请输入4位密码进入家长中心';

  @override
  String get parentPinSubtitleSetup => '为家长中心设置一个4位专属密码';

  @override
  String get parentPinSubtitleConfirm => '请再次输入相同的4位密码';

  @override
  String get parentPinSubtitleChange => '请输入您的新4位密码';

  @override
  String get parentPinSubtitleChangeConfirm => '请再次输入相同的新密码';

  @override
  String get parentPinSuccess => '✅ 验证成功，正在进入…';

  @override
  String parentPinDefaultHint(String pin) {
    return '忘记密码？默认密码为 $pin';
  }

  @override
  String get parentPinSetupHint => '💡 此密码用于防止儿童误入家长中心，仅作简单保护用途。';
}
