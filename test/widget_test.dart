import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:kiddo_play/app/app.dart';
import 'package:kiddo_play/app/route_args.dart';
import 'package:kiddo_play/app/router.dart';
import 'package:kiddo_play/core/app_controllers.dart';
import 'package:kiddo_play/core/game_models.dart';
import 'package:kiddo_play/core/widgets/figma_home_icons.dart';
import 'package:kiddo_play/features/difficulty_select/difficulty_select_page.dart';
import 'package:kiddo_play/features/games/number_game/number_game_page.dart';
import 'package:kiddo_play/features/home/home_page.dart';
import 'package:kiddo_play/l10n/app_localizations.dart';

Widget _buildTestApp(
  SharedPreferences preferences, {
  Widget home = const HomePage(),
}) {
  return ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(preferences),
    ],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: const Locale('zh'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: home,
      onGenerateRoute: AppRouter.onGenerateRoute,
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('app boots into splash content', (tester) async {
    final preferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(preferences),
        ],
        child: const KiddoPlayApp(),
      ),
    );
    await tester.pump();

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('Kiddo Playland'), findsOneWidget);
  });

  testWidgets('quick start opens color match difficulty on first use',
      (tester) async {
    final preferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(_buildTestApp(preferences));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('开始游戏'), findsOneWidget);

    await tester.tap(find.text('开始游戏'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('选择难度'), findsOneWidget);
    expect(find.text('颜色配对'), findsOneWidget);
  });

  testWidgets('quick start shows last played game and choose game opens list',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'kidapp_activity_log':
          '[{"gameId":"color-match","stars":3,"total":3,"difficulty":"easy","timestamp":"2026-04-30T10:00:00.000"}]',
    });
    final preferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(_buildTestApp(preferences));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('上次：'), findsOneWidget);
    expect(find.text('颜色配对'), findsOneWidget);

    await tester.ensureVisible(find.text('选择游戏'));
    await tester.tap(find.text('选择游戏'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('选择游戏'), findsWidgets);
    expect(find.text('颜色配对'), findsOneWidget);
    expect(find.text('找不同'), findsOneWidget);
    expect(find.text('打地鼠'), findsOneWidget);
    expect(find.text('记忆卡片'), findsOneWidget);
  });

  testWidgets('medium and hard difficulties start locked', (tester) async {
    final preferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      _buildTestApp(
        preferences,
        home: const DifficultySelectPage(
          args: DifficultyRouteArgs(gameId: GameId.colorMatch),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(FigmaLockIcon), findsNWidgets(2));

    await tester.tap(find.text('中等'));
    await tester.pump();

    expect(find.text('选择难度'), findsOneWidget);
    expect(find.text('第 1 / 5 题'), findsNothing);
  });

  testWidgets('completing easy unlocks medium but keeps hard locked',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'kidapp_game_stats':
          '{"color-match":{"played":1,"totalStars":3,"bestStars":3,"bestTotal":3,"lastPlayed":"2026-04-30T10:00:00.000","lastDifficulty":"easy","highestCompletedDifficulty":"easy"}}',
    });
    final preferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      _buildTestApp(
        preferences,
        home: const DifficultySelectPage(
          args: DifficultyRouteArgs(gameId: GameId.colorMatch),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(FigmaFloatIcon), findsNWidgets(2));
    expect(find.byType(FigmaLockIcon), findsOneWidget);

    await tester.tap(find.text('中等'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('第 1 / 5 题'), findsOneWidget);
  });

  testWidgets('number game advances after a correct answer', (tester) async {
    final preferences = await SharedPreferences.getInstance();
    const args = GameRouteArgs(
      gameId: GameId.numberGame,
      difficulty: GameDifficulty.easy,
    );

    await tester.pumpWidget(
      _buildTestApp(
        preferences,
        home: const NumberGamePage(args: args),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('第 1 / 3 题'), findsOneWidget);

    final container = ProviderScope.containerOf(
      tester.element(find.byType(NumberGamePage)),
    );
    final correctAnswer =
        container.read(numberGameViewModelProvider(args)).question.count;
    final answerFinder = find.byWidgetPredicate((widget) {
      return widget is Text &&
          widget.data == '$correctAnswer' &&
          widget.style?.fontSize == 50;
    });
    final answerCardFinder = find.ancestor(
      of: answerFinder.first,
      matching: find.byType(InkWell),
    );

    expect(answerCardFinder, findsOneWidget);
    await tester.tap(answerCardFinder);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1200));

    expect(find.text('第 2 / 3 题'), findsOneWidget);
  });
}
