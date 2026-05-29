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

  static bool popUntilNamed(BuildContext context, String name) {
    var found = false;
    Navigator.of(context).popUntil((route) {
      final matches = route.settings.name == name;
      found = found || matches;
      return matches || route.isFirst;
    });
    return found;
  }

  static void showHome(BuildContext context) {
    final found = popUntilNamed(context, AppRoutes.home);
    if (!found) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.home,
        (_) => false,
      );
    }
  }

  static void showGameSelect(BuildContext context) {
    final found = popUntilNamed(context, AppRoutes.gameSelect);
    if (!found) {
      Navigator.of(context).pushNamed(AppRoutes.gameSelect);
    }
  }

  static void popCurrentOrShowHome(BuildContext context) {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
      return;
    }
    showHome(context);
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
    return PageRouteBuilder<void>(
      settings: settings,
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
      pageBuilder: (_, __, ___) => child,
      transitionsBuilder: (_, __, ___, pageChild) => pageChild,
    );
  }
}
