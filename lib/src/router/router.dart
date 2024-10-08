// ignore_for_file: use_build_context_synchronously

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';
import 'package:mind_cows/src/core/exceptions.dart';
import 'package:mind_cows/src/core/utils/object_extensions.dart';
import 'package:mind_cows/src/features/auth/views/auth_screen.dart';
import 'package:mind_cows/src/features/auth/views/signup_screen.dart';
import 'package:mind_cows/src/features/game/game_screen.dart';
import 'package:mind_cows/src/features/game/search_game_screen.dart';
import 'package:mind_cows/src/features/home/home_screen.dart';
import 'package:mind_cows/src/features/settings/data/model/rules.dart';
import 'package:mind_cows/src/features/settings/pages/how_to_play_screen.dart';
import 'package:mind_cows/src/features/settings/pages/settings_screen.dart';
import 'package:mind_cows/src/features/splash/splash_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum AppRoute {
  splash,
  // initProfileData,
  auth,
  signUp,
  home,
  game,
  searchGame,
  settings,
  howToPlay,
}

final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

@singleton
final class RouterController {
  RouterController(this._client) {
    final currentSession = _client.auth.currentSession;
    router = GoRouter(
      debugLogDiagnostics: kDebugMode,
      initialLocation: currentSession.isNull ? '/auth' : '/splash',
      navigatorKey: rootNavigatorKey,
      redirect: (context, state) {
        return null;
      },
      routes: [
        GoRoute(
          path: '/splash',
          name: AppRoute.splash.name,
          pageBuilder: (context, state) {
            return adaptivePageRoute(
              key: ValueKey(state.pageKey.value),
              child: const SplashScreen(),
            );
          },
        ),
        GoRoute(
          path: '/auth',
          name: AppRoute.auth.name,
          pageBuilder: (context, state) {
            return adaptivePageRoute(
              key: ValueKey(state.pageKey.value),
              child: const AuthScreen(),
            );
          },
        ),
        GoRoute(
          path: '/signUp',
          name: AppRoute.signUp.name,
          pageBuilder: (context, state) {
            return adaptivePageRoute(
              key: ValueKey(state.pageKey.value),
              child: const SignUpScreen(),
            );
          },
        ),
        GoRoute(
          path: '/home',
          name: AppRoute.home.name,
          pageBuilder: (context, state) {
            return adaptivePageRoute(
              key: ValueKey(state.pageKey.value),
              child: const HomeScreen(),
            );
          },
          routes: [
            GoRoute(
              path: 'search-game',
              name: AppRoute.searchGame.name,
              pageBuilder: (context, state) {
                return adaptivePageRoute(
                  key: ValueKey(state.pageKey.value),
                  child: const SearchGameScreen(),
                );
              },
            ),
            GoRoute(
              path: 'game',
              name: AppRoute.game.name,
              pageBuilder: (context, state) {
                return adaptivePageRoute(
                  key: ValueKey(state.pageKey.value),
                  child: const GameScreen(),
                );
              },
            ),
            GoRoute(
              path: 'settings',
              name: AppRoute.settings.name,
              pageBuilder: (context, state) {
                return adaptivePageRoute(
                  key: ValueKey(state.pageKey.value),
                  child: const SettingsScreen(),
                );
              },
              routes: [
                GoRoute(
                  path: 'how-to-play',
                  name: AppRoute.howToPlay.name,
                  pageBuilder: (context, state) {
                    final rules = extraFromState<Rules>(state);
                    return adaptivePageRoute(
                      key: ValueKey(state.pageKey.value),
                      child: HowToPlayScreen(rules: rules),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  final SupabaseClient _client;
  late final GoRouter router;
}

/// Adaptive route that uses cupertino pages on iOS and macos, no transitions on web and material on the rest of the
/// platforms.
Page<T> adaptivePageRoute<T>({
  required LocalKey key,
  required Widget child,
  bool maintainState = true,
  bool fullscreenDialog = false,
  bool allowSnapshotting = true,
  String? name,
  String? title,
  Object? arguments,
  String? restorationId,
}) {
  final iosPlatforms = [TargetPlatform.iOS, TargetPlatform.macOS];
  if (iosPlatforms.contains(defaultTargetPlatform)) {
    return CupertinoPage<T>(
      key: key,
      child: child,
      name: name,
      title: title,
      allowSnapshotting: allowSnapshotting,
      arguments: arguments,
      fullscreenDialog: fullscreenDialog,
      maintainState: maintainState,
      restorationId: restorationId,
    );
  }
  return MaterialPage<T>(
    key: key,
    child: child,
    name: name,
    allowSnapshotting: allowSnapshotting,
    arguments: arguments,
    fullscreenDialog: fullscreenDialog,
    maintainState: maintainState,
    restorationId: restorationId,
  );
}

T extraFromState<T>(GoRouterState state, [T? orElse]) {
  if (state.extra is T) {
    return state.extra as T;
  } else {
    if (orElse != null) return orElse;
    throw Exception(state.uri.path);
  }
}
