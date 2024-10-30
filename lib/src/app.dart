import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mind_cows/l10n/l10n.dart';
import 'package:mind_cows/src/core/di/dependency_injection.dart';
import 'package:mind_cows/src/core/ui/theme.dart';
import 'package:mind_cows/src/features/auth/cubit/auth_cubit.dart';
import 'package:mind_cows/src/features/game/cubit/game_cubit.dart';
import 'package:mind_cows/src/features/player/cubit/player_cubit.dart';
import 'package:mind_cows/src/features/ranking/cubit/ranking_cubit.dart';
import 'package:mind_cows/src/features/settings/cubit/settings_cubit.dart';
import 'package:mind_cows/src/features/splash/cubit/app_cubit.dart';
import 'package:mind_cows/src/router/router.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final router = RouterController(getIt.get()).router;
  @override
  Widget build(BuildContext context) {
    final theme = AppTheme();
    return MultiBlocProvider(
      providers: [
        BlocProvider<SettingsCubit>(create: (_) => getIt.get()),
        BlocProvider<RankingCubit>(create: (_) => getIt.get()),
        BlocProvider<AppCubit>(create: (_) => getIt.get()),
        BlocProvider<AuthCubit>(create: (_) => getIt.get()),
        BlocProvider<GameCubit>(create: (_) => getIt.get()),
        BlocProvider<PlayerCubit>(create: (_) => getIt.get()),
      ],
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            theme: theme.light,
            darkTheme: theme.dark,
            locale: state.locale,
            themeMode: state.theme,
            routerConfig: router,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
          );
        },
      ),
    );
  }
}
