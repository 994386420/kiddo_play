import 'package:flutter/material.dart';

import '../core/game_models.dart';
import '../features/difficulty_select/difficulty_select_page.dart';
import '../features/game_select/game_select_page.dart';
import '../features/games/animal_sound/animal_sound_page.dart';
import '../features/games/color_match/color_match_page.dart';
import '../features/games/number_game/number_game_page.dart';
import '../features/games/shape_match/shape_match_page.dart';
import '../features/games/simple_puzzle/simple_puzzle_page.dart';
import '../features/home/home_page.dart';
import '../features/parent/parent_dashboard_page.dart';
import '../features/parent/parent_pin_page.dart';
import '../features/reward/reward_page.dart';
import '../features/splash/splash_page.dart';
import 'route_args.dart';

final appRouteObserver = RouteObserver<ModalRoute<dynamic>>();

enum AppRouteTransitionDirection { forward, backward }

abstract final class AppRoutes {
  static const splash = '/';
  static const home = '/home';
  static const gameSelect = '/select';
  static const difficulty = '/difficulty';
  static const colorMatch = '/color-match';
  static const numberGame = '/number-game';
  static const shapeMatch = '/shape-match';
  static const animalSound = '/animal-sound';
  static const simplePuzzle = '/simple-puzzle';
  static const reward = '/reward';
  static const parentPin = '/parent-pin';
  static const parentDashboard = '/parent';
}

abstract final class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    return _route(settings);
  }

  static Future<T?> pushBackwardAndRemoveUntil<T extends Object?>(
    BuildContext context, {
    required String name,
    Object? arguments,
    required RoutePredicate predicate,
  }) {
    final route = _route(
      RouteSettings(name: name, arguments: arguments),
      direction: AppRouteTransitionDirection.backward,
    ) as Route<T>;

    return Navigator.of(context).pushAndRemoveUntil<T>(
      route,
      predicate,
    );
  }

  static Route<dynamic> _route(
    RouteSettings settings, {
    AppRouteTransitionDirection direction = AppRouteTransitionDirection.forward,
  }) {
    final child = _buildPage(settings);
    return _page(settings, child, direction: direction);
  }

  static Widget _buildPage(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return const SplashPage();
      case AppRoutes.home:
        return const HomePage();
      case AppRoutes.gameSelect:
        return const GameSelectPage();
      case AppRoutes.difficulty:
        final args = settings.arguments as DifficultyRouteArgs;
        return DifficultySelectPage(args: args);
      case AppRoutes.colorMatch:
        final args = _gameArgs(settings, GameId.colorMatch);
        return ColorMatchPage(args: args);
      case AppRoutes.numberGame:
        final args = _gameArgs(settings, GameId.numberGame);
        return NumberGamePage(args: args);
      case AppRoutes.shapeMatch:
        final args = _gameArgs(settings, GameId.shapeMatch);
        return ShapeMatchPage(args: args);
      case AppRoutes.animalSound:
        final args = _gameArgs(settings, GameId.animalSound);
        return AnimalSoundPage(args: args);
      case AppRoutes.simplePuzzle:
        final args = _gameArgs(settings, GameId.simplePuzzle);
        return SimplePuzzlePage(args: args);
      case AppRoutes.reward:
        final args = settings.arguments as RewardRouteArgs;
        return RewardPage(args: args);
      case AppRoutes.parentPin:
        final args = settings.arguments is ParentPinRouteArgs
            ? settings.arguments as ParentPinRouteArgs
            : const ParentPinRouteArgs();
        return ParentPinPage(args: args);
      case AppRoutes.parentDashboard:
        return const ParentDashboardPage();
      default:
        return const HomePage();
    }
  }

  static GameRouteArgs _gameArgs(
      RouteSettings settings, GameId fallbackGameId) {
    final args = settings.arguments;
    if (args is GameRouteArgs) {
      return args;
    }

    return GameRouteArgs(
      gameId: fallbackGameId,
      difficulty: GameDifficulty.medium,
    );
  }

  static PageRouteBuilder<dynamic> _page(
    RouteSettings settings,
    Widget child, {
    AppRouteTransitionDirection direction = AppRouteTransitionDirection.forward,
  }) {
    final isBackward = direction == AppRouteTransitionDirection.backward;

    return PageRouteBuilder<void>(
      settings: settings,
      transitionDuration: Duration(milliseconds: isBackward ? 300 : 380),
      reverseTransitionDuration: Duration(milliseconds: isBackward ? 260 : 340),
      pageBuilder: (_, __, ___) => child,
      transitionsBuilder: (context, animation, secondaryAnimation, pageChild) {
        final primaryCurve = CurvedAnimation(
          parent: animation,
          curve: isBackward ? Curves.easeOutCubic : Curves.easeOutQuart,
          reverseCurve: Curves.easeOutCubic,
        );
        final secondaryCurve = CurvedAnimation(
          parent: secondaryAnimation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeOutCubic,
        );

        return SlideTransition(
          position: Tween<Offset>(
            begin: isBackward ? const Offset(-0.08, 0) : const Offset(0.14, 0),
            end: Offset.zero,
          ).animate(primaryCurve),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: Offset.zero,
              end: isBackward ? const Offset(0.04, 0) : const Offset(-0.08, 0),
            ).animate(secondaryCurve),
            child: FadeTransition(
              opacity: Tween<double>(begin: isBackward ? 0.94 : 0.88, end: 1)
                  .animate(
                CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOut,
                  reverseCurve: Curves.easeOut,
                ),
              ),
              child: pageChild,
            ),
          ),
        );
      },
    );
  }
}
